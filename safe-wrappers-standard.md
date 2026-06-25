# Safe Wrappers Standard

## Motivation

AI agents and shell automation invoke git and gh commands generically. Without guardrails, a commit with `--no-verify` can bypass hook enforcement, a `--force` push can rewrite remote history, and an unverified identity can corrupt attribution. Safe wrappers intercept these commands to enforce policy at the shell level.

## Architecture

Safe wrappers are executables in `~/.local/bin/` that shadow the native `git` and `gh` commands (since `~/.local/bin` is early on `PATH`). Each wrapper:

1. Resolves the **real** git binary (skipping `~/.local/bin` to avoid recursion)
2. Applies environment and argument guardrails
3. Normalizes the repo state
4. Executes the real command

## Wrappers

### `git-safe-commit`

Replaces `git commit`. Enforces:

- **No `--no-verify`** — prevents bypassing pre-commit hooks
- **No `--no-gpg-sign`** — prevents bypassing commit signing
- **Identity check** — verifies configured identity against `hooks.allowed-committer-name`/`email` (if set)
- **Forced signing** — always passes `-c commit.gpgsign=true` to the real git

### `git-safe-push`

Replaces `git push`. Enforces:

- **No `--no-verify`** — prevents bypassing pre-push hooks
- **No `--force`** — only `--force-with-lease` is allowed (saher force-push)
- **Identity strip** — unsets `GIT_COMMITTER_*` and `GIT_AUTHOR_*` env vars before push (prevents env-based identity injection)

### `git-safe-normalize`

Scrubs stale local git config overrides that conflict with global identity settings:

- Unsets local `user.name` if it differs from global
- Unsets local `user.email` if it differs from global
- Unsets local `commit.gpgsign = false`
- Unsets local `gpg.format` if it differs from `ssh`
- Reports current author, committer, and branch

### `gh-safe-pr-create`

Simple pass-through wrapper that ensures `gh` is available before calling `gh pr create`.

### `gh-ensure-signed-rules`

Applies "Require verified signed commits" branch protection rulesets to GitHub repositories:

- Enumerates all repos for a given owner (default: authenticated user)
- Skips archived repos
- Skips repos with an existing signed-commit ruleset
- Creates the ruleset via GitHub API (POST /repos/{repo}/rulesets)

## Deployment

Canonical sources live in `scripts/wrappers/` in the standards repo. Run to install:

```bash
bash scripts/deploy-wrappers.sh
```

This copies all wrapper scripts to `~/.local/bin/`, overwriting any previous versions.

## PATH Priority

`~/.local/bin/` must appear early (ideally first) in `PATH` so wrapper scripts shadow native commands:

```bash
export PATH="${HOME}/.local/bin:${PATH}"
```

## Audit Checks

The audit verifies:

1. **All 5 wrapper scripts exist** in `~/.local/bin/`
2. **Each wrapper is executable**
3. **`~/.local/bin` is on PATH** before system bin directories
4. **Canonical sources exist** in `scripts/wrappers/`

## See Also

- [Git Identity Security Standard](git-identity-security-standard.md) — identity enforcement and signing
- `scripts/hooks/pre-commit` — hook-level identity gate
