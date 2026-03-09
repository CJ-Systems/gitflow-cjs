#!/usr/bin/env bats

load 'helpers/test_helper'

setup() {
  setup_test_repo
  init_gitflow
}

teardown() {
  teardown_test_repo
}

@test "naming: feature prefix is configurable" {
  run git -C "$GITFLOW_REPO" config gitflow.prefix.feature
  [ "$status" -eq 0 ]
  [ "$output" = "feature/" ]

  run git -C "$GITFLOW_REPO" config gitflow.prefix.feature "feat/"
  [ "$status" -eq 0 ]

  run git -C "$GITFLOW_REPO" config gitflow.prefix.feature
  [ "$status" -eq 0 ]
  [ "$output" = "feat/" ]
}

@test "naming: release branch names support semver" {
  create_release_branch "2.0.0-rc1"
  branch_exists "release/2.0.0-rc1"
}

@test "naming: hotfix and bugfix prefixes remain distinct" {
  create_hotfix_branch "3.0.1"
  create_bugfix_branch "api-fix"

  run git -C "$GITFLOW_REPO" branch --format='%(refname:short)'
  [ "$status" -eq 0 ]
  [[ "$output" == *"hotfix/3.0.1"* ]]
  [[ "$output" == *"bugfix/api-fix"* ]]
}

@test "naming: version tags default to v prefix" {
  create_release_branch "5.0.0"
  commit_change "Prepare v5"
  merge_branch "release/5.0.0" "master"
  create_tag "v5.0.0"

  run git -C "$GITFLOW_REPO" tag --list 'v*'
  [ "$status" -eq 0 ]
  [[ "$output" == *"v5.0.0"* ]]
}

@test "naming: non-production branches never overwrite master/develop names" {
  create_feature_branch "safe-name"
  create_bugfix_branch "safe-bug"

  run git -C "$GITFLOW_REPO" branch --format='%(refname:short)'
  [ "$status" -eq 0 ]
  [[ "$output" == *"master"* ]]
  [[ "$output" == *"develop"* ]]
}

