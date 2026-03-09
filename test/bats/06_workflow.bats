#!/usr/bin/env bats

load 'helpers/test_helper'

setup() {
  setup_test_repo
  init_gitflow
}

teardown() {
  teardown_test_repo
}

@test "workflow: feature to release to tag" {
  create_feature_branch "payments"
  commit_change "Implement payments"
  merge_branch "feature/payments" "develop"

  create_release_branch "1.0.0"
  commit_change "Prepare 1.0.0"
  merge_branch "release/1.0.0" "master"
  merge_branch "release/1.0.0" "develop"
  create_tag "v1.0.0" "Release 1.0.0"

  tag_exists "v1.0.0"
}

@test "workflow: hotfix after release produces patch tag" {
  create_release_branch "1.1.0"
  commit_change "Prepare 1.1.0"
  merge_branch "release/1.1.0" "master"
  create_tag "v1.1.0"

  create_hotfix_branch "1.1.1"
  commit_change "Critical hotfix"
  merge_branch "hotfix/1.1.1" "master"
  merge_branch "hotfix/1.1.1" "develop"
  create_tag "v1.1.1"

  tag_exists "v1.1.0"
  tag_exists "v1.1.1"
}

@test "workflow: supports parallel features merged in any order" {
  create_feature_branch "search"
  commit_change "Add search"
  create_feature_branch "profile"
  commit_change "Add profile"

  merge_branch "feature/profile" "develop"
  merge_branch "feature/search" "develop"

  run git -C "$GITFLOW_REPO" log develop --oneline
  [ "$status" -eq 0 ]
  [[ "$output" == *"Merge feature/profile into develop"* ]]
  [[ "$output" == *"Merge feature/search into develop"* ]]
}

@test "workflow: integrates bugfix before feature completion" {
  create_bugfix_branch "session-bug"
  commit_change "Fix session bug"
  merge_branch "bugfix/session-bug" "develop"

  create_feature_branch "notifications"
  commit_change "Add notifications"
  merge_branch "feature/notifications" "develop"

  run git -C "$GITFLOW_REPO" rev-list --count develop
  [ "$status" -eq 0 ]
  [ "$output" -ge 5 ]
}

