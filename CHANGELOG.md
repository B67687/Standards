# Changelog

## [Unreleased]

## [0.1.0] - 2026-06-23

### Added

- Initial audit system with 17 standards and 89 automated checks
- Cross-repo compliance dashboard with HTML output
- AI Attribution standard: CREDITS.md, badge generation, README integration
- Path Agnosticism standard: no hardcoded paths, configurable search dirs
- Agent evaluation framework for subjective quality checks
- README-quality, badge-quality, and SVG-screenshot agent-based checks
- Batch audit runner for multi-repo compliance tracking
- Git hooks (pre-commit, pre-push, commit-msg, prepare-commit-msg)
- `--fix` mode for automated remediation (CREDITS.md, badges, README)
- Self-auditing: all 17 standards applied to the standards repo itself

### Changed

- Naming conventions: `.omo` directory exempted from kebab-case check

### Fixed

- Report spacing in terminal output
- Command injection in commit-conventions.sh
- Path traversal in CREDITS.md brand field
- JSON escaping in audit-lib.sh report_json
- audit-all.sh exit code tracking
- Shellcheck issues across all scripts

[Unreleased]: https://github.com/B67687/Standards/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/B67687/Standards/releases/tag/v0.1.0
