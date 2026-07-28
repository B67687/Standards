# Private-Public Repo Split Standard

## What

All projects maintain **two repos**: a private development repo (where work happens) and a public repo (read-only snapshots at release time).

## Why

1. **History hygiene** — Secrets, experiments, and iterative work stay private. Only clean, intentional commits reach the public.
2. **No contributor graph bloat** — Scrub-and-reupload gives a fresh public repo with zero history, not a messy git log with force-pushes.
3. **Privacy by default** — Repo naming conventions, .gitignore patterns, and internal tooling stay invisible.
4. **Release discipline** — Publishing requires an explicit decision. No accidental pushes of half-baked work.

## Convention

| Repo | Purpose | Visibility | Gitignore |
|------|---------|------------|-----------|
| `<Project>` | Public snapshot | Public | Strict gitaccept (whitelist only) |
| `<Project>-Dev` | Source of truth | Private | Strict gitaccept (whitelist only) |

## Workflow

```
1. Clone private repo: git clone git@github.com:B67687/<Project>-Dev.git
2. Work normally: commit, push, PR — all to private
3. When ready to publish:
   a. Delete the public repo on GitHub
   b. Create a new public repo with the same name (empty)
   c. Add as remote: git remote add public https://github.com/B67687/<Project>.git
   d. Push: git push public main
       → Result: 1 clean commit on public, zero history, no contributor graph bloat
4. Repeat step 3 for each release
```

## Scrub policy

Before the initial push to private, or before a public release:

- Scan git history for: API keys, tokens, private keys, .env files, credentials
- If found: `git filter-repo --path <offending-file> --force` on a fresh clone
- Then `git rebase --root -S` to re-sign all commits
- Then push to private
- Only after scrub → consider pushing to public

Current scrub findings (as of 2026-07-28):
- Standards: `.env.encrypted` and `.sops.yaml` scrubbed from history
- Development Protocol: clean — nothing ever committed
- Lessons: clean — nothing ever committed

## Applied to

- B67687/Standards → B67687/Standards-Dev
- B67687/Development-Protocol → B67687/Development-Protocol-Dev
- B67687/Lessons → B67687/Lessons-Dev
