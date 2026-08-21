# RESEARCH_VERIFICATION.md: Research on Demand Record

> **Purpose:** Every decision-relevant claim in SPECIFICATION.md carries a verification tier (L0-L3) and a source that exists. This record is the audit trail. Tiers follow the Development Protocol's LANDSCAPE.md § Verification Tiers (lines 155-180): the tier is set by the CONSEQUENCE of being wrong, never by AI confidence.

## Verification Tiers (reference)

| Tier | Trigger | Action | Cost |
| --- | --- | --- | --- |
| **L0: No check** | Trivial claim, no decision impact; output of executed code/tool (self-verifying) | State it; no tool calls | ~0 |
| **L1: Lightweight authoritative check** (DEFAULT for factual claims) | Any claim that could affect planning/decisions; any number, date, name, version, API, or citation | One targeted search against an authoritative source | 1 call |
| **L2: Cross-check** | Decision-relevant, surprising, contested, or newly-claimed; would trigger rework if wrong | 2+ independent sources; corroborate; attach per-claim citations | 2-4 calls |
| **L3: Deep verification** | One-way-door / high-stakes decision | Multi-source research with adversarial refutation pass; external oracle | Mini-research project |

## Claims in SPECIFICATION.md and Their Verification

| Claim (SPEC section) | Tier | Source that exists | Verified |
| --- | --- | --- | --- |
| "The repo passes its own audit" (§1, §5, §8) | L0 | `./scripts/audit.sh --exit-code .`: self-verifying by execution | Yes: run at commit time, exit 0 |
| "24 standards, 128 checks" (§1, §4, §8; authoritative per README.md) | L0 | `./scripts/audit.sh --list-standards` + `ls scripts/checks/*.sh`: self-verifying by execution | Yes: 24 registered standards, 128 checks |
| "Plugin architecture: drop a `checks/<standard>.sh` file, it auto-registers" (§2, §4, §11) | L0 | `scripts/audit.sh` source loop over `scripts/checks/*.sh` | Yes: read the source |
| "No runtime dependencies beyond standard POSIX tools" (§6, §10) | L0 | `scripts/audit.sh`, `scripts/audit-lib.sh`: pure bash, no external binaries | Yes: read the source |
| "Self-consistency check prevents recursive failure via `SELF_CONSISTENCY_ACTIVE` env guard" (§5) | L0 | `scripts/checks/self-consistency.sh` lines 32-38 | Yes: read the source |
| "Shell checks before agent judgment" (§0, §6, §11) | L0 | `scripts/audit.sh` runs shell checks synchronously; `--agent-reviews` is opt-in | Yes: read the source |
| "Checks are advisory by default; `--fix` applies additive safe fixes" (§6, §11) | L0 | `scripts/audit.sh` `FIX_MODE` handling; `_fix_run` in `scripts/audit-lib.sh` | Yes: read the source |
| "Standards may reference authoritative external sources (OWASP, NASA, RFC 6761, Keep a Changelog, SemVer)" (§12) | L1 | OWASP (owasp.org), NASA (nasa.gov), RFC 6761 (rfc-editor.org), Keep a Changelog (keepachangelog.com), SemVer (semver.org): all exist and are authoritative | Yes: authoritative standards bodies |
| "State-machine transition tables catch invariant violations at spec time" (PROJECT_MODEL rationale, §2) | L2 | The canonical Development-Protocol SPECIFICATION.md §2 cites Torkar (transition-table tests) and D'Ambros (co-change defect prediction). The specific quantitative figures (26 faults, p=0.01) could NOT be corroborated at L2 in this pass, so they are NOT carried into this repo's SPECIFICATION.md. The qualitative claim (transition tables catch invariant violations) is retained as design rationale, not as a cited statistic. | Partial: qualitative claim retained, quantitative figures omitted |

## Operating Rules Applied

1. **Decisiveness gate**: every claim above was asked "would the decision change if this claim were false?"; the self-verifying claims are L0 because the repo's own tooling is the oracle.
2. **Ground, don't recall**: no claim in SPECIFICATION.md is asserted from model memory; each is backed by a file in this repo or an authoritative external standard.
3. **Corroborate or abstain**: the Torkar/D'Ambros quantitative figures could not be corroborated and were therefore omitted rather than guessed.
4. **Separate writer from checker**: this record was written against the SPEC and re-checked against the actual scripts before commit.

## Update Procedure

When a new decision-relevant claim enters SPECIFICATION.md: add a row to the table above with its tier and a source that exists, before the change is committed. A claim with no source row is an unverified claim and blocks the commit.