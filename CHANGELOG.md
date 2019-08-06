# Changelog

#### 2.2.0-SNAPSHOT
* feat: add option to hotfix finish to allow for backmerge to release branch. Thank You [Bankers88](https://github.com/Bankers88)
* fix: Prevent hotfixes being merged to develop with nobackmerge flag. Thank You [adamrodger](https://github.com/adamrodger)
* feat(feature): add release sub command. Thank You [codesurf42](https://github.com/codesurf42) for the initial pr
* feat(init): add sign flag to create initial signed commit
* feat(init): add support for "Support Git Environment Credentials" pull request #19 from filipekiss/feature/environment_credentials
* docs: update repository url in source files
* docs: update copyright information in source files
* fix: wording for help text in git flow log pull request #15 from Shea690901/hotfix/git-flow-log_help-message
* refactor(git-flow): add support for busybox-readlink request #12 from KAction/readlink-busybox

#### 2.1.0
* feat: add create command to release allowing for a single step release prodution
* feat: add missing hook script filter-flow-release-finish-version
* fix: multi-line tag message when using -m
* docs: update readme with better description as to why this fork was created. Thank You [shaedrick](https://github.com/shaedrich)
**NOTE:** The format for a multi-line tag message is now "$(printf 'line of text with \n escape codes placed as needed for proper formating of the message')"

#### 2.0.1
* fix incorrect version identification along with updating source repository in gitflow-installer. Corrections pointed out by [bobstuart](https://github.com/bobstuart)

#### 2.0.0
* Bugfix/help text and reorder rename args Thank You [bmcdonnell](https://github.com/bmcdonnell)
* Cherry-Pick  Speed up "list" command execution #325 from gpongelli/gitflow-avh/tree/speedUpListCmd
* Updated readme links Thank You [JamesSkemp](https://github.com/JamesSkemp)
* Support gitflow-cjs being used as a plugin for zsh users via antigen. Thank You [matthewfranglen](https://github.com/matthewfranglen)
