#!/bin/bash
# Gitflow Test Runner Script
# Convenient script to run tests with various options

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
VERBOSE=""
FORMAT="progress"
FAIL_FAST=""
JOBS=""
TARGET=""

# Function to print usage
usage() {
    cat << EOF
${BLUE}Gitflow Test Runner${NC}

Usage: $0 [OPTIONS]

Options:
  -h, --help              Show this help message
  -a, --all               Run all tests (default)
  -f, --feature           Run feature branch tests
  -r, --release           Run release branch tests
  -x, --hotfix            Run hotfix branch tests
  -b, --bugfix            Run bugfix branch tests
  -i, --init              Run initialization tests
  -w, --workflow          Run workflow integration tests
  -n, --naming            Run naming convention tests
  -s, --state             Run state validation tests

  -v, --verbose           Enable verbose output
  -t, --tap               Output in TAP format
  -j, --junit             Output in JUnit format
  --json                  Output in JSON format
  --fail-fast             Stop on first failure
  --jobs N                Run N tests in parallel

Examples:
  $0                      # Run all tests
  $0 --feature --verbose  # Run feature tests with verbose output
  $0 --all --junit        # Run all tests, output JUnit
  $0 --hotfix --fail-fast # Run hotfix tests, stop on first failure
EOF
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            ;;
        -a|--all)
            TARGET=""
            shift
            ;;
        -i|--init)
            TARGET="spec/gitflow_init_spec.sh"
            shift
            ;;
        -f|--feature)
            TARGET="spec/gitflow_feature_spec.sh"
            shift
            ;;
        -r|--release)
            TARGET="spec/gitflow_release_spec.sh"
            shift
            ;;
        -x|--hotfix)
            TARGET="spec/gitflow_hotfix_spec.sh"
            shift
            ;;
        -b|--bugfix)
            TARGET="spec/gitflow_bugfix_spec.sh"
            shift
            ;;
        -w|--workflow)
            TARGET="spec/gitflow_workflow_spec.sh"
            shift
            ;;
        -n|--naming)
            TARGET="spec/gitflow_naming_spec.sh"
            shift
            ;;
        -s|--state)
            TARGET="spec/gitflow_state_spec.sh"
            shift
            ;;
        -v|--verbose)
            VERBOSE="--verbose"
            shift
            ;;
        -t|--tap)
            FORMAT="tap"
            shift
            ;;
        -j|--junit)
            FORMAT="junit"
            shift
            ;;
        --json)
            FORMAT="json"
            shift
            ;;
        --fail-fast)
            FAIL_FAST="--fail-fast"
            shift
            ;;
        --jobs)
            JOBS="--jobs $2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

# Check if shellspec is installed
if ! command -v shellspec &> /dev/null; then
    echo -e "${RED}Error: shellspec is not installed${NC}"
    echo ""
    echo "Install shellspec with:"
    echo "  curl -fsSL https://git.io/shellspec | sh -s -- --yes"
    exit 1
fi

# Build command
CMD="shellspec"
[ -n "$TARGET" ] && CMD="$CMD $TARGET"
CMD="$CMD --format $FORMAT"
[ -n "$VERBOSE" ] && CMD="$CMD $VERBOSE"
[ -n "$FAIL_FAST" ] && CMD="$CMD $FAIL_FAST"
[ -n "$JOBS" ] && CMD="$CMD $JOBS"
CMD="$CMD --color"

# Print header
echo -e "${BLUE}"
echo "╔════════════════════════════════════════╗"
echo "║  Gitflow BDD Test Suite Runner         ║"
echo "╚════════════════════════════════════════╝"
echo -e "${NC}"

# Show configuration
echo -e "${YELLOW}Configuration:${NC}"
[ -z "$TARGET" ] && echo "  Tests: All tests" || echo "  Tests: $(basename $TARGET)"
echo "  Format: $FORMAT"
[ -n "$VERBOSE" ] && echo "  Verbose: Yes" || echo "  Verbose: No"
[ -n "$FAIL_FAST" ] && echo "  Fail Fast: Yes" || echo "  Fail Fast: No"
[ -n "$JOBS" ] && echo "  Jobs: $(echo $JOBS | cut -d' ' -f2)" || echo "  Jobs: Default"
echo ""

# Run tests
echo -e "${BLUE}Running tests...${NC}"
echo ""

if eval "$CMD"; then
    echo ""
    echo -e "${GREEN}✓ All tests passed!${NC}"
    exit 0
else
    echo ""
    echo -e "${RED}✗ Tests failed!${NC}"
    exit 1
fi

