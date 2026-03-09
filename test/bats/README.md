# Gitflow TDD Test Suite (BATS)

This directory contains a comprehensive Test-Driven Development (TDD) suite for the gitflow branching model using [BATS](https://github.com/bats-core/bats-core).

## Coverage

- `01_init.bats`: repository and gitflow initialization
- `02_feature.bats`: feature branch lifecycle
- `03_release.bats`: release branch lifecycle and tagging
- `04_hotfix.bats`: hotfix flow and back-merge rules
- `05_bugfix.bats`: bugfix flow in develop
- `06_workflow.bats`: end-to-end cross-branch workflows
- `07_naming.bats`: naming and prefix rules
- `08_state.bats`: repository integrity and state checks

## Prerequisites

- Git
- Bash
- BATS (bats-core)

## Run

```bash
bats test/bats
```

Run one file:

```bash
bats test/bats/02_feature.bats
```

## Notes

- Tests use isolated temporary repositories for every test case.
- Shared helpers live in `test/bats/helpers/test_helper.bash`.

