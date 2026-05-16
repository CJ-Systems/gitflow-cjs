# gitflow-cjs

A prose-native implementation of [Vincent Driessen's git-flow branching model](http://nvie.com/posts/a-successful-git-branching-model/).

## What this is

gitflow-cjs began as a fork of `git-flow-avh` — ~6,000 lines of bash implementing the git-flow workflow. That codebase is frozen on `legacy-main` / `legacy-develop`.

This repo's `develop` branch is the **modernization**: a hybrid agent + script architecture. The same git-flow workflows, but split into two layers — prose that an AI agent reads to handle intent, judgment, and the conversation with the user, plus small Python scripts that handle the deterministic mechanics (git operations, state checks, config writes). The user only ever reads what the agent wrote; everything else is plumbing.

The thesis: git-flow is fundamentally a *workflow* — a set of conventions about branches, merges, and tags. The historical bash encoded those conventions in 6k lines of imperative code that no one wanted to read or test. The new shape separates the workflow's *intent and voice* (in prose) from its *mechanics* (in scripts). The prose is small enough to read in one sitting; the scripts are small enough to audit; together they're a fraction of the legacy codebase's size, and the agent layer turns every state — success and failure — into a sentence the user can act on.

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

**Requires:** `python3` on `PATH` (any 3.x). Git, obviously.

## Inside the skill

```
skills/gitflow/
├── SKILL.md          ← what the agent reads and follows (intent, judgment, voice)
├── BACKGROUND.md     ← humans-only: what git-flow is, why this shape
└── scripts/
    ├── feature_start.py   ← mechanics for `feature start`
    └── init.py            ← mechanics for first-time setup
```

The agent loads `SKILL.md`, invokes a script, parses its JSON result, and writes back to the user. Scripts return structured statuses (`ok`, `dirty_tree`, `not_initialized`, `branch_exists`, etc.); the skill maps each one to a sentence in the agent's voice.

## Why not a CLI

A standalone CLI is a likely follow-up (so that non-Claude-Code users can adopt it). But the agent + script split is sharpest when the agent layer is provided — the workflow doesn't need argument parsing, exit codes, or stderr-formatted error messages glued onto it for human consumption. Those re-emerge when the user wants them, but they aren't the design center.

## Legacy

The original bash implementation is preserved untouched on `legacy-main` and `legacy-develop` for anyone still using it. The original gitflow-avh model and Vincent Driessen's original post are the reference for what these workflows mean — this repo doesn't change the model, only how it's expressed.

## Resources

- **Original model:** [A successful Git branching model](http://nvie.com/posts/a-successful-git-branching-model/)
- **Issues:** [github.com/CJ-Systems/gitflow-cjs/issues](https://github.com/CJ-Systems/gitflow-cjs/issues)
- **Discussions:** [github.com/CJ-Systems/gitflow-cjs/discussions](https://github.com/CJ-Systems/gitflow-cjs/discussions)

## License

MIT
