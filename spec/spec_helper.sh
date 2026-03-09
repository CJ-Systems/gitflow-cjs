# spec_helper.sh
# Shared test setup and utilities for gitflow shellspec tests

set -e

# Test environment setup
export GITFLOW_TEST_DIR="${GITFLOW_TEST_DIR:-./.gitflow-test-tmp}"
export GITFLOW_REPO="$GITFLOW_TEST_DIR/test-repo"
export GITFLOW_SCRIPT_DIR="$(cd "$(dirname "$0")/../legacy" && pwd)"

# Git test configuration
export GIT_AUTHOR_NAME="Test User"
export GIT_AUTHOR_EMAIL="test@example.com"
export GIT_COMMITTER_NAME="Test User"
export GIT_COMMITTER_EMAIL="test@example.com"

# Gitflow branch names (defaults)
export MASTER_BRANCH="master"
export DEVELOP_BRANCH="develop"
export FEATURE_PREFIX="feature/"
export RELEASE_PREFIX="release/"
export HOTFIX_PREFIX="hotfix/"
export BUGFIX_PREFIX="bugfix/"
export SUPPORT_PREFIX="support/"
export VERSION_PREFIX="v"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper function: Setup a clean test repository
setup_test_repo() {
    # Clean up any existing test directory
    if [ -d "$GITFLOW_TEST_DIR" ]; then
        rm -rf "$GITFLOW_TEST_DIR"
    fi

    mkdir -p "$GITFLOW_REPO"
    cd "$GITFLOW_REPO"

    # Initialize git repository
    git init
    git config user.name "$GIT_AUTHOR_NAME"
    git config user.email "$GIT_AUTHOR_EMAIL"

    # Create initial commit on master
    echo "# Test Repository" > README.md
    git add README.md
    git commit -m "Initial commit"

    # Create and switch to develop branch
    git checkout -b "$DEVELOP_BRANCH"
    echo "Development branch initialized" >> README.md
    git add README.md
    git commit -m "Initialize development branch"
}

# Helper function: Cleanup test repository
cleanup_test_repo() {
    if [ -d "$GITFLOW_TEST_DIR" ]; then
        cd /
        rm -rf "$GITFLOW_TEST_DIR"
    fi
}

# Helper function: Initialize gitflow for the test repo
init_gitflow() {
    cd "$GITFLOW_REPO"

    # Configure gitflow prefixes
    git config gitflow.branch.master "$MASTER_BRANCH"
    git config gitflow.branch.develop "$DEVELOP_BRANCH"
    git config gitflow.prefix.feature "$FEATURE_PREFIX"
    git config gitflow.prefix.release "$RELEASE_PREFIX"
    git config gitflow.prefix.hotfix "$HOTFIX_PREFIX"
    git config gitflow.prefix.bugfix "$BUGFIX_PREFIX"
    git config gitflow.prefix.support "$SUPPORT_PREFIX"
    git config gitflow.prefix.versiontag "$VERSION_PREFIX"
}

# Helper function: Create a feature branch
create_feature_branch() {
    local feature_name="$1"
    cd "$GITFLOW_REPO"

    git checkout "$DEVELOP_BRANCH" > /dev/null 2>&1
    git checkout -b "${FEATURE_PREFIX}${feature_name}" > /dev/null 2>&1
}

# Helper function: Create a release branch
create_release_branch() {
    local version="$1"
    cd "$GITFLOW_REPO"

    git checkout "$DEVELOP_BRANCH" > /dev/null 2>&1
    git checkout -b "${RELEASE_PREFIX}${version}" > /dev/null 2>&1
}

# Helper function: Create a hotfix branch
create_hotfix_branch() {
    local version="$1"
    cd "$GITFLOW_REPO"

    git checkout "$MASTER_BRANCH" > /dev/null 2>&1
    git checkout -b "${HOTFIX_PREFIX}${version}" > /dev/null 2>&1
}

# Helper function: Create a bugfix branch
create_bugfix_branch() {
    local bugfix_name="$1"
    cd "$GITFLOW_REPO"

    git checkout "$DEVELOP_BRANCH" > /dev/null 2>&1
    git checkout -b "${BUGFIX_PREFIX}${bugfix_name}" > /dev/null 2>&1
}

# Helper function: Get list of branches
get_local_branches() {
    cd "$GITFLOW_REPO"
    git branch | grep -v '^*' | awk '{print $1}'
}

# Helper function: Get current branch
get_current_branch() {
    cd "$GITFLOW_REPO"
    git rev-parse --abbrev-ref HEAD
}

# Helper function: Commit a change
commit_change() {
    local message="$1"
    local filename="${2:-test.txt}"

    cd "$GITFLOW_REPO"
    echo "Test change: $message" >> "$filename"
    git add "$filename"
    git commit -m "$message"
}

# Helper function: Merge branch
merge_branch() {
    local source_branch="$1"
    local target_branch="$2"

    cd "$GITFLOW_REPO"
    git checkout "$target_branch" > /dev/null 2>&1
    git merge --no-ff "$source_branch" -m "Merge $source_branch into $target_branch" > /dev/null 2>&1
}

# Helper function: Check if branch exists
branch_exists() {
    local branch_name="$1"
    cd "$GITFLOW_REPO"
    git rev-parse --verify "$branch_name" > /dev/null 2>&1
}

# Helper function: Check if branch does not exist
branch_not_exists() {
    local branch_name="$1"
    cd "$GITFLOW_REPO"
    ! git rev-parse --verify "$branch_name" > /dev/null 2>&1
}

# Helper function: Get commits on a branch
get_branch_commits() {
    local branch_name="$1"
    cd "$GITFLOW_REPO"
    git rev-list --count "$branch_name"
}

# Helper function: Create a tag
create_tag() {
    local tag_name="$1"
    local message="${2:-}"

    cd "$GITFLOW_REPO"
    if [ -z "$message" ]; then
        git tag "$tag_name"
    else
        git tag -a "$tag_name" -m "$message"
    fi
}

# Helper function: Check if tag exists
tag_exists() {
    local tag_name="$1"
    cd "$GITFLOW_REPO"
    git rev-parse -q --verify "refs/tags/$tag_name" > /dev/null 2>&1
}

# Helper function: Get tag message
get_tag_message() {
    local tag_name="$1"
    cd "$GITFLOW_REPO"
    git tag -l -n10 "$tag_name" | tail -n +2
}

# Clean up test repos after each test
After() {
    cleanup_test_repo
}

