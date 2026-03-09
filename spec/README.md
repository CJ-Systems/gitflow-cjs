# Gitflow BDD Test Suite

A comprehensive Behavior-Driven Development (BDD) test suite for the gitflow branching model using [shellspec](https://shellspec.info/).

## Overview

This test suite provides complete coverage of the gitflow branching model, including:

- **Initialization** - Setting up gitflow in a repository
- **Feature branches** - Creating, managing, and finishing features
- **Release branches** - Preparing and publishing releases
- **Hotfix branches** - Emergency production fixes
- **Bugfix branches** - Development environment bug fixes
- **Integration workflows** - Complete end-to-end scenarios
- **Branch naming** - Naming conventions and prefix configuration

## Directory Structure

```
spec/
├── spec_helper.sh              # Shared test utilities and setup
├── gitflow_init_spec.sh        # Initialization tests
├── gitflow_feature_spec.sh     # Feature branch tests
├── gitflow_release_spec.sh     # Release branch tests
├── gitflow_hotfix_spec.sh      # Hotfix branch tests
├── gitflow_bugfix_spec.sh      # Bugfix branch tests
├── gitflow_workflow_spec.sh    # Complete workflow tests
└── gitflow_naming_spec.sh      # Naming convention tests
```

## Installation

### Prerequisites

- Git (2.13+)
- Bash/Shell (4.0+)
- ShellSpec (0.28+)

### Installing ShellSpec

```bash
# macOS with Homebrew
brew install shellspec

# Linux with curl
curl -fsSL https://git.io/shellspec | sh -s -- --yes

# Manual installation
git clone https://github.com/shellspec/shellspec.git
cd shellspec
make install
```

## Running Tests

### Run all tests
```bash
shellspec
```

### Run specific test file
```bash
shellspec spec/gitflow_feature_spec.sh
```

### Run with verbose output
```bash
shellspec --verbose
```

### Run with TAP (Test Anything Protocol) format
```bash
shellspec --format tap
```

### Run with junit output
```bash
shellspec --format junit
```

### Run with coverage report
```bash
shellspec --coverage
```

## Test Structure

Each test file follows the BDD convention with:

- **Describe blocks** - Group related tests
- **It blocks** - Individual test cases
- **Before blocks** - Setup for each test
- **When/The assertions** - Test logic and assertions

### Example Test Structure

```bash
Describe "Git Flow Feature Management"
  Describe "Feature Branch Creation"
    Before "setup_test_repo; init_gitflow"
    
    It "should create a feature branch from develop"
      When call create_feature_branch "user-login"
      The variable FEATURE_PREFIX should equal "feature/"
      The output "$(branch_exists feature/user-login; echo $?)" should equal "0"
    End
  End
End
```

## Test Coverage

### Gitflow Initialization (8 tests)
- Default branch configuration
- Prefix setup
- Branch creation and maintenance

### Feature Branches (15 tests)
- Creation from develop
- Finishing and merging
- Collaboration scenarios
- Best practices

### Release Branches (15 tests)
- Creation and preparation
- Merging to master and develop
- Version tagging
- Release workflow

### Hotfix Branches (15 tests)
- Creation from master
- Merging to both master and develop
- Emergency patching
- Version tagging

### Bugfix Branches (15 tests)
- Creation from develop
- Merging and cleanup
- Bug fix workflow
- Feature vs bugfix distinction

### Complete Workflows (15 tests)
- Feature development lifecycle
- Release process
- Hotfix and patch releases
- Complex scenarios

### Branch Naming (15 tests)
- Default branch names
- Prefix configuration
- Naming conventions
- Branch isolation

## Shared Test Utilities

The `spec_helper.sh` file provides helper functions:

### Repository Setup
- `setup_test_repo()` - Create test git repository
- `cleanup_test_repo()` - Remove test directory
- `init_gitflow()` - Configure gitflow in repo

### Branch Operations
- `create_feature_branch(name)` - Create feature branch
- `create_release_branch(version)` - Create release branch
- `create_hotfix_branch(version)` - Create hotfix branch
- `create_bugfix_branch(name)` - Create bugfix branch
- `merge_branch(source, target)` - Merge between branches
- `branch_exists(name)` - Check if branch exists
- `branch_not_exists(name)` - Check if branch doesn't exist

### Commit Operations
- `commit_change(message, [filename])` - Create a commit
- `get_branch_commits(branch)` - Count commits on branch
- `get_current_branch()` - Get current branch name
- `get_local_branches()` - List all local branches

### Tag Operations
- `create_tag(name, [message])` - Create git tag
- `tag_exists(name)` - Check if tag exists
- `get_tag_message(name)` - Retrieve tag message

## Example Workflows

### Creating and Merging a Feature
```bash
# Setup
setup_test_repo
init_gitflow

# Create feature
create_feature_branch "user-auth"
commit_change "Implement authentication"

# Merge feature
merge_branch "feature/user-auth" "develop"

# Verify
branch_exists "develop"
```

### Releasing a Version
```bash
# Create release branch
create_release_branch "1.0.0"
commit_change "Version 1.0.0"

# Merge to master
merge_branch "release/1.0.0" "master"

# Tag the release
create_tag "v1.0.0" "Version 1.0.0"
```

### Emergency Hotfix
```bash
# Create hotfix branch
create_hotfix_branch "1.0.1"
commit_change "Critical fix"

# Merge to master and develop
merge_branch "hotfix/1.0.1" "master"
merge_branch "hotfix/1.0.1" "develop"

# Tag the patch
create_tag "v1.0.1"
```

## Environment Variables

The test suite uses these environment variables:

```bash
GITFLOW_TEST_DIR      # Temporary test directory (./.gitflow-test-tmp)
GITFLOW_REPO          # Test repository path
MASTER_BRANCH         # Master branch name (default: master)
DEVELOP_BRANCH        # Develop branch name (default: develop)
FEATURE_PREFIX        # Feature prefix (default: feature/)
RELEASE_PREFIX        # Release prefix (default: release/)
HOTFIX_PREFIX         # Hotfix prefix (default: hotfix/)
BUGFIX_PREFIX         # Bugfix prefix (default: bugfix/)
VERSION_PREFIX        # Version tag prefix (default: v)
```

## Continuous Integration

### GitHub Actions Example
```yaml
name: Gitflow Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Install ShellSpec
        run: curl -fsSL https://git.io/shellspec | sh -s -- --yes
      - name: Run Tests
        run: shellspec
```

### GitLab CI Example
```yaml
test:
  image: ubuntu:latest
  before_script:
    - apt-get update && apt-get install -y git
    - curl -fsSL https://git.io/shellspec | sh -s -- --yes
  script:
    - shellspec
```

## Troubleshooting

### ShellSpec not found
```bash
# Add shellspec to PATH
export PATH="/usr/local/lib/shellspec:$PATH"
```

### Git configuration issues
```bash
# Clear git global config for tests
git config --global --remove-section gitflow 2>/dev/null || true
```

### Permission denied errors
```bash
# Make spec files executable
chmod +x spec/*.sh
```

### Test isolation issues
- Tests automatically clean up after each run
- If cleanup fails, manually remove: `rm -rf .gitflow-test-tmp`

## Contributing

To add new tests:

1. Create a new `*_spec.sh` file in the `spec/` directory
2. Include the helper: `Include "spec/spec_helper.sh"`
3. Follow the BDD structure with Describe/It blocks
4. Use helper functions for common operations
5. Run: `shellspec spec/your_new_spec.sh`

## Best Practices

1. **Isolation** - Each test creates fresh repository
2. **Cleanup** - Automatic after each test
3. **Meaningful names** - Test descriptions explain intent
4. **Focused assertions** - One logical assertion per test
5. **Reusable helpers** - Use provided utilities
6. **Clear output** - Descriptive failure messages

## References

- [Gitflow Model](https://nvie.com/posts/a-successful-git-branching-model/)
- [ShellSpec Documentation](https://shellspec.info/)
- [Git Branching Strategies](https://www.git-tower.com/learn/git/ebook/en/command-line/branching-merging/workflows)
- [BDD in Shell Scripts](https://github.com/shellspec/shellspec/wiki)

## License

MIT - See LICENSE file for details

