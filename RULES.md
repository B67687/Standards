# Standards — Self-RULES.md

**Project:** Standards
**Phase:** PERFECT (exists, functional, needs formalization)
**Project type:** STANDARD (document-driven, familiar domain)
**Location:** /home/nami/projects/dev/standards/
**Updated:** 2026-07-27

## 1. Project Type Routing

STANDARD route — documentation + automation project, clear scope, familiar domain.

## 2. Intent Decomposition

The project decomposes into three layers:

1. **Standard documents** — what "good" means (31 standards, 152 checks)
2. **Audit scripts** — automated enforcement (shell-based, plugin architecture)
3. **Cross-repo integration** — compliance dashboard across all repos

## 3. Constitution

1. **Deterministic before judgment** — Shell checks before agent evaluations. Same repo, same result.
2. **Plugin architecture** — Drop a `checks/<standard>.sh` file, it auto-registers.
3. **Agnostic** — No hardcoded paths, no machine-specific config. Run from anywhere.
4. **Advisory by default** — Audit reports without modifying. `--fix` for remediation.
5. **Exit-code gated** — `--exit-code` for CI enforcement.
6. **Cross-repo by nature** — Standards apply across all repos, not per-project.
7. **Referential** — May reference external standards (OWASP, NASA, etc.) where they exist.

## 4. Phase Definitions

| Phase      | Status      | Key Deliverable                            |
| ---------- | ----------- | ------------------------------------------ |
| DISCOVER   | ✅ Complete | 31 standards identified, auditable         |
| WORK       | ✅ Complete | Audit scripts, CI, dashboard               |
| PERFECT    | ✅ Current  | Protocol alignment, missing artifacts      |
| DISTRIBUTE | ⬜ Next     | Cross-reference with Dev Protocol, Lessons |

## 5. Learning Shifts

| #   | What we learned                                             | Decision                                        |
| --- | ----------------------------------------------------------- | ----------------------------------------------- |
| 1   | Standards should be referenceable by name from Dev Protocol | REVIEW.md now checks Standards audit            |
| 2   | Standards is one of three meta-projects                     | Trio formalized: Protocol + Standards + Lessons |

## 6. Companion Repos

| Repo                                                          | Relationship                                      |
| ------------------------------------------------------------- | ------------------------------------------------- |
| Development-Protocol (github.com/B67687/Development-Protocol) | References Standards in REVIEW.md Phase 4.6       |
| Lessons                                                       | Cross-project learning, auto-loaded every session |

## 7. Current Artifacts

| Artifact                | Exists                              | Quality                |
| ----------------------- | ----------------------------------- | ---------------------- |
| README.md               | ✅ 150 lines, comprehensive         | Good                   |
| 31 standard documents   | ✅ Substantive (2-18K each)         | Good — clear structure |
| 23+ audit scripts       | ✅ Shell-based, plugin architecture | Good                   |
| CI pipeline             | ✅ GitHub Actions                   | Good                   |
| ADRs                    | ✅ docs/adr/                        | Good                   |
| Dashboard               | ✅ .omo/dashboard/                  | Good                   |
| cross-repo-standards.md | ✅ Master inventory (399 lines)     | Good                   |
| RULES.md (this)         | ✅ NEW                              | —                      |
| EXPLAINER.md            | ❌ Missing                          | —                      |
| SPECIFICATION.md        | ❌ Missing                          | —                      |
| shift-log.md            | ❌ Missing                          | —                      |

## 8. Content Audit Summary

Sampled standards show:

- **ADR Standard** (124 lines) — Clear what/when/where/format/hooks/scope/evolution. Professional quality.
- **.gitignore Standard** (522 lines) — Philosophy, implementation, examples, edge cases. Comprehensive.
- **AI Attribution Standard** (8.5K) — Detailed, with pattern reference and badge system. Production grade.
- General pattern: Each standard has What/When/Where/Format/Scope sections. Consistent structure.

The content is NOT dusty — it's substantive and well-organized. The gaps are:

1. Missing protocol governance artifacts (EXPLAINER.md, SPECIFICATION.md)
2. Some standards could reference external authorities where they exist
3. Integration with Dev Protocol needs documentation
