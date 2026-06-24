# Handover – Standards Enforcement Project

## Why This Exists

The standards repo started as documentation — 16 well-written standards covering everything from AI attribution to repo structure. But documentation doesn't enforce itself. Every repo still needs individual manual effort to comply, and there's no deterministic way to check or apply standards across all 20+ repos.

**The goal:** Turn this from a document library into an enforcement system. The standards should apply automatically, deterministically, without you having to think about them.

## Current State

### What's Solid
- **16 standards documents** — well-researched, decision-complete (see README.md for index)
- **7 scripts** in `scripts/` — git hooks + badge generator + topic setter
- **Cross-repo inventory** in `cross-repo-standards.md` — tracks which standards apply to which repos
- **Global git hooks** installed via `scripts/install-ai-commit-hooks.sh` — pre-commit (identity gate), pre-push (signature check), prepare-commit-msg (AI attribution)
- **Meta-standard** (`0-meta-standards.md`) — Minimal Surface Principle, YAGNI, no cleanup commits

### What's Missing (the enforcement gap)
| Problem | Example |
|---------|---------|
| No single "audit" command | Can't run `./check.sh bus-hop` to see which standards it violates |
| Most standards are docs only | `repo-structure-standard.md` says what to do, but nothing checks it |
| Enforcement is per-hook/per-repo | `commit-msg` hook only targets `agentic-workflows` |
| No "apply" automation | Applying a standard to a new repo is manual copy-paste |
| Cross-repo inventory is static | `cross-repo-standards.md` must be hand-updated |
| No deterministic CI gate | No way to say "this repo fails if it doesn't meet standards" |

## Strategic Direction

### The Core Insight
Your leverage is **AI orchestration**, not hand-written enforcement code. The enforcement system should:

1. **Be AI-native** — the enforcer runs as AI agent instructions, not just shell scripts
2. **Be declarative** — each repo declares which standards it follows; the system checks them
3. **Be deterministic** — same input, same result. No ambiguity.
4. **Be composable** — standards combine; checking "AI attribution" includes checking CREDITS.md format + trailer format + badge presence

### Why This Fits You
- It's a **meta-project** (tools about tools) — pure orchestration thinking
- No hand-cranking — you define what "compliant" means, AI does the checking
- It compounds — every hour spent here saves 10 hours across 20 repos
- You already wrote all the standards — the hard thinking is done

## Immediate Next Steps (when you start)

### 1. Pick the enforcement model
Three approaches, pick one or hybrid:

| Approach | How It Works | Pros | Cons |
|----------|-------------|------|------|
| **A: Agent Prompt** | One prompt that checks all standards for a repo | Flexible, no code | Not deterministic, varies by model |
| **B: Shell Audit** | `./audit.sh <repo-path>` runs checks per standard | Deterministic, fast | More code, each check is a script |
| **C: Hybrid** | Shell checks structural things (file exists, has badge), Agent checks content quality | Best of both | Two code paths |

**My recommendation: C (Hybrid).** Shell scripts for "does file X exist?", "does Y have the right format?", agent for "does this README follow the section order standard?"

### 2. Start with one standard to enforce (suggested)
**Start with `ai-attribution-standard.md`.** It's the most mature, already has tooling (hooks + badge generator), and affects every repo. A win here proves the pattern.

Implementation checkpoints:
- [ ] `scripts/audit-attribution.sh <repo>` — checks CREDITS.md exists, has correct format, AI trailers present, badges in README
- [ ] Add to the commit-msg hook to validate trailer format when `AI_COMMIT=1`
- [ ] `scripts/fix-attribution.sh <repo>` — auto-generates missing CREDITS.md, adds badges

### 3. Then chain the pattern for others
Once the attribution checker pattern works, replicate for:
- `audit-readme.sh` — README section order, badge header, license mention
- `audit-repo-structure.sh` — docs/ exists, scripts/ exists, gitignore present
- `audit-ci.sh` — checks for semgrep config, pre-commit config, etc.

### 4. Finally: the cross-repo dashboard
`scripts/audit-all.sh` runs all audits across all repos and produces a summary table — turning `cross-repo-standards.md` from a static doc into a live report.

## Things to Keep

### Minimal Surface Principle
The meta-standard is good. Don't generate enforcement scripts that produce more boilerplate than they save. One `audit.sh` script is better than 16 individual checkers if they share logic.

### Don't rebuild what exists
The hooks already work. `generate-badge.sh` already works. The docs are complete. Build *on top* of these, don't redo them.

### AI Credit Format
Trailer format is `Co-Authored-By: Model via Harness <model+harness@models.local>`. Yes, it's a `.local` domain (RFC 6761). Don't change this.

---

## Addendum 2026-06-24 — New System Tools Available

The homelab (Ubuntu 26.04 minipc) had 6 tools installed system-wide across a session in `agentic-workflows`. These are now available for all repos and should be wired into the enforcement system.

