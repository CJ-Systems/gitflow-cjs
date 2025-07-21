#!/usr/bin/env bash
set -e
expected=$(grep -m1 '^GITFLOW_VERSION=' git-flow-version | cut -d'=' -f2)
output=$(bash -c 'source ./git-flow-version; cmd_default')
if [ "$output" = "$expected (CJS Edition)" ]; then
  echo "Version test passed"
  exit 0
else
  echo "Expected '$expected (CJS Edition)' but got '$output'" >&2
  exit 1
fi
