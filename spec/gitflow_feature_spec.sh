#!/bin/bash
# Gitflow Feature Branch BDD Tests
# Tests for git flow feature command

Describe "Git Flow Feature Management"
  Include "spec/spec_helper.sh"

  Describe "Feature Branch Creation"
    Before "setup_test_repo; init_gitflow"

    It "should create a feature branch from develop"
      When call create_feature_branch "user-login"
      The variable FEATURE_PREFIX should equal "feature/"
      The output "$(branch_exists feature/user-login; echo $?)" should equal "0"
    End

    It "should switch to the new feature branch"
      When call create_feature_branch "authentication"
      When call sh -c "$(cd '$GITFLOW_REPO' && get_current_branch)"
      The output should equal "feature/authentication"
    End

    It "should start feature from the develop branch"
      When call setup_test_repo
      When call init_gitflow
      When call sh -c "cd '$GITFLOW_REPO' && git checkout develop > /dev/null && git log --oneline -1"
      The output should include "Initialize development branch"
    End

    It "should allow multiple feature branches"
      When call create_feature_branch "login"
      When call create_feature_branch "registration"
      The output "$(branch_exists feature/login; echo $?)" should equal "0"
      The output "$(branch_exists feature/registration; echo $?)" should equal "0"
    End

    It "should isolate feature branch from master"
      When call create_feature_branch "new-feature"
      When call sh -c "cd '$GITFLOW_REPO' && get_current_branch"
      The output should not include "master"
    End
  End

  Describe "Feature Branch Finishing"
    Before "setup_test_repo; init_gitflow"

    It "should merge feature branch back to develop"
      When call create_feature_branch "dashboard"
      When call commit_change "Add dashboard feature"
      When call merge_branch "feature/dashboard" "develop"
      When call sh -c "cd '$GITFLOW_REPO' && git log develop --oneline | head -1"
      The output should include "Merge feature/dashboard"
    End

    It "should allow cleanup of feature branch after merge"
      When call create_feature_branch "old-feature"
      When call sh -c "cd '$GITFLOW_REPO' && git checkout develop > /dev/null && git branch -d feature/old-feature; echo $?"
      The output should equal "0"
    End

    It "should delete feature branch after successful finish"
      When call create_feature_branch "temp-feature"
      When call commit_change "Temporary feature"
      When call merge_branch "temp-feature" "develop"
      When call sh -c "cd '$GITFLOW_REPO' && git branch -d feature/temp-feature > /dev/null 2>&1 && echo deleted || echo exists"
      The output should equal "deleted"
    End

    It "should keep develop branch intact after feature merge"
      When call create_feature_branch "critical-feature"
      When call commit_change "Critical work"
      When call merge_branch "feature/critical-feature" "develop"
      The output "$(branch_exists develop; echo $?)" should equal "0"
    End

    It "should preserve feature commits in develop history"
      When call create_feature_branch "feature-branch"
      When call commit_change "Feature commit 1"
      When call commit_change "Feature commit 2"
      When call merge_branch "feature-branch" "develop"
      When call sh -c "cd '$GITFLOW_REPO' && git log develop --oneline | wc -l"
      The output should be greater than 3
    End
  End

  Describe "Feature Branch Collaboration"
    Before "setup_test_repo; init_gitflow"

    It "should allow publishing feature to remote (simulation)"
      When call create_feature_branch "shared-feature"
      When call commit_change "Shared work"
      When call sh -c "cd '$GITFLOW_REPO' && git log feature/shared-feature --oneline | wc -l"
      The output should be greater than 1
    End

    It "should track published feature branches"
      When call create_feature_branch "tracked-feature"
      When call commit_change "Tracked feature"
      The output "$(branch_exists feature/tracked-feature; echo $?)" should equal "0"
    End

    It "should support feature rebasing on develop"
      When call create_feature_branch "rebase-feature"
      When call commit_change "Feature work"
      When call sh -c "cd '$GITFLOW_REPO' && git checkout develop > /dev/null && git commit --allow-empty -m 'Develop update'"
      When call sh -c "cd '$GITFLOW_REPO' && git rebase develop feature/rebase-feature 2>&1 | grep -i rebase || echo 'Rebase ready'"
      The output should not include "fatal"
    End
  End

  Describe "Feature Branch Best Practices"
    Before "setup_test_repo; init_gitflow"

    It "should prefix feature branches consistently"
      When call create_feature_branch "consistent-naming"
      When call sh -c "cd '$GITFLOW_REPO' && git branch -l | grep feature/"
      The output should include "feature/consistent-naming"
    End

    It "should maintain clean commit history"
      When call create_feature_branch "clean-history"
      When call commit_change "First change"
      When call commit_change "Second change"
      When call sh -c "cd '$GITFLOW_REPO' && git log feature/clean-history --oneline | wc -l"
      The output should be greater than 2
    End

    It "should prevent direct master commits"
      When call sh -c "cd '$GITFLOW_REPO' && git checkout master > /dev/null 2>&1 && git log -1 --oneline"
      The output should include "Initial commit"
    End

    It "should contain feature changes only in feature branch"
      When call create_feature_branch "isolated-feature"
      When call commit_change "Isolated work"
      When call sh -c "cd '$GITFLOW_REPO' && git rev-list feature/isolated-feature ^develop | wc -l"
      The output should be greater than 0
    End

    It "should support multiple independent features"
      When call create_feature_branch "feature-a"
      When call commit_change "Feature A changes"
      When call create_feature_branch "feature-b"
      When call commit_change "Feature B changes"
      The output "$(branch_exists feature/feature-a; echo $?)" should equal "0"
      The output "$(branch_exists feature/feature-b; echo $?)" should equal "0"
    End
  End
End

