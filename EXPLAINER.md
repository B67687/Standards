# Standards — EXPLAINER.md

> Plain-language explanation of how the Standards repo works. No code reading required.

## Macro Architecture

The Standards repo answers one question: **what does "good" look like?** It has three layers:

```
Standard documents (31 .md files)
    ↓ define the rules
Audit scripts (23 .sh files)
    ↓ check compliance
Reports + Dashboard (terminal, JSON, HTML)
    ↓ show results
```

Each standard is a Markdown document explaining a convention (like "every repo must have a README in a specific format"). Each standard has a corresponding shell script that checks whether a repo follows that convention. Run the audit, get a report.

## Data Flow Walk

1. A standard is written as a `.md` file: "Every repo must have a CREDITS.md with AI attribution."
2. A check script is written as a `.sh` file: `scripts/checks/ai-attribution.sh` checks if CREDITS.md exists and follows the format.
3. The user runs `./scripts/audit.sh /path/to/project`.
4. The audit runner discovers all check scripts automatically (plugin system — drop a file, it registers).
5. Each check script runs against the target repo and reports pass/fail.
6. Results are displayed in terminal and saved as JSON.
7. For multiple repos, `./scripts/audit-all.sh -d /projects` runs across all of them.
8. `./scripts/dashboard.sh` generates an HTML dashboard showing compliance across all repos.

## Module Breakdown

| Module                     | What it does                                                           |
| -------------------------- | ---------------------------------------------------------------------- |
| `*.md` standard docs (31)  | Define each convention: what it requires, why it matters, how to check |
| `scripts/audit.sh`         | Main entry point. Run this to check a repo.                            |
| `scripts/audit-lib.sh`     | Shared code for all checks (reporting, JSON output, exit codes)        |
| `scripts/checks/*.sh` (23) | One file per standard. Each check is a shell script.                   |
| `scripts/audit-all.sh`     | Run audit across many repos at once                                    |
| `scripts/dashboard.sh`     | Generate compliance dashboard HTML                                     |
| `docs/adr/`                | Architecture Decision Records — why specific design choices were made  |
| `.omo/dashboard/`          | Generated dashboard (HTML + JSON)                                      |

## Key Decisions

1. **Shell scripts, not a compiled language.** Runs on any machine with a POSIX shell — no dependencies to install. The audit should work the first time, every time.

2. **Plugin architecture.** Drop a new `checks/<standard>.sh` file and it automatically registers. No config files to update. This makes adding new standards frictionless.

3. **Deterministic before judgment.** Shell checks first (same result every time). AI-powered checks second (for subjective judgments). The AI checks are opt-in, not required.

4. **Exit-code gated.** `--exit-code` returns 0 (pass) or 1 (fail), making it easy to integrate into CI pipelines.

5. **Cross-repo by design.** The audit is designed to check ANY repo, not just the Standards repo itself. `audit-all.sh` checks all repos at once.

## Quality Guarantees

- 152 automated checks across 31 standards
- Self-consistency standard (standard #31 — audits Standards itself against its own rules)
- Every standard document has: What / When / Where / Format / Scope sections
- CI pipeline runs the audit on every push
- Cross-repo dashboard provides visibility across all projects
