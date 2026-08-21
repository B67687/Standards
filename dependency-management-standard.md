# Dependency Management Standard

## Purpose

Tier every project's dependency policy so each one gets exactly the right amount of attention — and no more. The goal is zero-worry dependency management: a project either has an automated, tested update flow, a scheduled batch, or is deliberately frozen. No middle ground, no per-PR agonizing.

The tier is a **risk decision**, not a reflection of love for the project. Love all your projects; give each one a policy.

## The Tiering Model

| Tier | Name | Cadence | When |
|------|------|---------|------|
| T0 | Frozen | Never | Throwaway, forks, archived, dormant |
| T1 | Quarterly | Every 3 months | Personal tools, no external consumers |
| T2 | Weekly | Every week | Active projects you maintain |
| T3 | Audited | Weekly + gate | Internet-facing, money, credentials |

### Tier Assignment Criteria

Ask, in order:

1. **Does it face the internet, handle money, or hold credentials?** → T3
2. **Do other people depend on it?** → T2 (minimum)
3. **Are you actively working on it?** → T2
4. **Do you still use it at all?** → T1
5. **Anything else (throwaway, fork, archived, group project you don't own)?** → T0

Private `*-Dev` scratchpad repos **inherit their public mirror's tier** — they are one maintenance unit, never two.

## Files

### Universal: lockfile

Every repo with dependency manifests MUST commit its lockfile. The lockfile — `package-lock.json`, `Cargo.lock`, `uv.lock`, `poetry.lock`, `go.sum` — is what pins exact versions. **Pinning is already solved by the lockfile; the tier decides when you move it.**

### Tier marker: `.dependency-tier`

The repo declares its tier in a root file `.dependency-tier` containing exactly one of `T0`, `T1`, `T2`, `T3`. This makes the tier machine-readable for the audit and unambiguous for humans. Repos without a marker default to T1 (recommended personal default) for audit purposes.

### T2/T3: `renovate.json`

Renovate is the canonical bot. Rationale: it **groups** dependency updates into few PRs (one "all patch/minor" PR per week) instead of flooding one PR per dependency like Dependabot. Grouping is what makes dependency maintenance cheap enough to be weekly.

```json
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "extends": ["config:recommended"],
  "schedule": ["before 8am on monday"],
  "groupName": "all non-major",
  "group": {
    "matchUpdateTypes": ["patch", "minor"],
    "groupName": "all non-major"
  },
  "packageRules": [
    {
      "matchUpdateTypes": ["patch", "minor"],
      "automerge": true,
      "automergeType": "pr",
      "platformAutomerge": true
    }
  ],
  "separateMajorMinor": true
}
```

**CI is a precondition for T2.** Auto-merging on green CI is the whole mechanism; no CI means no auto-merge — run the tier "T2-lite" (grouped PRs, manual merge) until CI exists.

## Rules

1. **Lockfile MUST be committed** for any repo with dependency manifests
2. **Lockfile MUST be tracked by git** — never gitignored
3. **Tier MUST be declared** via `.dependency-tier` (T0–T3)
4. **T2/T3 MUST have a dependency bot** — Renovate (preferred) or Dependabot, one per repo
5. **T2/T3 MUST have CI** that runs tests on PRs before automerge is enabled
6. **Renovate MUST group** patch+minor updates and separate majors
7. **Patch/minor automerge only** — majors always require human review
8. **T1 MUST batch quarterly** — no weekly churn, no per-PR review
9. **T0 MUST be untouched** — no updates, no scanning, no attention. Risk is consciously accepted
10. **T3 adds the audit gate** — CI fails on known critical vulnerabilities (`cargo audit`, `npm audit`, `osv-scanner`), plus supply-chain verification and SBOM for releases

11. **Lockfile MUST be enforced in CI** — install with a frozen-lockfile command (`npm ci`, `cargo --locked`, `uv sync --locked`, `poetry install --locked`); never a bare update on build
12. **Only trusted sources** — pin resolution to official registries (crates.io, npmjs); forbid unvetted git/path/alternate-registry sources unless explicitly allowlisted
13. **No install scripts by default** — ignore package install scripts unless individually allowlisted (npm `ignore-scripts` + `allow-scripts`); review before enabling

## Supply-Chain Security

The tier above sets *when* dependencies move. This section sets *what is allowed in* and *how it is verified* — the security dimension all frameworks converge on ([SLSA](https://slsa.dev), [NIST SSDF SP 800-218](https://csrc.nist.gov/pubs/sp/800/218/final), [OWASP A03:2025](https://owasp.org/Top10/A03_2025-Software_Supply_Chain_Failures/), [CNCF Best Practices](https://tag-security.cncf.io)), mapped onto the tier model so each tier carries exactly the attention it needs.

### Security posture by tier

| Tier | Posture | Key requirements added |
|------|---------|------------------------|
| T0 | Conscious acceptance | None — risk deliberately accepted, not scanned
| T1 | Source + integrity | Trusted sources only; lockfile enforced; frozen install
| T2 | + scanning gate | SCA gate in CI fails on critical/high; review before major bumps
| T3 | + provenance & SBOM | Signed provenance (SLSA L2+); SBOM generated in CI; source whitelist

### The six controls

1. **Inventory everything** — include transitive deps. T3 generates an SBOM (CycloneDX or SPDX) in CI covering the CISA/NSA/FBI [2026 Minimum Elements for an SBOM](https://www.cisa.gov) (supersedes NTIA 2021).
2. **Scan continuously, gate on risk** — SCA in CI fails on critical/high (T3) or high (T2). Remediate criticals within days. `cargo audit`, `npm audit`, `osv-scanner`, Dependency-Check.
3. **Trusted sources + integrity** — official registries only, source-whitelisted; lockfiles carry content hashes; prefer signed packages; verify registry signatures where available.
4. **Provenance / attestation** — build integrity claims (SLSA L1–L3). T3: signed provenance, publish with attestation (npm `--provenance` / Sigstore).
5. **Harden the pipeline** — least privilege, MFA, env-scoped secrets, immutable artifacts, staged/canary rollouts, separation of duties in CI/CD.
6. **Minimize + deliberate choice** — remove unused deps, prefer maintained ones, upgrade deliberately (never `*`/`latest`), pin via lockfile.

### Source whitelisting (dependency confusion / typosquatting)

- **Rust/Cargo**: `cargo-deny` `[sources]` — allow only `crates.io-index`; deny git/path/unknown. The strongest mainstream source control.
- **npm**: scoped internal names (`@yourorg/pkg`), pin scopes to the private registry in `.npmrc`, reserve internal names on the public registry (empty placeholders), disable install scripts by default.
- General: verify package identity (registry metadata, changelog) before adding; treat typosquatting/slopsquatting as the default threat model.

## Edge Cases

### Repos with no dependencies

Docs-only repos (pure Markdown) have no manifests → no lockfile, no bot, tier irrelevant. The audit skips them automatically. Do not create `.dependency-tier` files for them unless you want them registered.

### Forks

Forks are T0 by default — you don't own the upstream policy. Only upgrade to T1+ if you maintain a meaningful delta.

### Group projects you don't own

T0. You are a collaborator, not the policy owner. Dependency decisions belong to the repo owner.

### Archived / superseded repos

T0. Archive them (`gh repo archive`) so they drop out of attention entirely.

### Semver-compatible ranges vs pins

Manifest ranges (`^4.18.0`) are fine — the lockfile pins what you actually install. Never put `"*"` or `latest` in manifests; the lockfile stops being a pin and every build becomes a gamble.

## Reference

- [Renovate configuration docs](https://docs.renovatebot.com/configuration-options/)
- [Renovate grouping docs](https://docs.renovatebot.com/key-concepts/groups/)
- [osv-scanner](https://google.github.io/osv-scanner/)
- [cargo audit](https://github.com/rustsec/rustsec)
- [npm audit](https://docs.npmjs.com/cli/v10/commands/npm-audit)
- [SLSA v1.2](https://slsa.dev/spec/v1.2/requirements)
- [NIST SSDF SP 800-218](https://csrc.nist.gov/pubs/sp/800/218/final)
- [OWASP A03:2025 Supply Chain](https://owasp.org/Top10/A03_2025-Software_Supply_Chain_Failures/)
- [CISA 2026 Minimum Elements for an SBOM](https://www.cisa.gov)
- [CNCF Software Supply Chain Best Practices](https://tag-security.cncf.io)
- [cargo-deny](https://github.com/EmbarkStudios/cargo-deny) / [cargo-vet](https://mozilla.github.io/cargo-vet/) / [cargo-crev](https://github.com/crev-dev/cargo-crev)
- [OpenSSF npm Best Practices](https://openssf.org/blog/2022/09/01/)
