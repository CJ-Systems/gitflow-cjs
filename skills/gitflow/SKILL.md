---
name: gitflow
description: Run Vincent Driessen's git-flow branching model — start feature branches, and (later) finish them, cut releases, and ship hotfixes. Trigger when the user asks to "start a feature," "create a gitflow branch," "kick off feature X," or otherwise wants gitflow workflow operations on a git repository.
---

# gitflow

This is the **gitflow skill**. When someone asks Claude Code to start a feature branch in a git project, this file is what Claude reads to figure out what to do. Everything that happens — the checks, the git commands, the messages back to the user — is described below in plain English.

If you're a person reading this out of curiosity (rather than an AI executing it): welcome. You're looking at the source code. There's no compiled binary behind this document, no bash script doing the real work. The prose you're reading *is* the implementation. That's the central idea: a workflow that used to take six thousand lines of shell scripts is now a few hundred lines of explanation, and the explanation is what runs.

## What git-flow is, briefly

Git-flow is a convention for managing branches in a git repository. It was published by Vincent Driessen in 2010 and adopted widely. The short version:

- **Production code** lives on a long-lived branch (usually `main` or `master`).
- **Day-to-day development** happens on a parallel long-lived branch called `develop`.
- **New features** are built on short-lived branches that start from `develop`, get merged back into `develop` when ready, and are deleted.
- **Releases** are prepared on short-lived branches that start from `develop`, get merged into both `main` *and* `develop` (with a version tag) when they ship.
- **Hotfixes** are emergency fixes that branch from `main`, get merged back into both `main` and `develop`, and also get a tag.

The historical implementation (`git-flow-avh`, then `gitflow-cjs`) wrapped these flows in bash scripts so people could type `git flow feature start login` instead of remembering all the branch-and-merge steps. This rewrite keeps the same flows but moves the implementation into prose that an AI agent reads and executes — letting the agent handle intent ("I want to start work on the login redesign"), validation ("is your working tree clean?"), and conversation ("local develop is behind origin — fetch first?") while git does the mechanical work.

## What's available so far

- **`feature start`** — create a new feature branch from develop (or another base). Includes inline first-time setup for repos that haven't been gitflow-configured yet.

What's not built yet, but coming: `feature finish`, `feature publish`, `feature checkout`, `feature list`, and the full release / hotfix / bugfix / support flows. If a user asks for one of these, say so plainly and don't improvise — the workflows have subtleties that matter.

## When this skill runs

Claude reads this file when a user's intent matches one of these shapes:

- "start a feature called X" / "start a new feature for X"
- "create a gitflow feature branch"
- "I want to begin work on the search rewrite" (or similar — read for intent, not exact wording)
- The literal command `git flow feature start X` — treat that as intent, not as a shell instruction to forward

If the user clearly wants a different gitflow operation (`feature finish`, `release start`, etc.), see "What's available so far" above — explain plainly that it isn't shipped yet.

## Things to check before doing anything

Three preconditions. Each one protects against a specific failure mode, and each maps to a single git command that confirms or denies it.

### 1. The user is inside a project

Git-flow only makes sense inside a project that uses git for version control. If we're not in one, there's nothing to start.

```
git rev-parse --is-inside-work-tree
```

If that prints anything other than `true`, stop. Tell the user something like: "I don't see a project here — try `cd`-ing into your project folder first." Don't quote git's raw error message at them.

### 2. The user has no unsaved work

If there are changes that haven't been committed yet, switching branches could lose work or create confusing merges. We refuse to proceed.

```
git status --porcelain
```

If that produces any output, there's unsaved work. Read the output to learn *which* files have changes, and tell the user concretely: "You have unsaved changes in `src/auth.ts` and `README.md` — commit them or set them aside (`git stash`) first, then I'll start the feature." Naming the files matters; "you have changes" without telling them where is useless feedback.

### 3. Gitflow has been initialized in this repo

Git-flow uses a few git-config keys to remember which branch is production, which is develop, and what prefix to use for feature branches. Until those keys exist, we can't start a feature.

