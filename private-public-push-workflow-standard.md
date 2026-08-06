# Private-Public Push Workflow Standard (Thematic Squash)

## What

The release path for a two-repo project (`<Project>-Dev` private / `<Project>` public): **all** work commits land in the private repo; the public repo receives only **thematically squashed, signed commits** after explicit user approval. This supersedes the delete-and-recreate release path in [private-public-split-standard.md](./private-public-split-standard.md) for ongoing releases (that standard's scrub+reset remains the one-time initial-publication path).

## Why

1. **History hygiene** — the public git log reads as intentional units (`feat:`/`fix:`/`docs:`/`refactor:`), not WIP noise.
2. **No contributor graph bloat** — raw commits are squashed away; the graph shows only clean, user-authorized commits.
3. **Private = staging** — back-and-forth, experiments, and agent-driven iterations stay invisible.
4. **Release discipline** — public push requires an explicit user gate. No accidental publication of half-baked work.
5. **It is the only sustainable model** — private and public share the same content; squashing rewrites history, so you cannot incrementally squash a shared-history repo without diverging the remotes. The squash therefore happens at release time on a staging branch, then a clean fast-forward push publishes it.

## Convention

| Repo | Purpose | Visibility | Push |
|------|---------|------------|------|
| `<Project>-Dev` | Source of truth — all work | Private | Any commit, any time |
| `<Project>` | Public snapshot | Public | Squashed thematic commits, explicit user go only |

Local branches during a release:

| Branch | Purpose |
|--------|---------|
| `main` | Current work (tracked to `*-Dev` remote) |
| `backup-pre-squash` | Snapshot of raw history before squashing — the recovery path |
| `squash-work` | Staging branch where thematic squashing happens |

## Workflow

```
1. CONFIRM Dev-first (every session, before any commit):
     git status && git remote -v && git log --oneline -5
     origin MUST point to <Project>-Dev.git, else STOP and report.

2. Work normally: commit, push — all to origin (private). No attribution.
     GIT_MASTER=1 GIT_COMMITTER_DATE="$(git log -1 --format=%aD)" git-safe-commit -S -m "<msg>"
     git-safe-push origin main

3. When the user says "ready to publish" (explicit go — never assume):
     a. git branch backup-pre-squash          # recovery snapshot of raw history
     b. git checkout -b squash-work           # staging branch
     c. git rebase -i <base>                  # squash raw commits into THEMES:
        - one commit per logical unit (feature, fix, docs, refactor)
        - conventional subjects (see below)
     d. git log --oneline                     # review the themed list
     e. verify signatures: git log --format="%h %G?" -> G on EVERY commit
     f. git checkout main && git merge squash-work --ff-only

4. Push public (clean fast-forward):
     git-safe-push public main

5. Verify: public main == private main (same SHA), working tree CLEAN.

6. Clean up after user confirms public is correct:
     git branch -D squash-work backup-pre-squash
```

## Thematic squash rules

- Group by **behavior / logical unit**, not by time or by file. (Reference execution: 31 raw commits → 8 themed commits.)
- Conventional prefixes: `feat:` new capability; `fix:` correction; `docs:` documentation; `refactor:` behavior-preserving restructure; `chore:` maintenance.
- Imperative mood, ~50-char subject, no trailing period.
- **NEVER include agent attribution** — no `Co-authored-by`, no tool footers. The repo owner is the sole author.
- All squashed commits signed (`-S`); `git log --format="%h %G?"` must show `G` on every commit.

## One-time reset (delete + re-upload)

When public history is already messy and a clean slate is wanted (e.g., first standardization of a repo that was pushed raw):

1. User confirms the private repo is exactly as wanted.
2. User gives explicit go to replace the public repo.
3. Delete the public repo on GitHub (`gh repo delete B67687/<Project>`), recreate empty with the same name.
4. From private HEAD, create orphan branch `public-clean`; optionally split the final state into thematic commits.
5. `git push public main` (fresh repo accepts it as the root).
6. Verify tree equality: `git ls-tree` diff shows public tree == private tree, zero private-only paths (e.g. `.omo/`).

## Applied to

- B67687/Standards → B67687/Standards-Dev
- B67687/Development-Protocol → B67687/Development-Protocol-Dev
- B67687/Ithmb-Codec-Web → B67687/Ithmb-Codec-Web-Dev (reference execution: 1.4.0 — 31 raw → 8 signed themed commits)
- B67687/Lessons → B67687/Lessons-Dev
