# Git History Cleanup Standard

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

When in doubt, **just revoke the credential.** History rewriting is cosmetic — the real protection is rotating the exposed secret. If a regulation applies, consult legal before rewriting.

## Requirements

- **Python 3.6+** — `pip install git-filter-repo`
- **Git 2.22+** (2.24+ recommended)
- A **fresh mirror clone** of the repo (filter-repo refuses to run on a dirty working tree)

## Tool

Use `git filter-repo` via the venv where it's installed:

```bash
# Find the venv path
pip show git-filter-repo | grep Location
# → Location: /path/to/.venv/lib/python3.xx/site-packages

# Run filter-repo through that venv's python
/path/to/.venv/bin/python3 -m git_filter_repo [args]
```

Do NOT use `git filter-branch` (deprecated).

If the `git filter-repo` binary at `~/.local/bin/git-filter-repo` doesn't find the module, use the venv invocation above instead.

> ⚠️ **Warning:** History rewriting is **irreversible**. Once a force-push is accepted, the old commits are unrecoverable from the remote. Always create a backup and verify before pushing.

## Workflow

### Step 0: Revoke the compromised credential FIRST

Before ANY git operation: **rotate the exposed secret at the source.** Change the API key, revoke the token, reset the password. History rewriting does NOT revoke a credential — it only prevents it from appearing in future clones. Anyone who already has a copy (collaborators, CI logs, forks) still sees it.

**This is the only action that truly protects you.** History cleanup is cosmetic.

### Step 1: Coordinate with collaborators

Before force-pushing:
- Alert all collaborators that a history rewrite is happening
- Agree on a freeze window — no one pushes during the operation
- Identify open PRs that will need recreation (force-push invalidates all commit SHAs)
- Ensure no one has un-pushed work

### Step 2: Create a fresh mirror clone

```bash
git clone --mirror git@github.com:B67687/REPO.git /tmp/REPO-clean
cd /tmp/REPO-clean
```

`--mirror` clones all branches, tags, notes, and replace refs. The local reflog, stash, and worktrees are NOT cloned — this is intentional, as they would retain old object references.

**Create a backup before filtering:**
```bash
cp -a /tmp/REPO-clean /tmp/REPO-clean-backup-$(date +%s)
```

### Step 2.5: Analyze before filtering

Preview what exists before deciding what to remove:

```bash
# Generate analysis report
git filter-repo --analyze --force
# View results
less .git/filter-repo/analysis/path-all-sizes.txt  # large files
less .git/filter-repo/analysis/path-all.txt         # all paths ever
less .git/filter-repo/analysis/extensions-all.txt   # by file extension

# Preview what commits reference a path
git log --all --oneline -- config/secrets.json | wc -l
# Preview size impact
git rev-list --all --objects -- config/secrets.json \
  | git cat-file --batch-check='%(objectsize:disk)' \
  | paste -sd+ | bc
```

### Step 3: Remove the offending content

**Strategy decision tree:**

| Scenario | Recommended Flag |
|----------|-----------------|
| Single known file | `--path <file> --invert-paths` |
| Directory of secrets | `--path <dir> --invert-paths` |
| Specific string in any file | `--replace-text <file>` |
| Large file bloat | `--strip-blobs-bigger-than <N>` |
| Only one branch tainted | Add `--refs refs/heads/<branch>` |
| Commit message contains secret | Use `--message-callback` (see Step 3.5) |
| Secret removal (filter-repo ≥2.47) | Add `--sensitive-data-removal` for extra safety checks |

**Remove a specific file from all history:**
```bash
git filter-repo --path config/secrets.json --invert-paths --force
```

**Remove a directory from all history:**
```bash
git filter-repo --path .env --invert-paths --force
```

Note: `--path .env` (no trailing slash) matches both files AND directories named `.env`.

**Remove multiple files:**
```bash
git filter-repo \
  --path .env \
  --path config/credentials.json \
  --path '**/secrets*' \
  --invert-paths --force
```

**Remove a specific string from all files:**
```bash
echo "AKIAIOSFODNN7EXAMPLE" > /tmp/secrets.txt
git filter-repo --replace-text /tmp/secrets.txt --force
```

For multiple secrets, add one per line to the text file.

**Remove large files (over 10MB):**
```bash
git filter-repo --strip-blobs-bigger-than 10M --force
```

**Limit scope to specific branches (recommended for large repos):**
```bash
git filter-repo --refs refs/heads/main --path .env --invert-paths --force
```

**For secret removal (filter-repo ≥2.47 recommended):**
```bash
git filter-repo --sensitive-data-removal --path .env --invert-paths --force
```

### Step 3.5: Clean commit messages

#### Remove secrets from commit messages

`--replace-text` only covers file content, NOT commit messages. If a secret was pasted into a commit subject or body, use `--message-callback` with regex:

```bash
git filter-repo --force --message-callback '
import re
msg = message.decode("utf-8")
msg = re.sub(r"sk-[a-zA-Z0-9]{20,50}", "[REDACTED API KEY]", msg)
msg = re.sub(r"AKIA[0-9A-Z]{16}", "[REDACTED AWS KEY]", msg)
return msg.encode("utf-8")
'
```

