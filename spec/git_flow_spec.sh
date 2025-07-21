Describe 'git-flow'
  Describe 'version command'
    It 'prints current version' 
      When run script ../git-flow version
      The output should eq '2.2.1 (CJS Edition)'
      The status should be success
    End
  End

  Describe 'usage without arguments'
    It 'shows help text'
      When run script ../git-flow
      The status should be failure
      The output should start with 'usage: git flow'
    End
  End
End
