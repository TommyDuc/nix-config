---
name: generic-commits
description: Split uncommitted changes into small, feature-atomic, one-line Conventional Commits, or `fixup!`/`amend!` commits targeting commits on the current branch, shown as a table for approval before committing. Only adds commits; never pushes, amends or rebases. Use when the user asks to commit or to write commit messages.
disable-model-invocation: true
---

# Atomic Commits

## Hard rules

- **Only add commits.** Never `git push`, `git commit --amend`, `git rebase`, `git reset`, `--force`, or anything that rewrites history.
- Never skip hooks (`--no-verify`).
- Never stage with `git add -A` or `git add .`; always `git add -- <paths>`.
- No empty commits. If there is nothing to commit, say so.
- Avoid merge commits and keep the history linear.
- Keep git's default commit messages whenever possible (e.g. for merge commits).
- `git commit --fixup=<sha>` / `--fixup=amend:<sha>` are allowed: they add commits. Never run `git rebase --autosquash` yourself.

## 1. Gather context

Run in parallel:

- `git status --short`
- `git diff` and `git diff --cached`
- `git diff --stat`
- `git log --oneline -15` -- match the existing type/scope style
- Commits only on the current branch (pushed or not) -- the valid fixup/amend targets. Excludes anything reachable from other local/remote branches, so the base is detected automatically:

  ```sh
  b=$(git branch --show-current)
  u=$(git rev-parse --abbrev-ref '@{upstream}' 2>/dev/null)
  git log --oneline HEAD --not --exclude="$b" --branches --exclude="${u:-$b}" --remotes
  ```

## 2. Security check

Stop and warn the user (do not commit) if the changes contain secrets, credentials, API keys, tokens, `.env`/`.envrc` files, generated/vendored output, or stray build artifacts/binaries.

Only stage lockfiles alongside their corresponding dependency/manifest changes unless the update is intentional.

## 3. Split into commits

- Commits are **small and feature-atomic**: one concern per commit.
- Keep tests (or fixtures/stories) required by a change in the same commit as the change they test.
- **Prefer reviewability over compilation.** Each commit compiling and passing tests is encouraged but not mandatory.
- If a single file mixes unrelated concerns, split it by hunks: write a partial patch and stage it with `git apply --cached <patch>` (`git add -p` is interactive and unavailable). Ask the user when the split is ambiguous.

## 3b. Fixup / amend

For each atomic change, check whether it belongs to a commit on the current branch (the step 1 command with `-- <path>` appended). If it has the same concern and scope, attach it to that commit instead of creating a new one:

- `fixup!`: the change corrects or completes the target, and the target's message is still accurate. `git commit --fixup=<sha>`
- `amend!`: the change makes the target's message inaccurate, or only the message is wrong. `git commit --fixup=amend:<sha> -m "<new message>"`

Fixup/amend commits must be squashable later with `git rebase --autosquash`. Best effort, no verification: only pick a target when no later commit in `<target>..HEAD` touches the same lines, and never target a merge commit or another `fixup!`/`amend!`. When in doubt, or when several targets fit, make a normal commit or ask.

## 4. Order

Commits are created in this order (first to last):

1. Anything else
2. Generic project changes (config, tooling, docs, AGENTS/skills, deps, CI)
3. Foundational / data layer (schemas, migrations, types, core utilities)
4. Core logic / domain layer (business logic, use cases, services, packages)
5. Interface / integration layer (API/transport handlers, hooks, adapters)
6. Surface / entrypoints (UI components, CLI/app entrypoints, wiring)

Secondary priority: dependencies before dependants.

Tertiary priority: highest chance of being accepted without changes in code review first, down to lowest, so later commits are easier to fixup and rebase.

## 5. Commit message

**One line only. No body.**

Format: `<type>[(scope)][!]: <subject>`

| Type       | When to use                                 |
| ---------- | ------------------------------------------- |
| `feat`     | New feature or capability                   |
| `fix`      | Bug fix                                     |
| `refactor` | Restructuring without behavior change       |
| `chore`    | Maintenance, config, tooling                |
| `docs`     | Documentation only                          |
| `style`    | Formatting only                             |
| `test`     | Adding or updating tests                    |
| `ci`       | CI/CD pipeline changes                      |
| `perf`     | Performance improvement                     |
| `build`    | Build system or external dependency changes |

Derive scopes from the repository's existing `git log` style (e.g. feature, module, or package name, or common tooling scopes like `config`, `docs`, `deps`, `ci`, `skills`). Omit the scope when none fits or the repository doesn't use scopes.

Subject rules:

- Imperative mood ("add", "fix", "remove")
- Lowercase after the colon, no trailing period
- 72 characters max for the whole line
- Breaking change: `!` after type/scope

`fixup!` subjects are generated by git; never edit them, or autosquash will not match the target. The `amend!` replacement message follows every rule above.

## 6. Present the table, then stop

Before committing anything, show a table in commit order and wait for approval:

| #   | Content (files and/or lines) | Commit message | Target | Why it is its own commit (or why it belongs to the target) |
| --- | ---------------------------- | -------------- | ------ | ---------------------------------------------------------- |

`Target` is the short SHA and subject of the fixup/amend target, or `-` for a normal commit.

## 7. Commit

After approval, for each row in order:

```sh
git add -- <paths> && git commit -m "<message>"
git add -- <paths> && git commit --fixup=<sha>
git add -- <paths> && git commit --fixup=amend:<sha> -m "<message>"
```

## 8. Verify

Run `git status --short` and `git log --oneline -<N>` and show the result.

If fixup/amend commits were created, tell the user they can squash them with `git rebase -i --autosquash <base>`; do not run it.
