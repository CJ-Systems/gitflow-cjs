# Gitflow BDD Test Suite - Quick Reference

## File Structure

```
spec/
├── spec_helper.sh                    # Helper functions and setup
├── .shellspec                        # ShellSpec configuration
├── README.md                         # Detailed test documentation
│
├── gitflow_init_spec.sh             # Initialization tests (8)
├── gitflow_feature_spec.sh          # Feature branch tests (15)
├── gitflow_release_spec.sh          # Release branch tests (15)
├── gitflow_hotfix_spec.sh           # Hotfix branch tests (15)
├── gitflow_bugfix_spec.sh           # Bugfix branch tests (15)
├── gitflow_workflow_spec.sh         # Integration tests (15)
├── gitflow_naming_spec.sh           # Naming convention tests (15)
└── gitflow_state_spec.sh            # Repository state tests (15)
```

## Quick Commands

### Installation
```bash
# macOS
brew install shellspec

# Linux
curl -fsSL https://git.io/shellspec | sh -s -- --yes

# Manual
git clone https://github.com/shellspec/shellspec.git
cd shellspec && make install
```

### Running Tests
```bash
# All tests
shellspec

# Specific file
shellspec spec/gitflow_feature_spec.sh

# Specific test
shellspec -p "should create a feature"

# With options
shellspec --verbose --color=always --fail-fast

# Different format
shellspec --format tap      # Test Anything Protocol
shellspec --format junit    # JUnit XML
shellspec --format json     # JSON
```

### Test Organization

| Scope | Command | Result |
|-------|---------|--------|
| All | `shellspec` | All 113 tests |
| Init | `shellspec spec/gitflow_init_spec.sh` | 8 tests |
| Feature | `shellspec spec/gitflow_feature_spec.sh` | 15 tests |
| Release | `shellspec spec/gitflow_release_spec.sh` | 15 tests |
| Hotfix | `shellspec spec/gitflow_hotfix_spec.sh` | 15 tests |
| Bugfix | `shellspec spec/gitflow_bugfix_spec.sh` | 15 tests |
| Workflow | `shellspec spec/gitflow_workflow_spec.sh` | 15 tests |
| Naming | `shellspec spec/gitflow_naming_spec.sh` | 15 tests |
| State | `shellspec spec/gitflow_state_spec.sh` | 15 tests |

## Test Helpers Summary

### Repository Setup
```bash
setup_test_repo              # Create clean git repo
init_gitflow                 # Configure gitflow
cleanup_test_repo            # Remove test artifacts
```

### Branch Operations
```bash
create_feature_branch "name"      # feature/name
create_release_branch "1.0.0"     # release/1.0.0
create_hotfix_branch "1.0.1"      # hotfix/1.0.1
create_bugfix_branch "name"       # bugfix/name
merge_branch "source" "target"    # Merge branches
branch_exists "name"              # Check existence
get_current_branch                # Get active branch
get_local_branches                # List all branches
```

### Commit Operations
```bash
commit_change "message" [file]    # Create commit
get_branch_commits "branch"       # Count commits
```

### Tag Operations
```bash
create_tag "v1.0.0" [message]    # Create tag
tag_exists "tag"                 # Check tag
get_tag_message "tag"            # Get tag info
```

## BDD Structure

```bash
# Test file template
#!/bin/bash
Describe "Feature Description"
  Include "spec/spec_helper.sh"
  
  Describe "Specific behavior"
    Before "setup_test_repo; init_gitflow"
    
    It "should do something"
      When call function_name arg1 arg2
      The output should equal "expected"
    End
    
    It "should verify state"
      The variable VAR should equal "value"
    End
  End
End
```

## Common Assertions

```bash
# Output assertions
The output should equal "text"
The output should include "text"
The output should match "pattern"
The status should be success
The status should be failure

# Variable assertions
The variable VAR should equal "value"
The variable VAR should not equal "value"

# Numeric assertions
The output should be greater than 5
The output should be less than 10
```

## BDD Test Flow

```
Test Case
  ├── Before (setup_test_repo; init_gitflow)
  ├── When (execute command/function)
  ├── The (assert result)
  └── After (cleanup_test_repo)
```

## Feature Branch Example

