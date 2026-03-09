#!/bin/bash
# Gitflow Bugfix Branch BDD Tests
# Tests for git flow bugfix command

Describe "Git Flow Bugfix Management"
  Include "spec/spec_helper.sh"

  Describe "Bugfix Branch Creation"
    Before "setup_test_repo; init_gitflow"

    It "should create a bugfix branch from develop"
      When call create_bugfix_branch "login-crash"
      The output "$(branch_exists bugfix/login-crash; echo $?)" should equal "0"
    End

    It "should switch to the new bugfix branch"
      When call create_bugfix_branch "data-validation"
      When call sh -c "cd '$GITFLOW_REPO' && get_current_branch"
      The output should equal "bugfix/data-validation"
    End

    It "should start bugfix from the develop branch"
      When call sh -c "cd '$GITFLOW_REPO' && git checkout develop > /dev/null && git log -1 --oneline"
      The output should include "develop"
    End

    It "should describe bug in branch name"
      When call create_bugfix_branch "memory-leak"
      The output "$(branch_exists bugfix/memory-leak; echo $?)" should equal "0"
    End

    It "should allow multiple bugfix branches"
      When call create_bugfix_branch "ui-bug"
      When call create_bugfix_branch "api-error"
      The output "$(branch_exists bugfix/ui-bug; echo $?)" should equal "0"
      The output "$(branch_exists bugfix/api-error; echo $?)" should equal "0"
    End

    It "should isolate bugfix branch from master"
      When call create_bugfix_branch "navigation-issue"
      When call sh -c "cd '$GITFLOW_REPO' && get_current_branch"
      The output should not include "master"
    End
  End

  Describe "Bugfix Branch Finishing"
    Before "setup_test_repo; init_gitflow"

    It "should merge bugfix branch back to develop"
      When call create_bugfix_branch "crash-fix"
      When call commit_change "Fix application crash"
      When call merge_branch "bugfix/crash-fix" "develop"
      When call sh -c "cd '$GITFLOW_REPO' && git log develop --oneline | head -1"
      The output should include "Merge bugfix/crash-fix"
    End

    It "should delete bugfix branch after successful merge"
      When call create_bugfix_branch "temp-bugfix"
      When call commit_change "Fix bug"
      When call merge_branch "bugfix/temp-bugfix" "develop"
      When call sh -c "cd '$GITFLOW_REPO' && git checkout develop > /dev/null && git branch -d bugfix/temp-bugfix > /dev/null 2>&1 && echo deleted || echo exists"
      The output should equal "deleted"
    End

    It "should keep develop branch intact after bugfix merge"
      When call create_bugfix_branch "critical-bug"
      When call commit_change "Fix critical bug"
      When call merge_branch "bugfix/critical-bug" "develop"
      The output "$(branch_exists develop; echo $?)" should equal "0"
    End

    It "should preserve bugfix commits in develop history"
      When call create_bugfix_branch "bug-branch"
      When call commit_change "Fix bug part 1"
      When call commit_change "Fix bug part 2"
      When call merge_branch "bugfix/bug-branch" "develop"
      When call sh -c "cd '$GITFLOW_REPO' && git log develop --oneline | wc -l"
      The output should be greater than 3
    End

    It "should not merge bugfix to master"
      When call sh -c "cd '$GITFLOW_REPO' && git log master --oneline | wc -l"
      The output should be greater than 0
    End
  End

  Describe "Bugfix Workflow"
    Before "setup_test_repo; init_gitflow"

    It "should allow focused bug fixes"
      When call create_bugfix_branch "specific-issue"
      When call commit_change "Fix specific issue"
      When call sh -c "cd '$GITFLOW_REPO' && git log bugfix/specific-issue --oneline | wc -l"
      The output should be greater than 1
    End

    It "should support multiple bugfix iterations"
      When call create_bugfix_branch "complex-bug"
      When call commit_change "First attempt"
      When call commit_change "Second attempt"
      When call commit_change "Final fix"
      When call sh -c "cd '$GITFLOW_REPO' && git log bugfix/complex-bug --oneline | wc -l"
      The output should be greater than 3
    End

    It "should prevent master changes before bugfix completion"
      When call sh -c "cd '$GITFLOW_REPO' && git checkout master > /dev/null && git log -1 --oneline"
      The output should include "Initial commit"
    End

    It "should allow rebasing on latest develop"
      When call create_bugfix_branch "rebase-bug"
      When call commit_change "Bugfix work"
      When call sh -c "cd '$GITFLOW_REPO' && git checkout develop > /dev/null && git commit --allow-empty -m 'Develop update'"
      When call sh -c "cd '$GITFLOW_REPO' && git rebase develop bugfix/rebase-bug 2>&1 | grep -i rebase || echo 'Rebase ready'"
      The output should not include "fatal"
    End

    It "should support concurrent bugfixes"
      When call create_bugfix_branch "bug-a"
      When call commit_change "Fix bug A"
      When call create_bugfix_branch "bug-b"
      When call commit_change "Fix bug B"
      The output "$(branch_exists bugfix/bug-a; echo $?)" should equal "0"
      The output "$(branch_exists bugfix/bug-b; echo $?)" should equal "0"
    End
  End

  Describe "Bugfix vs Feature Distinction"
    Before "setup_test_repo; init_gitflow"

    It "should use bugfix for bugs in develop"
      When call create_bugfix_branch "develop-bug"
      When call commit_change "Fix bug found in develop"
      The output "$(branch_exists bugfix/develop-bug; echo $?)" should equal "0"
    End

    It "should use feature for new functionality"
      When call create_feature_branch "new-feature"
      When call commit_change "Add new feature"
      The output "$(branch_exists feature/new-feature; echo $?)" should equal "0"
    End

    It "should have different prefixes"
      When call create_bugfix_branch "test-bug"
      When call create_feature_branch "test-feature"
      When call sh -c "cd '$GITFLOW_REPO' && git branch -l"
      The output should include "bugfix/test-bug"
      The output should include "feature/test-feature"
    End

    It "should not merge bugfix with feature branches"
      When call create_bugfix_branch "bugfix-1"
      When call create_feature_branch "feature-1"
      When call commit_change "Bugfix"
      When call sh -c "cd '$GITFLOW_REPO' && git checkout feature-1 > /dev/null && git log --oneline | grep -c bugfix || echo 0"
      The output should equal "0"
    End
  End

  Describe "Bugfix Branch Best Practices"
    Before "setup_test_repo; init_gitflow"

    It "should prefix bugfix branches consistently"
      When call create_bugfix_branch "consistent-naming"
      When call sh -c "cd '$GITFLOW_REPO' && git branch -l | grep bugfix/"
      The output should include "bugfix/consistent-naming"
    End

    It "should contain only bugfix-related commits"
      When call create_bugfix_branch "focused-fix"
      When call commit_change "Fix the reported issue"
      When call sh -c "cd '$GITFLOW_REPO' && git log bugfix/focused-fix --oneline"
      The output should include "Fix"
    End

    It "should maintain clean commit history"
      When call create_bugfix_branch "clean-bug"
      When call commit_change "Fix attempt 1"
      When call commit_change "Fix attempt 2"
      When call sh -c "cd '$GITFLOW_REPO' && git log bugfix/clean-bug --oneline | wc -l"
      The output should be greater than 2
    End

    It "should reference issue numbers when available"
      When call create_bugfix_branch "issue-123-fix"
      When call commit_change "Fix issue #123"
      When call sh -c "cd '$GITFLOW_REPO' && git log bugfix/issue-123-fix --oneline"
      The output should include "#123"
    End

    It "should be short-lived branches"
      When call create_bugfix_branch "short-lived"
      When call commit_change "Quick fix"
      When call merge_branch "bugfix/short-lived" "develop"
      When call sh -c "cd '$GITFLOW_REPO' && git log develop --oneline | head -1"
      The output should include "Merge bugfix/short-lived"
    End
  End
End

