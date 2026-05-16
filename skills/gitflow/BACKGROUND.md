# gitflow skill — background

This file is for humans. The agent doesn't load it at runtime — that work happens in `SKILL.md` (the executable spec) and `scripts/*.py` (the mechanics). This file exists so anyone browsing the skill can understand *what* git-flow is, *why* this skill is shaped the way it is, and *how* the pieces fit together.

## What git-flow is, briefly

Git-flow is a convention for managing branches in a git repository. It was published by Vincent Driessen in 2010 and adopted widely. The short version:

- **Production code** lives on a long-lived branch (usually `main` or `master`).
- **Day-to-day development** happens on a parallel long-lived branch called `develop`.
- **New features** are built on short-lived branches that start from `develop`, get merged back into `develop` when ready, and are deleted.
- **Releases** are prepared on short-lived branches that start from `develop`, get merged into both `main` *and* `develop` (with a version tag) when they ship.
- **Hotfixes** are emergency fixes that branch from `main`, get merged back into both `main` and `develop`, and also get a tag.

The historical implementation (`git-flow-avh`, then `gitflow-cjs`) wrapped these flows in bash scripts so people could type `git flow feature start login` instead of remembering all the branch-and-merge steps.

## Why this skill is shaped the way it is

This rewrite keeps the same git-flow workflows but reorganizes the implementation around two ideas:

**Software 3.0 (prose-as-code).** The workflow's *spec* — what counts as starting a feature, what the preconditions are, what to say to the user when something goes wrong — lives as plain English in `SKILL.md`. An AI agent (Claude Code, in the current form) reads that prose and follows it. The historical 6,000-line bash codebase wasn't readable; the prose is, and the prose is what runs.

**Hybrid agent / script split.** The agent handles intent ("I want to start a feature"), judgment (init dialogue, error translation), and voice (everything the user reads). Small Python scripts in `scripts/` handle the deterministic mechanics — running git commands, checking branch state, writing config. The scripts return structured JSON results; the agent translates them into conversation.

This split exists for two reasons. First, it keeps the user experience entirely in the agent's voice — substrate output (from git, from the scripts) is plumbing, never visible to the user. Second, it keeps per-invocation token cost bounded: the agent reads a short SKILL.md, invokes one script, parses one JSON result, and composes a message. The old prose-only approach loaded ~280 lines of SKILL.md and did 7–10 separate git calls; the hybrid does roughly half that.

## How the pieces fit together

```
~/.claude/skills/gitflow/
├── SKILL.md          ← what the agent loads and follows
├── BACKGROUND.md     ← this file (humans only)
└── scripts/
    ├── feature_start.py   ← mechanics for `feature start`
    └── init.py            ← mechanics for first-time setup
```

When a user asks Claude Code to start a feature:

1. Claude Code loads `SKILL.md` (because the user's intent matched the skill's `description`).
2. The agent invokes `scripts/feature_start.py` with the user's args.
3. The script runs all the deterministic git operations silently and emits a single JSON result.
4. The agent reads the JSON, decides what to do (success → confirm; `dirty_tree` → ask the user to commit/stash; `not_initialized` → walk through init by invoking `scripts/init.py` with chosen defaults, then re-run `feature_start.py`; etc.), and writes a user-facing message.
5. The user only ever reads what the agent wrote.

## What's shipped today

Just `feature start` (with inline first-time setup if the project isn't gitflow-configured). The rest of the gitflow workflows — `feature finish/publish/checkout/list`, `release`, `hotfix`, `bugfix`, `support` — will follow the same pattern: one script per workflow under `scripts/`, one table-of-statuses section per workflow in `SKILL.md`.

## The legacy code

The original ~6,000 lines of bash that this repo inherited from `git-flow-avh` are preserved untouched on `legacy-main` and `legacy-develop`. They still work and they're still installable for anyone who prefers them. They're frozen — no new features, no bugfixes — because the new shape supersedes them.
