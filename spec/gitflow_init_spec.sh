#!/bin/bash
# Gitflow Initialization BDD Tests
# Tests for git flow init command

Describe "Git Flow Initialization"
  Include "spec/spec_helper.sh"

  Describe "git flow init"
    Before "setup_test_repo"

    It "should initialize gitflow with default branch names"
      When call init_gitflow
      The variable MASTER_BRANCH should equal "master"
      The variable DEVELOP_BRANCH should equal "develop"
    End

    It "should set gitflow branch configuration"
      When call init_gitflow
      When call sh -c "cd '$GITFLOW_REPO' && git config gitflow.branch.master"
      The output should equal "master"
    End

    It "should set feature prefix"
      When call init_gitflow
      When call sh -c "cd '$GITFLOW_REPO' && git config gitflow.prefix.feature"
      The output should equal "feature/"
    End

    It "should set release prefix"
      When call init_gitflow
      When call sh -c "cd '$GITFLOW_REPO' && git config gitflow.prefix.release"
      The output should equal "release/"
    End

    It "should set hotfix prefix"
      When call init_gitflow
      When call sh -c "cd '$GITFLOW_REPO' && git config gitflow.prefix.hotfix"
      The output should equal "hotfix/"
    End

    It "should set bugfix prefix"
      When call init_gitflow
      When call sh -c "cd '$GITFLOW_REPO' && git config gitflow.prefix.bugfix"
      The output should equal "bugfix/"
    End

    It "should set version tag prefix"
      When call init_gitflow
      When call sh -c "cd '$GITFLOW_REPO' && git config gitflow.prefix.versiontag"
      The output should equal "v"
    End

    It "should create develop branch"
      When call init_gitflow
      The output "$(branch_exists develop; echo $?)" should equal "0"
    End

    It "should maintain master branch"
      When call init_gitflow
      The output "$(branch_exists master; echo $?)" should equal "0"
    End

    It "should set develop branch as tracking develop"
      When call init_gitflow
      When call sh -c "cd '$GITFLOW_REPO' && git config gitflow.branch.develop"
      The output should equal "develop"
    End
  End
End

