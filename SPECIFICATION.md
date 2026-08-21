# Standards Repo: Specification

## 0. Constitution (Immutable Project Rules)

The constitution constrains ALL executor actions. If an action would violate these rules, the executor MUST refuse.

### MACRO: System Principles

```
Standards Repo Constitution:
1. Correctness: wrong output at any speed is useless. A check that passes on a non-compliant repo is worse than no check.
2. No magic: explicit > implicit. Every standard, check, and dependency is declared in a document or manifest.
3. Inward dependencies: core knows nothing about edges. The audit framework (audit.sh + audit-lib.sh) knows nothing about any specific target repo.
4. Test what matters: one behavior per check, edge cases before happy path. Checks assert a predicate, not a vibe.
5. Fail with context: every failed check names the rule, the predicate, and the repo it ran against.
6. Tool-first: never hand-roll what a deterministic tool handles. Shell checks before agent judgment; shellcheck, sops, trivy, and mise do the deterministic work.
7. No new runtime dependency without a Y-Statement: recorded in section 2.
8. Self-auditing: the Standards repo must pass its own audit (self-consistency standard).
```

**MESO/MICRO:** Inward dependencies means check plugins never import each other and never depend on a target repo's internals; they only read files and run predicates. Tool-first means a new standard ships with a deterministic check script, not a prose promise. Every check plugin registers itself via `ALL_STANDARDS+=()` and exposes `checks_<name> <repo>`; there is no central registry to update.

## 1. Overview

The Standards repo is an authoritative reference library of quality standards with automated shell-based audit enforcement. It defines what "good" means for every project in the ecosystem and provides deterministic tooling to verify compliance. 31 standards, 152 checks, cross-repo dashboard. Self-auditing: the repo passes its own audit.

Part of the meta-project trio (Process / Quality / Knowledge). The Standards repo owns quality conventions. The Dev Protocol owns process conventions. The Lessons repo owns experiential knowledge.

**OUT OF SCOPE (V1):**
- New standards beyond the 24 documented: deferred until the existing inventory is fully audited
- A compiled audit runtime: the POSIX-shell system is the contract; no rewrite
- Continuous monitoring or alerting: audits run on demand or on commit/PR

## 2. Architecture

```
standards/
├── *.md                           # Standard definitions (what + why)
├── scripts/
│   ├── audit.sh                   # CLI entry point: audit a single repo
│   ├── audit-lib.sh               # Shared framework: _check, reporter, JSON output
│   ├── audit-all.sh               # Batch audit across multiple repos
│   ├── agent-check.sh             # Dispatches agent-eval requests for subjective checks
│   ├── checks/*.sh                # One file per standard: plugins auto-discovered
│   ├── generate-badge.sh          # shields.io-style inline SVG badge generator
│   ├── set-repo-topics.sh         # Apply GitHub topic sets per repo type
│   ├── install-ai-commit-hooks.sh # Global hook installer (pre-commit, pre-push, prepare-commit-msg)
│   ├── pre-commit                 # Identity gate hook
│   ├── pre-push                   # Signature check hook
│   ├── prepare-commit-msg         # AI attribution trailer hook
│   ├── commit-msg                 # Commit conventions hook
│   └── setup-env-enc.sh           # Encrypted env setup (sops/age)
├── docs/
│   ├── adr/                       # Architecture decision records
│   ├── badges/                    # Static SVG badges (no external service)
│   └── screenshots/               # App/screenshot assets
├── .omo/
│   ├── dashboard/                 # Generated audit results + HTML dashboard
│   ├── audit/                     # Per-repo audit artifacts
│   ├── drafts/                    # Draft standard documents
│   ├── plans/                     # Execution plans
│   └── ledger/                    # Project ledger
├── Makefile                       # self-audit, shellcheck, check targets
├── mise.toml                      # Tool version manifest
├── .gitignore                     # Whitelist-based (gitaccept pattern)
├── .github/workflows/ci.yml       # GitHub Actions: shellcheck + self-audit
├── .pre-commit-config.yaml        # Pre-commit hooks
├── .commitlintrc.json             # Conventional commit config
├── .editorconfig                  # Cross-editor config
├── .env.example                   # Env template
├── .env.encrypted                 # Encrypted env (sops/age)
├── .sops.yaml                     # SOPS config
├── CREDITS.md                     # AI attribution table + badges
├── CHANGELOG.md                   # Keep a Changelog + SemVer
└── README.md                      # Project index + quick start
```