### What Was Installed

| Tool | Version | Path | What It Does |
|------|---------|------|-------------|
| **mise** | 2026.6.13 | `~/.local/bin/mise` | Single version manager (replaces nvm/pyenv/goenv/asdf) |
| **sops + age** | 3.9.4 / 1.2.1 | `~/.local/bin/sops`, `~/.local/bin/age` | Git-native secrets encryption |
| **lefthook** | 2.1.9 | `~/.local/bin/lefthook` | Parallel git hook runner |
| **go-task** | 3.42.0 | `~/.local/bin/task` | YAML task runner (Makefile replacement) |
| **trivy** | 0.71.2 | `~/.local/bin/trivy` | All-in-one security scanner (secrets, vulns, IaC) |
| **git-cliff** | 2.8.0 | `~/.local/bin/git-cliff` | Conventional-commit changelog generator |

All binaries in `~/.local/bin/` (already on `$PATH`). Mise auto-activates in new shells via `.bashrc`. SOPS/age key at `~/.config/sops/age/key.txt` (must be backed up).

### Relevance to Standards Enforcement

| Tool | Standard(s) It Touches | What to Do |
|------|----------------------|-----------|
| **mise** | New: `tool-versions-standard.md` | Define a standard for `.mise.toml` across repos — which tools, which versions, which plugins |
| **sops/age** | `gitignore-standard.md` | Add `.env` (unencrypted) to gitignore pattern; define `.env.enc` convention |
| **lefthook** | `auto-commit-gitops-standard.md`, `ci-pipeline-standard.md` | Evaluate vs. existing pre-commit hooks. Lefthook is simpler, parallel, no Python deps. Could replace `.pre-commit-config.yaml`. |
| **go-task** | `repo-structure-standard.md` | Propose `Taskfile.yml` as the standard task runner. The `task --list` output is agent-discoverable. Existing Makefiles could be migrated. |
| **trivy** | `ci-pipeline-standard.md` | Add a `trivy` check plugin to the audit framework (`scripts/checks/ci-pipeline.sh`). Scan for secrets leaks + vulns. |
| **git-cliff** | `changelog-standard.md` | `git-cliff -o CHANGELOG.md` is the canonical generation command. Standardize `cliff.toml` config across repos. The current changelog check plugin should verify CLIFF-generated format. |

### Integration Points with Existing Audit Framework

The existing `scripts/checks/*.sh` plugin system makes it straightforward to add tool-specific checks:

```bash
# Example placeholder — scripts/checks/trivy-secrets.sh
_check "trivy-secrets" "No secrets detected by trivy" repo
_trivy_result=$(trivy fs --scanners secrets --quiet --exit-code 1 "$repo" 2>&1)
_check_result $? "$_trivy_result"
```

Similarly for mise (check `.mise.toml` exists and is valid), go-task (check `Taskfile.yml` exists and parses), git-cliff (check `cliff.toml` exists and `CHANGELOG.md` matches).

### What the Standards Should Define

The standards should answer:
1. **Which tools are mandatory?** (e.g., "All repos MUST have `.mise.toml`")
2. **Which tool versions?** (the mise standard itself, specifying what mise manages)
3. **Which hooks run?** (lefthook config template vs. pre-commit config)
4. **Secrets pattern** (`.env` → `.env.enc` via sops/age, never commit plaintext)
5. **Security baseline** (trivy scan on CI, thresholds for CRED/HIGH/MEDIUM)
6. **Changelog format** (git-cliff config, conventional-commit parsing)

See `agentic-workflows/dev/TOOLKIT_QUICKSTART.md` for detailed usage examples.

---

## Files to Read First When Starting

```bash
# Start here to understand the full scope:
code README.md              # Index of all standards
code cross-repo-standards.md  # Which repos have what
code 0-meta-standards.md    # The philosophy

# Then the priority implementation targets:
code ai-attribution-standard.md  # Most mature, best starting point
code ci-pipeline-standard.md      # Has the 3-stage model
code auto-commit-gitops-standard.md  # Current enforcement architecture

# Reference the existing scripts:
ls scripts/
```

## Questions to Answer When Starting

1. **"Audit" vs "Apply"?** Do you want a check-only mode, or also auto-fix? Auto-fix is riskier (could overwrite CREDITS.md). Suggest: audit first, apply as a separate `--fix` flag.

2. **Per-repo config?** Does each repo declare which standards it follows (via `STANDARDS.md`), or does the audit script infer from repo type? Inference is less config overhead.

3. **Fail level?** Should audit failure be blocking (pre-commit, pre-push) or advisory (CI report)? Advisory is safer to start. Make it blocking later.

4. **Centralized vs distributed?** Do the audit scripts live in `standards/` and take a repo path arg, or do they get copied into each repo? Centralized is easier to update.
