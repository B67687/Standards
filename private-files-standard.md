# Private Files Standard

**Standard:** `private-files`
**Check script:** `scripts/checks/private-files.sh`
**Checks:** 4 (shell)

## Purpose

Prevent private agent-workspace and secret material from being tracked by git
and leaking into public repositories. Git ignore rules alone are insufficient
(they do not untrack files already added, and `git add -f` bypasses them), so
this standard enforces the boundary at the source: private paths must never
appear in the tracked tree.

## Scope

Applies to every repository, including documentation-only and public-facing
repos. It is the enforcement backend for the "`.omo/` never enters the public
tree" rule of the private/public push workflow.

## Private paths (must never be tracked)

- `.omo/` agent workspace content (NEVER tracked — zero .omo on public)
- Environment/secret files: `.env`, `.env.*` (excluding `.env.example` and
  `.env.enc`, which are safe to track), `secrets/`, `*.pem`, `*.key`
- Agent session state: `ses_*.json`, `.omo/run-continuation/`, `.omo/ledger/`,
  `.omo/plans/`, `.omo/drafts/`, `.omo/reviews/`, `.omo/dashboard/`,
  `.omo/audit/`

## Contract

A repository satisfies this standard when:

1. No `.omo/` content is tracked (zero .omo on public).
2. No secret/private file pattern is tracked (`.env`, `*.pem`, `*.key`,
   `secrets/`, etc.).
3. No agent session state is tracked.
4. The repository declares its public/private contract (an AGENTS.md or README
   note stating that `.omo/` is private / never committed to public).

## Enforcement

The `private-files.sh` check runs as part of the standard `audit.sh` sweep.
Any violation fails the audit with a clear message identifying the offending
tracked path. Repositories that need to release to a public remote must pass
this check first.

## Notes

- Tracked files bypass `.gitignore`; removing a leaked file requires
  `git rm --cached` and, for history already pushed, a history rewrite
  (e.g. `git-filter-repo`).
- `.env.example` and `.env.enc` (age/sops-encrypted) are explicitly allowed:
  they are templates or encrypted, not plaintext secrets.
- The `.omo/` directory is agent ephemera and must never be tracked in any
  repo. If shift-log content is valuable publicly, copy it to `docs/shift-log.md`.