### PROJECT_MODEL: Whole-Project State Machine (MANDATORY)

The Standards repo documents its whole-project state machine at `docs/PROJECT_MODEL.md`: states, valid/invalid transitions, invariants, and the blast-radius map of which standard documents and check scripts co-change. Not optional polish: the project's health contract. Every change to the standard inventory or the audit framework is a state transition and must appear in that table. See [docs/PROJECT_MODEL.md](docs/PROJECT_MODEL.md).

## 3. Intent

Single source of truth for what "good" means across all projects. Prevents each project from re-deriving quality criteria independently. Provides deterministic enforcement so compliance is machine-verifiable, not human-negotiable.

The system answers three questions:

- What are the rules? (standard documents)
- Does this repo follow them? (audit scripts)
- Which repos need work? (cross-repo dashboard)

## 4. File Tree

### Standard Documents (31)

| File                                  | Scope                                                 |
| ------------------------------------- | ----------------------------------------------------- |
| `0-meta-standards.md`                 | Minimal Surface Principle, YAGNI, no cleanup commits  |
| `adr-standard.md`                     | Architecture Decision Records format and workflow     |
| `agent-first-vcs.md`                  | Whitelist-native VCS design for AI agent workflows    |
| `ai-attribution-standard.md`          | CREDITS.md format, badge system, README attribution   |
| `auto-commit-gitops-standard.md`      | Automated commit workflow, lefthook conventions       |
| `badge-standard.md`                   | SVG badge format, color conventions, generator script |
| `changelog-standard.md`               | Keep a Changelog + SemVer, git-cliff integration      |
| `ci-pipeline-standard.md`             | 3-stage model, local review.sh, SAST, security tools  |
| `commit-conventions-standard.md`      | 10 commit types, structured messages, scopes          |
| `cs-project-architecture-standard.md` | C# project structure conventions                      |
| `git-history-cleanup-standard.md`     | Rebase, squash, filter-repo rules                     |
| `github-topics-standard.md`           | Topic naming, per-repo topic sets                     |
| `gitignore-standard.md`               | Whitelist/gitaccept approach, tiered classification   |
| `license-standard.md`                 | MIT default, copyright format, exceptions             |
| `naming-conventions-standard.md`      | File, directory, and symbol naming rules              |
| `path-agnosticism-standard.md`        | No hardcoded paths, configurable search dirs          |
| `README-standard.md`                  | Section order, badge header, templates per audience   |
| `repo-structure-standard.md`          | Standard directory layout across projects             |
| `secrets-management-standard.md`      | sops/age encrypted env, gitignore patterns            |
| `self-consistency-standard.md`        | Meta-standard: standards repo must pass own audit     |
| `svg-screenshots-standard.md`         | SVG screenshot format, mobile/CLI/web types           |
| `tool-versions-standard.md`           | mise.toml convention, tool version manifest           |
| `svg-approach-decision-guide.md`      | Hand-crafted vs Mermaid pipeline decision tree        |
| `svg-standards.md`                    | Hand-crafted inline SVG standard (16 sections)        |
| `ai-attribution-pattern.md`           | Canonical format reference for CREDITS.md             |

_(Additional standards exist as reference docs and cross-repo inventory entries)_

### Audit Check Scripts (23 active check files)

