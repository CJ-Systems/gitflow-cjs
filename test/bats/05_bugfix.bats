#!/usr/bin/env bats

load 'helpers/test_helper'

setup() {
  setup_test_repo
  init_gitflow
}

teardown() {
  teardown_test_repo
}

@test "bugfix: creates bugfix branch from develop" {
  create_bugfix_branch "login-crash"
  branch_exists "bugfix/login-crash"
}

@test "bugfix: checks out bugfix branch" {
  create_bugfix_branch "api-timeout"
  run git -C "$GITFLOW_REPO" rev-parse --abbrev-ref HEAD
  [ "$status" -eq 0 ]
  [ "$output" = "bugfix/api-timeout" ]
}

@test "bugfix: merges bugfix into develop" {
  create_bugfix_branch "validation"
  commit_change "Fix validation issue"
  merge_branch "bugfix/validation" "develop"

  run git -C "$GITFLOW_REPO" log develop --oneline -1
  [ "$status" -eq 0 ]
  [[ "$output" == *"Merge bugfix/validation into develop"* ]]
}

@test "bugfix: keeps master unchanged until release/hotfix" {
  create_bugfix_branch "dev-only"
  commit_change "Fix development bug"
  merge_branch "bugfix/dev-only" "develop"

  run git -C "$GITFLOW_REPO" log master --oneline --max-count=1
  [ "$status" -eq 0 ]
  [[ "$output" == *"Initial commit"* ]]
}

@test "bugfix: allows multiple concurrent bugfix branches" {
  create_bugfix_branch "a"
  create_bugfix_branch "b"
  branch_exists "bugfix/a"
  branch_exists "bugfix/b"
}

@test "bugfix: branch can be deleted after merge" {
  create_bugfix_branch "cleanup"
  commit_change "Fix and cleanup"
  merge_branch "bugfix/cleanup" "develop"

  run git -C "$GITFLOW_REPO" branch -d "bugfix/cleanup"
  [ "$status" -eq 0 ]
}

