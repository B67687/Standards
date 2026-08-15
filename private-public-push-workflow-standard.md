# Private-Public Push Workflow Standard (Thematic Squash)

## What

The release path for a project with a **local-dev airlock + private dev + public release** split: work happens in the **local ↔ github-dev** loop; the public repo receives only **thematically squashed, signed commits** on explicit user decision. After a release, dev and public **mirror each other** — identical content, identical squashed history. History is **append-only**: published commits are never rewritten.

## The four-layer naming model (canonical since 2026-08-11)

Every project under this standard uses FOUR named layers. The local-dev layer is a **non-git, physically untrackable folder** that acts as an airlock for private test files, unreleasable artifacts, and session handovers.

| Layer | Location | Role | Pushes to GitHub? |
|------|----------|------|-------------------|
| **local** | `<project>-working-dir` (e.g. `/home/nami/projects/dev/Ithmb-Codec-Web/`) | authoritative working tree, no suffix | pushes to **github-dev** every time |
| **local-dev** | `<project>-Local/` (e.g. `Ithmb-Codec-Web-Local/`) | private test files, unreleasable artifacts, handover docs | **never** (not a git repo — physically untrackable) |
| **github-dev** | `<Project>-Dev` on GitHub | receives every local push; CI runs there; visibility toggles public/private | it IS GitHub (usually private) |
| **github-public** | `<Project>` on GitHub | the release repo — append-only, pushed only on explicit user go | it IS GitHub (live) |

**Remote naming differs by project family — do not mix these up:**

- **Web projects** (e.g. Ithmb-Codec-Web): `origin` = github-public, `dev` = github-dev.
- **Codec/plugin projects** (e.g. Ithmb-Codec, Imageglass-Ithmb-Plugin, Standards): `origin` = github-dev, `public` = github-public.

**CI billing caveat (Actions)**: GitHub Actions free minutes apply to PUBLIC repos. A private github-dev repo gets NO Actions. Workaround: temporarily flip github-dev PUBLIC (`gh repo edit <owner>/<Project>-Dev --visibility public`), run/rerun CI, then flip back to PRIVATE. The safety guard: github-dev must never hold local-dev (airlock) content — private test files / handovers — or the public window leaks it.

## Why

1. **History hygiene** — the public (and post-release private) git log reads as intentional units (`feat:`/`fix:`/`docs:`/`refactor:`), not WIP noise.
2. **No contributor graph bloat** — raw commits are squashed away before anything public; the graph shows only clean, user-authorized commits.
3. **Scratch stays scratch** — the private repo is a scratchpad: working cycles accumulate there between releases, and nothing about the scratch is precious or kept for its own sake.
4. **Release discipline** — public push happens only on an explicit user decision that the scratch is good enough. No accidental publication of half-baked work.
5. **Append-only is the only sustainable mode** — a full-history rewrite is not viable for anything large. Releases append to existing history; what's public stays public.

## Convention

| Repo / layer | Purpose | Visibility | Push |
|-------------|---------|------------|------|
| `local` | Authoritative working tree | local disk | Any commit, any time → github-dev |
| `local-dev` | Private airlock: test files, handovers | non-git folder | **never** |
| `<Project>-Dev` | Scratchpad — all work | Private (flip public only for CI runs) | Any commit, any time |
| `<Project>` | Public snapshot, mirror of dev after release | Public | Squashed thematic commits, explicit user go only |

Single branch: `main` (tracked to `<Project>-Dev` remote; pushed to the public remote at release).

## Workflow

```
1. CONFIRM Dev-first (every session, before any commit):
     git status && git remote -v && git log --oneline -5
     origin MUST point to <Project>-Dev.git (web-family: the `dev` remote
     must point to <Project>-Dev.git), else STOP and report.

2. Work in the local ↔ github-dev loop: commit, push — all to the dev remote.
   GitHub CI runs on the DEV repo, validating scratch as it happens. If the
   dev repo is PRIVATE, CI gets NO Actions minutes (billing block) — flip the
   dev repo PUBLIC temporarily for the run, then flip back (see caveat above).
   If CI is unavailable entirely, run the repo's local check (e.g. ./scripts/check.sh).
     GIT_MASTER=1 GIT_COMMITTER_DATE="$(git log -1 --format=%aD)" git-safe-commit -S -m "<msg>"
     git-safe-push origin main   # or: git-safe-push dev main (web-family)

3. When the user decides the scratch is good enough to release (explicit go —
   never assume), squash thematically the delta since the last release tip:
     - group by behavior / logical unit (feature, fix, docs, refactor, chore)
     - conventional subjects, imperative ~50-char
     - all signed: git log --format="%h %G?" -> G on EVERY commit
     - no agent attribution

4. Propagate local -> github-dev -> github-public:
     a. push the squashed history to github-dev:  git-safe-push origin main
        (web-family: git-safe-push dev main)
     b. on explicit user go, push public:          git-safe-push public main
        (web-family: git-safe-push origin main — the PUBLIC remote)

5. Verify: public main == private main == local main (same SHA),
   working tree CLEAN. The repos now mirror each other.

6. Repeat for the next release: squash only the delta since this tip — append,
   never rewrite. The value judgement on when to make an appended thematic
   commit is a session-time decision between the user and the agent.
```

## Thematic squash rules

- Group by **behavior / logical unit**, not by time or by file. (Reference executions: ithmb 1.4.0 — 31 raw → 8 themed commits; Development-Protocol 2026-08-06 — 62 raw → 12 themed commits.)
- Conventional prefixes: `feat:` new capability; `fix:` correction; `docs:` documentation; `refactor:` behavior-preserving restructure; `chore:` maintenance.
- Imperative mood, ~50-char subject, no trailing period.
- **NEVER include agent attribution** — no `Co-authored-by`, no tool footers. The repo owner is the sole author.
- All squashed commits signed (`-S`); `git log --format="%h %G?"` must show `G` on every commit.
- **Append-only**: squash only the delta since the last release tip. Published commits are NEVER rewritten. A full-history reset is not a routine option (see One-time reset).

## One-time reset (delete + re-upload) — NOT routine

For establishing clean history ONCE per repo (e.g. first standardization of a repo that was pushed raw). Executed for Development-Protocol on 2026-08-06. Do not treat as a routine release path:

1. User confirms the private repo is exactly as wanted AND gives explicit go.
2. Delete the public repo on GitHub (`gh repo delete B67687/<Project>` — user must run it; agent permission-denied), recreate empty with the same name.
3. From private HEAD, create orphan branch `public-clean`; optionally split the final state into thematic commits; strip private-only paths (e.g. `.omo/`) from every commit.
4. `git push public main` (fresh repo accepts it as the root).
5. Verify tree equality: `git ls-tree` diff shows public tree == private tree, zero private-only paths.
6. Collapse the private repo to the same squashed history so the two repos mirror each other.

## Applied to

- B67687/Standards → B67687/Standards-Dev
- B67687/Development-Protocol → B67687/Development-Protocol-Dev (reference execution: 62 raw → 12 themed, 2026-08-06)
- B67687/Ithmb-Codec → B67687/Ithmb-Codec-Dev (origin=dev, public=release)
- B67687/Ithmb-Codec-Web → B67687/Ithmb-Codec-Web-Dev (web-family: origin=public, dev=github-dev; reference execution: 1.4.0 — 31 raw → 8 signed themed commits)
- B67687/Imageglass-Ithmb-Plugin → B67687/Imageglass-Ithmb-Plugin-Dev (origin=dev, public=release)
- B67687/Lessons → B67687/Lessons-Dev
