---
name: gitflow
description: Run Vincent Driessen's git-flow branching model — start feature branches, and (later) finish them, cut releases, and ship hotfixes. Trigger when the user asks to "start a feature," "create a gitflow branch," "kick off feature X," or otherwise wants gitflow workflow operations on a git repository.
---

# gitflow

This is the gitflow skill. When a user wants to run a gitflow operation on their project, this file tells you how to invoke the workflow scripts in `scripts/` and how to translate their results into user-facing voice.

**The hybrid pattern:**
- *You* (the agent) own intent parsing, judgment calls (init dialogue, error handling), and voice — every sentence the user reads, you wrote.
- *The scripts* in `scripts/` own deterministic mechanics. They run git operations silently and return a single JSON object on stdout describing what happened.
- The user sees only your voice. Script JSON and git output are your INPUTS, never the user's output.

(For background on what git-flow is and why this skill is shaped this way, see `BACKGROUND.md` in this folder — but you don't need to load it to do the work.)

## What's available so far

- **`feature start`** — create a new feature branch (with inline first-time setup if the project isn't gitflow-configured)

Not yet shipped: `feature finish`, `feature publish`, `feature checkout`, `feature list`, plus release/hotfix/bugfix/support workflows. If the user asks for any of these, say so plainly — don't improvise.

## When this skill runs

Read for intent, not exact wording. Examples that match:

- "start a feature called X"
- "I want to begin work on the search rewrite"
- "create a gitflow feature branch"
- The literal command `git flow feature start X` (treat as intent, not as a shell instruction to forward)

## Operating principle — agent voice is the only UX surface

Every sentence the user reads in the conversation, you wrote. Script output and git output never reach the user raw — capture them, parse them, translate. If a tool call returns text and you don't immediately compose a user-facing message from it, you have a leak.

Two specific rules:
- **Don't echo script JSON.** Parse it and speak about it.
- **Don't run git commands the scripts already cover.** If you find yourself running `git status` or `git diff` to "investigate," step back — the script captured that state already, and ad-hoc git calls leak substrate output.

## `feature start` — invocation

```
python3 ~/.claude/skills/gitflow/scripts/feature_start.py <name> [--base BASE] [--fetch]
```

Run from the user's project directory (the script inherits your cwd). Capture stdout; it will be exactly one line of JSON.

### Result statuses

| Status            | What it means                                       | What to do                                                                                                                                                                                                |
| ----------------- | --------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ok`              | Branch created. JSON includes `branch`, `base`.     | Tell the user: created `<branch>` from `<base>`, they're on it now, start working. Mention that `feature finish` isn't shipped — for now `git merge --no-ff` into `<base>` manually.                      |
| `not_in_repo`     | User isn't inside a git project.                    | "I don't see a project here — try `cd`-ing into your project folder first."                                                                                                                               |
| `dirty_tree`      | Unsaved changes. JSON includes `files`.             | Name the files: "You have unsaved changes in `<files>` — commit them or set them aside (`git stash`) first, then I'll start the feature." Stop. Don't auto-fix; let the user decide.                     |
| `not_initialized` | Gitflow config missing. JSON includes `has_main`, `has_master`, `has_develop`. | Walk the user through init (see below), then re-invoke `feature_start.py`.                                                                                |
| `base_missing`    | Base branch doesn't exist. JSON includes `base`.    | "The base branch `<base>` doesn't exist." If `<base>` is `develop`, offer to repair init.                                                                                                                 |
| `branch_exists`   | Branch already exists. JSON includes `branch`.      | "`<branch>` already exists. Want to switch to it? (`git checkout <branch>`)" — once `feature checkout` ships, route to that instead.                                                                      |
| `behind_origin`   | Local base is stale. JSON includes `base`, `behind`. | "Your local `<base>` is `<behind>` changes behind origin. Add `--fetch` and I'll pull the latest, or run `git pull` yourself and retry."                                                                  |
| `fetch_failed`    | `--fetch` was passed; fetch failed. `error_detail`. | Look at `error_detail` for clues (network? auth?) and translate into plain language. Don't quote the raw error.                                                                                           |
| `unknown_error`   | Unexpected git error. `error_detail`.               | Translate `error_detail` into the user's language; suggest retry or escalate.                                                                                                                             |

## Init dialogue (when `feature_start.py` returns `not_initialized`)

The script returns `has_main`, `has_master`, `has_develop` flags. Use them to pick defaults intelligently:

- **Production branch:** if only `has_main`, default to `main`. If only `has_master`, default to `master`. If both, ask the user which one is production. If neither, something's unusual — clarify before continuing.
- **Develop:** default to `develop` (the init script will create it from production if missing).
- **Prefixes:** the historical standard — `feature/`, `bugfix/`, `release/`, `hotfix/`, `support/`, empty string for version tag.

Tell the user what you're about to set up in one sentence:

> This project isn't set up for gitflow yet — I'll configure it with production: `<prod>`, develop: `develop`, feature prefix: `feature/`. Say so if you want different values.

If they accept (or stay quiet), invoke:

```
python3 ~/.claude/skills/gitflow/scripts/init.py \
  --production <prod> --develop develop \
  --feature-prefix feature/ --bugfix-prefix bugfix/ \
  --release-prefix release/ --hotfix-prefix hotfix/ \
  --support-prefix support/ --version-tag-prefix ""
```

### Init script result statuses

| Status                   | What it means                                | What to do                                                                                       |
| ------------------------ | -------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| `ok`                     | Config written. JSON includes `production`, `develop`, `develop_created`, `feature_prefix`. | One-line confirmation; if `develop_created` is true, mention you created develop from production. Then re-invoke `feature_start.py`. |
| `not_in_repo`            | Caller isn't in a git project.               | Same as for `feature_start.py`.                                                                  |
| `production_missing`     | Specified production branch doesn't exist.   | "I can't find a `<production>` branch in this project. Which branch holds your production code?" |
| `develop_create_failed`  | Couldn't create develop from production.     | Translate `error_detail`; suggest the user check branch permissions or state.                    |
| `unknown_error`          | Unexpected git error.                        | Translate `error_detail`.                                                                        |

After init succeeds, re-run `feature_start.py` with the original args to actually start the feature. The user's final message should cover both: "Set up gitflow for this project. Created `feature/<name>` from `develop` — start working."

## How to talk to the user when things go wrong

Same principles regardless of where the failure came from (script, git, your own logic):

1. **Don't quote raw JSON or git output.** Translate.
2. **Prefer the words the user thinks in.** "Project" over "git repository." "Unsaved changes" over "uncommitted changes." Workflow vocabulary the user opted into (`branch`, `merge`, `develop`, `feature/`) stays.
3. **Name files and branches.** Concrete beats vague.
4. **Always suggest the next move.** Every message has a remedy or a question — never a dead-end.
5. **Stay terse.** Two sentences max for an error. Calm and direct.

## Things this skill won't do

- **Invent commands.** If the user asks for `feature finish`, `release start`, or anything else not in "What's available so far," say so plainly. Don't improvise — these workflows have subtleties (rebasing, version tags, merging into multiple branches) that are easy to get subtly wrong.
- **Modify the user's files or git history on their behalf.** Don't run `git add`, `git commit`, `git stash`, `git reset`, etc. as a "fix" for a precondition. Stop. Tell the user. Wait for them to act.
- **Push to remote.** Unless the user explicitly asks.
- **Run ad-hoc git inspection commands** (`git status`, `git diff`, `git log`) that the scripts already cover. They leak substrate output and duplicate work the script just did.

## Where this is headed

Each new workflow gets its own script in `scripts/` and its own table-of-statuses section in this file. The pattern stays identical: script returns JSON, agent translates to voice, user reads the agent.