| File                                | Checks | Standard                |
| ----------------------------------- | ------ | ----------------------- |
| `checks/adr.sh`                     | 5      | ADR                     |
| `checks/ai-attribution.sh`          | 6      | AI Attribution          |
| `checks/auto-commit-gitops.sh`      | 6      | Auto-Commit GitOps      |
| `checks/badge-shell.sh`             | 5      | Badge (shell)           |
| `checks/badge-quality.sh`           | 3      | Badge Quality (agent)   |
| `checks/changelog.sh`               | 6      | Changelog               |
| `checks/ci-pipeline.sh`             | 6      | CI Pipeline             |
| `checks/commit-conventions.sh`      | 6      | Commit Conventions      |
| `checks/cs-project-architecture.sh` | 4      | CS Project Architecture |
| `checks/git-history-cleanup.sh`     | 5      | Git History Cleanup     |
| `checks/github-topics.sh`           | 5      | GitHub Topics           |
| `checks/gitignore.sh`               | 7      | .gitignore              |
| `checks/lefthook.sh`                | 6      | Lefthook                |
| `checks/license.sh`                 | 4      | License                 |
| `checks/naming-conventions.sh`      | 5      | Naming Conventions      |
| `checks/path-agnosticism.sh`        | 4      | Path Agnosticism        |
| `checks/readme-quality.sh`          | 8      | README Quality          |
| `checks/repo-structure.sh`          | 7      | Repo Structure          |
| `checks/secrets-management.sh`      | 4      | Secrets Management      |
| `checks/self-consistency.sh`        | 1      | Self-Consistency        |
| `checks/svg-screenshots.sh`         | 5      | SVG Screenshots         |
| `checks/tool-versions.sh`           | 5      | Tool Versions           |
| `checks/trivy-secrets.sh`           | 5      | Trivy Secrets           |

### Architecture Decision Records

| Date                                      | Title                                                                        |
| ----------------------------------------- | ---------------------------------------------------------------------------- |
| `2026-06-23-audit-system-architecture.md` | Audit System Architecture: shell checks + agent evals + plugin architecture |

### Supporting Scripts

| Script                       | Purpose                                                 |
| ---------------------------- | ------------------------------------------------------- |
| `generate-badge.sh`          | shields.io-style inline SVG generator with icon support |
| `set-repo-topics.sh`         | Apply standardized GitHub topics per repo type          |
| `install-ai-commit-hooks.sh` | Global hook installer for all repos                     |
| `setup-env-enc.sh`           | Environment setup with sops/age encryption              |

## 5. CI

**GitHub Actions**: single workflow at `.github/workflows/ci.yml`:

```yaml
on: [push, pull_request] → main
jobs:
  audit:
    steps:
      - checkout
      - apt: shellcheck
      - shellcheck scripts/*.sh scripts/checks/*.sh
      - ./scripts/audit.sh --exit-code .
```

Triggers on push and PR to main. Two gates:

1. **shellcheck**: all scripts must pass shellcheck at warning severity
2. **self-audit**: `audit.sh --exit-code .` must exit 0 (the repo must conform to its own standards)

The self-audit gate ensures that every standard the repo enforces externally also applies internally. Self-consistency check prevents recursive failure via `SELF_CONSISTENCY_ACTIVE` env guard.

## 6. UX

All audit commands are single-binary shell scripts. No runtime dependencies beyond standard POSIX tools (bash, grep, sed, find, sort). Optional: python3 for dashboard, sops/age for encrypted secrets.

### Audit a single repo

```bash
./scripts/audit.sh /path/to/repo
./scripts/audit.sh --fix /path/to/repo          # Auto-fix common issues
./scripts/audit.sh --exit-code --standard ai-attribution /path/to/repo  # Targeted CI gate
```

### Batch audit across repos

