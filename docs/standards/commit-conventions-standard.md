# Commit Conventions Standard

## Domains

universal


## Branch Naming

Branches follow the format: `type/description-in-kebab-case`

| Type | When to Use | Example |
|------|-------------|---------|
| `feat/` | New features, additions | `feat/bus-route-caching` |
| `fix/` | Bug fixes | `fix/null-pointer-decode` |
| `refactor/` | Code restructuring, no behavior change | `refactor/simd-pipeline` |
| `docs/` | Documentation only | `docs/api-usage-guide` |
| `chore/` | Maintenance, tooling, CI | `chore/update-commitlint-config` |
| `experiment/` | Temporary branches for exploration | `experiment/neon-optimization` |

Branch names are kebab-case, short but descriptive (< 50 chars). No issue numbers in branch names (use commit body for references).

## Commit Message Structure

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Subject Line

Required. Max **100 characters** (config-conventional default). Imperative present tense ("add" not "added" or "adds"). No period at end.

```
feat(core): add bus route caching
fix(parser): handle null pointer in decode
refactor: extract common SIMD helpers
```

### Scope

Optional but recommended. The module/area affected. Lowercase, kebab-case.

| Scope | Used In |
|-------|---------|
| `core` | Central logic |
| `ui` | User interface |
| `api` | API endpoints |
| `docs` | Documentation |
| `ci` | CI/CD workflows |
| `config` | Configuration |

Omitting scope is fine for broad changes: `refactor: simplify error handling`.

### Body

Optional. Use when the subject line alone is insufficient. Explain WHAT and WHY, not HOW. Blank line between subject and body. Wrap at 72 characters.

```
feat(core): add bus route caching

Bus arrival data is fetched on every screen load.
Caching responses for 30s reduces API calls by ~80%
and makes the UI feel instant on repeated lookups.
```

### Footer

Optional. References to issues, PRs, or breaking changes.

```
refactor: extract common SIMD helpers

Moved RGB565/RGB555/UYVY shared logic into a common helper
to eliminate code duplication across decoders.

Closes #142
```

### AI Attribution (Committer-Based)

For AI-assisted commits, see [ai-attribution-standard.md](./ai-attribution-standard.md). The AI harness becomes the **committer** with a `.local` email, and the model is recorded in an `Generated-By:` trailer:

```
Author:     B67687 <111849193+B67687@users.noreply.github.com>
Committer:  OhMyOpenAgent <ohmyopenagent@local>

    feat(core): add bus route caching

    Bus arrival data is cached for 30s to reduce API calls.
    
    Generated-By: DeepSeek V4 Flash
```

For human pair-programming, use the standard GitHub `Co-authored-by:` with the person's actual GitHub email. `Co-Authored-By:` is reserved for human collaboration only — never for AI attribution.

### Breaking Changes

Mark with `BREAKING CHANGE:` in the footer or a `!` after the type/scope:

```
feat(api)!: change response format

BREAKING CHANGE: The /arrivals endpoint now returns
ISO 8601 timestamps instead of Unix epoch.
```

## Commit Granularity

- **One concern per commit.** A commit should represent a single logical change.
- **Do NOT mix refactoring with feature work.** A commit that reformats code AND adds logic is two commits.
- **Small commits are better than large ones.** If a change spans multiple files but has a single purpose, it's one commit. If it does two separate things, split it.
- **WIP commits are squashed before merge.** Use `git commit --fixup` for fixups, then `git rebase -i --autosquash`.

## Signed Commits

GPG or SSH signing is **recommended** for all commits. The standard signals that you take code integrity seriously. GitHub shows a green "Verified" badge on signed commits.

```bash
# Enable auto-signing
git config --global commit.gpgsign true

# Or sign per commit
git commit -S -m "feat: add bus route caching"
```

## AI-Assisted Commits

AI-generated commit messages are permitted as long as they:
- Pass commitlint validation (same rules as human-written)
- Are reviewed by a human before committing
- Set the committer to the AI harness with a `.local` email per [ai-attribution-standard.md](./ai-attribution-standard.md)
- Include an `Generated-By:` trailer identifying the model

Recommended tools: `gh copilot suggest -t commit`, `aicommits`, or prompting an AI to format your diff as a conventional commit.

## PR / Merge Conventions

- **Squash merge** for branches with multiple small/fixup commits. Single commit per PR.
- **Rebase merge** when the branch has meaningful individual commits that should be preserved.
- **PR title** follows the same convention as a commit subject: `type(scope): description`.
  Since squash merge uses the PR title as the commit message, PR title quality is critical.

## What Commitlint Enforces

All repos use `.commitlintrc.json` with these allowed types:

```
feat, fix, docs, refactor, perf, test, chore, cleanup, security, revert
```

This is enforced:
- Locally via `commitlint --from HEAD~1` (review.sh stage)
- In CI via `wagoid/commitlint-github-action`

## Type-to-Release Mapping (semantic-release)

Only two types drive version bumps. The rest are for changelog organization:

| Type | Version Bump | Change Type |
|------|-------------|-------------|
| `feat` | MINOR | New feature |
| `fix` | PATCH | Bug fix |
| `perf` | PATCH | Performance improvement |
| `revert` | PATCH | Revert previous change |
| Any with `BREAKING CHANGE` | MAJOR | Breaking change |
| All others | None | Documentation, refactoring, etc. |

## References

- Conventional Commits: https://www.conventionalcommits.org/
- commitlint config: `.commitlintrc.json` (copy from ithmb-codec)
- semantic-release: https://semantic-release.gitbook.io/
- git-cliff: https://git-cliff.github.io/
