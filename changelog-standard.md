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

## Tools

- **[git-cliff](https://git-cliff.github.io/)** — optional changelog generator from conventional commits. Use it as a pre-release completeness check, not a replacement for hand-crafted narrative. Works with existing commitlint setup.
- **[commitlint](https://commitlint.js.org/)** — conventional commit enforcement. Already in ithmb-codec.

## Reference

- ithmb-codec [`CHANGELOG.md`](https://github.com/B67687/Ithmb-Codec/blob/main/CHANGELOG.md) — best existing example
- [keepachangelog.com](https://keepachangelog.com/) — the standard
- [semver.org](https://semver.org/) — versioning standard
