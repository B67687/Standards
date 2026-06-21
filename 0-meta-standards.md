# Meta-Standard: Minimal Surface Principle

## Rule

Every file in the repository must contain **exactly as much as required, no more and no less**.

Anything extra is a liability:
- Extra **entries** in `.gitignore` leak local directory structure
- Extra **comments** in config files document implementation details that should remain local
- Extra **documentation** of internal processes creates a maintenance burden
- Extra **whitelist entries** reveal file names that should never be mentioned

## Application

| File | What to Strip |
|------|--------------|
| `.gitignore` | Only entries that counteract whitelist patterns. No documentation of local-only files. No section headers. No redundant `!` patterns. |
| `README.md` | Only information the end user needs. No build instructions for internal tooling. No CI configuration details. |
| `CHANGELOG.md` | Only changes users can see. No infrastructure changes, CI updates, or internal refactoring. |
| Config files | Only settings that differ from defaults. No explanatory comments. |
| CI configs | Never push CI configs to GitHub if CI runs locally. |

## Rationale

Every line in a committed file is **public documentation**. It reveals:
- What tooling you use
- What files exist on your local machine
- What processes you run internally
- What conventions you follow

If a file doesn't need to mention something, not mentioning it is the safest option. The absence of information is not a gap — it's a deliberate protection boundary.

## READMEs

README is the most public-facing file. It must not reference:
- Local-only scripts or tools (`review.sh`, `scripts/`, `local CI commands`)
- Local directory structure (`docs/adr/`, `docs/solutions/` — these are empty until filled)
- Local CI infrastructure (cron schedules, local-only tools, package managers)
- Internal processes that only matter to the maintainer

The README should describe what the project IS and how to USE it — not how it's BUILT internally.

## Removing Evidence of Cleaning

When files are removed from history or moved to local-only, all evidence of the operation must be cleaned:

- **Commit messages** must not reference the removed content. "chore: remove review.sh" tells readers review.sh once existed. Use neutral messages like "chore: update config" or batch into general housekeeping commits.
- **READMEs** must not reference files that no longer exist on GitHub (review.sh, .github/workflows/).
- **Config files** must not mention local-only files by name (see .gitignore principles).
- **Changelogs** must not log infrastructure changes that expose internal tooling. A changelog is for users, not maintainers.

## When to Add

Add content only when:
1. A tool REQUIRES it to function (e.g., `.gitignore` patterns)
2. A user NEEDS it to use the project (e.g., README install instructions)
3. A standard MANDATES it (e.g., LICENSE file)

Remove content when:
1. It documents local-only infrastructure
2. It's redundant with a broader pattern
3. It reveals more than necessary about your setup