```
git config --get gitflow.prefix.feature
```

If this returns nothing (non-zero exit), the repo hasn't been set up for gitflow yet. Don't bail — the user clearly wants to use gitflow, so we'll do the setup inline. See the next section.

## First-time setup (when gitflow isn't initialized)

The setup is conversational, not a dialog box. Tell the user something like:

> This project isn't set up for gitflow yet — I'll configure it. I'll use the standard defaults unless you'd rather pick something else.

Then list what you're about to write (see "Defaults" below). Accept overrides if the user offers them. Otherwise proceed.

### Defaults

These are the historical git-flow-avh defaults and are what most projects use. Each is a key written into the user's git config.

| What it controls          | Git config key                  | Default value |
| ------------------------- | ------------------------------- | ------------- |
| Production branch name    | `gitflow.branch.master`         | `main`        |
| Development branch name   | `gitflow.branch.develop`        | `develop`     |
| Feature branch prefix     | `gitflow.prefix.feature`        | `feature/`    |
| Bugfix branch prefix      | `gitflow.prefix.bugfix`         | `bugfix/`     |
| Release branch prefix     | `gitflow.prefix.release`        | `release/`    |
| Hotfix branch prefix      | `gitflow.prefix.hotfix`         | `hotfix/`     |
| Support branch prefix     | `gitflow.prefix.support`        | `support/`    |
| Version tag prefix        | `gitflow.prefix.versiontag`     | *(none)*      |

### One thing to detect rather than assume

Different repos use different names for the production branch. Repos created in the last few years usually use `main`; older repos use `master`. Check which one actually exists before defaulting:

```
git rev-parse --verify main
git rev-parse --verify master
```

Default to the one that exists. If both exist, ask the user which one is the production branch — don't guess. If neither exists, something unusual is going on and the user should clarify.

### If `develop` doesn't exist, create it

The development branch needs to exist before features can branch from it. If `git rev-parse --verify develop` fails, create it from the production branch:

```
git branch develop <production-branch>
```

Tell the user you did this — it's not a silent side effect.

### Writing the config

For each setting, run:

```
git config <key> <value>
```

When all keys are written, give the user a one-line confirmation:

> Gitflow initialized — production: main, develop: develop, feature prefix: feature/.

Then proceed to whatever they originally asked for.

## The `feature start` workflow

When the user wants to start a feature, here's what happens.

### What the command looks like

The user might phrase it however they like, but it maps to:

- `feature start <name>` — start a feature from `develop`
- `feature start <name> <base>` — start it from `<base>` instead
- Either form might include `--fetch` (or `-F`) to pull from origin first

### Step 1: Figure out the names

Pull these from git config and the user's arguments:

- **feature_prefix** ← `git config --get gitflow.prefix.feature` (typically `feature/`)
- **develop_branch** ← `git config --get gitflow.branch.develop` (typically `develop`)
- **name** ← the user's argument. If missing, just ask: "What do you want to call the feature?"
- **base** ← the user's second argument, or `develop_branch` if they didn't give one
- **branch** ← `feature_prefix + name` (e.g. `feature/login-redesign`)

Two small hygiene checks:

- If the user typed the prefix themselves (e.g. `feature start feature/foo`), strip it so we don't end up with `feature/feature/foo`.
- If the name contains spaces or shell-unfriendly characters, warn the user and suggest a clean slug. Don't silently mangle their input.

### Step 2: Confirm the base branch actually exists

We can't branch from a branch that isn't there.

```
git rev-parse --verify --quiet refs/heads/<base>
```

If this fails, tell the user the base branch is missing. If the missing branch is `develop` specifically, that means gitflow init didn't fully complete — offer to fix it.

### Step 3: Confirm the new branch doesn't already exist

If the user already has a `feature/login-redesign` branch, we don't want to clobber it.

```
git rev-parse --verify --quiet refs/heads/<branch>
```