```bash
./scripts/audit-all.sh -d /path/to/projects      # Discover all git repos
./scripts/audit-all.sh -f repo-list.txt          # Explicit repo list
./scripts/audit-all.sh --agent-reviews           # Also run agent evaluations
```

### Generate dashboard

```bash
./scripts/dashboard.sh                           # Reads batch results, generates HTML
./scripts/dashboard.sh --json-only               # Machine-readable compliance matrix
```

### List and inspect

```bash
./scripts/audit.sh --list-standards              # All registered standard IDs
./scripts/audit.sh --help                        # Full option reference
```

### Self-audit (from repo root)

```bash
make audit                                       # Audit current repo
make audit-exit                                  # Audit with CI-style exit code
make check                                       # audit-exit + shellcheck
```

### Output formats

- **terminal** (default): color-coded pass/fail/pending per check, summary table
- **json**: structured results for machine consumption, stdout is pure JSON
- **quiet**: no output, exit code only

Exit code 1 on any failure when `--exit-code` is set. Advisory by default (never blocks).

## 7. Non-Goals

- **Not a meta-protocol**: Process conventions belong in the Dev Protocol repo, not here
- **Not a knowledge base**: Experiential learning, post-mortems, and patterns belong in the Lessons repo
- **Not language-specific**: All standards must apply across any language or project type. Shell-based enforcement is deliberately language-agnostic
- **Not a CI system**: Audit scripts report status; they do not run builds, deploy artifacts, or orchestrate pipelines
- **Not a propagation system**: Cross-repo template propagation was considered and explicitly deferred
- **Not a linter**: Standards define what "good" means; existing language-specific linters (shellcheck, clippy, ruff) are referenced but not replaced
- **Not real-time**: Audits run on demand or on commit/PR. No continuous monitoring or alerting

## 8. Success Metrics

| Metric                    | Target                    | Current                           |
| ------------------------- | ------------------------- | --------------------------------- |
| Standards documented      | 31                        | 31 (identified, varying maturity) |
| Automated checks          | 152                       | 152 (shell + agent + tool)        |
| Repos compliant           | All tracked repos         | Partial (per standard)            |
| Dashboard status          | All green                 | Per-standard pass/fail/pending    |
| Self-audit pass           | Always                    | Enforced by CI                    |
| Shellcheck pass           | All scripts warning-free  | Enforced by CI                    |
| Cross-repo inventory live | auto-generated from audit | Static + audit-driven             |

## 9. Timeline

The Standards repo already exists and is functional. The trajectory follows four phases:

| Phase      | Status   | What                                                                |
| ---------- | -------- | ------------------------------------------------------------------- |
| DISCOVER   | Complete | 31 standards identified across 33+ repos                            |
| WORK       | Complete | Audit scripts, CI, dashboard operational                            |
| PERFECT    | Current  | Protocol alignment, missing artifacts, cross-references             |
| DISTRIBUTE | Next     | Cross-reference with Dev Protocol; integrate REVIEW.md audit checks |

**Circuit breaker:** IF the self-audit (`./scripts/audit.sh --exit-code .`) fails on main THEN the project SHALL stop adding standards or checks until the audit is green again.
This specification document is part of the PERFECT phase: formalizing governance artifacts that were previously implicit.

## 10. Dependencies

**None.** The entire audit system runs on standard POSIX shell. No runtime, no interpreter beyond bash, no package manager, no npm/pip/cargo install.

### Optional dependencies (for specific features)

| Tool           | Version (mise.toml)             | Required by                      | Purpose                               |
| -------------- | ------------------------------- | -------------------------------- | ------------------------------------- |
| `python3`      | system                          | `dashboard.sh`                   | JSON parsing, HTML generation         |
| `jq`           | system                          | `dashboard.sh` (fallback)        | JSON parsing when python3 unavailable |
| `shellcheck`   | mise: latest                    | CI, `make shellcheck`            | Script linting                        |
| `sops` + `age` | mise: latest                    | `secrets-management-standard.md` | Encrypted secrets                     |
| `trivy`        | mise: latest                    | `trivy-secrets` check            | Secret scanning                       |
| `git-cliff`    | mise: latest                    | `changelog-standard.md`          | Changelog generation                  |
| `lefthook`     | mise: latest                    | `auto-commit-gitops-standard.md` | Hook management                       |
| `mise`         | min_version 2024.1.1            | `tool-versions-standard.md`      | Version management                    |

