#!/usr/bin/env bats

load 'helpers/test_helper'

setup() {
  setup_test_repo
  init_gitflow
}

teardown() {
  teardown_test_repo
}

@test "feature: creates a feature branch from develop" {
  create_feature_branch "user-login"
  branch_exists "feature/user-login"
}

@test "feature: checks out new feature branch" {
  create_feature_branch "auth"
  run git -C "$GITFLOW_REPO" rev-parse --abbrev-ref HEAD
  [ "$status" -eq 0 ]
  [ "$output" = "feature/auth" ]
}

@test "feature: keeps feature commits isolated from master" {
  create_feature_branch "isolation"
  commit_change "Add isolation feature"
  run git -C "$GITFLOW_REPO" rev-list --count master..feature/isolation
  [ "$status" -eq 0 ]
  [ "$output" -ge 1 ]
}

@test "feature: merges feature back into develop" {
  create_feature_branch "dashboard"
  commit_change "Add dashboard"
  merge_branch "feature/dashboard" "develop"

  run git -C "$GITFLOW_REPO" log develop --oneline -1
  [ "$status" -eq 0 ]
  [[ "$output" == *"Merge feature/dashboard into develop"* ]]
}

@test "feature: supports multiple concurrent feature branches" {
  create_feature_branch "a"
  create_feature_branch "b"
  branch_exists "feature/a"
  branch_exists "feature/b"
}

@test "feature: allows branch cleanup after merge" {
  create_feature_branch "cleanup"
  commit_change "Finish cleanup"
  merge_branch "feature/cleanup" "develop"

  run git -C "$GITFLOW_REPO" branch -d "feature/cleanup"
  [ "$status" -eq 0 ]
}

