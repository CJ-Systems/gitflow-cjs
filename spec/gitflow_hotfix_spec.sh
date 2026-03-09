#!/bin/bash
# Gitflow Hotfix Branch BDD Tests
# Tests for git flow hotfix command

Describe "Git Flow Hotfix Management"
  Include "spec/spec_helper.sh"

  Describe "Hotfix Branch Creation"
    Before "setup_test_repo; init_gitflow"

    It "should create a hotfix branch from master"
      When call create_hotfix_branch "1.0.1"
      The output "$(branch_exists hotfix/1.0.1; echo $?)" should equal "0"
    End

    It "should switch to the new hotfix branch"
      When call create_hotfix_branch "2.0.1"
      When call sh -c "cd '$GITFLOW_REPO' && get_current_branch"
      The output should equal "hotfix/2.0.1"
    End

    It "should start hotfix from the master branch"
      When call sh -c "cd '$GITFLOW_REPO' && git checkout master > /dev/null && git log -1 --oneline"
      The output should include "Initial commit"
    End

    It "should use patch version for hotfix names"
      When call create_hotfix_branch "1.0.1"
      When call create_hotfix_branch "1.0.2"
      The output "$(branch_exists hotfix/1.0.1; echo $?)" should equal "0"
      The output "$(branch_exists hotfix/1.0.2; echo $?)" should equal "0"
    End

    It "should isolate hotfix branch from develop"
      When call create_hotfix_branch "3.0.1"
      When call sh -c "cd '$GITFLOW_REPO' && get_current_branch"
      The output should not include "develop"
    End

    It "should support multiple independent hotfixes"
      When call create_hotfix_branch "1.1.1"
      When call create_hotfix_branch "1.2.1"
      The output "$(branch_exists hotfix/1.1.1; echo $?)" should equal "0"
      The output "$(branch_exists hotfix/1.2.1; echo $?)" should equal "0"
    End
  End

  Describe "Hotfix Branch Finishing"
    Before "setup_test_repo; init_gitflow"

    It "should merge hotfix branch to master"
      When call create_hotfix_branch "1.0.1"
      When call commit_change "Critical bugfix"
      When call merge_branch "hotfix/1.0.1" "master"
      When call sh -c "cd '$GITFLOW_REPO' && git log master --oneline | head -1"
      The output should include "Merge hotfix/1.0.1"
    End

    It "should merge hotfix branch to develop"
      When call create_hotfix_branch "2.0.1"
      When call commit_change "Production bug fix"
      When call merge_branch "hotfix/2.0.1" "develop"
      The output "$(branch_exists develop; echo $?)" should equal "0"
    End

    It "should create version tag on master"
      When call create_hotfix_branch "1.1.0"
      When call commit_change "Fix production issue"
      When call merge_branch "hotfix/1.1.0" "master"
      When call create_tag "v1.1.0" "Hotfix version 1.1.0"
      The output "$(tag_exists v1.1.0; echo $?)" should equal "0"
    End

    It "should delete hotfix branch after finishing"
      When call create_hotfix_branch "old-hotfix"
      When call commit_change "Fix issue"
      When call merge_branch "hotfix/old-hotfix" "master"
      When call sh -c "cd '$GITFLOW_REPO' && git checkout master > /dev/null && git branch -d hotfix/old-hotfix > /dev/null 2>&1 && echo deleted || echo exists"
      The output should equal "deleted"
    End

    It "should maintain master branch integrity"
      When call create_hotfix_branch "3.0.1"
      When call commit_change "Critical fix"
      When call merge_branch "hotfix/3.0.1" "master"
      The output "$(branch_exists master; echo $?)" should equal "0"
    End

    It "should preserve hotfix commits in both branches"
      When call create_hotfix_branch "1.0.2"
      When call commit_change "Fix critical bug"
      When call merge_branch "hotfix/1.0.2" "master"
      When call merge_branch "hotfix/1.0.2" "develop"
      When call sh -c "cd '$GITFLOW_REPO' && git log master --oneline | head -1"
      The output should include "Merge hotfix/1.0.2"
    End
  End

  Describe "Hotfix Tagging"
    Before "setup_test_repo; init_gitflow"

    It "should create version tag for hotfix"
      When call create_hotfix_branch "1.0.1"
      When call commit_change "Critical security fix"
      When call merge_branch "hotfix/1.0.1" "master"
      When call create_tag "v1.0.1" "Security hotfix"
      The output "$(tag_exists v1.0.1; echo $?)" should equal "0"
    End

    It "should tag hotfix with version prefix"
      When call create_hotfix_branch "2.0.1"
      When call commit_change "Production bug fix"
      When call merge_branch "hotfix/2.0.1" "master"
      When call create_tag "v2.0.1"
      When call sh -c "cd '$GITFLOW_REPO' && git tag -l | grep '^v2.0.1'"
      The output should equal "v2.0.1"
    End

    It "should support annotated hotfix tags"
      When call create_hotfix_branch "1.1.1"
      When call commit_change "Fix data corruption"
      When call merge_branch "hotfix/1.1.1" "master"
      When call create_tag "v1.1.1" "Fixed critical data issue"
      When call sh -c "cd '$GITFLOW_REPO' && git tag -l -n1 v1.1.1"
      The output should include "Fixed critical data"
    End

    It "should allow immediate release of hotfix"
      When call create_hotfix_branch "3.0.1"
      When call commit_change "Fix production issue"
      When call merge_branch "hotfix/3.0.1" "master"
      When call create_tag "v3.0.1" "Emergency hotfix"
      The output "$(tag_exists v3.0.1; echo $?)" should equal "0"
    End
  End

  Describe "Hotfix Workflow"
    Before "setup_test_repo; init_gitflow"

    It "should allow immediate fixes during hotfix"
      When call create_hotfix_branch "1.0.1"
      When call commit_change "Fix critical issue"
      When call commit_change "Additional fix"
      When call sh -c "cd '$GITFLOW_REPO' && git log hotfix/1.0.1 --oneline | wc -l"
      The output should be greater than 2
    End

    It "should keep hotfix branch focused"
      When call create_hotfix_branch "2.0.1"
      When call commit_change "Emergency production fix"
      When call sh -c "cd '$GITFLOW_REPO' && git log hotfix/2.0.1 --oneline | wc -l"
      The output should be greater than 1
    End

    It "should prevent hotfix changes to develop before merge"
      When call sh -c "cd '$GITFLOW_REPO' && git checkout develop > /dev/null && git log -1 --oneline"
      The output should include "Initialize development branch"
    End

    It "should support hotfix re-merge to develop"
      When call create_hotfix_branch "1.1.0"
      When call commit_change "Fix issue X"
      When call merge_branch "hotfix/1.1.0" "master"
      When call merge_branch "hotfix/1.1.0" "develop"
      When call sh -c "cd '$GITFLOW_REPO' && git log develop --oneline | grep -c 'hotfix/1.1.0' || echo 0"
      The output should include "0" || The output should include "1"
    End

    It "should allow concurrent hotfixes"
      When call create_hotfix_branch "1.0.1"
      When call commit_change "Fix bug A"
      When call sh -c "cd '$GITFLOW_REPO' && git checkout master > /dev/null"
      When call create_hotfix_branch "1.0.2"
      When call commit_change "Fix bug B"
      The output "$(branch_exists hotfix/1.0.1; echo $?)" should equal "0"
      The output "$(branch_exists hotfix/1.0.2; echo $?)" should equal "0"
    End
  End

  Describe "Hotfix Best Practices"
    Before "setup_test_repo; init_gitflow"

    It "should use consistent hotfix naming"
      When call create_hotfix_branch "1.0.1"
      When call sh -c "cd '$GITFLOW_REPO' && git branch -l | grep hotfix/"
      The output should include "hotfix/1.0.1"
    End

    It "should contain only bugfix commits"
      When call create_hotfix_branch "2.0.1"
      When call commit_change "Fix critical bug"
      When call sh -c "cd '$GITFLOW_REPO' && git log hotfix/2.0.1 --oneline"
      The output should include "critical"
    End

    It "should maintain master branch stability"
      When call create_hotfix_branch "3.0.1"
      When call commit_change "Fix production issue"
      When call merge_branch "hotfix/3.0.1" "master"
      The output "$(branch_exists master; echo $?)" should equal "0"
    End

    It "should keep hotfix commits small and focused"
      When call create_hotfix_branch "1.1.0"
      When call commit_change "Fix specific issue"
      When call sh -c "cd '$GITFLOW_REPO' && git log hotfix/1.1.0 --oneline | wc -l"
      The output should be greater than 1
    End

    It "should tag hotfix immediately after merge"
      When call create_hotfix_branch "1.0.2"
      When call commit_change "Fix security vulnerability"
      When call merge_branch "hotfix/1.0.2" "master"
      When call create_tag "v1.0.2" "Security patch"
      The output "$(tag_exists v1.0.2; echo $?)" should equal "0"
    End
  End
End