If this **succeeds**, the branch already exists. Stop and tell the user concretely. Once `feature checkout` ships, offer to switch to the existing branch instead; for now, suggest `git checkout <branch>`.

### Step 4: If the user asked, fetch first

If they passed `--fetch` or `-F`:

```
git fetch origin <base>
```

If the fetch fails (no network, auth issue, etc.), tell the user plainly — don't pretend it worked. Don't proceed.

### Step 5: Check that local base isn't out of date

If a remote-tracking version of the base branch exists (`origin/<base>`), make sure the user's local copy matches it. Branching off a stale base is a real footgun — work gets done on top of old commits, and the eventual merge gets messy.

First check whether the remote-tracking branch exists:

```
git rev-parse --verify --quiet refs/remotes/origin/<base>
```

If it does, compare local against origin:

```
git rev-list --left-right --count <base>...origin/<base>
```

This prints two numbers: how many changes local is ahead, and how many it's behind, relative to origin. If local is behind, **don't proceed silently**. Tell the user:

> Your local `develop` branch is 3 changes behind the version on origin. Add `--fetch` and I'll pull the latest, or run `git pull` yourself and retry.

If local is *ahead* of origin, that's usually fine — the user just hasn't pushed their work yet. Mention it so they know, then continue.

### Step 6: Create the branch

```
git checkout -b <branch> <base>
```

This both creates the new branch and switches the user onto it.

### Step 7: Remember where this branch came from

When the user eventually finishes the feature, the finish workflow needs to know which branch to merge back into. Record it in git config:

```
git config gitflow.branch.<branch>.base <base>
```

This is required even though `feature finish` isn't shipped yet — both the future prose version and the legacy bash scripts read this key.

### Step 8: Tell the user what happened

Keep the message informative and short. Something like:

> Created `feature/login-redesign` from `develop`. You're on it now — start working. When you're done, you'll run `feature finish login-redesign` (not shipped yet — for now, merge it back into `develop` manually with `git merge --no-ff`).

If first-time setup also happened in this same flow, mention that in the same summary so the user has a complete picture of what changed.

## How to talk to the user when things go wrong

The historical bash printed git's raw error messages and exited with a numeric code. This rewrite does not. Every error path produces a sentence the user can act on, in your voice — not git's.

Four principles:

1. **Don't quote `fatal: ...` lines.** Translate them. "fatal: not a git repository" becomes "I don't see a project here — try `cd`-ing into your project folder."
2. **Prefer the words the user thinks in.** "Working tree dirty" is jargon. "You have unsaved changes in `src/auth.ts`" lands. Use the natural word unless precision genuinely requires the technical one.
3. **Name the specific files and branches.** Vague messages are dead-ends; concrete ones are actionable.
4. **Always suggest the next move.** Every error message includes either a remedy or a question. Never a dead-end.
5. **Stay terse.** Two sentences max for an error. Calm and direct, not chatty.

## Things this skill won't do

- **Invent commands.** If the user asks for `feature finish`, `release start`, or anything else not in the "What's available so far" list, say so plainly. Don't improvise — these workflows have subtleties (rebasing, version tags, merging into multiple branches) that are easy to get subtly wrong.
- **Run destructive operations.** No force-push, no `branch -D`, no `reset --hard` as part of `feature start`. None of them are needed for the workflows here.
- **Push to remote.** Unless the user explicitly asks, we stay local.
- **Skip the precondition checks** because "the user seems to know what they're doing." The checks are cheap. The failure mode without them — stale base, lost work, surprising merge — is expensive.

## Where this is headed

When the rest of the workflows arrive, they'll live as additional sections in this file (or in sibling files under `skills/gitflow/`), following the same shape: what the user might ask for, things to check, step-by-step, how to talk to the user. The first-time-setup section and the error-handling principles are shared across all of them.

The non-feature workflows (release, hotfix, bugfix, support) are larger — each needs its own section — but the architectural pattern is identical: prose for intent and validation, git for mechanical operations, the agent's voice for the conversation in between.
