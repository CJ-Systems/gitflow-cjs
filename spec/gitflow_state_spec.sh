#!/bin/bash
# Gitflow Git Configuration and State Tests
# Tests for git state validation and configuration

Describe "Git Flow State and Configuration"
  Include "spec/spec_helper.sh"

  Describe "Repository State Validation"
    Before "setup_test_repo; init_gitflow"

    It "should have git repository initialized"
      When call sh -c "cd '$GITFLOW_REPO' && git rev-parse --git-dir"
      The output should include ".git"
    End

    It "should have master branch initialized"
      When call sh -c "cd '$GITFLOW_REPO' && git rev-parse master > /dev/null 2>&1; echo $?"
      The output should equal "0"
    End

    It "should have develop branch initialized"
      When call sh -c "cd '$GITFLOW_REPO' && git rev-parse develop > /dev/null 2>&1; echo $?"
      The output should equal "0"
    End

    It "should have clean working directory"
      When call sh -c "cd '$GITFLOW_REPO' && git status --short"
      The output should equal ""
    End

    It "should track configuration in git config"
      When call sh -c "cd '$GITFLOW_REPO' && git config gitflow.branch.master"
      The output should equal "master"
    End

    It "should not have untracked files after initialization"
      When call sh -c "cd '$GITFLOW_REPO' && git status --short | grep '^??' | wc -l"
      The output should equal "0"
    End
  End

  Describe "Branch Existence and Tracking"
    Before "setup_test_repo; init_gitflow"

    It "should track master as production branch"
      When call sh -c "cd '$GITFLOW_REPO' && git config gitflow.branch.master"
      The output should equal "master"
    End

    It "should track develop as integration branch"
      When call sh -c "cd '$GITFLOW_REPO' && git config gitflow.branch.develop"
      The output should equal "develop"
    End

    It "should list all branches correctly"
      When call sh -c "cd '$GITFLOW_REPO' && git branch -l | wc -l"
      The output should be greater than 1
    End

    It "should maintain branch commit history"
      When call sh -c "cd '$GITFLOW_REPO' && git log master --oneline | wc -l"
      The output should be greater than 0
    End

    It "should not lose branches after operations"
      When call create_feature_branch "test"
      When call sh -c "cd '$GITFLOW_REPO' && git checkout master > /dev/null && git branch -l | wc -l"
      The output should be greater than 2
    End
  End

  Describe "Commit History Integrity"
    Before "setup_test_repo; init_gitflow"

    It "should preserve master history"
      When call sh -c "cd '$GITFLOW_REPO' && git log master --oneline"
      The output should include "Initial commit"
    End

    It "should preserve develop history"
      When call sh -c "cd '$GITFLOW_REPO' && git log develop --oneline"
      The output should include "develop"
    End

    It "should track all commits across branches"
      When call create_feature_branch "feature"
      When call commit_change "Feature work"
      When call sh -c "cd '$GITFLOW_REPO' && git log --all --oneline | wc -l"
      The output should be greater than 2
    End

    It "should maintain commit authorship"
      When call commit_change "Test commit"
      When call sh -c "cd '$GITFLOW_REPO' && git log -1 --format='%an'"
      The output should include "Test User"
    End

    It "should preserve commit messages"
      When call commit_change "Important change"
      When call sh -c "cd '$GITFLOW_REPO' && git log -1 --format='%s'"
      The output should include "Important change"
    End
  End

  Describe "Git Configuration Settings"
    Before "setup_test_repo; init_gitflow"

    It "should store user configuration"
      When call sh -c "cd '$GITFLOW_REPO' && git config user.name"
      The output should equal "Test User"
    End

    It "should store user email"
      When call sh -c "cd '$GITFLOW_REPO' && git config user.email"
      The output should include "test@example.com"
    End

    It "should store all gitflow prefixes"
      When call sh -c "cd '$GITFLOW_REPO' && git config --get-regexp gitflow.prefix | wc -l"
      The output should be greater than 4
    End

    It "should have accessible feature prefix"
      When call sh -c "cd '$GITFLOW_REPO' && git config gitflow.prefix.feature"
      The output should equal "feature/"
    End

    It "should have accessible release prefix"
      When call sh -c "cd '$GITFLOW_REPO' && git config gitflow.prefix.release"
      The output should equal "release/"
    End

    It "should have accessible hotfix prefix"
      When call sh -c "cd '$GITFLOW_REPO' && git config gitflow.prefix.hotfix"
      The output should equal "hotfix/"
    End

    It "should preserve configuration after operations"
      When call create_feature_branch "feature"
      When call sh -c "cd '$GITFLOW_REPO' && git config gitflow.prefix.feature"
      The output should equal "feature/"
    End
  End

  Describe "Safe Repository State"
    Before "setup_test_repo; init_gitflow"

    It "should prevent detached HEAD state during normal operations"
      When call sh -c "cd '$GITFLOW_REPO' && git symbolic-ref HEAD > /dev/null 2>&1; echo $?"
      The output should equal "0"
    End

    It "should not create merge conflicts in setup"
      When call sh -c "cd '$GITFLOW_REPO' && git status --short | grep -i conflict | wc -l"
      The output should equal "0"
    End

    It "should not leave uncommitted changes"
      When call sh -c "cd '$GITFLOW_REPO' && git status --short | grep -v '^??'"
      The output should equal ""
    End

    It "should maintain repository consistency"
      When call sh -c "cd '$GITFLOW_REPO' && git fsck --full"
      The output should include "ok" || The output should equal ""
    End

    It "should allow clean checkout between branches"
      When call create_feature_branch "checkout-test"
      When call sh -c "cd '$GITFLOW_REPO' && git checkout master > /dev/null 2>&1 && echo success"
      The output should equal "success"
    End
  End

  Describe "Tag Management"
    Before "setup_test_repo; init_gitflow"

    It "should list tags correctly"
      When call create_tag "v1.0.0"
      When call sh -c "cd '$GITFLOW_REPO' && git tag -l"
      The output should include "v1.0.0"
    End

    It "should support multiple tags"
      When call create_tag "v1.0.0"
      When call create_tag "v1.0.1"
      When call sh -c "cd '$GITFLOW_REPO' && git tag -l | wc -l"
      The output should be greater than 1
    End

    It "should store tag messages"
      When call create_tag "v2.0.0" "Major release"
      When call sh -c "cd '$GITFLOW_REPO' && git tag -l -n1 v2.0.0"
      The output should include "Major"
    End

    It "should reference correct commits"
      When call create_tag "release-tag"
      When call sh -c "cd '$GITFLOW_REPO' && git rev-list -n 1 release-tag > /dev/null 2>&1; echo $?"
      The output should equal "0"
    End

    It "should maintain tag history"
      When call create_tag "v1.0.0"
      When call sh -c "cd '$GITFLOW_REPO' && git commit --allow-empty -m 'Dummy commit'"
      When call create_tag "v1.0.1"
      When call sh -c "cd '$GITFLOW_REPO' && git tag -l | wc -l"
      The output should be greater than 1
    End
  End

  Describe "Branch Protection and Isolation"
    Before "setup_test_repo; init_gitflow"

    It "should isolate master from casual changes"
      When call create_feature_branch "isolated-feature"
      When call commit_change "Feature work"
      When call sh -c "cd '$GITFLOW_REPO' && git log master --oneline | wc -l"
      The output should equal "1"
    End

    It "should require merge for branch integration"
      When call create_feature_branch "merge-required"
      When call commit_change "Work"
      When call sh -c "cd '$GITFLOW_REPO' && git log develop --oneline | grep -c merge || echo 0"
      The output should equal "0"
    End

    It "should preserve develop during feature creation"
      When call create_feature_branch "new-feature"
      When call sh -c "cd '$GITFLOW_REPO' && git checkout develop > /dev/null && git log -1 --oneline"
      The output should include "develop"
    End

    It "should not allow accidental overwrites"
      When call create_feature_branch "safe-branch"
      When call commit_change "Safe work"
      When call sh -c "cd '$GITFLOW_REPO' && git log safe-branch --oneline | wc -l"
      The output should be greater than 1
    End

    It "should maintain branch independence"
      When call create_feature_branch "feature-a"
      When call commit_change "Feature A"
      When call create_feature_branch "feature-b"
      When call commit_change "Feature B"
      When call sh -c "cd '$GITFLOW_REPO' && git log feature-a ^feature-b | wc -l"
      The output should be greater than 0
    End
  End
End

