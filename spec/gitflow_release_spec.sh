#!/bin/bash
# Gitflow Release Branch BDD Tests
# Tests for git flow release command

Describe "Git Flow Release Management"
  Include "spec/spec_helper.sh"

  Describe "Release Branch Creation"
    Before "setup_test_repo; init_gitflow"

    It "should create a release branch from develop"
      When call create_release_branch "1.0.0"
      The output "$(branch_exists release/1.0.0; echo $?)" should equal "0"
    End

    It "should switch to the new release branch"
      When call create_release_branch "2.0.0"
      When call sh -c "cd '$GITFLOW_REPO' && get_current_branch"
      The output should equal "release/2.0.0"
    End

    It "should start release from the develop branch"
      When call sh -c "cd '$GITFLOW_REPO' && git checkout develop > /dev/null && git log -1 --oneline"
      The output should include "develop"
    End

    It "should use semantic versioning in release names"
      When call create_release_branch "1.2.3"
      The output "$(branch_exists release/1.2.3; echo $?)" should equal "0"
    End

    It "should allow multiple release branches"
      When call create_release_branch "1.0.0"
      When call create_release_branch "2.0.0"
      The output "$(branch_exists release/1.0.0; echo $?)" should equal "0"
      The output "$(branch_exists release/2.0.0; echo $?)" should equal "0"
    End

    It "should isolate release branch from master"
      When call create_release_branch "3.0.0"
      When call sh -c "cd '$GITFLOW_REPO' && get_current_branch"
      The output should not include "master"
    End
  End

  Describe "Release Branch Finishing"
    Before "setup_test_repo; init_gitflow"

    It "should merge release branch to master"
      When call create_release_branch "1.0.0"
      When call commit_change "Bump version to 1.0.0"
      When call merge_branch "release/1.0.0" "master"
      When call sh -c "cd '$GITFLOW_REPO' && git log master --oneline | head -1"
      The output should include "Merge release/1.0.0"
    End

    It "should merge release branch back to develop"
      When call create_release_branch "1.5.0"
      When call commit_change "Update CHANGELOG for 1.5.0"
      When call merge_branch "release/1.5.0" "develop"
      The output "$(branch_exists develop; echo $?)" should equal "0"
    End

    It "should create version tag on master"
      When call create_release_branch "2.0.0"
      When call commit_change "Release version 2.0.0"
      When call merge_branch "release/2.0.0" "master"
      When call create_tag "v2.0.0" "Release version 2.0.0"
      The output "$(tag_exists v2.0.0; echo $?)" should equal "0"
    End

    It "should delete release branch after finishing"
      When call create_release_branch "old-release"
      When call commit_change "Release version"
      When call merge_branch "release/old-release" "master"
      When call sh -c "cd '$GITFLOW_REPO' && git checkout master > /dev/null && git branch -d release/old-release > /dev/null 2>&1 && echo deleted || echo exists"
      The output should equal "deleted"
    End

    It "should maintain master branch integrity"
      When call create_release_branch "1.2.0"
      When call commit_change "Release updates"
      When call merge_branch "release/1.2.0" "master"
      The output "$(branch_exists master; echo $?)" should equal "0"
    End
  End

  Describe "Release Tagging"
    Before "setup_test_repo; init_gitflow"

    It "should create annotated tags for releases"
      When call create_release_branch "1.0.0"
      When call commit_change "Release 1.0.0"
      When call merge_branch "release/1.0.0" "master"
      When call create_tag "v1.0.0" "Release version 1.0.0"
      The output "$(tag_exists v1.0.0; echo $?)" should equal "0"
    End

    It "should include version prefix in tags"
      When call create_release_branch "2.1.0"
      When call commit_change "Release 2.1.0"
      When call merge_branch "release/2.1.0" "master"
      When call create_tag "v2.1.0" "Version 2.1.0"
      When call sh -c "cd '$GITFLOW_REPO' && git tag -l | grep '^v'"
      The output should include "v2.1.0"
    End

    It "should store release message in tag"
      When call create_release_branch "3.0.0"
      When call commit_change "Release 3.0.0"
      When call merge_branch "release/3.0.0" "master"
      When call create_tag "v3.0.0" "Major release with new features"
      When call sh -c "cd '$GITFLOW_REPO' && git tag -l -n10 v3.0.0"
      The output should include "Major release"
    End

    It "should support lightweight tags"
      When call create_release_branch "1.5.0"
      When call commit_change "Release 1.5.0"
      When call merge_branch "release/1.5.0" "master"
      When call create_tag "v1.5.0"
      The output "$(tag_exists v1.5.0; echo $?)" should equal "0"
    End

    It "should allow multiple tags on release commits"
      When call create_release_branch "2.0.0"
      When call commit_change "Release 2.0.0"
      When call merge_branch "release/2.0.0" "master"
      When call create_tag "v2.0.0" "Release 2.0.0"
      When call create_tag "release-2.0.0" "Release candidate"
      The output "$(tag_exists v2.0.0; echo $?)" should equal "0"
      The output "$(tag_exists release-2.0.0; echo $?)" should equal "0"
    End
  End

  Describe "Release Branch Workflow"
    Before "setup_test_repo; init_gitflow"

    It "should allow bugfixes during release"
      When call create_release_branch "1.0.0"
      When call commit_change "Fix critical bug"
      When call sh -c "cd '$GITFLOW_REPO' && git log release/1.0.0 --oneline | wc -l"
      The output should be greater than 2
    End

    It "should keep release branch stable"
      When call create_release_branch "2.0.0"
      When call commit_change "Prepare release"
      When call commit_change "Update version"
      When call sh -c "cd '$GITFLOW_REPO' && git log release/2.0.0 --oneline | wc -l"
      The output should be greater than 2
    End

    It "should prevent master changes before release merge"
      When call sh -c "cd '$GITFLOW_REPO' && git checkout master > /dev/null && git log -1 --oneline"
      The output should include "Initial commit"
    End

    It "should support collaborative release preparation"
      When call create_release_branch "1.5.0"
      When call commit_change "Changelog update"
      When call commit_change "Version bump"
      When call sh -c "cd '$GITFLOW_REPO' && git log release/1.5.0 --oneline | wc -l"
      The output should be greater than 2
    End
  End

  Describe "Release Branching Best Practices"
    Before "setup_test_repo; init_gitflow"

    It "should use consistent release branch naming"
      When call create_release_branch "1.0.0"
      When call sh -c "cd '$GITFLOW_REPO' && git branch -l | grep release/"
      The output should include "release/1.0.0"
    End

    It "should contain release-specific commits"
      When call create_release_branch "2.0.0"
      When call commit_change "Update version number"
      When call sh -c "cd '$GITFLOW_REPO' && git log release/2.0.0 --oneline | wc -l"
      The output should be greater than 2
    End

    It "should not contain feature development commits"
      When call create_release_branch "1.2.0"
      When call commit_change "Release preparation"
      When call sh -c "cd '$GITFLOW_REPO' && git log release/1.2.0 --oneline"
      The output should include "Release preparation"
    End

    It "should maintain clean merge history"
      When call create_release_branch "3.0.0"
      When call commit_change "Release 3.0.0"
      When call merge_branch "release/3.0.0" "master"
      When call sh -c "cd '$GITFLOW_REPO' && git log master --oneline --graph | head -3"
      The output should include "Merge"
    End
  End
End

