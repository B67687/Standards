# ADR Standard

## Domains

docs


## What

An Architecture Decision Record captures a significant decision: context, decision, rationale, and consequences. It preserves the "why" across time and across context resets.

## When to Write

Write an ADR for any decision that is:
- **Architecturally significant** — affects how the system works, not just implementation details
- **Hard to reverse** — changing your mind later would be costly
- **Not obvious** — the choice needs explanation (alternatives existed)
- **Cross-cutting** — affects multiple repos or multiple standards

Examples: choosing a CI tool, adopting a standard, changing the repo structure, picking a license.

## Where

`docs/adr/` in the repository. For cross-repo decisions, use `agentic-workflows/docs/adr/`.

## Filename

`YYYY-MM-DD-title-in-kebab-case.md`

```
docs/adr/
  2026-06-14-calibration-protocol.md
  2026-06-17-ai-attribution-standard.md
```

## Status Lifecycle

Every ADR has a status. The lifecycle is:

```
Proposed → Accepted → Superseded
              ↓
           Deprecated
```

- **Proposed** — decision is being considered, not yet final
- **Accepted** — decision has been made and implemented
- **Deprecated** — decision is no longer recommended (but not yet replaced)
- **Superseded** — replaced by a newer ADR (link to the new one)

## Format

```markdown
# Title

**Date:** YYYY-MM-DD
**Status:** Accepted
**Last Reviewed:** YYYY-MM-DD

## Context

What prompted this decision? What problem does it solve?

## Decision

What was decided? Be specific.

## Rationale

Why this choice over alternatives? What tradeoffs were accepted?

## Consequences

What changes as a result? What needs to happen next?

## Alternatives Considered

Briefly note what else was explored and why it wasn't chosen (optional).
```

### Example

```markdown
# Adopt Keep a Changelog

**Date:** 2026-06-17
**Status:** Accepted
**Last Reviewed:** 2026-06-17

## Context

Changelog formatting was inconsistent across repos. Some had no changelog,
some used dated entries, some used Keep a Changelog format.

## Decision

All repos will use Keep a Changelog format with SemVer versioning.

## Rationale

Keep a Changelog is the most widely adopted changelog standard.
It's the de facto industry convention.

## Consequences

- New repos get a CHANGELOG.md at init
- Existing repos without changelogs get one added
- Existing changelogs in different formats are migrated

## Alternatives Considered

- Auto-generated from conventional commits: too impersonal
- No changelog (rely on git log): not user-friendly
```

## Last Reviewed

Every ADR MUST include a `**Last Reviewed:**` date field alongside `**Date:**` and `**Status:**`. This field records when the ADR was last reviewed for continued relevance.

- **On creation:** Set `Last Reviewed` equal to `Date`
- **On review:** Update `Last Reviewed` to the current date when reviewing (but do NOT change the `Date` — that's the decision date)
- **Purpose:** Stale ADRs are worse than no ADRs. A Last Reviewed date makes it obvious when an ADR hasn't been looked at in years.

## Superseding

When a decision changes, mark the old ADR as Superseded and link to the new one:

```markdown
## [Superseded by 2026-12-01-new-approach.md](./2026-12-01-new-approach.md)
```

Do NOT edit the old ADR's Decision or Rationale — it should remain as a record of what was decided at the time.

## Rules

- **Immutable once committed.** ADRs document decisions. If the decision changes, write a new ADR that supersedes the old one — don't edit the existing one.
- **Date only, no version number.** The date is the identifier.
- **One decision per ADR.** If a decision involves multiple related aspects, that's fine — but don't merge two unrelated decisions into one ADR.
- **File in the repo where the decision applies.** Cross-repo decisions go in agentic-workflows.
