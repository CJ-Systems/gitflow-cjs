#!/usr/bin/env python3
"""
Deterministic mechanics for `gitflow feature start`.

Invoked by the gitflow skill. Returns a single JSON object on stdout
describing what happened (or what needs to happen). Never prints anything
else; never interacts with the user. The agent owns voice.

Run from the user's project directory (inherits cwd from caller).

Usage:
  feature_start.py <name> [--base BASE] [--fetch]

Result statuses:
  ok               — branch created (returns: branch, base)
  not_in_repo      — caller isn't inside a git work tree
  dirty_tree       — uncommitted changes (returns: files)
  not_initialized  — gitflow config missing (returns: has_main, has_master, has_develop)
  base_missing     — specified base branch doesn't exist (returns: base)
  branch_exists    — a branch with that name already exists (returns: branch)
  fetch_failed     — --fetch was passed but fetch failed (returns: base, error_detail)
  behind_origin    — local base is behind origin (returns: base, behind)
  unknown_error    — script hit an unexpected git error (returns: error_detail)
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
    parser.add_argument("name")
    parser.add_argument("--base", default=None)
    parser.add_argument("--fetch", action="store_true")
    args = parser.parse_args()

    rc, out, _ = git("rev-parse", "--is-inside-work-tree")
    if rc != 0 or out != "true":
        emit({"status": "not_in_repo"})
        return

    rc, dirty, _ = git("status", "--porcelain")
    if dirty:
        files = [line[3:].strip() for line in dirty.splitlines() if line]
        emit({"status": "dirty_tree", "files": files})
        return

    rc, prefix, _ = git("config", "--get", "gitflow.prefix.feature")
    if rc != 0 or not prefix:
        rc_m, _, _ = git("rev-parse", "--verify", "--quiet", "refs/heads/main")
        rc_master, _, _ = git("rev-parse", "--verify", "--quiet", "refs/heads/master")
        rc_d, _, _ = git("rev-parse", "--verify", "--quiet", "refs/heads/develop")
        emit({
            "status": "not_initialized",
            "has_main": rc_m == 0,
            "has_master": rc_master == 0,
            "has_develop": rc_d == 0,
        })
        return

    rc, develop_branch, _ = git("config", "--get", "gitflow.branch.develop")
    if rc != 0 or not develop_branch:
        develop_branch = "develop"

    name = args.name
    if name.startswith(prefix):
        name = name[len(prefix):]
    base = args.base or develop_branch
    branch = f"{prefix}{name}"

    rc, _, _ = git("rev-parse", "--verify", "--quiet", f"refs/heads/{base}")
    if rc != 0:
        emit({"status": "base_missing", "base": base})
        return

    rc, _, _ = git("rev-parse", "--verify", "--quiet", f"refs/heads/{branch}")
    if rc == 0:
        emit({"status": "branch_exists", "branch": branch})
        return

    if args.fetch:
        rc, _, err = git("fetch", "--quiet", "origin", base)
        if rc != 0:
            emit({"status": "fetch_failed", "base": base, "error_detail": err})
            return

    rc, _, _ = git("rev-parse", "--verify", "--quiet", f"refs/remotes/origin/{base}")
    if rc == 0:
        rc, counts, _ = git("rev-list", "--left-right", "--count", f"{base}...origin/{base}")
        if rc == 0 and counts:
            parts = counts.split()
            if len(parts) == 2:
                behind = int(parts[1])
                if behind > 0:
                    emit({"status": "behind_origin", "base": base, "behind": behind})
                    return

    rc, _, err = git("checkout", "-q", "-b", branch, base)
    if rc != 0:
        emit({"status": "unknown_error", "error_detail": err})
        return

    git("config", f"gitflow.branch.{branch}.base", base)

    emit({"status": "ok", "branch": branch, "base": base})


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        emit({"status": "unknown_error", "error_detail": f"{type(exc).__name__}: {exc}"})
        sys.exit(0)
