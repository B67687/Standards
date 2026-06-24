# Cross-Repo Standardization — Master Inventory

> **Purpose:** Capture every standardization target discovered across 33 local + 5 GitHub repos.
> One section per target. We iterate each one in detail before considering it mature.
>
> **Status legend:** 🟢 mature | 🟡 partial | 🔴 absent | ⚪ needs research

---

## Target 1: AI Attribution (CREDITS.md + README badges)

**Status:** 🟢 **Mature — designed and documented (2026-06-17)**

### Canonical Format

See `docs/ai-attribution-pattern.md` for the full standard.

**Key design decisions reached:**

- 4-column table: Phase | Model (reasoning) | Harness | Role
- Reasoning folded into Model column as `Model Name (reasoning level)`
- "Interface" renamed to "Harness" (tool/platform, not UI surface)
- "Plan" column removed (billing info, no attribution value, privacy risk)
- Role broadened to include research + strategic discussion + meta-work
- Boilerplate refined to capture bi-directional influence
- Table format for ALL repos (single-model: one row, Phase="Full development")
- README badge-per-model pattern retained (identity/vanity)
- Static SVGs committed to `docs/badges/`, no external badge service dependency

### Existing Reference File

`docs/ai-attribution-pattern.md` (~115 lines, updated 2026-06-17)

---

## Target 2: SVG Diagram Generation

**Status:** 🟢 **Mature — expanded to 16 sections (2026-06-17)**

### Standard Location

`bus-hop/docs/svg-standards.md` (expanded from 214 lines to comprehensive 16-section standard)

### What Was Added in Expansion

- **Section 5: Spacing System** — 8px grid, named spacing tokens (`--col-gap`, `--arrow-gap`, `--sub-box-height`, etc.), padding consistency table, section gap rules
- **Section 6: Color System & Derivation** — semantic color hierarchy, color derivation rules (fill saturation → border saturation ratios), color assignment rules table, dark mode auto-calculation, prohibited color uses
- **Section 13: Accessibility Rules** — WCAG contrast minimums verified against current palette (found `.dc`/`.s` fails AA at 3.5:1), color-blind safety rules, line/border visibility minimums
- **Section 14: Validation Checklist** — 25-item pre-commit checklist covering content, layout, color, and style
- **Section 15: Maximum Complexity Rules** — hard limits: 20 nodes max, 4 nesting levels, 6 hues max, 2 font sizes max, 2 stroke widths max
- **Section 16: Common Pitfalls** — expanded from 10 to 15 items (added contrast fail, color overload, text overflow, fractional pixels, inconsistent arrow gaps)

### Design Decisions Confirmed

- Hand-crafted inline SVG is the standard (preferred over D2, Structurizr, Mermaid)
- Custom CSS class system (`.bx`, `.i`, `.ci`, `.gr`, `.or`, `.dc`, `.t`, `.l`, `.s`, `.e`) is the core
- No auto-layout — explicit pixel coordinates for full control
- Max 4 column types (architecture, data flow, pipeline, rule box)

### Pattern A: Hand-Crafted Inline SVG (bus-hop)

- `bus-hop/docs/svg-standards.md` (214 lines) — full standard document
- CSS classes: `.bx`, `.i`, `.ci`, `.gr`, `.or`, `.dc`, `.t`, `.l`, `.s`, `.e`
- Color palette: blue containers, light-blue subs, green primaries, orange transitions, grey annotations
- Layout: explicit pixel coordinates, 800px viewBox, geometric centering formulas
- Arrow marker: custom `<marker id="a">` in `<defs>`
- Used in: bus-hop architecture.svg + pipeline.svg, ithmb-codec architecture.svg + pipeline.svg
- Pro: full control, no tooling dependency
- Con: tedious to author, easy to break coordinates

### Pattern B: Mermaid → SVG Pipeline (ithmb-codec / agentic-workflows standard)

- `docs/svg-diagram-standards.md` (147 lines) — Mermaid-first standard
- Source: `.mmd` files (Mermaid)
- Tool: `scripts/tools/render-mermaid.sh` — wraps `mmdc` + Puppeteer
- CI: auto-render on `.mmd` changes via GitHub Actions
- `scripts/tools/render-mermaid.sh` options: input, output, width, theme, background, scale
- Used in: ithmb-codec (gitignores `.mmd` sources, commits SVG only)
- Pro: source-driven, reproducible, fast iteration
- Con: bloated SVG output, can't use custom CSS classes for diagrams

### Gap (both patterns):

- SVG screenshots of app UIs — no repo does this at all. bus-hop uses PNG/JPEG screenshots.
- No unified `scripts/diagram.sh` that converts `.mmd` → SVG with bus-hop's custom CSS styling applied

### Existing Reference Files

