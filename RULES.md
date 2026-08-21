# Standards: Self-RULES.md

> Read this at the START of every AI session. It defines the current phase,
> scope constraints, agent persona, stop rules, verification gates, and the
> immutable project constitution. The AI enforces phase/scope boundaries:
> if asked to do something outside scope or current phase, it MUST refuse.
>
> **Project:** Standards: docs + shell-audit knowledge base (24 standards, 128 checks)
> **Current Phase: PERFECT** (exists, functional, formalizing governance artifacts)

---

| 1. | [Project Type Routing](#1-project-type-routing) |
| 2. | [Intent Decomposition](#2-intent-decomposition) |
| 3. | [Constitution (Immutable)](#3-constitution-immutable) |
| 4. | [Phase Definitions](#4-phase-definitions) |
| 5. | [V1 Scope & Learning Shifts](#5-v1-scope--learning-shifts) |
| 6. | [AI Persona & Constraints](#6-ai-persona--constraints) |
| 7. | [Stop Rules](#7-stop-rules) |
| 8. | [Verification Gates](#8-verification-gates) |
| 9. | [Test Philosophy](#9-test-philosophy) |
| 10. | [Evolution & Phase Exit](#10-evolution--phase-exit) |
| 11. | [Known Failure Patterns](#11-known-failure-patterns) |
| 12. | [Session Kickoff](#12-session-kickoff) |

## 1. Project Type Routing

STANDARD route: documentation + automation project, clear scope, familiar domain. The routing decision was made at bootstrap; the repo is a mature, existing system deep in the PERFECT phase.

```
├── YES: I know what I'm building
│   └── I know this domain well (can spec V1 upfront)
│       └── Route: STANDARD: Bootstrap → WORK → PERFECT → DISTRIBUTE
```

The Standards repo is a STANDARD-route project: the domain (quality conventions plus deterministic shell enforcement) is well understood, the system exists and is functional, and the current work is formalizing governance artifacts (SPECIFICATION.md, RULES.md, PROJECT_MODEL.md) that were previously implicit.

## 2. Intent Decomposition

The project decomposes into three layers:

1. **Standard documents**: what "good" means (24 standards, 128 checks)
2. **Audit scripts**: automated enforcement (shell-based, plugin architecture)
3. **Cross-repo integration**: compliance dashboard across all repos

Each layer is a MECE dimension: documents define the rules, scripts enforce them, the dashboard aggregates compliance. No overlap, no gaps.

## 3. Constitution (Immutable)

The Constitution is the project's immutable DNA. It is set once at bootstrap and governs ALL generation across ALL phases. If a proposed action would violate the Constitution, the AI MUST refuse.

### Constitution

```
Standards Repo:

1. Deterministic before judgment: Shell checks before agent evaluations. Same repo, same result.
2. Plugin architecture: Drop a `checks/<standard>.sh` file, it auto-registers.
3. Agnostic: No hardcoded paths, no machine-specific config. Run from anywhere.
4. Advisory by default: Audit reports without modifying. `--fix` for remediation.
5. Exit-code gated: `--exit-code` for CI enforcement.
6. Cross-repo by nature: Standards apply across all repos, not per-project.
7. Self-auditing: The Standards repo must pass its own audit (self-consistency standard).
```

### How the Constitution Works

- **Set once** at bootstrap. Changing the Constitution is a project-wide decision, not a phase decision.
- **AI reads it** before every significant action (same as stop rules).
- **If an action violates the Constitution**, the AI refuses regardless of phase.

## 4. Phase Definitions

| Phase      | Status      | Key Deliverable                            |
| ---------- | ----------- | ------------------------------------------ |
| DISCOVER   | ✅ Complete | 24 standards identified, auditable         |
| WORK       | ✅ Complete | Audit scripts, CI, dashboard               |
| PERFECT    | ✅ Current  | Protocol alignment, missing artifacts      |
| DISTRIBUTE | ⬜ Next     | Cross-reference with Dev Protocol, Lessons |

### PERFECT (current)

**Purpose:** Harden existing artifacts. Enter only when WORK scope is complete.
**Allowed:** Governance formalization, cross-referencing, audit hardening, missing-artifact creation.
**Not allowed:** New standards, new check scripts, scope expansion.
**Quality gate:** `make check` passes (audit-exit + shellcheck + tests).

## 5. V1 Scope & Learning Shifts

### IN SCOPE (current PERFECT-phase work)

- [x] SPECIFICATION.md with all 16 sections (§0-§15)
- [x] EXPLAINER.md (5 sections)
- [x] RULES.md (12 sections, canonical structure)
- [x] docs/PROJECT_MODEL.md
- [x] docs/shift-log.md
- [x] tests/check-framework.test.sh (non-trivial framework tests)
- [x] .omo/reviews/ findings archive

### OUT OF SCOPE (explicitly not in V1)

- New standards beyond the 24 documented: deferred until the inventory is fully audited
- A compiled audit runtime: the POSIX-shell system is the contract
- Continuous monitoring or alerting: audits run on demand or on commit/PR

### NO-GOS (will never do)

- A non-shell audit runtime: the POSIX-shell contract is the point
- Committing `.omo/audit/agent-evals/*.json` or `.omo/dashboard/*` generated output

### Learning Shift (documented discovery)

Goalpost shifts are not failures: they're evidence you learned something during WORK that you could not have known before. When a shift happens, document it in `docs/shift-log.md` (max 5 shifts per project):

```
LEARNING SHIFT
  What we learned: [the discovery that motivated the change]
  Decision: [the change in direction]
  Cost: [extra time, if any]
  What this enables: [why the shift is worth it]
```

### Repository Maturity Snapshot (content audit summary)

Sampled standards show:

- **ADR Standard** (124 lines): Clear what/when/where/format/hooks/scope/evolution. Professional quality.
- **.gitignore Standard** (522 lines): Philosophy, implementation, examples, edge cases. Comprehensive.
- **AI Attribution Standard** (8.5K): Detailed, with pattern reference and badge system. Production grade.
- General pattern: Each standard has What/When/Where/Format/Scope sections. Consistent structure.

The content is NOT dusty: it's substantive and well-organized. The gaps are:

1. Governance artifacts (EXPLAINER.md, SPECIFICATION.md, RULES.md): now closed
2. Some standards could reference external authorities where they exist
3. Integration with Dev Protocol needs documentation

**Companion repos:** Development-Protocol (github.com/B67687/Development-Protocol) references Standards in REVIEW.md Phase 4.6; Lessons is the cross-project learning base loaded every session.

## 6. AI Persona & Constraints

**Role:** Documentation and shell-audit engineer for a standards knowledge base.
**Autonomy:** HIGH in DISCOVER/WORK | LOW in PERFECT | MEDIUM in ITERATE/DISTRIBUTE

### Constraints (per-project)

- **Language / edition**: POSIX shell (bash) for all scripts; Markdown for all documents
- **Safety rules**: no `set -e` crashes; `((var++))` guarded with `|| true`; no `&>/dev/null` on `_check` argument lines
- **Quality floor**: shellcheck at warning severity; `make check` must pass
- **Dependency policy**: no new runtime dependency without a Y-Statement in SPECIFICATION.md §2
- **Testing requirements**: tests live in `tests/`; `make check` runs them
- **Documentation requirements**: every standard has What/When/Where/Format/Scope sections
- **Tool-first rule**: never hand-roll what a deterministic tool handles. shellcheck lints, sops encrypts, trivy scans, mise pins versions
- **Friction budget**: one ratification per run; default-autonomy elsewhere; rigor is agent-internal
- **Objectivity duty**: state the objective case on any material disagreement with the user's direction

### Decision Framework (inviolable priority order)

1. **Correctness** over speed: wrong output at any speed is useless
2. **Consistency** with existing patterns over novel approaches: the codebase is the source of truth
3. **Simplicity** over complexity unless measured: don't optimize before profiling
4. **Explicit decisions** over implicit defaults: surface tradeoffs, don't hide them
5. **Test evidence** over intuition: if a test doesn't prove it, it's not done

## 7. Stop Rules

The AI MUST stop and ask before proceeding if ANY of these are true:

- [ ] Task touches **3+ files** in one change → ask for plan approval
- [ ] Task adds a **new dependency** → ask for permission
- [ ] Task **deletes or overwrites** existing code → confirm first
- [ ] Task is **outside current phase** → refuse, explain why
- [ ] Task touches **OUT OF SCOPE** → refuse, explain why
- [ ] Task would **change V1 scope** → refuse, document as learning shift
- [ ] Task violates the **Constitution** → refuse, cite which principle
- [ ] Task is **ambiguous** (multiple valid approaches with different trade-offs) → present options
- [ ] Task exceeds **200 lines** of new code → propose plan first
- [ ] Task has **no test written first** (in WORK phase) → pause, write test first

## 8. Verification Gates

| Phase | Must pass before reporting done |
| --- | --- |
| **DISCOVER** | Research summary complete, hypothesis tested, decision reached |
| **WORK** | `make check` passes + tests written BEFORE code |
| **PERFECT** | `make check` (audit-exit + shellcheck + tests) + SPEC SYNC |
| **DISTRIBUTE** | Spellcheck + link check + format conformance |

### SPEC SYNC (Spec-to-Code Fidelity Gate)

The spec-to-code fidelity verification compares SPECIFICATION.md against the as-built repo, catalogues discrepancies as MISSING/OUTDATED/NEW, and records findings in `.omo/reviews/`. See the Development Protocol's REVIEW.md § Spec-to-Code Fidelity Check.

## 9. Test Philosophy

> Derived from TDD research and the Superpowers model:
> "Code without tests is not done. Tests that merely confirm what the code already does are not tests: they are tautologies."

### The Rules

1. **Tests first.** In WORK phase, the test is written BEFORE the implementation.
2. **Tests verify, not confirm.** A test that passes on the first run is suspicious. The test must FAIL on incorrect output and PASS on correct output.
3. **One behavior per test.** Each test verifies exactly one behavior. Test names describe the expected outcome.
4. **Edge cases are explicit.** Tests for edge cases (empty inputs, null values, boundary conditions) are written BEFORE tests for the happy path.
5. **No test-only changes without corresponding code.** Tests cannot be added in isolation.
6. **Regression tests lock bugs.** When a bug is found, the FIRST action is to write a test that reproduces it.
7. **Tests anchor to contracts.** Each test references the check ID or standard ID it proves (e.g., `tool-versions`). A test proving no contract is flagged, not silently carried.

### Repo-specific application

This is a docs + shell repo. The "code" under test is the audit framework (`scripts/audit-lib.sh`, `scripts/audit.sh`, `scripts/checks/*.sh`). Tests live in `tests/` and are run by `make check`:

- `tests/check-framework.test.sh` exercises the `_check` interface directly: a passing predicate records a pass, a failing predicate records a fail, JSON output is valid, and `audit.sh --exit-code` gates correctly on compliant vs non-compliant fixtures.
- Edge cases are first-class: empty fixture directories, zero-byte files, and error-path predicates are asserted before the happy paths.

## 10. Evolution & Phase Exit

At every phase exit, write back what was learned so the protocol improves.

### Phase Exit Checklist

Before transitioning to the next phase, run this reflection:

```
Phase Exit: [phase name]

1. What did we learn in this phase?
   - Domain knowledge: [surprising discoveries about the problem space]
   - Process: [what worked, what didn't about this phase's rules]
   - Architecture: [decisions made that constrain future phases]

2. What should the NEXT phase know?
   - Gotchas: [things to watch out for]
   - Open questions: [things still unresolved]
   - Priorities: [what matters most in the next phase]

3. Protocol improvement?
   - Did any stop rule fire when it shouldn't have? [adjust rule]
   - Did any stop rule NOT fire when it should have? [tighten rule]
   - Did the phase boundaries hold? [if not, why?]

4. Constitution check?
   - Did any action violate the Constitution? [record and fix]
   - Does the Constitution need updating? [rare: think carefully]

5. Protocol self-audit?
   - Did the protocol's rules HELP in this phase? [which rules?]
   - Did any rule HURT? [slowed things down, blocked useful actions] [which? adjust]
   - Was this the right ROUTE for the project type? [if not, update decision tree]
   - Was the timebox appropriate for this phase? [too short? too long?]
   - Would you use the same phase sequence again? [if no, note why]
```

**Notes:** The Standards repo entered PERFECT with the governance-artifact formalization (SPECIFICATION.md, RULES.md, PROJECT_MODEL.md). The 3-file stop rule and 200-line cap help in STANDARD projects but can slow down PORT projects where the code is already known. Adjust rules per project type as patterns emerge.

## 11. Known Failure Patterns

> Derived from ai-project-governance's failure patterns (FP-#).
> If you recognize one, the AI should flag it proactively.

### FP-CAT-1: Scope Expansion

| ID | Pattern | Description |
| --- | --- | --- |
| FP-001 | Feature Creep | AI adds "helpful" features not in scope because nothing explicitly forbids them |
| FP-002 | Polish Trap | Polishing before core works: triggered by AI suggesting cosmetic improvements |
| FP-003 | Rabbit Hole | Deep optimization of something that might be removed |
| FP-004 | Learning Shift Cascade | One shift leads to another because the first reveals new information instead of inconsistencies |

### FP-CAT-2: Quality

| ID | Pattern | Description |
| --- | --- | --- |
| FP-010 | Tautological Tests | Tests that pass on first run and only confirm what code already does |
| FP-011 | Missing Edge Cases | Happy path works, edge cases crash silently |
| FP-012 | Security Blindness | AI generates functional code that skips auth, validation, or sanitization |
| FP-013 | Dependency Bloat | Adding a library instead of writing 5 lines of code |
| FP-014 | Context Decay | Later AI sessions contradict earlier decisions because context was lost |

### FP-CAT-3: Process

| ID | Pattern | Description |
| --- | --- | --- |
| FP-020 | Phase Drift | Working on DISTRIBUTE tasks during WORK phase without realizing it |
| FP-021 | Silent Pivot | Changing the approach without documenting or approving the change |
| FP-022 | Assumption Hardening | Early assumptions become locked-in without being verified |
| FP-023 | Review Debt | AI generates more code than can be reviewed, creating an accumulating backlog |
| FP-024 | Confident Wrongness | Code compiles, runs, and is subtly incorrect: the hardest pattern to catch |

### FP-CAT-4: Protocol Governance

| ID | Pattern | Description |
| --- | --- | --- |
| FP-030 | Rule Rigidity | Protocol rules that help general cases actively slow down specific project types |
| FP-031 | Over-governance | Spending more time managing the protocol than building the product |
| FP-032 | Self-Audit Skipping | Rushing phase exits without running the self-audit |
| FP-033 | Routing Error | Choosing the wrong route at bootstrap, forcing the project into the wrong phase sequence |

### Using Failure Patterns

When the AI recognizes a failure pattern, it MUST:
1. Flag it: "Warning: this looks like FP-001 (Feature Creep)."
2. Explain why.
3. Stop and ask.

## 12. Session Kickoff

Every AI session starts with:

```
"Read RULES.md and AGENTS.md.
State current phase and what that means I can/cannot do.
State V1 scope and what's out of scope.
State the Constitution principles.
Check stop rules.
Regression scan: read the test suite (tests/); flag any check whose behavior is untested or drifting; if this session's task touches the audit framework, its tests must PASS before edits (regression-first).
If blocked, refuse and explain. If clear, proceed."
```