# Private-Public Repo Split Standard

## What

All projects maintain two repos: a private development repo (where work happens) and a public repo (read-only snapshots at release time).

## Why

1. History hygiene — secrets stay private
2. No contributor graph bloat — fresh public repo has zero history
3. Privacy by default — naming and conventions stay invisible
4. Release discipline — publishing requires explicit decision

## Convention

| Repo | Purpose | Visibility |
|------|---------|------------|
| <Project> | Public snapshot | Public |
| <Project>-Dev | Source of truth | Private |

## Workflow

1. Clone private: `git clone git@github.com:B67687/<Project>-Dev.git`
2. Work normally — all to private
3. When ready to publish:
   - Delete public repo on GitHub
   - Create new public repo (empty) with same name
   - `git remote add public https://github.com/B67687/<Project>.git`
   - `git push public main` — 1 clean commit, zero history
4. Repeat for each release

## Scrub policy

Before pushing to public: scan history for secrets.
If found: `git filter-repo --path <file>` on a fresh clone, re-sign, push to private.
Only then consider publishing.

## Applied to

- B67687/Standards -> B67687/Standards-Dev
- B67687/Development-Protocol -> B67687/Development-Protocol-Dev
- B67687/Lessons -> B67687/Lessons-Dev