### Meta-dependency

The Standards repo depends on the Dev Protocol for its governance structure (phase definitions, artifact templates, cross-referencing conventions). This is a documentation coupling, not a runtime coupling.

## 11. Design for Change Rules

| Rule                         | Status                                | Application                                                                                                                                                     |
| ---------------------------- | ------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Interface after 2nd consumer | Plugin architecture                   | Checks auto-register from `scripts/checks/*.sh`. No central registry to update. New standard = new file.                                                        |
| Test contract, not impl      | Shell checks are deterministic        | Each check tests a predicate (file exists, grep matches, format validates). Implementation details of the target repo are invisible.                            |
| Module boundary              | Single entry point                    | `audit.sh` is the only CLI. All checks are sourced plugins. No subcommands, no nested executables.                                                              |
| Size (250/40)                | Standard documents may exceed 250 LOC | Exception noted. Some standards (gitignore at 522 lines, svg-standards) are reference documents with examples and edge cases. Audit scripts stay under 250 LOC. |
| Shippable per cycle          | Each standard + check                 | Adding a new standard means: write the `.md`, add the `checks/*.sh`, register in the inventory. Each addition is independently shippable.                       |
| Appetite before scope        | Not applicable                        | Existing project. Standards are identified, not invented.                                                                                                       |
| AI code same checks          | Scripts pass own audit                | Self-consistency check enforces that audit scripts themselves meet the standards they enforce. No special exemptions.                                           |
| Rule of three                | Standard extraction                   | When the same convention appears across three repos independently, it gets extracted into a standard document.                                                  |
| Core != infrastructure       | Pure shell                            | Audits are pure functions of repo state. No daemons, no databases, no state files, no infra coupling.                                                           |

## 12. Documentation Strategy

**Standard documents ARE the documentation.** Each `*-standard.md` file is self-contained: it defines the rule, the rationale, the success criteria, and the audit check that enforces it. No separate implementation guide.

| Layer            | File                        | Audience                                  |
| ---------------- | --------------------------- | ----------------------------------------- |
| Index            | `README.md`                 | New users, quick reference                |
| Master inventory | `cross-repo-standards.md`   | Maintainers tracking maturity             |
| Self-diagnostics | `RULES.md`                  | AI agents understanding project structure |
| This spec        | `SPECIFICATION.md`          | Protocol-level formalization              |
| Handover         | `HANDOVER.md`               | Future developers picking up the project  |
| Credits          | `CREDITS.md`                | AI attribution transparency               |
| Changelog        | `CHANGELOG.md`              | Release history                           |
| Meta-standard    | `0-meta-standards.md`       | Philosophy: Minimal Surface Principle     |
| Decision records | `docs/adr/`                 | Architecture decisions and rationale      |
| Badges           | `docs/badges/*.svg`         | Visual status indicators                  |
| Dashboard        | `.omo/dashboard/index.html` | Live cross-repo compliance                |

**External references**: Standards may reference authoritative external sources (OWASP, NASA, RFC 6761, Keep a Changelog, SemVer) where they exist. The standard defines how we apply them, not what they say.

**Research verification**: decision-relevant claims in this specification are verified per the Research-on-Demand tiers (L0-L3) from the Development Protocol's LANDSCAPE.md. The verification record, with sources that exist and support each claim, is at [docs/RESEARCH_VERIFICATION.md](docs/RESEARCH_VERIFICATION.md).

## 13. AI Attribution

