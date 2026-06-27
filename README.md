<div align="center">

# Standards

<img src="https://github.com/B67687/Standards/actions/workflows/ci.yml/badge.svg" alt="CI">
<img alt="standards: 31" src="docs/badges/standards.svg">
  <img alt="checks: 152" src="docs/badges/checks.svg">
<img alt="license: MIT" src="https://img.shields.io/github/license/B67687/Standards">

A framework of cross-repo conventions with automated shell-based audit enforcement for AI-enhanced software projects.

**31 standards** defining convention rules for repos. **152 automated checks** enforce them. **Dashboard** tracks compliance across all repos.

Built with AI assistance — see [CREDITS.md](./CREDITS.md).

<img alt="Standards Audit Terminal" src="docs/screenshots/audit-terminal.svg" width="80%">

</div>

<p align="center">
  <img alt="model: DeepSeek V4 Flash (Max)" src="docs/badges/deepseek-v4.svg">
  <img alt="harness: Oh My OpenAgent" src="docs/badges/oh-my-openagent-harness.svg">
</p>

## Quick start

```bash
# Audit the current directory
./scripts/audit.sh

# Audit + auto-fix (CREDITS.md, badges, README attribution)
./scripts/audit.sh --fix /path/to/repo

# Check a single standard, JSON output, exit 1 on failure
./scripts/audit.sh --standard ai-attribution --report json --exit-code /path/to/repo

# List all registered standards
./scripts/audit.sh --list-standards

# Batch audit all repos under a directory
./scripts/audit-all.sh -d /path/to/projects

# Generate dashboard from batch results
./scripts/dashboard.sh
```

## Architecture

```
standards/
├── *.md                    # Standard definitions (what + why)
├── scripts/
│   ├── audit.sh            # CLI entry point — audit a single repo
│   ├── audit-lib.sh        # Shared framework: _check, reporter, JSON output
│   ├── audit-all.sh        # Batch audit across multiple repos
│   ├── agent-check.sh      # Dispatches agent-eval requests for subjective checks
│   ├── checks/*.sh         # One file per standard — plugins auto-discovered
│   └── ...                 # Utility scripts (badge generator, hooks, etc.)
└── .omo/dashboard/         # Generated audit results + HTML dashboard
```

### How it works

1. **Standard documents** (`docs/standards/*-standard.md`) define each convention's rules, rationale, and success criteria.
2. **Check scripts** (`scripts/checks/*.sh`) implement deterministic tests for each rule — file existence, grep patterns, format validation via shell.
3. **Agent evals** extend shell checks for subjective judgments (README quality, badge accessibility, SVG correctness). Checks write structured JSON prompts; `agent-check.sh` collects them.
4. **Audit runner** (`audit.sh`) discovers all check plugins, executes them against a repo, and produces terminal + JSON reports.
5. **Dashboard** (`audit-all.sh` + `dashboard.sh`) runs batch audits across repos, aggregates into a compliance matrix, and generates a self-contained HTML dashboard.

## Standards

| Standard | File | Checks |
|----------|------|-------|
| ADR | `docs/standards/adr-standard.md` | 6 |
| Agent Evaluation | `docs/standards/agent-evaluation-standard.md` | 0 |
| AI Attribution | `docs/standards/ai-attribution-standard.md` | 6 |
| Architecture Documentation | `docs/standards/architecture-documentation-standard.md` | 4 |
| Auto-Commit GitOps | `docs/standards/auto-commit-gitops-standard.md` | 6 |
| Badge (shell) | `docs/standards/badge-standard.md` | 5 |
| Badge Quality (agent) | `docs/standards/badge-standard.md` | 3 |
| Changelog | `docs/standards/changelog-standard.md` | 6 |
| CI Pipeline | `docs/standards/ci-pipeline-standard.md` | 6 |
| Code Documentation | `docs/standards/code-documentation-standard.md` | 3 |
| Commit Conventions | `docs/standards/commit-conventions-standard.md` | 6 |
| CS Project Architecture | `docs/standards/cs-project-architecture-standard.md` | 4 |
| Git History Cleanup | `docs/standards/git-history-cleanup-standard.md` | 5 |
| Git Identity Security | `docs/standards/git-identity-security-standard.md` | 6 |
| GitHub Topics | `docs/standards/github-topics-standard.md` | 5 |
| .gitignore | `docs/standards/gitignore-standard.md` | 7 |
| Language | `docs/standards/language-standard.md` | 7 |
| Lefthook | `docs/standards/auto-commit-gitops-standard.md` | 6 |
| License | `docs/standards/license-standard.md` | 4 |
| Link Rot | `docs/standards/link-rot-standard.md` | 4 |
| Naming Conventions | `docs/standards/naming-conventions-standard.md` | 5 |
| Overview Documentation | `docs/standards/overview-documentation-standard.md` | 4 |
| Path Agnosticism | `docs/standards/path-agnosticism-standard.md` | 4 |
| README Quality | `docs/standards/README-standard.md` | 8 |
| Repo Structure | `docs/standards/repo-structure-standard.md` | 7 |
| Safe Wrappers | `docs/standards/safe-wrappers-standard.md` | 4 |
| Secrets Management (sops/age) | `docs/standards/secrets-management-standard.md` | 4 |
| SVG Screenshots | `docs/standards/svg-screenshots-standard.md` | 5 |
| Tool Versions (mise) | `docs/standards/tool-versions-standard.md` | 5 |
| Trivy Secrets | `docs/standards/ci-pipeline-standard.md` | 5 |
| Self-Consistency | `docs/standards/self-consistency-standard.md` | 1 |

**Total: 31 standards, 152 checks**

## CI / exit codes

The audit runner returns exit code 1 if any check fails:

```bash
./scripts/audit.sh --exit-code /path/to/repo && echo "Compliant"
```

Combine with `--standard <name>` for targeted CI gates.

## Dashboard

Generate the compliance matrix across all repos:

```bash
./scripts/audit-all.sh -d /path/to/projects
./scripts/dashboard.sh
# Open .omo/dashboard/index.html
```

The dashboard shows per-repo, per-standard compliance with pass/fail/pending cells, a total score column, and a machine-readable `compliance-matrix.json`.

## Design principles

- **Deterministic** — same repo, same result. Shell checks before agent judgment.
- **Plugin architecture** — drop a `checks/<standard>.sh` file, it auto-registers.
- **Agnostic** — no hardcoded paths, no machine-specific config. Run from anywhere.
- **Advisory by default** — audit reports without modifying. `--fix` for remediation.
- **Exit-code gated** — `--exit-code` for CI enforcement.

## License

MIT — see [LICENSE](./LICENSE).
