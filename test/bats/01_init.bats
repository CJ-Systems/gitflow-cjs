#!/usr/bin/env bats

load 'helpers/test_helper'

setup() {
  setup_test_repo
  init_gitflow
}

teardown() {
  teardown_test_repo
}

@test "init: keeps default master/develop branch names" {
  run git -C "$GITFLOW_REPO" config gitflow.branch.master
  [ "$status" -eq 0 ]
  [ "$output" = "master" ]

  run git -C "$GITFLOW_REPO" config gitflow.branch.develop
  [ "$status" -eq 0 ]
  [ "$output" = "develop" ]
}

@test "init: writes all standard gitflow prefixes" {
  run git -C "$GITFLOW_REPO" config --get-regexp '^gitflow.prefix\.'
  [ "$status" -eq 0 ]
  [[ "$output" == *"gitflow.prefix.feature feature/"* ]]
  [[ "$output" == *"gitflow.prefix.release release/"* ]]
  [[ "$output" == *"gitflow.prefix.hotfix hotfix/"* ]]
  [[ "$output" == *"gitflow.prefix.bugfix bugfix/"* ]]
  [[ "$output" == *"gitflow.prefix.versiontag v"* ]]
}

@test "init: repository starts with master and develop branches" {
  run git -C "$GITFLOW_REPO" branch --format='%(refname:short)'
  [ "$status" -eq 0 ]
  [[ "$output" == *"master"* ]]
  [[ "$output" == *"develop"* ]]
}

@test "init: working tree stays clean after initialization" {
  run git -C "$GITFLOW_REPO" status --short
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "init: develop contains initial development commit" {
  run git -C "$GITFLOW_REPO" log develop --oneline -1
  [ "$status" -eq 0 ]
  [[ "$output" == *"Initialize development branch"* ]]
}

@test "init: git repository metadata is valid" {
  run git -C "$GITFLOW_REPO" rev-parse --git-dir
  [ "$status" -eq 0 ]
  [[ "$output" == ".git" ]]
}

