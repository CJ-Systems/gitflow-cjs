#!/usr/bin/env bats

setup() {
  # Source required scripts
  source "$BATS_TEST_DIRNAME/../../gitflow-shFlags" >/dev/null
  source "$BATS_TEST_DIRNAME/../../gitflow-common"
}

@test "check_boolean returns true for yes" {
  run bash -c 'check_boolean yes'
  [ "$status" -eq 0 ]
}

@test "check_boolean returns false for no" {
  run bash -c 'check_boolean no'
  [ "$status" -eq 1 ]
}

@test "check_boolean returns error for maybe" {
  run bash -c 'check_boolean maybe'
  [ "$status" -eq 2 ]
}

@test "startswith detects prefix" {
  run bash -c 'startswith foobar foo'
  [ "$status" -eq 0 ]
}

@test "startswith detects absence of prefix" {
  run bash -c 'startswith foobar bar'
  [ "$status" -ne 0 ]
}
