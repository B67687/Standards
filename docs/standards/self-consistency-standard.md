# Self-Consistency Standard

## Domains

quality,ai


## Purpose

The standards repository must be self-consistent — it must practice what it
preaches. Every standard defined in this repo applies to this repo itself.
If a standard cannot be satisfied by this repo (e.g., because the standard is a
meta-standard about a type of project this repo isn't), it MUST be documented
as an explicit exception.

This is the **meta-standard**: it audits the auditor.

## Rule

1. The standards repository MUST pass `./scripts/audit.sh --exit-code .`
   with exit code 0 at all times.
2. Exceptions to individual standards MUST be documented in this file under
   "Known Exceptions".
3. When a new standard is added, the standards repo must be made compliant
   as part of the same change (or an explicit exception added).
4. CI pipelines for the standards repo MUST run `make check` (or equivalent)
   to enforce self-consistency.

## Rationale

- **Credibility**: If the standards repo doesn't follow its own rules, why
  would any other repo?
- **Testability**: The easiest way to verify a check script works is to run
  it against the standards repo itself.
- **Regression protection**: Adding a standard that the standards repo can't
  satisfy is a design smell — it signals the standard may be too narrow or
  too specific.

## Known Exceptions

| Standard | Reason |
|----------|--------|
| Auto-Commit GitOps | Checks global git config (~/.config/git/ai-commit-hooks/), not per-repo. The standard repo has the hooks config but the hooks themselves are installed globally. |

## Enforcement

```bash
# Run self-consistency check
./scripts/audit.sh --exit-code .

# Or via Makefile
make check
```

## Related

- [`self-consistency.sh`](../scripts/checks/self-consistency.sh) — Check script
