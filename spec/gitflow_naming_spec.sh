#!/bin/bash
# Gitflow Branch Naming and Configuration BDD Tests
# Tests for branch naming conventions and configuration

Describe "Git Flow Branch Naming and Prefixes"
  Include "spec/spec_helper.sh"

  Describe "Default Branch Names"
    Before "setup_test_repo; init_gitflow"

    It "should use 'master' as main production branch"
      When call sh -c "cd '$GITFLOW_REPO' && git branch -l | grep '^  master$'"
      The output should include "master"
    End

    It "should use 'develop' as main integration branch"
      When call sh -c "cd '$GITFLOW_REPO' && git branch -l | grep '^  develop$'"
      The output should include "develop"
    End

    It "should not modify branch names after initialization"
      When call sh -c "cd '$GITFLOW_REPO' && git branch -l | grep -E '^  (master|develop)$' | wc -l"
      The output should equal "2"
    End
  End

  Describe "Feature Branch Prefixes"
    Before "setup_test_repo; init_gitflow"

    It "should use 'feature/' prefix for feature branches"
      When call create_feature_branch "new-feature"
      When call sh -c "cd '$GITFLOW_REPO' && git branch -l | grep feature/"
      The output should include "feature/new-feature"
    End

    It "should allow custom feature prefixes"
      When call sh -c "cd '$GITFLOW_REPO' && git config gitflow.prefix.feature 'feat/'"
      When call sh -c "cd '$GITFLOW_REPO' && git config gitflow.prefix.feature"
      The output should equal "feat/"
    End

    It "should respect feature prefix in configuration"
      When call sh -c "cd '$GITFLOW_REPO' && git config gitflow.prefix.feature"
      The output should equal "feature/"
    End
  End

  Describe "Release Branch Prefixes"
    Before "setup_test_repo; init_gitflow"

    It "should use 'release/' prefix for release branches"
      When call create_release_branch "1.0.0"
      When call sh -c "cd '$GITFLOW_REPO' && git branch -l | grep release/"
      The output should include "release/1.0.0"
    End

    It "should allow custom release prefixes"
      When call sh -c "cd '$GITFLOW_REPO' && git config gitflow.prefix.release 'rel/'"
      When call sh -c "cd '$GITFLOW_REPO' && git config gitflow.prefix.release"
      The output should equal "rel/"
    End

    It "should respect release prefix in configuration"
      When call sh -c "cd '$GITFLOW_REPO' && git config gitflow.prefix.release"
      The output should equal "release/"
    End
  End

  Describe "Hotfix Branch Prefixes"
    Before "setup_test_repo; init_gitflow"

    It "should use 'hotfix/' prefix for hotfix branches"
      When call create_hotfix_branch "1.0.1"
      When call sh -c "cd '$GITFLOW_REPO' && git branch -l | grep hotfix/"
      The output should include "hotfix/1.0.1"
    End

    It "should allow custom hotfix prefixes"
      When call sh -c "cd '$GITFLOW_REPO' && git config gitflow.prefix.hotfix 'fix/'"
      When call sh -c "cd '$GITFLOW_REPO' && git config gitflow.prefix.hotfix"
      The output should equal "fix/"
    End

    It "should respect hotfix prefix in configuration"
      When call sh -c "cd '$GITFLOW_REPO' && git config gitflow.prefix.hotfix"
      The output should equal "hotfix/"
    End
  End

  Describe "Bugfix Branch Prefixes"
    Before "setup_test_repo; init_gitflow"

    It "should use 'bugfix/' prefix for bugfix branches"
      When call create_bugfix_branch "critical-bug"
      When call sh -c "cd '$GITFLOW_REPO' && git branch -l | grep bugfix/"
      The output should include "bugfix/critical-bug"
    End

    It "should allow custom bugfix prefixes"
      When call sh -c "cd '$GITFLOW_REPO' && git config gitflow.prefix.bugfix 'bug/'"
      When call sh -c "cd '$GITFLOW_REPO' && git config gitflow.prefix.bugfix"
      The output should equal "bug/"
    End

    It "should respect bugfix prefix in configuration"
      When call sh -c "cd '$GITFLOW_REPO' && git config gitflow.prefix.bugfix"
      The output should equal "bugfix/"
    End
  End

  Describe "Version Tag Prefixes"
    Before "setup_test_repo; init_gitflow"

    It "should use 'v' prefix for version tags"
      When call create_release_branch "1.0.0"
      When call commit_change "Release"
      When call merge_branch "release/1.0.0" "master"
      When call create_tag "v1.0.0"
      When call sh -c "cd '$GITFLOW_REPO' && git tag -l"
      The output should include "v1.0.0"
    End

    It "should allow custom version tag prefixes"
      When call sh -c "cd '$GITFLOW_REPO' && git config gitflow.prefix.versiontag 'release-'"
      When call sh -c "cd '$GITFLOW_REPO' && git config gitflow.prefix.versiontag"
      The output should equal "release-"
    End

    It "should respect version tag prefix in configuration"
      When call sh -c "cd '$GITFLOW_REPO' && git config gitflow.prefix.versiontag"
      The output should equal "v"
    End
  End

  Describe "Branch Naming Conventions"
    Before "setup_test_repo; init_gitflow"

    It "should use lowercase branch names"
      When call create_feature_branch "myfeature"
      When call sh -c "cd '$GITFLOW_REPO' && git branch -l | grep feature/myfeature"
      The output should equal "  feature/myfeature"
    End

    It "should use hyphens for multi-word names"
      When call create_feature_branch "user-authentication"
      When call sh -c "cd '$GITFLOW_REPO' && git branch -l | grep feature/"
      The output should include "feature/user-authentication"
    End

    It "should avoid underscores in branch names"
      When call create_feature_branch "user-auth"
      When call sh -c "cd '$GITFLOW_REPO' && git branch -l | grep 'feature.*user'"
      The output should include "feature/user-auth"
    End

    It "should use numeric versions in release branches"
      When call create_release_branch "1.2.3"
      When call sh -c "cd '$GITFLOW_REPO' && git branch -l | grep release/"
      The output should include "release/1.2.3"
    End

    It "should support semantic versioning"
      When call create_release_branch "2.0.0-beta"
      When call create_release_branch "2.0.0-rc1"
      When call create_release_branch "2.0.0"
      When call sh -c "cd '$GITFLOW_REPO' && git branch -l | grep release/"
      The output should include "release/2.0.0"
    End
  End

  Describe "Branch Prefix Configuration"
    Before "setup_test_repo; init_gitflow"

    It "should store all prefixes in git config"
      When call sh -c "cd '$GITFLOW_REPO' && git config --get-regexp 'gitflow.prefix' | wc -l"
      The output should be greater than 3
    End

    It "should retrieve feature prefix"
      When call sh -c "cd '$GITFLOW_REPO' && git config gitflow.prefix.feature"
      The output should equal "feature/"
    End

    It "should retrieve release prefix"
      When call sh -c "cd '$GITFLOW_REPO' && git config gitflow.prefix.release"
      The output should equal "release/"
    End

    It "should retrieve hotfix prefix"
      When call sh -c "cd '$GITFLOW_REPO' && git config gitflow.prefix.hotfix"
      The output should equal "hotfix/"
    End

    It "should retrieve bugfix prefix"
      When call sh -c "cd '$GITFLOW_REPO' && git config gitflow.prefix.bugfix"
      The output should equal "bugfix/"
    End

    It "should retrieve version tag prefix"
      When call sh -c "cd '$GITFLOW_REPO' && git config gitflow.prefix.versiontag"
      The output should equal "v"
    End
  End

  Describe "Branch Isolation by Type"
    Before "setup_test_repo; init_gitflow"

    It "should keep feature branches separate from hotfixes"
      When call create_feature_branch "my-feature"
      When call create_hotfix_branch "1.0.1"
      When call sh -c "cd '$GITFLOW_REPO' && git branch -l | grep feature/"
      The output should include "feature/my-feature"
    End

    It "should keep bugfixes separate from features"
      When call create_bugfix_branch "bug-fix"
      When call create_feature_branch "new-feature"
      When call sh -c "cd '$GITFLOW_REPO' && git branch -l | grep -E '(feature|bugfix)'"
      The output should include "bugfix/bug-fix"
      The output should include "feature/new-feature"
    End

    It "should clearly identify release branches"
      When call create_release_branch "1.0.0"
      When call sh -c "cd '$GITFLOW_REPO' && git branch -l | grep -v '^  (master|develop)'"
      The output should include "release/1.0.0"
    End

    It "should identify production branch"
      When call sh -c "cd '$GITFLOW_REPO' && git branch -l | grep '^  master'"
      The output should equal "  master"
    End

    It "should identify integration branch"
      When call sh -c "cd '$GITFLOW_REPO' && git branch -l | grep '^  develop'"
      The output should equal "  develop"
    End
  End
End

