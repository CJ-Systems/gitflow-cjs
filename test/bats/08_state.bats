#!/usr/bin/env bats

load 'helpers/test_helper'

setup() {
  setup_test_repo
  init_gitflow
}

teardown() {
  teardown_test_repo
}

@test "state: repository stays consistent after branch operations" {
  create_feature_branch "consistency"
  commit_change "Consistency work"
  merge_branch "feature/consistency" "develop"

  run git -C "$GITFLOW_REPO" fsck --full
  [ "$status" -eq 0 ]
}

@test "state: no detached HEAD after branch creation" {
  create_feature_branch "head-check"

  run git -C "$GITFLOW_REPO" symbolic-ref --short HEAD
  [ "$status" -eq 0 ]
  [ "$output" = "feature/head-check" ]
}

@test "state: commit author metadata is preserved" {
  create_feature_branch "authoring"
  commit_change "Track author metadata"

  run git -C "$GITFLOW_REPO" log -1 --format='%an <%ae>'
  [ "$status" -eq 0 ]
  [ "$output" = "Test User <test@example.com>" ]
}

@test "state: merge commits preserve history boundaries" {
  create_feature_branch "history"
  commit_change "History change"
  merge_branch "feature/history" "develop"

  run git -C "$GITFLOW_REPO" log develop --oneline -1
  [ "$status" -eq 0 ]
  [[ "$output" == *"Merge feature/history into develop"* ]]
}

@test "state: working tree is clean after controlled flow" {
  create_release_branch "6.0.0"
  commit_change "Prepare 6.0.0"
  merge_branch "release/6.0.0" "master"

  run git -C "$GITFLOW_REPO" status --short
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

