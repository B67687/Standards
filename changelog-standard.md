# Changelog Standard

## Format

Use **[Keep a Changelog](https://keepachangelog.com/en/2.0.0/)** format with **[Semantic Versioning](https://semver.org/spec/v2.0.0.html)**.

## File

`CHANGELOG.md` in repo root.

## Structure

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added

- New features, additions

### Changed

- Changes to existing functionality

### Deprecated

- Soon-to-be-removed features

### Removed

- Removed features

### Fixed

- Bug fixes

### Security

- Vulnerability fixes

## [1.0.0] — 2026-06-14

### Added

- Initial release features...

[Unreleased]: https://github.com/OWNER/REPO/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/OWNER/REPO/releases/tag/v1.0.0
```

## Change Types

| Type           | When to use                                                   |
| -------------- | ------------------------------------------------------------- |
| **Added**      | New features, new files, new capabilities                     |
| **Changed**    | Modifications to existing code, behavior changes, refactoring |
| **Deprecated** | Features marked for removal (not yet removed)                 |
| **Removed**    | Features that were deprecated and now removed                 |
| **Fixed**      | Bug fixes, patches                                            |
| **Security**   | Vulnerability disclosures, security hardening                 |

Non-standard sections like `Infrastructure` or `Documentation` may be used for project-specific tracking but should not replace the six standard types.

## Versioning

- Follow [SemVer](https://semver.org/): `MAJOR.MINOR.PATCH`
- **MAJOR**: breaking changes, incompatible API changes
- **MINOR**: new features, backward-compatible
- **PATCH**: bug fixes, backward-compatible
- Pre-release: `1.0.0-alpha.1`, `1.0.0-beta.2`

## Dates

ISO 8601: `YYYY-MM-DD`

## When to Start

Add `CHANGELOG.md` at **project init** — not at first release. An empty `## [Unreleased]` section signals that the project tracks changes from the start. Waiting until v1.0.0 means losing the changelog trail for the most important early development.

## Workflow

### Hand-Crafted (Default)

1. Keep an `## [Unreleased]` section at the top
2. Add entries as changes are made (under the appropriate type header)
3. At release time, rename `[Unreleased]` to the version number and date
4. Create a fresh `## [Unreleased]` section above it

### Hybrid (Optional: Hand-Crafted + git-cliff)

For repos with commitlint/conventional-commits setup:

1. Maintain hand-crafted narrative entries in `[Unreleased]` during development
2. Before release, run `git cliff --unreleased --tag <version> --prepend CHANGELOG.md` as a completeness check
3. Review entries (keep curated narrative, remove generated noise)
4. Commit, tag, release

This catches commits you forgot to mention without losing the editorial voice.

## Entry Detail

- **One-liner** for most changes: `- Added bus route caching`
- **Paragraph + context** for complex features: `- ARM64 NEON SIMD: full NEON implementations for RGB565, RGB555, and UYVY decoders — these previously fell to scalar on ARM64`
- **Cross-references** to related work: `Inspired by iOpenPod's _resolve_packed_geometry trailing-trim approach`

## Supplementary Sections

Non-standard sections may appear below the six standard types when they add structure:

```
### SIMD Architecture
| Decoder | x64 | ARM64 |
...
### Infrastructure
- CI: CodeQL analysis...
```

These are supplemental, not replacements. Keep them below the six standard types.

## Yanked Releases

```
## [0.0.5] — 2014-12-13 [YANKED]
```

Mark yanked releases with `[YANKED]` in the header. Explain why in the body.

## Reference Links

Use footnote-style links for version comparisons:

```markdown
[Unreleased]: https://github.com/OWNER/REPO/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/OWNER/REPO/compare/v0.9.0...v1.0.0
```

## Integration with Conventional Commits

| Commit Type | Changelog Section                        |
| ----------- | ---------------------------------------- |
| `feat`      | Added                                    |
| `fix`       | Fixed                                    |
| `refactor`  | Changed                                  |
| `docs`      | _Only if user-facing doc changes_        |
| `test`      | _Only if testing infrastructure changes_ |
| `chore`     | _Skip unless significant_                |
| `perf`      | Changed                                  |
| `security`  | Security                                 |
| `deprecate` | Deprecated                               |
| `remove`    | Removed                                  |

## Template

Copy this into any new repo:

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
Do NOT include pre-release versions as separate entries. Track changes in `[Unreleased]` section. Only create an entry when the stable version ships. If a pre-release has meaningful breaking changes that users must know about, add a single entry marked with *(Preview — not for production)*.

### Multiple release lines (e.g. v1.x and v2.x)
Split into per-version files when maintaining multiple active release lines:

```
CHANGELOG.md          # Root index with quick-reference table + links
CHANGELOG_V2.md       # v2.x series (active)
CHANGELOG_V1.md       # v1.x series (maintenance/EOL)
```

The root `CHANGELOG.md` remains the entry point, linking to detail files.

### Security advisories
Lead security entries with the CVE ID:

```markdown
### Security
- CVE-2026-1234: Fixed SQL injection in query builder.
- CVE-2026-5678: Patched XSS in template rendering.
```

### Private / internal repos
Keep a changelog regardless of visibility. A lightweight format (`Added`, `Changed`, `Fixed`, `Removed`) is sufficient. The changelog serves your future self as much as collaborators.

### Docs-only repos
The same format works, but section meanings shift: `Added` = new pages, `Changed` = rewrites, `Fixed` = typos/corrections, `Removed` = retired pages.

### Internationalization
Single language (English). Do NOT translate the changelog itself — maintaining N translations per release is not worth the cost.

### Version links
Reference-style links at the bottom of the file. First version links to its tag; subsequent versions link to compare:

```markdown
[Unreleased]: https://github.com/OWNER/REPO/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/OWNER/REPO/compare/v0.0.1...v1.0.0
[0.0.1]: https://github.com/OWNER/REPO/releases/tag/v0.0.1
```

## Tools

- **[git-cliff](https://git-cliff.github.io/)** — optional changelog generator from conventional commits. Use it as a pre-release completeness check, not a replacement for hand-crafted narrative. Works with existing commitlint setup. Configured via `cliff.toml` at repo root.
- **[commitlint](https://commitlint.js.org/)** — conventional commit enforcement. Already in ithmb-codec.

### git-cliff Configuration (`cliff.toml`)

When using git-cliff, keep `cliff.toml` at repo root. Minimal template:

```toml
[changelog]
header = "# Changelog\n\nAll notable changes to this project will be documented in this file.\n\n"
body = """
{% for group, commits in commits | group_by(attribute="group") %}
### {{ group | upper_first }}
{% for commit in commits %}
- {{ commit.message | upper_first }}{% if commit.breaking %} [breaking]{% endif %}
{% endfor %}
{% endfor %}
"""
footer = """
<!-- generated by git-cliff -->
"""
trim = true

[git]
conventional_commits = true
filter_unconventional = true
```


## Reference

- ithmb-codec [`CHANGELOG.md`](https://github.com/B67687/Ithmb-Codec/blob/main/CHANGELOG.md) — best existing example
- [keepachangelog.com](https://keepachangelog.com/) — the standard
- [semver.org](https://semver.org/) — versioning standard
