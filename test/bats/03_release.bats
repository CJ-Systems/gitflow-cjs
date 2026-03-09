#!/usr/bin/env bats

load 'helpers/test_helper'

setup() {
  setup_test_repo
  init_gitflow
}

teardown() {
  teardown_test_repo
}

@test "release: creates release branch from develop" {
  create_release_branch "1.0.0"
  branch_exists "release/1.0.0"
}

@test "release: enforces semantic release naming pattern" {
  create_release_branch "2.1.3"
  run git -C "$GITFLOW_REPO" branch --format='%(refname:short)'
  [ "$status" -eq 0 ]
  [[ "$output" == *"release/2.1.3"* ]]
}

@test "release: merges release to master" {
  create_release_branch "1.2.0"
  commit_change "Release prep 1.2.0"
  merge_branch "release/1.2.0" "master"

  run git -C "$GITFLOW_REPO" log master --oneline -1
  [ "$status" -eq 0 ]
  [[ "$output" == *"Merge release/1.2.0 into master"* ]]
}

@test "release: merges release back to develop" {
  create_release_branch "1.3.0"
  commit_change "Release prep 1.3.0"
  merge_branch "release/1.3.0" "develop"

  run git -C "$GITFLOW_REPO" log develop --oneline -1
  [ "$status" -eq 0 ]
  [[ "$output" == *"Merge release/1.3.0 into develop"* ]]
}

@test "release: tags finished release" {
  create_release_branch "2.0.0"
  commit_change "Release 2.0.0"
  merge_branch "release/2.0.0" "master"
  create_tag "v2.0.0" "Release 2.0.0"
  tag_exists "v2.0.0"
}

@test "release: branch can be deleted after finish" {
  create_release_branch "3.0.0"
  commit_change "Release 3.0.0"
  merge_branch "release/3.0.0" "master"

  run git -C "$GITFLOW_REPO" branch -d "release/3.0.0"
  [ "$status" -eq 0 ]
}

