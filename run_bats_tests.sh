#!/usr/bin/env bash
# Gitflow BATS TDD test runner.

set -euo pipefail

TARGET="test/bats"

usage() {
  cat <<'EOF'
Usage: ./run_bats_tests.sh [OPTIONS]

Options:
  -h, --help        Show this help
  -a, --all         Run all BATS tests (default)
  -i, --init        Run initialization tests
  -f, --feature     Run feature tests
  -r, --release     Run release tests
  -x, --hotfix      Run hotfix tests
  -b, --bugfix      Run bugfix tests
  -w, --workflow    Run workflow tests
  -n, --naming      Run naming tests
  -s, --state       Run state tests
  -t, --tap         Output TAP format
EOF
}

BATS_ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    -a|--all)
      TARGET="test/bats"
      shift
      ;;
    -i|--init)
      TARGET="test/bats/01_init.bats"
      shift
      ;;
    -f|--feature)
      TARGET="test/bats/02_feature.bats"
      shift
      ;;
    -r|--release)
      TARGET="test/bats/03_release.bats"
      shift
      ;;
    -x|--hotfix)
      TARGET="test/bats/04_hotfix.bats"
      shift
      ;;
    -b|--bugfix)
      TARGET="test/bats/05_bugfix.bats"
      shift
      ;;
    -w|--workflow)
      TARGET="test/bats/06_workflow.bats"
      shift
      ;;
    -n|--naming)
      TARGET="test/bats/07_naming.bats"
      shift
      ;;
    -s|--state)
      TARGET="test/bats/08_state.bats"
      shift
      ;;
    -t|--tap)
      BATS_ARGS+=("--tap")
      shift
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if ! command -v bats >/dev/null 2>&1; then
  echo "Error: bats is not installed or not on PATH." >&2
  echo "Install bats-core and try again." >&2
  exit 1
fi

exec bats --print-output-on-failure "${BATS_ARGS[@]}" "$TARGET"