#### Remove evidence of cleaning

After removing files, commit messages that reference the removed content are still evidence of the cleanup:

```bash
git filter-repo --force --message-callback '
import re
message = message.decode("utf-8")
message = re.sub(r"\(never pushed to GitHub\)", "", message)
message = re.sub(r"\(local CI on MiniPC\)", "", message)
message = re.sub(r" from all history", "", message)
return message.encode("utf-8")
'
```

This removes phrases like "(never pushed to GitHub)" and "from all history" from all commit messages, making it look like the files never existed.

**For a more thorough approach**, reword entire cleanup commits:

```bash
git filter-repo --force --message-callback '
message = message.decode("utf-8")
message = message.replace("chore: remove", "chore: update")
message = message.replace("chore: move", "chore: update")
return message.encode("utf-8")
'
```

> ⚠️ `--message-callback` cannot be combined with `--path` or `--replace-text` in the same pass. Batch multiple message patterns in one callback, or run separate passes.

### Step 4: Prune old objects

```bash
git reflog expire --expire=now --all
git gc --aggressive --prune=now
```

This removes lingering object references from the mirror clone's own reflog and packs the remaining objects.

### Step 5: Verify the result

```bash
# Check that the offending file is gone from all branches
git log --all --oneline -- config/secrets.json | grep -q . && echo "STILL EXISTS" || echo "CLEAN"

# Check that the secret string is gone
git log --all -p | grep -c "AKIAIOSFODNN7EXAMPLE"
# Should return 0

# Check author dates are preserved
git log --format="%H %ai %cI" | head -5

# Check repo integrity
git fsck --full

# Check object count reduction
git count-objects -v
```

### Step 5.1: Assess PR impact

Before pushing, check how many PRs will be affected:

```bash
grep -c '^refs/pull/.*/head$' .git/filter-repo/changed-refs
# Output: number of PRs that will break
```

### Step 5.2: Check for orphaned LFS objects

If the repo uses Git LFS, filter-repo may have orphaned LFS objects:

```bash
# Check filter-repo output for: "NOTE: There were LFS Objects Orphaned"
# If so, run local cleanup:
git lfs prune --verify-remote

# Verify LFS is clean
git lfs ls-files --all | wc -l
```

Orphaned LFS objects on the remote server require a GitHub Support ticket to purge.

### Step 6: Re-add origin and force-push

Filter-repo removes the `origin` remote. Re-add it:

```bash
git remote add origin git@github.com:B67687/REPO.git
```

For history cleanup on a dedicated mirror clone, force push with the raw git binary:

```bash
/usr/bin/git push origin --force --all
/usr/bin/git push origin --force --tags
```

Note: `git-safe-push` blocks bare `--force` — use `/usr/bin/git push` directly for this operation.

### Step 6.1: Notify fork owners

Forks retain old history independently after force-push. Uses of the sensitive data persist in every fork:

```bash
# List forks (GitHub CLI)
gh repo list B67687/REPO --json name,owner --fork
```

Contact fork owners and ask them to delete or refresh their fork. If the repo has public forks, expect the cleanup to be incomplete — old data will persist in each fork indefinitely.

### Step 7: Purge GitHub ecosystem (if secrets were exposed)

History cleanup only removes data from git history. GitHub stores data in multiple places outside git — each must be cleaned separately.

#### 7.1 GitHub Actions

Workflow runs, logs, caches, and artifacts may contain copies of the secret:

```bash
# List and delete recent workflow runs (GitHub CLI)
gh run list --limit 50 --json databaseId --jq '.[].databaseId' | xargs -I{} gh run delete {}

# Delete all caches
gh actions-cache list --limit 100 | cut -f 1 | xargs -I{} gh actions-cache delete {}

# Or use the API directly for more control
# DELETE /repos/{owner}/{repo}/actions/caches
```

#### 7.2 GitHub Releases

Release binaries are stored separately from git history. If a release binary contains embedded secrets:

```bash
# Delete a release and its assets
gh release delete <tag> --yes --cleanup-tag
# Recreate the release from the cleaned history
gh release create <tag> --generate-notes
```

Note: GitHub's auto-generated source archives (tarballs/ZIPs for each tag) will reflect the rewritten history automatically after force-push. Only manually uploaded assets need manual cleanup.

#### 7.3 GitHub Pages

If the secret was in documentation deployed to GitHub Pages, the live site still serves the old content:

```bash
# Trigger a Pages rebuild via API
curl -X POST -H "Authorization: Bearer $GH_TOKEN" \
  https://api.github.com/repos/OWNER/REPO/pages/builds
```

Verify the live site no longer contains the secret after rebuild.

#### 7.4 GitHub Support ticket

After the above steps, contact **GitHub Support** for server-side cleanup:

- Cache invalidation for affected commit SHAs
- Removal of cached commit data from CDN and API endpoints
- Server-side garbage collection (prunes unreferenced objects)
- Purging orphaned LFS objects (if LFS was affected)