```bash
Describe "Feature Branch"
  Before "setup_test_repo; init_gitflow"
  
  It "should create feature from develop"
    When call create_feature_branch "user-auth"
    The output "$(branch_exists feature/user-auth; echo $?)" should equal "0"
  End
  
  It "should merge to develop"
    When call create_feature_branch "dashboard"
    When call commit_change "Add dashboard"
    When call merge_branch "feature/dashboard" "develop"
    The output "$(branch_exists develop; echo $?)" should equal "0"
  End
End
```

## Expected Output

```
Gitflow Feature Management
  Feature Branch Creation
    ✓ should create a feature branch from develop
    ✓ should switch to the new feature branch
    ...
  Feature Branch Finishing
    ✓ should merge feature branch back to develop
    ...
  Feature Branch Collaboration
    ✓ should allow publishing feature to remote
    ...

113 examples, 0 failures
```

## Environment Variables

```bash
# Auto-set by helpers
GITFLOW_TEST_DIR      # .gitflow-test-tmp
GITFLOW_REPO          # $GITFLOW_TEST_DIR/test-repo
MASTER_BRANCH         # master
DEVELOP_BRANCH        # develop
FEATURE_PREFIX        # feature/
RELEASE_PREFIX        # release/
HOTFIX_PREFIX         # hotfix/
BUGFIX_PREFIX         # bugfix/
VERSION_PREFIX        # v
```

## Gitflow Branch Model

```
Master (Production)
  ├── Initial commit
  ├── Merge release/1.0.0 → tag v1.0.0
  ├── Merge hotfix/1.0.1 → tag v1.0.1
  └── Merge release/2.0.0 → tag v2.0.0

Develop (Integration)
  ├── feature/user-auth → merge
  ├── feature/dashboard → merge
  ├── Merge release/1.0.0
  ├── bugfix/crash → merge
  ├── Merge hotfix/1.0.1
  └── feature/new-feature → merge
```

## Common Test Patterns

### Feature Workflow
```bash
create_feature_branch "name"
commit_change "work"
merge_branch "feature/name" "develop"
```

### Release Workflow
```bash
create_release_branch "1.0.0"
commit_change "Version bump"
merge_branch "release/1.0.0" "master"
create_tag "v1.0.0"
merge_branch "release/1.0.0" "develop"
```

### Hotfix Workflow
```bash
create_hotfix_branch "1.0.1"
commit_change "Critical fix"
merge_branch "hotfix/1.0.1" "master"
create_tag "v1.0.1"
merge_branch "hotfix/1.0.1" "develop"
```

## Debugging

### View test repository
```bash
ls -la .gitflow-test-tmp/test-repo
cd .gitflow-test-tmp/test-repo
git log --all --graph --oneline
```

### Check git configuration
```bash
git config --get-regexp gitflow
```

### Clean up failed tests
```bash
rm -rf .gitflow-test-tmp
```

### Run with verbose output
```bash
shellspec --verbose spec/gitflow_feature_spec.sh
```

## CI/CD Quick Start

### GitHub Actions
```yaml
- name: Test Gitflow
  run: |
    curl -fsSL https://git.io/shellspec | sh -s -- --yes
    shellspec --format json
```

### GitLab CI
```yaml
test:
  before_script:
    - curl -fsSL https://git.io/shellspec | sh -s -- --yes
  script:
    - shellspec
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| ShellSpec not found | `export PATH="/usr/local/lib/shellspec:$PATH"` |
| Permission denied | `chmod +x spec/*.sh` |
| Git config missing | `git config --global --remove-section gitflow 2>/dev/null \|\| true` |
| Cleanup failed | `rm -rf .gitflow-test-tmp` |
| Wrong output | Use `--verbose` flag |

## Resources

- Full Documentation: `spec/README.md`
- Complete Guide: `TEST_SUITE_DOCUMENTATION.md`
- Gitflow Model: https://nvie.com/posts/a-successful-git-branching-model/
- ShellSpec Docs: https://shellspec.info/

## Test Statistics

- **Total Tests:** 113
- **Test Files:** 8
- **Helper Functions:** 20+
- **Estimated Runtime:** 2-3 minutes
- **Coverage:** All gitflow operations

## Version

- Created: 2026-03-09
- Test Suite Version: 1.0.0
- Gitflow-CJS Compatibility: 1.x.x

