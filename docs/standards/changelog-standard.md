# Changelog Standard

## Domains

docs,universal


## Format

Use **[Keep a Changelog](https://keepachangelog.com/en/2.0.0/)** format with **[Semantic Versioning](https://semver.org/spec/v2.0.0.html)**.

`CHANGELOG.md` in repo root.

## Structure

```markdown
## [Unreleased]

### Added / Changed / Deprecated / Removed / Fixed / Security

- One-liner for most changes; paragraph + context for complex features
- Cross-references to related work where helpful

## [1.0.0] — 2026-06-14

### Added
- Initial release features...

[Unreleased]: https://github.com/OWNER/REPO/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/OWNER/REPO/releases/tag/v1.0.0
```

## Change Types

| Type | When to use |
| ---- | ----------- |
| **Added** | New features, new files, new capabilities |
| **Changed** | Modifications, behavior changes, refactoring |
| **Deprecated** | Features marked for removal (not yet removed) |
| **Removed** | Features deprecated and now removed |
| **Fixed** | Bug fixes, patches |
| **Security** | Vulnerability disclosures, security hardening |

Non-standard sections may appear below the six types for project-specific tracking.

## Integration with Conventional Commits

| Commit Type | Section | | Commit Type | Section |
| ----------- | ------- | | ----------- | ------- |
| `feat` | Added | | `perf` | Changed |
| `fix` | Fixed | | `security` | Security |
| `refactor` | Changed | | `deprecate` | Deprecated |
| `docs` | _If user-facing_ | | `remove` | Removed |
| `test` | _If infra changes_ | | `chore` | _Skip unless significant_ |

## Versioning

- Follow [SemVer](https://semver.org/): `MAJOR.MINOR.PATCH`
- **MAJOR**: breaking changes
- **MINOR**: new features, backward-compatible
- **PATCH**: bug fixes, backward-compatible
- Pre-release: `1.0.0-alpha.1`, `1.0.0-beta.2`

## Dates

ISO 8601: `YYYY-MM-DD`

## When to Start

Add `CHANGELOG.md` at **project init** — not at first release. An empty `## [Unreleased]` section signals tracking from day one.

## Workflow

### Hand-Crafted (Default)

1. Keep `## [Unreleased]` at the top; add entries per type as changes are made
2. At release, rename `[Unreleased]` to the version number and date
3. Create a fresh `## [Unreleased]` section above it

### Hybrid (Optional: Hand-Crafted + git-cliff)

For repos with commitlint/conventional-commits setup:

1. Hand-craft entries in `[Unreleased]` during development
2. Run `git cliff --unreleased --tag <version> --prepend CHANGELOG.md` as completeness check
3. Review entries (keep curated narrative, remove generated noise)
4. Commit, tag, release

## Template

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

[Unreleased]: https://github.com/OWNER/REPO/compare/v0.1.0...HEAD
```

## Edge Cases

### Pre-release versions (alpha, beta, rc)
Do not create stable entries for pre-releases. Track in `[Unreleased]`. If a pre-release has breaking changes users must know about, add one entry marked *(Preview — not for production)*.

### Multiple release lines (v1.x, v2.x)
Split into per-version files: `CHANGELOG_V2.md` (active), `CHANGELOG_V1.md` (maintenance). Root `CHANGELOG.md` links to detail files.

### Security advisories
Lead entries with the CVE ID: `- CVE-2026-1234: Description`.

### Yanked releases
Mark header with `[YANKED]`. Explain why in the body.

### Private / internal repos
Keep a changelog regardless of visibility. Lightweight format (`Added`, `Changed`, `Fixed`, `Removed`) is sufficient.

### Docs-only repos
Same format: `Added` = new pages, `Changed` = rewrites, `Fixed` = typos, `Removed` = retired pages.

### Internationalization
Single language (English). Do not translate the changelog.

### Version links
Reference-style links at bottom. First version links to its tag; subsequent versions link to compare:

```markdown
[Unreleased]: https://github.com/OWNER/REPO/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/OWNER/REPO/compare/v0.0.1...v1.0.0
[0.0.1]: https://github.com/OWNER/REPO/releases/tag/v0.0.1
```

## Tools

- **[git-cliff](https://git-cliff.github.io/)** — optional changelog generator from conventional commits. Use as a pre-release completeness check, not a replacement for hand-crafted narrative. Keep `cliff.toml` at repo root with `conventional_commits = true`.
- **[commitlint](https://commitlint.js.org/)** — conventional commit enforcement.

## Reference

- [keepachangelog.com](https://keepachangelog.com/) — the standard
- [semver.org](https://semver.org/) — versioning standard
- ithmb-codec [`CHANGELOG.md`](https://github.com/B67687/Ithmb-Codec/blob/main/CHANGELOG.md) — reference example