Include in the ticket:
- Owner/repo name
- Number of affected PRs (from Step 5.1)
- First Changed Commits (from filter-repo output)
- Whether LFS Objects Orphaned appeared

Open a ticket at: https://support.github.com/

### Step 8: Clean the local working repo

After force-pushing, the local repo still has old objects cached. Clean it:

```bash
cd ~/projects/dev/REPO
git stash drop              # drop any stash referencing old history
git tag -d <old-tag>        # delete old local tags
git fetch origin --tags --force  # fetch rewritten tags
git reflog expire --expire=now --all
git gc --aggressive --prune=now
```

Verify the local repo is clean:

```bash
git log --all --oneline -- review.sh | grep -q . && echo "DIRTY" || echo "CLEAN"
```

### Step 9: Notify collaborators

After force-pushing:

- Everyone must **re-clone** or rebase carefully. Existing clones have the old tainted history.
- **Rebase, never merge.** A single `git pull` + `git push` from an uncleaned clone will recontaminate the remote with all the old history. Collaborators with branches must use:
  ```bash
  git rebase --onto origin/main origin/main@{1} feature-branch
  ```
- Open PRs found in Step 5.1 must be recreated from scratch (commit SHAs changed).
- GitHub issue references to specific commit SHAs may break.
- All commit statuses and CI checks are invalidated (rewritten commits = new SHAs).
- Branch protection rules may need to be temporarily disabled to force-push.
- GitHub forks still retain the old history — rewriting does NOT affect forks.

## Rollback

If the filter operation produces unexpected results:

**Before force-push:** Simply delete the mirror clone and start over from the remote (original history is intact).

**After force-push but before others re-clone:** Restore from the backup:
```bash
rm -rf /tmp/REPO-clean
mv /tmp/REPO-clean-backup-<timestamp> /tmp/REPO-clean
cd /tmp/REPO-clean
# The backup still has origin configured (filter-repo hasn't removed it yet)
git push origin --force-with-lease --all
git push origin --force-with-lease --tags
```

**After force-push and others have re-cloned:** Rollback is destructive — everyone would need to re-clone again. Only do this if the error is severe enough to justify the disruption.

## Performance Notes

- Filter-repo loads all matching commits into memory. For repos with 100K+ commits, this can require multiple GB of RAM.
- The mirror clone + filter-repo internal clone requires 2-3× the repo size in free disk space.
- Use `--refs` to limit scope to only the branches that need cleaning.
- Prefer `--path` over `--strip-blobs-bigger-than` for targeted removals — it's faster and more precise.

## Signed & Verified Commits

**Signatures on modified commits WILL be stripped by filter-repo.** The commit hash changes, which invalidates the cryptographic signature. This is unavoidable — a signature cannot be preserved when the signed content changes. Unmodified commits retain their signatures.

### Verify After Cleanup

After filter-repo and before push, check which commits were affected:

```bash
# Check how many commits have signatures
git log --all --format="%H %ai %GS" | head -20
# %GS = signer (empty if unsigned)

# Count signed vs unsigned
signed=$(git log --all --format="%GS" | grep -c .)
unsigned=$(git log --all --format="%GS" | grep -c "^$")
echo "Signed: $signed, Unsigned: $unsigned"

# Check if any commits have no signature at all
git log --all --format="%H %GS" | grep " $" | head -5
# If all commits were signed before but some are now unsigned,
# they were modified by filter-repo
```

On GitHub, commits appear as **Unverified** if the signature was stripped. To restore verification, commits must be re-signed and re-pushed.

### Re-sign All Commits

If you want all commits to remain verified after cleanup:

```bash
# Re-sign all commits in the rewritten history
git rebase --exec 'git commit --amend --no-edit -S' --root
```

This creates yet another set of new commit SHAs, which means **another force-push** and another round of collaborator notification. Only do this if commit verification is critical for your workflow.

### Verify Signatures Are Restored

```bash
# Check signatures are present after re-signing
git log --all --format="%H %ai %GS" | head -10

# Verify them cryptographically
git log --show-signature | head -20
```

### GitHub Verification

Even with proper GPG signatures, GitHub must know your public key. Upload it at:
https://github.com/settings/gpg/keys

After force-push, GitHub will show commits as **Verified** (green badge) if:
1. The commit is GPG-signed with a key uploaded to GitHub
2. The signer email matches a verified email on your GitHub account
3. The signature passes cryptographic verification

## Prevention

The best cleanup is the one you never need. These standards and tools prevent history cleaning:

| Prevention Layer | Tool / Standard | What It Prevents |
|-----------------|-----------------|------------------|
| 1 — Whitelist .gitignore | `docs/gitignore-standard.md` | Secrets, agent sessions, build artifacts from being committed |
| 2 — Pre-commit scanning | Gitleaks / TruffleHog via `.pre-commit-config.yaml` | Secrets caught before commit |
| 3 — Pre-push scanning | Gitleaks / TruffleHog pre-push hook | Secrets caught before push |
| 4 — CI scanning | Gitleaks Action, Dependency Review via `docs/ci-pipeline-standard.md` | Secrets caught on PR |
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