- `bus-hop/docs/svg-standards.md` (hand-crafted standard)
- `agentic-workflows/docs/svg-diagram-standards.md` (Mermaid pipeline standard)

---

## Target 3: SVG Badge Generation

**Status:** 🟢 **Done (2026-06-17)**

### Standard

`docs/badge-standard.md` + `scripts/generate-badge.sh`

- **Format:** shields.io-style inline SVG (two-part: dark label + colored value)
- **Storage:** `docs/badges/*.svg` committed as static files (no external badge service)
- **Portable script:** `scripts/generate-badge.sh --label "tests" --value "161" --color "34A853"` works on any repo
- **Icon support:** `--icon kotlin` / `--icon java` for embedded icon data URIs
- **Color convention:** green (#34a853) = metrics, yellow (#d8b800) = license, blue (#4285f4) = CI, per-model colors = AI badges

---

## Target 4: README Structure

**Status:** 🟢 **Done (2026-06-17)**

### Standard

`docs/README-standard.md`

- **Section order codified:** Title → Badges → Description → AI Attribution → Features → Quick Start → Usage → Architecture → ... → License (always last)
- **Badge header:** centered `<img>` row with `docs/badges/` SVGs
- **AI attribution:** `Built with AI assistance — see CREDITS.md` right below badges
- **When to split:** README > 300 lines → split into ARCHITECTURE.md, DEVELOPMENT.md, etc.
- **3 templates:** harness, library, application (section order differs by audience)
- **Images:** always in `docs/` subdirectories

---

## Target 5: Local CI Pipeline

**Status:** 🟢 **Standard defined — 3-stage model with local review.sh + cron (see docs/ci-pipeline-standard.md)**

### Reference Pipeline (ithmb-codec)

| Layer        | Tool           | Config                         | Purpose                                                 |
| ------------ | -------------- | ------------------------------ | ------------------------------------------------------- |
| SAST         | Semgrep        | `.semgrep.yml`                 | Static analysis (null-check, pointer safety, catch-all) |
| Security     | CodeQL         | `.github/workflows/codeql.yml` | Security analysis                                       |
| Git hooks    | Pre-commit     | `.pre-commit-config.yaml`      | Local quality gates                                     |
| Commits      | Commitlint     | `.commitlintrc.json`           | Conventional commit enforcement                         |
| Links        | Lychee         | `.lycheeignore`                | Broken link check                                       |
| Tests        | GitHub Actions | `.github/workflows/test.yml`   | Automated testing                                       |
| Orchestrator | review.sh      | `review.sh`                    | 8-stage local review pipeline                           |

### Coverage Across All Repos

| Repo         | Semgrep | CodeQL | Pre-commit | Commitlint | Lychee | review.sh |
| ------------ | ------- | ------ | ---------- | ---------- | ------ | --------- |
| ithmb-codec  | ✅      | ✅     | ✅         | ✅         | ✅     | ✅        |
| All other 32 | ❌      | ❌     | ❌         | ❌         | ❌     | ❌        |

### What's Missing

- Extracted templates from ithmb-codec (generalized, not C#-specific)
- Configuration for each language type (C#, Kotlin, Python, Go, Shell)
- `review.sh` for other repos (Semgrep rules would differ by language)
- Pre-commit hook standard

---

## Target 6: Changelog Standard

**Status:** 🟢 **Done (2026-06-17)**

### Standard

`docs/changelog-standard.md`

- **Format:** Keep a Changelog + SemVer
- **File:** `CHANGELOG.md` in repo root
- **Change types:** Added, Changed, Deprecated, Removed, Fixed, Security
- **Dates:** ISO 8601 (`YYYY-MM-DD`)
- **Workflow:** Unreleased section → rename at release → new Unreleased
- **Template included** in the standard doc
- **Conventional commits mapping:** feat→Added, fix→Fixed, etc.

---

## Target 7: SVG Screenshots

**Status:** 🟢 **Standard defined — 3 types (mobile, CLI terminal, web) with dark mode support (see docs/svg-screenshots-standard.md)**

### Current Screenshot Approach

- bus-hop: `docs/screenshots/screenshot_main.jpg` + `screenshot_search.png` (manually captured)
- All other repos: either no screenshots or static images
- No repo uses SVG for screenshots

### What This Would Cover

- Generate app UI screenshots as SVG (for README display, inline rendering)
- Potential tools: Playwright → SVG, Puppeteer → SVG, or template-based approach
- Could be a script: `scripts/screenshot.sh --url http://localhost:3000 --out docs/screenshots/app.svg`

### Status

Needs research phase — assign @scout to investigate existing tooling before designing.

---

## Target 8: GitHub Repo Topics

**Status:** 🟢 **Done (2026-06-17) — topics applied to 9 repos across B67687 + b67687-stable**

### Current Topics

| Repo              | Topics  | Issue              |
| ----------------- | ------- | ------------------ |
| Agentic-Workflows | (empty) | No discoverability |
| Ithmb-Codec       | (empty) | No discoverability |
| Agent-Harness     | (empty) | No discoverability |
| CS-Notes          | (empty) | No discoverability |
| Scoop             | (empty) | No discoverability |

### What's Missing

- Each repo should have 3-6 relevant topics
- Consistent naming convention across related repos
- A `scripts/set-repo-topics.sh` that applies topic sets per repo type

---

## Target 9: .gitignore Standardisation

**Status:** 🟢 **Mature — whitelist/gitaccept standard documented (2026-06-17)**

### Standard Location

`bus-hop/docs/gitignore-standard.md` (full whitepaper)

### Key Design Decisions

- **Whitelist ("gitaccept") approach** — `/*` ignores everything, `!` accepts specific patterns. Inverts the traditional blacklist.
- **Tiered classification system** (T1-T4 from agentic-workflows) — Always Tracked / Conditional / Generated / External
- **Two-layer architecture**: Whitelist sections opt in file types, blacklist supplement catches edge cases
- **Hybrid recommendation**: whitelist for harness/security repos, traditional blacklist for open-source/polyglot repos
- **Critical mechanics**: parent-directory rule documented (cannot re-include inside an excluded dir), anchoring rules, evaluation order
- **Seven pitfall patterns** documented with fix examples

---

## Target 10: License Standard

**Status:** 🟢 **Done (2026-06-17)**

**Default:** MIT for all public repos. GitHub's built-in license picker handles the template.

**Convention:**

- File: `LICENSE` in repo root (no extension)
- Year: repo creation year (e.g. `2026`)
- Holder: `B67687`
- README badge: include `license.svg` matching the LICENSE file

**Exceptions:**

- Forks → keep upstream license (e.g. agentic-ui → Apache 2.0)
- Learning notes → "All Rights Reserved" or no license (CS-Notes)
- Private repos → no license needed

**Missing licenses to add (if desired):**

- ithmb-codec: README says MIT, no file
- agent-harness: nothing
- traffic-dashboard: README has MIT badge, no file

---

## Target 11: Configuration Files

**Status:** 🟢 **Merged into CI Pipeline standard under "Configuration Files" section**

### Current Coverage

| Config                    | ithmb-codec | All Others |
| ------------------------- | ----------- | ---------- |
| `.editorconfig`           | ✅          | ❌         |
| `.pre-commit-config.yaml` | ✅          | ❌         |
| `.commitlintrc.json`      | ✅          | ❌         |
| `.semgrep.yml`            | ✅          | ❌         |
| `.lycheeignore`           | ✅          | ❌         |

### What's Missing

- Language-agnostic `.editorconfig` template (indent, charset, trailing whitespace)
- Standard `.pre-commit-config.yaml` hooks relevant to each language
- `.commitlintrc.json` with conventional commit scope definitions per project

---

## Target 12: Two Repo Populations

**Status:** 🟡 **Discovered structural divide — 12 harness repos vs ~21 standalone repos**

### Harness Repos (12)

Have `AGENTS.md` + `CLAUDE.md` + `workflow-state.json` + `workflow.d/` or similar agentic-workflows infrastructure:

- agentic-workflows, agent-harness, agent-seed, agent-stack, agent-sessions, agent-ui, agentic-ui, agent-concourse, open-codex, reality, no-face-scan-app, rss-reader, fengshui, keyboard, fluent-prs, Comfer, random, hugo, image-magick, knowledge-base

### Standalone Repos (~12)

Traditional project layout, no harness:

- bus-hop, ithmb-codec, CS-Notes, traffic-dashboard, scenic-fetch, terax-ai, personal-voice, math-learning-notes, project-learner-brainstorm, 2002-Combat, design-md, nihaisha-tcm, scoops-fork

### What's Missing

- No clear documentation of when a repo becomes "harness" vs "standalone"
- The harness repos lack: CREDITS.md, LICENSE, CHANGELOG, CI pipeline, README badge standardization
- The standalone repos are more varied and harder to standardize

---

## Target 13: .github/ Workflow Configs

**Status:** 🟡 **Skipped — local dev on MiniPC, no GitHub PRs or Actions needed**

---

## Target 14: Propagation System

**Status:** 🟡 **Skipped per user's call — not needed for current workflow**

### How It Works

- `propagation/` in agentic-workflows contains 85+ template files
- Generated into `propagated/` in each target repo
- Currently 12 repos have `propagated/` directory (6 active participants identified)

### What's Missing

- Documented: which templates are "mandatory" vs "optional"
- Template versioning (how to handle breaking changes)
- Cross-repo sync mechanism when templates change

---

## Appendix: Repo Inventory

### GitHub Repos (B67687 org)

| Repo              | Type       | Language    | Has LICENSE         | Has CREDITS | Has CHANGELOG | Has CI | SVG |
| ----------------- | ---------- | ----------- | ------------------- | ----------- | ------------- | ------ | --- |
| Agentic-Workflows | Harness    | Shell       | ✅ MIT              | ✅          | ❌            | ❌     | ✅  |
| Ithmb-Codec       | Standalone | C#          | ❌ (badge says MIT) | ✅          | ✅ (KAC)      | ✅ (5) | ✅  |
| Agent-Harness     | Harness    | Shell       | ❌                  | ❌          | ❌            | ❌     | ❌  |
| CS-Notes          | Standalone | Python/Hugo | ❌                  | ❌          | ❌            | ✅ (1) | ❌  |
| Scoop             | Fork       | PowerShell  | N/A (upstream)      | ❌          | ❌            | N/A    | ❌  |

### Local Repos (not on GitHub)

`.dev/` contains 28+ additional repos (agent-seed, agent-stack, agent-sessions, agent-ui, agent-concourse, bus-hop, traffic-dashboard, scenic-fetch, open-codex, terax-ai, reality, no-face-scan-app, rss-reader, personal-voice, fengshui, keyboard, fluent-prs, Comfer, random, hugo, image-magick, knowledge-base, math-learning-notes, project-learner-brainstorm, 2002-Combat, design-taste/design-md, zhongyi/nihaisha-tcm, scoops-fork)

---

## Appendix: Standardization Priority Matrix

| Priority | Target                     | Effort   | Impact | Pre-requisites                      |
| -------- | -------------------------- | -------- | ------ | ----------------------------------- |
| P0       | AI Attribution (1)         | Low      | High   | Design decisions on format          |
| P0       | README Templates (4)       | Medium   | High   | Decide on 2-3 template archetypes   |
| P1       | Changelog (6)              | Low      | Medium | Need KAC template                   |
| P1       | Badge Generator (3)        | Medium   | Medium | Script creation                     |
| P1       | SVG Diagram Script (2)     | Medium   | Medium | Decide unified vs separate patterns |
| P2       | License (10)               | Low      | High   | MIT template, copyright format      |
| P2       | CI Pipeline Extraction (5) | High     | High   | Extract from ithmb-codec            |
| P3       | Configuration Files (11)   | Low      | Low    | Template creation                   |
| P3       | GitHub Topics (8)          | Very Low | Medium | Per-repo topic lists                |
| P3       | .gitignore Template (9)    | Low      | Low    | Extend from agentic-workflows       |
| P4       | SVG Screenshots (7)        | High     | Medium | Research phase first                |
| P4       | Propagation System (14)    | Medium   | High   | User doesn't want propagation yet   |
| P4       | .github/ Workflows (13)    | Medium   | Medium | Issue/PR templates, Dependabot      |

---

## Location

Standards moved to `./` as their own topic folder.
Scripts for applying standards are in `./scripts/`.

## Future Candidates (Not Yet Started)

| Domain | Cross-Repo | Status |
|--------|------------|--------|
| Repository Structure | ✅ | 🟢 Done |
| Commit Conventions | ✅ | 🟢 Done |
| Security Policy | ✅ | 🔴 SECURITY.md, vulnerability disclosure |
| Naming Conventions | ✅ | 🟢 Done |
| Testing Standards | 🟡 | 🔴 What tests, naming, coverage (for ~10 code repos) |
| Release Process | 🟡 | 🔴 Versioning, tagging, publishing |
| Code Review Standards | 🟡 | 🔴 Review checklist (future use) |
| ADR Standards | ✅ | 🟢 Done |
| Beyond-README Docs | ✅ | 🔴 When to split into ARCHITECTURE.md, DEVELOPMENT.md |
| Tool Versions (mise) | ✅ | 🟢 Done — `tool-versions-standard.md` |
| Secrets Management (sops/age) | 🟡 | 🟢 Done — `secrets-management-standard.md`, check pending |
| Lefthook (hooks) | ✅ | 🟢 Alternatives in `ci-pipeline-standard.md` + `auto-commit-gitops-standard.md` |
| Trivy (secrets) | ✅ | 🟢 Alternatives in `ci-pipeline-standard.md` |
| Git-Cliff (changelog) | ✅ | 🟢 Mentioned in `changelog-standard.md` |
| Go-Task (runner) | ✅ | 🟢 Mentioned in `repo-structure-standard.md` |
| Self-Consistency | ✅ | 🟢 Done — `self-consistency-standard.md` |
