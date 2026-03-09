#!/usr/bin/env bats

load 'helpers/test_helper'

setup() {
  setup_test_repo
  init_gitflow
}

teardown() {
  teardown_test_repo
}

@test "hotfix: creates hotfix branch from master" {
  create_hotfix_branch "1.0.1"
  branch_exists "hotfix/1.0.1"
}

@test "hotfix: checks out newly created hotfix branch" {
  create_hotfix_branch "1.0.2"
  run git -C "$GITFLOW_REPO" rev-parse --abbrev-ref HEAD
  [ "$status" -eq 0 ]
  [ "$output" = "hotfix/1.0.2" ]
}

@test "hotfix: merges to master for production patch" {
  create_hotfix_branch "2.0.1"
  commit_change "Critical patch"
  merge_branch "hotfix/2.0.1" "master"

  run git -C "$GITFLOW_REPO" log master --oneline -1
  [ "$status" -eq 0 ]
  [[ "$output" == *"Merge hotfix/2.0.1 into master"* ]]
}

@test "hotfix: also merges back to develop" {
  create_hotfix_branch "2.0.2"
  commit_change "Apply same patch"
  merge_branch "hotfix/2.0.2" "master"
  merge_branch "hotfix/2.0.2" "develop"

  run git -C "$GITFLOW_REPO" log develop --oneline -1
  [ "$status" -eq 0 ]
  [[ "$output" == *"Merge hotfix/2.0.2 into develop"* ]]
}

@test "hotfix: creates version tag" {
  create_hotfix_branch "3.0.1"
  commit_change "Fix severe regression"
  merge_branch "hotfix/3.0.1" "master"
  create_tag "v3.0.1" "Hotfix 3.0.1"
  tag_exists "v3.0.1"
}

@test "hotfix: supports multiple independent patch branches" {
  create_hotfix_branch "4.0.1"
  git -C "$GITFLOW_REPO" checkout master >/dev/null
  create_hotfix_branch "4.0.2"
  branch_exists "hotfix/4.0.1"
  branch_exists "hotfix/4.0.2"
}

