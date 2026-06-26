# Git History Cleanup Standard

## Domains

universal


## When to Use

Clean history when:
- A **secret** was committed (API key, token, password, .env file)
- **Private information** was committed (personal paths, emails, machine names)
- A **file that shouldn't exist** was committed (binary, dependency, agent session)
- A **large file** was committed that bloats the repo

Do NOT use for:
- Removing a file that was only in the latest commit (just `git rm` + amend)
- Renaming files (use `git mv`)
- Changing commit messages (use `git rebase -i` or `git commit --amend`)
- Repos with **public forks** (old history persists in each fork indefinitely; owners must be contacted)
- Repos under **regulatory/audit compliance** (SOX, SOC2 — history alteration may violate record-retention policies)
- When **litigation is pending or reasonably anticipated** (history rewriting may be considered spoliation of evidence)

### Regulatory Caveats

| Regulation | Rewriting Prohibited? | Notes |
|------------|----------------------|-------|
| SOX | No | But destroys audit trail. Avoid for financial systems. |
| PCI-DSS | No | Document exposure as security incident regardless. |
| SOC 2 | No | Will break code-audit controls. Document as control deviation. |
| GDPR | No | May be REQUIRED for PII erasure requests (Article 17). |

When in doubt, **just revoke the credential.** If a regulation applies, consult legal before rewriting.

## Requirements

- **Python 3.6+** — `pip install git-filter-repo`
- **Git 2.22+** (2.24+ recommended)
- A **fresh mirror clone** of the repo (filter-repo refuses to run on a dirty working tree)

## Tool

Use `git filter-repo` — NOT `git filter-branch` (deprecated). If the binary doesn't find the module, invoke via the venv's python.

> ⚠️ **Warning:** History rewriting is **irreversible**. Always create a backup and verify before pushing.

## Workflow

### Step 0: Revoke the compromised credential FIRST
Rotate the exposed secret at the source before any git operation. This is the only action that truly protects you — history cleanup only prevents it from appearing in future clones.

### Step 1: Coordinate with collaborators
Alert collaborators, agree on a freeze window, identify open PRs that will need recreation (force-push invalidates all commit SHAs), and ensure no one has un-pushed work.

### Step 2: Create a fresh mirror clone
Clone with `git clone --mirror` to capture all refs; reflog, stash, and worktrees are excluded intentionally. Create a timestamped backup before filtering.

### Step 2.5: Analyze before filtering
Run `git filter-repo --analyze --force`, then inspect the analysis files. Use `git log --all --oneline -- <path>` to preview what commits reference a target.

### Step 3: Remove the offending content
Use `--path <file> --invert-paths` for a specific file, `--path <dir> --invert-paths` for directories, `--replace-text <file>` for string replacement, `--strip-blobs-bigger-than <N>` for large files, `--refs refs/heads/<branch>` to limit scope, or `--message-callback` for commit message secrets. For secret removal (filter-repo ≥2.47), add `--sensitive-data-removal`.

### Step 3.5: Clean commit messages
`--replace-text` does NOT cover commit messages. Use `--message-callback` with regex to redact secrets from subjects and bodies. Cannot combine with `--path` or `--replace-text` in the same pass.

### Step 4: Prune old objects
Run `git reflog expire --expire=now --all && git gc --aggressive --prune=now` to remove lingering object references.

### Step 5: Verify the result
Confirm the offending file is gone, run `git fsck --full`, and check that author dates are preserved.

### Step 5.1: Assess PR impact
Check `.git/filter-repo/changed-refs` for `refs/pull/` entries to count PRs that will break.

### Step 5.2: Check for orphaned LFS objects
If filter-repo reports orphaned LFS objects, run `git lfs prune --verify-remote`. Remote orphaned LFS objects require a GitHub Support ticket.

### Step 6: Re-add origin and force-push
Re-add the remote and push with `/usr/bin/git push origin --force --all && ... --tags` (git-safe-push blocks bare `--force`).

### Step 6.1: Notify fork owners
List forks with `gh repo list` and contact owners to delete or refresh their fork. Old history persists in each fork independently.

### Step 7: Purge GitHub ecosystem (if secrets were exposed)
Separately purge: GitHub Actions workflow runs, caches, and artifacts; GitHub Releases (delete and recreate); GitHub Pages (trigger a rebuild); and open a GitHub Support ticket for server-side cleanup.

### Step 8: Clean the local working repo
Drop stashes, delete old local tags, force-fetch rewritten tags, then garbage-collect. Verify the local repo is clean.

### Step 9: Notify collaborators
Everyone must re-clone or rebase carefully — a merge from an uncleaned clone recontaminates the remote. Collaborators must use `git rebase --onto origin/main origin/main@{1} feature-branch`. Open PRs, commit statuses, and CI checks are invalidated. Branch protection may need temporary disabling.

## Rollback
Before force-push: delete the mirror clone and restart. After force-push but before re-clones: restore from backup and push with `--force-with-lease`. After re-clones: only if the error is severe enough to justify the disruption.

## Signed & Verified Commits
Signatures on modified commits WILL be stripped — the commit hash changes, invalidating the signature. Use `--refmap` with filter-repo to preserve the original-to-new commit mapping. To restore verification, re-sign all affected commits with `git rebase --exec 'GIT_COMMITTER_DATE="$(git log -1 --format=%aD)" git commit --amend --no-edit -S' --root`. This creates new SHAs requiring another force-push.

## Prevention

The best cleanup is the one you never need. These standards and tools prevent history cleaning:

| Prevention Layer | Tool / Standard | What It Prevents |
|-----------------|-----------------|------------------|
| 1 — Whitelist .gitignore | `docs/standards/gitignore-standard.md` | Secrets, agent sessions, build artifacts from being committed |
| 2 — Pre-commit scanning | Gitleaks / TruffleHog via `.pre-commit-config.yaml` | Secrets caught before commit |
| 3 — Pre-push scanning | Gitleaks / TruffleHog pre-push hook | Secrets caught before push |
| 4 — CI scanning | Gitleaks Action, Dependency Review via `docs/standards/ci-pipeline-standard.md` | Secrets caught on PR |
| 5 — GitHub push protection | GitHub Advanced Security | Secrets blocked at server on push |
| 6 — GitHub secret scanning | GitHub platform | Post-push server-side detection |
| 7 — Periodic full-history audit | Gitleaks `git` / TruffleHog `git` (scheduled) | Proactive discovery of latent secrets |

If the prevention layers work, you should rarely need history cleanup. But defense-in-depth assumes any single layer can fail — this standard exists for when prevention wasn't enough.

## References

- [git filter-repo](https://github.com/newren/git-filter-repo) — the underlying tool (Python 3.6+)
- [GitHub: Removing sensitive data from a repository](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)
- [GitHub: Best practices for preventing data leaks](https://docs.github.com/en/code-security/getting-started/best-practices-for-preventing-data-leaks-in-your-organization)
- [BFG Repo-Cleaner](https://rtyley.github.io/bfg-repo-cleaner/) — alternative for simple basename-only operations (Java)
- [TruffleHog](https://github.com/trufflesecurity/trufflehog) — proactive secret scanning with verified credential detection
- `~/.local/bin/git-safe-push` — safe push wrapper (blocks `--force`, normalizes identity)
