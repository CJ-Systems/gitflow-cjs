# gitflow-cjs

A prose-native implementation of [Vincent Driessen's git-flow branching model](http://nvie.com/posts/a-successful-git-branching-model/).

## What this is

gitflow-cjs began as a fork of `git-flow-avh` — ~6,000 lines of bash implementing the git-flow workflow. That codebase is frozen on `legacy-main` / `legacy-develop`.

This repo's `develop` branch is the **modernization**: the same workflow, re-expressed as prose that an agent reads and executes against git directly. No bash scripts, no `shFlags`, no compiled artifact between the workflow description and your repository.

The thesis: git-flow is fundamentally a *workflow* — a set of conventions about branches, merges, and tags. The historical bash encoded those conventions in 6k lines of imperative code that no one wanted to read or test. Re-expressed as prose, the same workflow is small enough to read in one sitting, the spec and the implementation are the same artifact, and the agent layer turns every error path into a sentence the user can act on.

## Project Status

**Phase:** prose-native rewrite in progress.

**Shipped:**
- `feature start` — create a new feature branch (with inline gitflow init if the repo isn't set up yet)

**Coming next:**
- `feature finish`, `feature publish`, `feature checkout`, `feature list`
- `release` workflow (start, finish, publish, track)
- `hotfix` workflow
- `bugfix`, `support`
- Packaging / distribution path beyond Claude Code

## Form factor

The new gitflow-cjs ships as a [Claude Code](https://claude.com/claude-code) skill. To use it:

```sh
git clone https://github.com/CJ-Systems/gitflow-cjs.git
mkdir -p ~/.claude/skills
ln -s "$(pwd)/gitflow-cjs/skills/gitflow" ~/.claude/skills/gitflow
```

Then in any git repo, ask Claude Code to start a feature:

> start a feature called login-redesign

The `gitflow` skill is invoked automatically when your intent matches. No CLI to learn — the conversation is the interface.

## Why not a CLI

A standalone CLI is a likely follow-up (so that non-Claude-Code users can adopt it). But the prose-as-canonical thesis is sharpest when the agent layer is provided — the workflow description doesn't have to be retrofitted into argument parsing, exit codes, and stderr-formatted error messages. Those re-emerge when the user wants them, but they aren't the design center.

## Legacy

The original bash implementation is preserved untouched on `legacy-main` and `legacy-develop` for anyone still using it. The original gitflow-avh model and Vincent Driessen's original post are the reference for what these workflows mean — this repo doesn't change the model, only how it's expressed.

## Resources

- **Original model:** [A successful Git branching model](http://nvie.com/posts/a-successful-git-branching-model/)
- **Issues:** [github.com/CJ-Systems/gitflow-cjs/issues](https://github.com/CJ-Systems/gitflow-cjs/issues)
- **Discussions:** [github.com/CJ-Systems/gitflow-cjs/discussions](https://github.com/CJ-Systems/gitflow-cjs/discussions)

## License

MIT
