Describe 'git flow init with defaults'
  BeforeAll setup
  AfterAll teardown

  setup() {
    TEST_DIR=$(mktemp -d)
    cd "$TEST_DIR"
    git init -q
    /workspace/gitflow-cjs/git-flow init -d >/dev/null
  }

  teardown() {
    rm -rf "$TEST_DIR"
  }

  It 'creates develop branch'
    When run git rev-parse --verify develop
    The status should be success
  End

  It 'stores branch configuration'
    When run git config gitflow.branch.master
    The output should eq 'master'
  End
End
