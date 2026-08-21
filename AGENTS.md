# AGENTS.md: AI Agent Guide for Standards

This file is for AI coding agents (Claude Code, Codex, Cursor, OpenCode). `README.md` is user-facing; this file tells agents what the repo is, where things live, and how to work in it correctly. Read this before editing anything.

## Repository Purpose

A docs-only knowledge base, no code, build, or runtime. It is the enforcement backend for engineering standards: standard documents define what "good" means, shell check scripts enforce it deterministically, and a dashboard tracks compliance across all repos in the ecosystem. It is also the knowledge backend for the `/solve` skill.

**24 standards, 128 automated checks** (114 shell + 9 agent-pending + 5 tool-availability). The repo is self-auditing: it passes its own audit (`./scripts/audit.sh --exit-code .`).

## Repository Layout

```
standards/
├── *.md                        # Standard definitions (24 × *-standard.md)
├── 0-meta-standards.md         # Meta-standard: standards about standards
├── cross-repo-standards.md     # Inventory: which standards apply to which repos
├── RULES.md                    # Working rules for this repo
├── SPECIFICATION.md            # Formal spec + architecture
├── EXPLAINER.md                # Plain-language explanation
├── HANDOVER.md                 # Handoff notes, current state
├── CREDITS.md                  # AI attribution (required by ai-attribution standard)
├── CHANGELOG.md
├── scripts/
│   ├── audit.sh                # CLI entry point: audit a single repo
│   ├── audit-lib.sh            # Shared check framework (source me, read first)
│   ├── audit-all.sh            # Batch audit across repos → .omo/dashboard/
│   ├── agent-check.sh          # Agent-eval dispatcher for subjective checks
│   ├── dashboard.sh            # HTML compliance dashboard generator
│   ├── check-parity.sh         # Local-vs-GitHub CI parity gate
│   ├── generate-badge.sh       # SVG badge generator
│   ├── set-repo-topics.sh      # GitHub topic setter
│   ├── install-ai-commit-hooks.sh  # Installs git hooks globally
│   ├── pre-commit / pre-push / prepare-commit-msg / commit-msg  # Git hook templates
│   ├── checks/*.sh             # One plugin per standard, auto-discovered
│   └── tools/setup-env-enc.sh  # Encrypted env setup (sops/age)
├── docs/                       # adr/, badges/, screenshots/, methodology-retrospective.md
├── mcp/                        # Node MCP server (server.js), wired via .opencode/mcp.json
├── Makefile                    # make audit / check / audit-exit / shellcheck
├── mise.toml                   # Tool versions (shellcheck, trivy, sops, age, git-cliff, ...)
├── .pre-commit-config.yaml     # pre-commit framework hooks
├── .commitlintrc.json          # Conventional commit rules (types: feat fix docs refactor perf test chore cleanup security revert)
├── .editorconfig
├── .env.encrypted / .env.example / .sops.yaml   # Secrets (encrypted, age-keys)
├── .github/workflows/ci.yml    # CI: shellcheck + self-audit on push/PR to main
└── .omo/                       # Agent workspace + generated audit output (never commit)
```

## How the Audit Works

1. **Standard documents** (`*-standard.md`) define rules, rationale, and success criteria.
2. **Check scripts** (`scripts/checks/*.sh`) implement deterministic tests. Each is a plugin: drop a file, it auto-registers via `ALL_STANDARDS+=("<name>")`.
3. **`audit.sh`** sources every check plugin, runs each `checks_<name> <repo>` function, and reports pass/fail/pending.
4. **Agent evals** (`agent-check.sh`) handle subjective checks (README quality, badge accessibility). Checks write JSON prompts; `agent-check.sh` processes them into pending results.
5. **Batch + dashboard** (`audit-all.sh -d` then `dashboard.sh`) aggregate across repos into `.omo/dashboard/`.

Checks are **advisory by default**: audit reports without modifying. `--fix` applies additive safe fixes, `--force` applies destructive ones.

## How to Add a New Standard

1. Create `<name>-standard.md` with rules, rationale, and success criteria.
2. Create `scripts/checks/<name>.sh` implementing the `_check` interface (below). It auto-registers; no other wiring needed.
3. Add a row to the standards table in `README.md`.
4. Verify: `./scripts/audit.sh --standard <name> /path/to/repo`.

See `scripts/checks/ai-attribution.sh` (well-commented) and `dependency-management-standard.md` (recently extended with supply-chain security) as reference examples.

## Check Script Interface

