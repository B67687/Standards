# Changelog

## [Unreleased]

### Added

- Self-Consistency meta-standard: standards repo must pass its own audit (`self-consistency-standard.md` + `scripts/checks/self-consistency.sh`)
- `Makefile` at repo root with `audit`, `shellcheck`, `check` targets
- `mise.toml` at repo root with tool version manifest
- Git Identity Security Standard: config-driven committer enforcement, SSH signing, useConfigOnly, gpgsign (7 checks)
- Safe Wrappers Standard: git-safe-commit/push/normalize, gh-safe-pr-create, gh-ensure-signed-rules (4 checks)
- `scripts/hooks/` — 4 canonical git hooks (pre-commit, prepare-commit-msg, commit-msg, pre-push) replacing old hardcoded global hooks
- `scripts/wrappers/` — 5 canonical safe wrapper scripts (config-driven, no hardcoded identity)
- `scripts/deploy-hooks.sh` — installs hooks from repo to `~/.config/git/ai-commit-hooks/`
- `scripts/deploy-wrappers.sh` — installs wrappers from repo to `~/.local/bin/`

### Changed

- `scripts/checks/lefthook.sh`: Now passes if `.pre-commit-config.yaml` exists (alternative hook manager)
- `scripts/checks/trivy-secrets.sh`: Now passes if gitleaks is configured in hooks or CI (alternative secret scanner)
- `.gitignore`: Whitelisted `Makefile` and `mise.toml`
- `README.md`: Updated standards table (25 standards, 131 checks)
- `docs/badges/standards.svg`: Updated from 18 to 25
- `docs/badges/checks.svg`: Updated from 95 to 131
- `cross-repo-standards.md`: Added Self-Consistency to Future Candidates
- `.github/workflows/ci.yml`: Added gitleaks secrets scanning step (was pre-commit only)
- `.gitattributes`: Broadened `sopsdiffer` pattern from `.env.encrypted` to `*.encrypted`

### Fixed

- `scripts/checks/commit-conventions.sh`: Aligned commit type regex with standard (10 types, removing `adopt|standardize|ci|build|style`)
- `scripts/hooks/commit-msg`: Aligned hook type set with standard (added `security`, `cleanup`; removed `ci`, `style`, `build`)
- `scripts/checks/cs-project-architecture.sh`: Added `set -euo pipefail` and `|| true` on `((var++))` arithmetic to prevent shell crash
- `scripts/checks/lefthook.sh`: Fixed `&>/dev/null` redirect suppressing `_check` output — wrapped in `bash -c`
- `scripts/checks/sops-secrets.sh`: Same redirect fix on sops and age binary checks
- `scripts/checks/self-consistency.sh`: Suppressed both stdout and stderr from inner audit (`>/dev/null 2>&1` instead of `2>/dev/null`)
- `.github/workflows/ci.yml`: Enforce `--exit-code` so CI fails on audit failures
- `scripts/checks/auto-commit-gitops.sh`: Added `SELF_CONSISTENCY_ACTIVE` guard for known self-consistency exception
- `.env.example` and `.env.encrypted`: Generated real 32-char hex APP_KEY (previously empty placeholder)

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
