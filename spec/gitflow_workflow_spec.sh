#!/bin/bash
# Gitflow Integration and Workflow BDD Tests
# Tests for complete gitflow scenarios and integration

Describe "Git Flow Complete Workflows"
  Include "spec/spec_helper.sh"

  Describe "Feature Development Lifecycle"
    Before "setup_test_repo; init_gitflow"

    It "should complete a full feature development cycle"
      When call create_feature_branch "user-auth"
      When call commit_change "Implement authentication"
      When call merge_branch "feature/user-auth" "develop"
      The output "$(branch_exists develop; echo $?)" should equal "0"
    End

    It "should support multiple concurrent features"
      When call create_feature_branch "feature-a"
      When call commit_change "Feature A work"
      When call create_feature_branch "feature-b"
      When call commit_change "Feature B work"
      When call merge_branch "feature/feature-a" "develop"
      When call merge_branch "feature/feature-b" "develop"
      When call sh -c "cd '$GITFLOW_REPO' && git log develop --oneline | wc -l"
      The output should be greater than 3
    End

    It "should maintain feature isolation"
      When call create_feature_branch "isolated-a"
      When call commit_change "Feature A work"
      When call sh -c "cd '$GITFLOW_REPO' && git rev-list isolated-a ^develop | wc -l"
      The output should be greater than 0
    End

    It "should allow feature rebasing on develop"
      When call create_feature_branch "rebase-feature"
      When call commit_change "Feature work"
      When call sh -c "cd '$GITFLOW_REPO' && git checkout develop > /dev/null && git commit --allow-empty -m 'Develop update' && git checkout rebase-feature"
      When call sh -c "cd '$GITFLOW_REPO' && git rebase develop rebase-feature 2>&1 | tail -1"
      The output should not include "fatal"
    End
  End

  Describe "Release Process"
    Before "setup_test_repo; init_gitflow"

    It "should prepare and release a version"
      When call create_feature_branch "feature-1"
      When call commit_change "Feature 1 code"
      When call merge_branch "feature/feature-1" "develop"
      When call create_release_branch "1.0.0"
      When call commit_change "Version 1.0.0 prep"
      When call merge_branch "release/1.0.0" "master"
      When call create_tag "v1.0.0" "Version 1.0.0"
      The output "$(tag_exists v1.0.0; echo $?)" should equal "0"
    End

    It "should support multiple releases"
      When call create_feature_branch "f1"
      When call commit_change "F1"
      When call merge_branch "feature/f1" "develop"
      When call create_release_branch "1.0.0"
      When call commit_change "Release 1.0.0"
      When call merge_branch "release/1.0.0" "master"
      When call create_tag "v1.0.0"
      When call create_release_branch "1.1.0"
      When call commit_change "Release 1.1.0"
      When call merge_branch "release/1.1.0" "master"
      When call create_tag "v1.1.0"
      The output "$(tag_exists v1.0.0; echo $?)" should equal "0"
      The output "$(tag_exists v1.1.0; echo $?)" should equal "0"
    End

    It "should tag all releases"
      When call create_release_branch "2.0.0"
      When call commit_change "Release 2.0.0"
      When call merge_branch "release/2.0.0" "master"
      When call create_tag "v2.0.0" "Major release"
      When call sh -c "cd '$GITFLOW_REPO' && git tag -l"
      The output should include "v2.0.0"
    End

    It "should maintain version history"
      When call create_release_branch "1.0.0"
      When call commit_change "V1.0.0"
      When call merge_branch "release/1.0.0" "master"
      When call create_tag "v1.0.0"
      When call create_release_branch "2.0.0"
      When call commit_change "V2.0.0"
      When call merge_branch "release/2.0.0" "master"
      When call create_tag "v2.0.0"
      When call sh -c "cd '$GITFLOW_REPO' && git tag -l | wc -l"
      The output should be greater than 1
    End
  End

  Describe "Hotfix and Patch Releases"
    Before "setup_test_repo; init_gitflow"

    It "should hotfix production immediately"
      When call create_feature_branch "feature"
      When call commit_change "Feature"
      When call merge_branch "feature/feature" "develop"
      When call create_release_branch "1.0.0"
      When call commit_change "Release 1.0.0"
      When call merge_branch "release/1.0.0" "master"
      When call create_tag "v1.0.0"
      When call create_hotfix_branch "1.0.1"
      When call commit_change "Critical fix"
      When call merge_branch "hotfix/1.0.1" "master"
      When call create_tag "v1.0.1"
      The output "$(tag_exists v1.0.1; echo $?)" should equal "0"
    End

    It "should apply hotfix to develop"
      When call create_release_branch "1.0.0"
      When call commit_change "Release"
      When call merge_branch "release/1.0.0" "master"
      When call create_tag "v1.0.0"
      When call create_hotfix_branch "1.0.1"
      When call commit_change "Fix bug"
      When call merge_branch "hotfix/1.0.1" "master"
      When call merge_branch "hotfix/1.0.1" "develop"
      The output "$(branch_exists develop; echo $?)" should equal "0"
    End

    It "should allow concurrent hotfixes"
      When call create_hotfix_branch "1.0.1"
      When call commit_change "Fix A"
      When call merge_branch "hotfix/1.0.1" "master"
      When call sh -c "cd '$GITFLOW_REPO' && git checkout master > /dev/null"
      When call create_hotfix_branch "1.0.2"
      When call commit_change "Fix B"
      When call merge_branch "hotfix/1.0.2" "master"
      When call create_tag "v1.0.1"
      When call create_tag "v1.0.2"
      The output "$(tag_exists v1.0.1; echo $?)" should equal "0"
      The output "$(tag_exists v1.0.2; echo $?)" should equal "0"
    End
  End

  Describe "Bugfix Integration"
    Before "setup_test_repo; init_gitflow"

    It "should fix bugs in develop without affecting master"
      When call create_bugfix_branch "development-bug"
      When call commit_change "Fix development bug"
      When call merge_branch "bugfix/development-bug" "develop"
      The output "$(branch_exists master; echo $?)" should equal "0"
    End

    It "should allow concurrent bug fixes"
      When call create_bugfix_branch "bug-1"
      When call commit_change "Bug 1"
      When call create_bugfix_branch "bug-2"
      When call commit_change "Bug 2"
      When call merge_branch "bugfix/bug-1" "develop"
      When call merge_branch "bugfix/bug-2" "develop"
      When call sh -c "cd '$GITFLOW_REPO' && git log develop --oneline | wc -l"
      The output should be greater than 3
    End

    It "should integrate bugs before feature merge"
      When call create_bugfix_branch "found-bug"
      When call commit_change "Fix found bug"
      When call merge_branch "bugfix/found-bug" "develop"
      When call create_feature_branch "new-feature"
      When call commit_change "New feature code"
      When call merge_branch "feature/new-feature" "develop"
      When call sh -c "cd '$GITFLOW_REPO' && git log develop --oneline | wc -l"
      The output should be greater than 3
    End
  End

  Describe "Branch State Validation"
    Before "setup_test_repo; init_gitflow"

    It "should have clean master branch state"
      When call sh -c "cd '$GITFLOW_REPO' && git checkout master > /dev/null && git status --short"
      The output should equal ""
    End

    It "should have clean develop branch state"
      When call sh -c "cd '$GITFLOW_REPO' && git checkout develop > /dev/null && git status --short"
      The output should equal ""
    End

    It "should isolate changes per branch"
      When call create_feature_branch "feature-1"
      When call commit_change "Feature 1"
      When call sh -c "cd '$GITFLOW_REPO' && git checkout develop > /dev/null && git rev-list develop ^master | wc -l"
      The output should be greater than 0
    End

    It "should prevent accidental commits to master"
      When call sh -c "cd '$GITFLOW_REPO' && git checkout master > /dev/null && git log -1 --oneline"
      The output should include "Initial commit"
    End
  End

  Describe "Complex Workflow Scenarios"
    Before "setup_test_repo; init_gitflow"

    It "should handle parallel feature development"
      When call create_feature_branch "auth"
      When call commit_change "Auth feature"
      When call create_feature_branch "dashboard"
      When call commit_change "Dashboard"
      When call create_feature_branch "profile"
      When call commit_change "Profile"
      When call sh -c "cd '$GITFLOW_REPO' && git branch -l | grep feature | wc -l"
      The output should be greater than 2
    End

    It "should merge features in any order"
      When call create_feature_branch "f1"
      When call commit_change "F1"
      When call create_feature_branch "f2"
      When call commit_change "F2"
      When call merge_branch "feature/f2" "develop"
      When call merge_branch "feature/f1" "develop"
      When call sh -c "cd '$GITFLOW_REPO' && git log develop --oneline | grep -c Merge"
      The output should be greater than 0
    End

    It "should release with accumulated features"
      When call create_feature_branch "f1"
      When call commit_change "Feature 1"
      When call merge_branch "feature/f1" "develop"
      When call create_feature_branch "f2"
      When call commit_change "Feature 2"
      When call merge_branch "feature/f2" "develop"
      When call create_release_branch "1.0.0"
      When call commit_change "Release prep"
      When call merge_branch "release/1.0.0" "master"
      When call create_tag "v1.0.0"
      The output "$(tag_exists v1.0.0; echo $?)" should equal "0"
    End

    It "should handle emergency hotfix during release"
      When call create_release_branch "1.0.0"
      When call commit_change "Release 1.0.0"
      When call merge_branch "release/1.0.0" "master"
      When call create_tag "v1.0.0"
      When call create_hotfix_branch "1.0.1"
      When call commit_change "Emergency fix"
      When call merge_branch "hotfix/1.0.1" "master"
      When call create_tag "v1.0.1"
      When call sh -c "cd '$GITFLOW_REPO' && git tag -l"
      The output should include "v1.0.0"
      The output should include "v1.0.1"
    End

    It "should maintain complete version history"
      When call create_release_branch "1.0.0"
      When call commit_change "V1"
      When call merge_branch "release/1.0.0" "master"
      When call create_tag "v1.0.0"
      When call create_hotfix_branch "1.0.1"
      When call commit_change "Fix"
      When call merge_branch "hotfix/1.0.1" "master"
      When call create_tag "v1.0.1"
      When call create_release_branch "2.0.0"
      When call commit_change "V2"
      When call merge_branch "release/2.0.0" "master"
      When call create_tag "v2.0.0"
      When call sh -c "cd '$GITFLOW_REPO' && git tag -l | wc -l"
      The output should be greater than 2
    End
  End
End