Check scripts are **sourced**, not executed, by `audit.sh`. They use the framework from `audit-lib.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../audit-lib.sh"   # via audit.sh; see existing checks

ALL_STANDARDS+=("my-standard")                            # register (kebab-case ID)

checks_my_standard() {                                    # function = checks_<id with _ for ->
  local repo="$1"
  CURR_STANDARD="my-standard"
  _check_header "My Standard"
  _check "rule-1-exists" "Description of rule 1" test -f "${repo}/SOMEFILE"
}
```

- `_check "<rule-id>" "<description>" <command...>`: passes when the command exits 0, fails otherwise. Always appends to `ALL_RESULTS` for reporting.
- `_check_header`, `_check_fail`, `_check_pending` (agent eval), `_fix`, `_fix_run` also available.
- Exit 0 = pass, non-zero predicate = fail. `audit.sh --exit-code` turns any fail/error into exit 1 (CI gate).
- JSON output via `./scripts/audit.sh --report json <repo>` (`report_json` in audit-lib.sh).
- Fixes for `--fix`/`--force` mode go in a separate `fixes_my_standard()` function.

## Canonical Commands

```bash
./scripts/audit.sh .                                  # Audit current repo
./scripts/audit.sh --fix /path/to/repo                # Audit + safe auto-fixes
./scripts/audit.sh --standard <name> --exit-code .    # CI gate for one standard
./scripts/audit.sh --list-standards                   # List registered standards
./scripts/audit.sh --report json <repo>               # Machine-readable output
./scripts/audit-all.sh -d /path/to/projects           # Batch audit → .omo/dashboard/
./scripts/dashboard.sh                                # Generate HTML dashboard + matrix
make audit                                            # Self-audit
make audit-exit                                       # Self-audit as CI gate
make check                                            # audit-exit + shellcheck
```

## Dev / Public Dual-Repo Workflow (CRITICAL)

```
origin → https://github.com/B67687/Standards-Dev.git   (PRIVATE, working repo)
public → https://github.com/B67687/Standards.git       (PUBLIC, release only)
```

- All work happens on `origin` (Standards-Dev) `main`. The public repo is **never** a work surface (see `private-public-push-workflow-standard.md` and `private-public-split-standard.md`).
- Release to `public` happens only on explicit user go. Do not push to public proactively.
- Git hooks (`scripts/pre-commit` identity gate, `pre-push` signature check, `prepare-commit-msg`, `commit-msg`) are installed globally via `scripts/install-ai-commit-hooks.sh`. Every commit is signed.

## Where to Look

| You want...                                        | Open this                                        |
| -------------------------------------------------- | ------------------------------------------------ |
| How the audit system works                         | `README.md`, `EXPLAINER.md`, `SPECIFICATION.md`  |
| Working rules for this repo                        | `RULES.md`                                       |
| Current state / handoff / next steps               | `HANDOVER.md`                                    |
| Which standards apply to which repos               | `cross-repo-standards.md`                        |
| A specific standard's rules                        | `<name>-standard.md` + `scripts/checks/<name>.sh` |
| The check framework API                           | `scripts/audit-lib.sh` (read first)              |
| AI attribution format                              | `CREDITS.md`, `ai-attribution-standard.md`       |
| Architecture decisions                             | `docs/adr/`                                      |
| Tool versions / secret tooling                     | `mise.toml`, `.sops.yaml`                        |
| Commit conventions / pre-commit hooks              | `.commitlintrc.json`, `.pre-commit-config.yaml`  |
| Secrets                                           | `.env.example`, `scripts/tools/setup-env-enc.sh` |
| Changelog                                         | `CHANGELOG.md`                                   |

## What NOT to Do

- Do NOT stage or commit `.omo/` content. It is agent workspace and generated audit output.
- Do NOT push to the `public` remote without explicit user go.
- Do NOT add a standard without a corresponding check script.
- Do NOT modify `scripts/checks/*.sh` without understanding the `_check` interface.
- Do NOT run `audit.sh --force` unless you understand the destructive fixes it applies.
- Do NOT edit `.env.encrypted` directly or commit changes to it without re-encrypting with sops.
- Do NOT add attribution lines (`Co-authored-by`, `Ultraworked with`) to commit messages.

## Do Not Touch / Generated Paths

- `.omo/`: agent workspace. The pre-existing tracked `.omo/audit/agent-evals/*.json` and `.omo/dashboard/*` files are generated, exempt, and volatile; leave them unmodified.
- `.env.encrypted`: encrypted secrets (sops/age, see `.sops.yaml`).
- `mcp/node_modules/`: generated dependency tree.
