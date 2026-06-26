# Auto-Commit GitOps Standard

## Purpose

Automate commit metadata so that every commit is **signed**, **attributed**, and **dated correctly** without manual effort.

## Architecture

```
AI Harness (oh-my-openagent, Codex, etc.)
  │
  ├── Sets env vars: AI_COMMIT=1, AI_MODEL, AI_HARNESS
  │
  ▼
git commit
  │
  ├── prepare-commit-msg hook
  │     └── Appends Co-Authored-By: trailer (if AI_COMMIT=1)
  │
  ├── pre-commit hook
  │     └── Verifies committer identity is B67687
  │
  ├── commit-msg hook
  │     └── Validates conventional commit format (opt-in repos)
  │
  ├── commit.gpgsign = true
  │     └── Signs commit with SSH key (G)
  │
  └── pre-push hook
        └── Verifies every pushed commit has valid signature
```

## What's Deployed

### Global Hooks (`~/.config/git/ai-commit-hooks/`)

| Hook | Purpose | Source |
|------|---------|--------|
| `pre-commit` | Identity gate — blocks commits not by B67687 | `dev/standards/scripts/pre-commit` |
| `prepare-commit-msg` | AI attribution — appends `Co-Authored-By:` trailer | `dev/standards/scripts/prepare-commit-msg` |
| `commit-msg` | Conventional commit validation (opt-in repos) | `dev/standards/scripts/commit-msg` |
| `pre-push` | Signature gate — blocks unsigned commits | `dev/standards/scripts/pre-push` |

### Git Aliases

| Alias | Expands To | Purpose |
|-------|-----------|---------|
| `git ca` | `!f() { AI_COMMIT=1 AI_MODEL="${AI_MODEL:-DeepSeek V4 Flash (Max)}" AI_HARNESS="${AI_HARNESS:-oh-my-openagent (Sisyphus)}" GIT_COMMITTER_DATE="$(git log -1 --format=%aD HEAD 2>/dev/null \|\| date)" git commit --amend "$@"; }; f` | Amend with auto-AI-trailer + date preservation |
| `git car` | `!f() { AI_COMMIT=1 AI_MODEL="${AI_MODEL:-DeepSeek V4 Flash (Max)}" AI_HARNESS="${AI_HARNESS:-oh-my-openagent (Sisyphus)}" GIT_COMMITTER_DATE="$(git log -1 --format=%aD HEAD 2>/dev/null \|\| date)" git commit --amend --no-edit "$@"; }; f` | Amend no-edit, AI trailered + date preserved |
| `git rb` | `rebase --committer-date-is-author-date` | Rebase while preserving original commit dates |
| `git ai-commit` | `AI_COMMIT=1 AI_MODEL="${AI_MODEL:-DeepSeek V4 Flash (Max)}" AI_HARNESS="${AI_HARNESS:-oh-my-openagent (Sisyphus)}" git commit` | Quick AI commit with defaults |

### Git Config

| Setting | Value | Why |
|---------|-------|-----|
| `core.hooksPath` | `~/.config/git/ai-commit-hooks` | Centralized hooks directory |
| `commit.gpgsign` | `true` | Auto-sign all commits |
| `user.signingkey` | `~/.ssh/id_ed25519` | SSH key for signing |

## Hook Manager: pre-commit vs Lefthook

Two hook managers are supported. Choose one per repo; do NOT mix both in the same repo.

| Aspect | pre-commit | Lefthook |
|--------|-----------|----------|
| Config file | `.pre-commit-config.yaml` | `lefthook.yml` |
| Execution model | Sequential (hooks run in order) | Parallel by default |
| Hook sources | External repos (git-cloned) | Local shell commands or scripts |
| Install | `pre-commit install` | `lefthook install` |
| Speed | Slower for many hooks | Faster with parallel hooks |
| Best for | Established projects, multi-repo hook sharing | Speed-sensitive repos, custom scripts |

**Recommendation:** Use pre-commit for repos that share hooks across multiple projects (managed centrally). Use lefthook when you want parallel execution or simpler local config. The global AI commit hooks (`~/.config/git/ai-commit-hooks/`) work with either manager — they are git hooks, not manager-specific.

## Environment Variables

AI tools MUST set these environment variables to enable automatic attribution:

| Variable | Example | Required | Description |
|----------|---------|----------|-------------|
| `AI_COMMIT` | `1` | Yes | Must be `1` to trigger the hook |
| `AI_MODEL` | `DeepSeek V4 Flash (Max)` | Yes | Full model name as branded |
| `AI_HARNESS` | `oh-my-openagent (Sisyphus)` | No (falls back to `oh-my-openagent`) | Tool orchestrating the AI |

## Trailer Format

When `AI_COMMIT=1`, the `prepare-commit-msg` hook appends:

```
Co-Authored-By: DeepSeek V4 Flash (Max) via oh-my-openagent (Sisyphus)
  <deepseek-v4-flash-max+oh-my-openagent@models.local>
```

Per [ai-attribution-standard.md](./ai-attribution-standard.md). The `.local` email prevents GitHub graph pollution.

## Committer Date Preservation

The problem: `git commit --amend` and `git rebase` reset committer date to the current time, while author date stays at the original. This creates a discrepancy.

| Operation | How to Preserve | Mechanism |
|-----------|----------------|-----------|
| Fresh `git commit` | Already equal (author date = committer date = now) | No action needed |
| `git commit --amend` | Use `git ca` alias | Alias wraps with `GIT_COMMITTER_DATE` env var |
| `git rebase` | Use `git rb` alias or `git rebase --committer-date-is-author-date` | Built-in git flag |
| `git rebase -i` | Same flag | `--committer-date-is-author-date` works with interactive too |

## Model/Harness Avatar (Proposal)

GitHub doesn't support avatars for non-user accounts. For visual attribution, use README badges per [badge-standard.md](./badge-standard.md):

```html
<img src="docs/badges/deepseek.svg" alt="model: DeepSeek V4 Flash (Max)">
<img src="docs/badges/oh-my-openagent-harness.svg" alt="harness: Oh My OpenAgent">
```

## Deploying to a New Machine

```bash
# One-liner from the standards repo
bash scripts/install-ai-commit-hooks.sh
```

## Lefthook Integration

Prefer [lefthook](https://lefthook.dev/) as the hook runner when available:

1. Install: `brew install lefthook` or `npm install -g lefthook`
2. Add `lefthook.yml` at repo root with commit-msg, pre-commit, pre-push commands
3. Run `lefthook install` to activate hooks

Lefthook is faster than pre-commit (Go binary, no Python dep) and runs hooks in parallel. For repos already using `scripts/hooks/`, the lefthook config can call those same scripts.

## Testing the Setup

```bash
# Test signing:
git commit --allow-empty -n -m "test: verify signing setup"
git show --format="%H %aD %cD %G?" -s
# Expected: G (good signature), aD ≈ cD (dates match)

# Test AI attribution:
AI_COMMIT=1 AI_MODEL="DeepSeek V4 Flash (Max)" AI_HARNESS="oh-my-openagent (Sisyphus)" \
  git commit --allow-empty -n -m "test: verify AI attribution"
git show -s
# Expected: Co-Authored-By trailer present

# Clean up test commits:
git reset --hard HEAD~2
```
