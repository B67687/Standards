# PROJECT_MODEL.md: The Standards Repo's Own State Machine

> **Purpose:** The Standards repo applies the Development Protocol's Project Health rule to itself. This document is the repo's state machine: every phase is a state, every arrow is a valid transition, and the invariants below are what must never change.
>
> **Why this exists:** The protocol mandates that every project document its whole-project state machine (see SPECIFICATION.md §2). This is that mandate applied to the Standards repo itself. Adding or removing a standard, a check script, or a governance artifact means updating this transition table: making the change explicit instead of silently breaking the inventory's invariants.

## States

The repo's states are its protocol phases plus the content states that live inside them:

```
BOOTSTRAP → DISCOVER → WORK → PERFECT → DISTRIBUTE → MAINTAINED
```

| State | Meaning |
|---|---|
| `BOOTSTRAP` | Initial setup: repo skeleton, whitelist .gitignore, tooling manifest |
| `DISCOVER` | Standards identified across the ecosystem; inventory drafted |
| `WORK` | Audit scripts, CI, dashboard built; standards documented |
| `PERFECT` | Governance formalization and hardening: SPECIFICATION.md, RULES.md, PROJECT_MODEL.md, tests, review archive |
| `DISTRIBUTE` | Cross-referencing with the Dev Protocol and Lessons; release to the public repo |
| `MAINTAINED` | Steady state: audits green, new standards added one at a time through the WORK transition |

## Valid Transitions

### Standard path (forward, phase-to-phase)

```
BOOTSTRAP → DISCOVER → WORK → PERFECT → DISTRIBUTE → MAINTAINED
```

### Valid deviations

| Transition | When valid |
|---|---|
| `MAINTAINED → WORK` | A new standard is added: write `<name>-standard.md`, add `scripts/checks/<name>.sh`, update the inventory |
| `MAINTAINED → PERFECT` | A governance artifact is missing or stale and needs formalization |
| `PERFECT → WORK` | A check bug is found and fixed (e.g., the 2026-08 self-consistency fixes) |
| `DISTRIBUTE → PERFECT` | Release review found a governance gap that must close before shipping |
| Any state → `DISCOVER` | A new class of conventions is identified across repos and needs inventorying |

### Invalid transitions

```
DISTRIBUTE → MAINTAINED without passing PERFECT gates (make check green)
WORK → DISTRIBUTE without PERFECT (governance artifacts must exist first)
MAINTAINED → DISTRIBUTE (a release is not a steady-state action; it re-enters PERFECT first)
```

> These are invariants: **no release ships without `make check` green. No new standard ships without a check script.**

## Invariants (What Must Never Change)

1. **The repo passes its own audit at all times.** `./scripts/audit.sh --exit-code .` exits 0. The self-consistency standard enforces this in CI.
2. **Every standard has a check script.** No standard document without a `scripts/checks/<name>.sh` plugin; no check plugin without a standard document.
3. **README.md counts are authoritative.** 24 standards, 128 checks (114 shell + 9 agent-pending + 5 tool-availability). Any inventory change updates README.md in the same commit.
4. **No new runtime dependency without a Y-Statement** recorded in SPECIFICATION.md §2.
5. **The public repo is never a work surface.** All work happens on `origin` (Standards-Dev); release to `public` only on explicit user go.
6. **Generated `.omo/` output is never committed.** `.omo/audit/agent-evals/*.json` and `.omo/dashboard/*` are exempt, volatile, and stay unmodified.
7. **The audit framework is POSIX shell.** No compiled runtime, no package-manager install, no interpreter beyond bash.

## Blast Radius Map (What Co-Changes Together)

Changing one artifact often requires changing its co-change partners. Check the row before editing.

| Change | Co-changes (must be updated in the same commit) |
|---|---|
| Add a standard | `<name>-standard.md` + `scripts/checks/<name>.sh` + README.md standards table + `cross-repo-standards.md` + SPECIFICATION.md §4 + EXPLAINER.md counts |
| Change a check script | The standard document (rules/success criteria) + README.md checks count + SPECIFICATION.md §4 + `tests/check-framework.test.sh` if framework behavior is affected |
| Change `scripts/audit-lib.sh` | ALL check plugins (they source it) + `tests/check-framework.test.sh` + SPECIFICATION.md §2 |
| Change `scripts/audit.sh` | `tests/check-framework.test.sh` + SPECIFICATION.md §2 + README.md quick-start examples |
| Change CI | `.github/workflows/ci.yml` + `Makefile` + `scripts/check-parity.config` (local-vs-GitHub parity gate) |
| Change a governance doc | SPECIFICATION.md (cross-references) + RULES.md + this file + `.omo/reviews/` findings |
| Change `.gitignore` | The whitelist governs what is tracked; verify no tracked file becomes ignored and no new artifact is silently excluded |

## Adding or Removing a Standard (Transition Update Procedure)

When a standard is added, removed, renamed, or reordered:

1. Update this file's **States** table if a new content state is introduced
2. Update the **Valid Transitions**: add/remove the state's arrows
3. Check the **Invariants**: does the change violate any? (e.g., adding a standard without a check script violates invariant 2)
4. Update the standards table in **README.md** and the inventory in **cross-repo-standards.md**
5. Grep all standard docs for stale references to the old standard (`grep -rn "OLDNAME" *.md`)
6. If this is a NEW standard: does it need a check script (invariant 2) and a row in SPECIFICATION.md §4?

> The failure mode this prevents: adding a standard without updating the inventory caused the README/SPEC count drift that the 2026-08 review flagged. With this procedure, inventory changes become a documented transition, not a silent regression.

## Test

The transition-table test for the repo itself:

- [ ] README.md standards table matches the actual `scripts/checks/*.sh` files
- [ ] README.md counts (24 standards, 128 checks) match the actual inventory
- [ ] Every standard document has a corresponding check plugin and vice versa
- [ ] `make check` passes (audit-exit + shellcheck + tests)
- [ ] Invariants hold: no path ships without `make check` green; no standard ships without a check script