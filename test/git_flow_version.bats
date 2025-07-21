#!/usr/bin/env bats

@test "git flow version prints expected output" {
  run /workspace/gitflow-cjs/git-flow version
  [ "$status" -eq 0 ]
  [ "$output" = "2.2.1 (CJS Edition)" ]
}