The Standards repo was built with AI assistance. All standard documents, audit scripts, and infrastructure were designed, implemented, and reviewed using AI models.

| Phase          | Model                           | Harness         | Role                                     |
| -------------- | ------------------------------- | --------------- | ---------------------------------------- |
| Architecture   | DeepSeek V4 / Claude 4 Sonnet   | Oh My OpenAgent | System design, pattern decisions         |
| Implementation | DeepSeek V4 Flash               | Oh My OpenAgent | Audit system, check scripts, dashboard   |
| Documentation  | DeepSeek V4 Flash               | Oh My OpenAgent | Standard definitions, this specification |
| Review         | DeepSeek V4 (Oracle)            | Oh My OpenAgent | Code review, QA, security audit          |
| Research       | DeepSeek V4 (Explore/Librarian) | Oh My OpenAgent | Codebase analysis, pattern discovery     |

Details: `CREDITS.md`, `docs/badges/` with per-model SVG badges. Human direction, review, and approval by B67687.

## 14. Ecosystem & Community (Tier 3)

### MACRO: Governance

```
License: MIT (SPDX: MIT)
Contribution model: PR-based, single maintainer (B67687); contribution breakdown in README
Code of conduct: not yet adopted (single maintainer); SECURITY.md defines the security reporting path
Consumers: this repo is the knowledge backend for the /solve skill and the source of the
  Development-Protocol governance standards enforced across the ithmb and standards repos
Standards compliance: Conventional Commits, editorconfig, typos, commitlint, pre-commit,
  gitleaks secret scan, shellcheck for scripts, SPDX license headers where applicable
```

**MESO/MICRO:** Upstream references: the Development-Protocol (REVIEW gate, LANDSCAPE.md
research tiers, RULES/SPEC/EXPLAINER conventions) and the external authorities cited by each
standard (OWASP, NIST, SLSA, NASA, RFC 6761, Keep a Changelog, SemVer). Downstream: the
repositories that adopt these standards (Ithmb-Codec, Ithmb-Codec-Web, Imageglass-Ithmb-Plugin)
and any project that imports a standard from this knowledge base. PR requirements: audit
green (`make audit-exit`), tests pass, Conventional Commit message, standards table in
README kept in sync with any new or changed standard.

## 15. Verification Checklist (Executor Reads Before Starting)

- [ ] All `{{placeholders}}` across all sections are filled
- [ ] No "TODO" or "TBD" remains
- [ ] Constitution (section 0) has at least 3 principles
- [ ] Out-of-scope list (section 1) is non-empty
- [ ] Each architecture decision (section 2) includes a Y-Statement
- [ ] Each dependency (section 10) has a version constraint
- [ ] Timeline (section 9) has a circuit breaker condition
- [ ] Tier 1 sections 0-7 are fully filled
- [ ] Tier 2 sections 8-11 are filled for production projects
- [ ] Tier 3 sections 12-14 are filled for open-source projects
- [ ] **Spec self-consistency grep**: run `grep -n "Step " SPEC.md` and confirm step/phase numbering is monotonic with no duplicates before EXECUTOR starts
- [ ] **FEATURES.md** exists (docs/FEATURES.md): every IN SCOPE item is an `approved` entry; no `applied` feature lacks linked tests; statuses are valid (proposed/approved/applied/archived). For the Standards repo the feature inventory is the standards table in README.md and cross-repo-standards.md
- [ ] **Test anchoring**: every test references a check ID or standard ID (e.g., `tool-versions`); a test proving no contract is flagged, not silently carried
- [ ] **PROJECT_MODEL**: docs/PROJECT_MODEL.md exists and the change under review appears as a transition
- [ ] **Research verification**: decision-relevant claims carry a verification tier and a source that exists (docs/RESEARCH_VERIFICATION.md)
- [ ] **Baseline**: test count and audit pass counts recorded for the next review to compare (see .omo/reviews/)
