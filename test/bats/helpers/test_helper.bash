#!/usr/bin/env bash
# Shared helpers for BATS TDD gitflow tests.

set -euo pipefail

export MASTER_BRANCH="master"
export DEVELOP_BRANCH="develop"
export FEATURE_PREFIX="feature/"
export RELEASE_PREFIX="release/"
export HOTFIX_PREFIX="hotfix/"
export BUGFIX_PREFIX="bugfix/"
export SUPPORT_PREFIX="support/"
export VERSION_PREFIX="v"

setup_test_repo() {
  export GITFLOW_TEST_DIR
  GITFLOW_TEST_DIR="$(mktemp -d "${TMPDIR:-/tmp}/gitflow-bats.XXXXXX")"
  export GITFLOW_REPO="$GITFLOW_TEST_DIR/repo"

  mkdir -p "$GITFLOW_REPO"
  # Force master for deterministic gitflow branch expectations.
  git -C "$GITFLOW_REPO" init -b "$MASTER_BRANCH" >/dev/null
  git -C "$GITFLOW_REPO" config user.name "Test User"
  git -C "$GITFLOW_REPO" config user.email "test@example.com"

  printf '# Test Repository\n' > "$GITFLOW_REPO/README.md"
  git -C "$GITFLOW_REPO" add README.md
  git -C "$GITFLOW_REPO" commit -m "Initial commit" >/dev/null

  git -C "$GITFLOW_REPO" checkout -b "$DEVELOP_BRANCH" >/dev/null
  printf 'Development branch initialized\n' >> "$GITFLOW_REPO/README.md"
  git -C "$GITFLOW_REPO" add README.md
  git -C "$GITFLOW_REPO" commit -m "Initialize development branch" >/dev/null
}

teardown_test_repo() {
  if [[ -n "${GITFLOW_TEST_DIR:-}" && -d "$GITFLOW_TEST_DIR" ]]; then
    rm -rf "$GITFLOW_TEST_DIR"
  fi
}

init_gitflow() {
  git -C "$GITFLOW_REPO" config gitflow.branch.master "$MASTER_BRANCH"
  git -C "$GITFLOW_REPO" config gitflow.branch.develop "$DEVELOP_BRANCH"
  git -C "$GITFLOW_REPO" config gitflow.prefix.feature "$FEATURE_PREFIX"
  git -C "$GITFLOW_REPO" config gitflow.prefix.release "$RELEASE_PREFIX"
  git -C "$GITFLOW_REPO" config gitflow.prefix.hotfix "$HOTFIX_PREFIX"
  git -C "$GITFLOW_REPO" config gitflow.prefix.bugfix "$BUGFIX_PREFIX"
  git -C "$GITFLOW_REPO" config gitflow.prefix.support "$SUPPORT_PREFIX"
  git -C "$GITFLOW_REPO" config gitflow.prefix.versiontag "$VERSION_PREFIX"
}

create_feature_branch() {
  local name="$1"
  git -C "$GITFLOW_REPO" checkout "$DEVELOP_BRANCH" >/dev/null
  git -C "$GITFLOW_REPO" checkout -b "${FEATURE_PREFIX}${name}" >/dev/null
}

create_release_branch() {
  local version="$1"
  git -C "$GITFLOW_REPO" checkout "$DEVELOP_BRANCH" >/dev/null
  git -C "$GITFLOW_REPO" checkout -b "${RELEASE_PREFIX}${version}" >/dev/null
}

create_hotfix_branch() {
  local version="$1"
  git -C "$GITFLOW_REPO" checkout "$MASTER_BRANCH" >/dev/null
  git -C "$GITFLOW_REPO" checkout -b "${HOTFIX_PREFIX}${version}" >/dev/null
}

create_bugfix_branch() {
  local name="$1"
  git -C "$GITFLOW_REPO" checkout "$DEVELOP_BRANCH" >/dev/null
  git -C "$GITFLOW_REPO" checkout -b "${BUGFIX_PREFIX}${name}" >/dev/null
}

commit_change() {
  local message="$1"
  # Default to per-commit file names to keep parallel branch merges conflict-free.
  local file="${2:-change-$(date +%s%N)-$RANDOM.txt}"
  printf '%s\n' "${message}" >> "$GITFLOW_REPO/$file"
  git -C "$GITFLOW_REPO" add "$file"
  git -C "$GITFLOW_REPO" commit -m "$message" >/dev/null
}

merge_branch() {
  local source="$1"
  local target="$2"
  git -C "$GITFLOW_REPO" checkout "$target" >/dev/null
  git -C "$GITFLOW_REPO" merge --no-ff "$source" -m "Merge $source into $target" >/dev/null
}

create_tag() {
  local tag="$1"
  local message="${2:-}"
  if [[ -z "$message" ]]; then
    git -C "$GITFLOW_REPO" tag "$tag"
  else
    git -C "$GITFLOW_REPO" tag -a "$tag" -m "$message"
  fi
}

branch_exists() {
  local branch="$1"
  git -C "$GITFLOW_REPO" rev-parse --verify "$branch" >/dev/null 2>&1
}

tag_exists() {
  local tag="$1"
  git -C "$GITFLOW_REPO" rev-parse -q --verify "refs/tags/$tag" >/dev/null 2>&1
}

