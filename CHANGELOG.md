# Changelog

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
