#!/usr/bin/env python3
"""
Deterministic mechanics for gitflow first-time setup.

Invoked by the gitflow skill after the agent has resolved which production
branch / develop branch / prefixes to use. Writes the gitflow.* config keys
and creates the develop branch from production if it's missing. Returns a
single JSON object on stdout. Never prints anything else; never interacts
with the user.

Run from the user's project directory (inherits cwd from caller).

Usage:
  init.py --production BRANCH --develop BRANCH \
          --feature-prefix STR --bugfix-prefix STR --release-prefix STR \
          --hotfix-prefix STR --support-prefix STR \
          [--version-tag-prefix STR]

Result statuses:
  ok                       — config written (returns: production, develop,
                             develop_created, feature_prefix)
  not_in_repo              — caller isn't inside a git work tree
  production_missing       — specified production branch doesn't exist
                             (returns: production)
  develop_create_failed    — couldn't create develop from production
                             (returns: error_detail)
  unknown_error            — script hit an unexpected git error
                             (returns: error_detail)
"""

import argparse
import json
import subprocess
import sys


def git(*args):
    result = subprocess.run(["git", *args], capture_output=True, text=True)
    return result.returncode, result.stdout.strip(), result.stderr.strip()


def emit(payload):
    print(json.dumps(payload))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--production", required=True)
    parser.add_argument("--develop", required=True)
    parser.add_argument("--feature-prefix", required=True)
    parser.add_argument("--bugfix-prefix", required=True)
    parser.add_argument("--release-prefix", required=True)
    parser.add_argument("--hotfix-prefix", required=True)
    parser.add_argument("--support-prefix", required=True)
    parser.add_argument("--version-tag-prefix", default="")
    args = parser.parse_args()

    rc, out, _ = git("rev-parse", "--is-inside-work-tree")
    if rc != 0 or out != "true":
        emit({"status": "not_in_repo"})
        return

    rc, _, _ = git("rev-parse", "--verify", "--quiet", f"refs/heads/{args.production}")
    if rc != 0:
        emit({"status": "production_missing", "production": args.production})
        return

    rc, _, _ = git("rev-parse", "--verify", "--quiet", f"refs/heads/{args.develop}")
    develop_created = False
    if rc != 0:
        rc, _, err = git("branch", args.develop, args.production)
        if rc != 0:
            emit({"status": "develop_create_failed", "error_detail": err})
            return
        develop_created = True

    configs = [
        ("gitflow.branch.master", args.production),
        ("gitflow.branch.develop", args.develop),
        ("gitflow.prefix.feature", args.feature_prefix),
        ("gitflow.prefix.bugfix", args.bugfix_prefix),
        ("gitflow.prefix.release", args.release_prefix),
        ("gitflow.prefix.hotfix", args.hotfix_prefix),
        ("gitflow.prefix.support", args.support_prefix),
        ("gitflow.prefix.versiontag", args.version_tag_prefix),
    ]
    for key, value in configs:
        git("config", key, value)

    emit({
        "status": "ok",
        "production": args.production,
        "develop": args.develop,
        "develop_created": develop_created,
        "feature_prefix": args.feature_prefix,
    })


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        emit({"status": "unknown_error", "error_detail": f"{type(exc).__name__}: {exc}"})
        sys.exit(0)
