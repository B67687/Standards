# AI Attribution Standard

## Domains

ai,universal


## Why

AI-assisted development is the norm across all projects in this org. Commits should be **transparent** about which tool and model produced them, but **never pollute** GitHub contributor stats with fake accounts or co-authors that aren't real people.

## Principles

1. **Author is always the human.** The `Author` field in every commit is the real person. GitHub uses the author for contributor stats, contribution graphs, and profile activity feeds.
2. **Committer is the harness.** The `Committer` field records the AI *harness* that applied the work. The harness is the direct orchestrating agent, not the runtime platform.
3. **Three layers, two in commits, one in credit system:**
   | Layer | Example | Where credited |
   |-------|---------|----------------|
   | **Platform** | OpenCode | CREDITS.md + badges |
   | **Harness** | OhMyOpenAgent | Git committer field |
   | **Model** | DeepSeek-V4-Flash | `Generated-By:` commit trailer |
4. **Model in a trailer.** The specific AI model is recorded in an `Generated-By:` trailer for machine parseability and fine-grained provenance.
5. **No fake co-authors.** `Co-Authored-By:` is reserved for human pair-programming partners. Using it for AI dilutes its meaning and has stirred community controversy.
6. **Non-routable identifiers.** All AI-related emails use the `.local` domain (RFC 6761). No AI email can ever map to a real GitHub account.
7. **Visual as well as textual.** AI attribution appears both as commit metadata and as README badges.

## Committer Field Format

Every AI-assisted commit sets the committer to the harness name and a `.local` email:
```
GIT_COMMITTER_NAME="<Harness>"
GIT_COMMITTER_EMAIL="<harness-slug>@local"
```
| Part | Value | Example |
|------|-------|---------|
| Harness | The orchestrating tool | `OhMyOpenAgent` |
| Email slug | Lowercased kebab-case harness name | `ohmyopenagent` |
| Domain | `.local` (RFC 6761 reserved TLD) | `@local` |

Examples: `OhMyOpenAgent <ohmyopenagent@local>`, `Claude Code <claude-code@local>`, `Codex CLI <codex-cli@local>`.

**Rationale:** `.local` never resolves in DNS — no GitHub account can claim it. The harness is not AI (the model is, credited in the trailer), so no `(AI)` suffix.

## Model Trailer Format

The specific AI model is recorded as a Git trailer on the last line of the commit body:
```
Generated-By: <model-name>
```
| Part | Value | Example |
|------|-------|---------|
| Generated-By | Trailer key | `Generated-By` |
| Value | Full model name as branded by provider | `DeepSeek V4 Flash` |

Examples: `Generated-By: DeepSeek V4 Flash`, `Generated-By: Claude Sonnet 4.5`, `Generated-By: GPT 5.4`, `Generated-By: DeepSeek V4 Flash (Max)`. The reasoning level or variant (if applicable) is included in parentheses.

## Full Commit Example

```
Author:     B67687 <111849193+B67687@users.noreply.github.com>
Committer:  OhMyOpenAgent <ohmyopenagent@local>

    feat(core): add bus route caching

    Bus arrival data is fetched on every screen load.
    Caching responses for 30s reduces API calls by ~80%
    and makes the UI feel instant on repeated lookups.

    Generated-By: DeepSeek V4 Flash
```

In GitHub's UI, the commit attributes to the author for contribution stats. The `.local` committer renders as an unlinked, unresolvable identity on the commit page.

## When to Use

| Level | When | Required? |
|-------|------|-----------|
| **Major contribution** | AI generated >50% of the commit content | SHOULD set committer + trailer |
| **Minor contribution** | AI assisted with debugging, refactoring, or documentation | MAY set committer + trailer |
| **No AI contribution** | Human-only commit | MUST NOT set AI committer or trailer |

## What NOT To Do

| Anti-pattern | Why |
|---|---|
| `Co-authored-by: DeepSeek <deepseek@example.com>` | Co-Authored-By is for humans. Email could resolve to a real GitHub account. |
| `Co-authored-by: Copilot <account@users.noreply.github.com>` | Same — co-author is for pair programming, not AI. |
| AI model name in subject line | Clutters the log, not machine-parseable. |
| `X-Generated-By:` prefix | `X-` headers are non-standard and may be stripped. |
| Setting author to AI name | The human is always the author. GitHub uses author for contributor stats. |

## How to Apply

**Via environment variables (preferred):**
```bash
export GIT_COMMITTER_NAME="OhMyOpenAgent"
export GIT_COMMITTER_EMAIL="ohmyopenagent@local"
git commit -m "feat: add rate limiting" \
  -m "Implementation details..." \
  --trailer "Generated-By: DeepSeek V4 Flash"
```

**Via git config (per-repo):**
```bash
git config committer.name "OhMyOpenAgent"
git config committer.email "ohmyopenagent@local"
```
Each commit then automatically uses the harness committer. The `Generated-By:` trailer still needs to be set per-commit. A `prepare-commit-msg` hook can automate both when `AI_HARNESS` and `AI_MODEL` env vars are set (see `scripts/prepare-commit-msg`).

## Badge Implementation

AI attribution is also **visual** — badges grouped under the "Built with AI assistance" line show which models, harnesses, and platforms a project uses at a glance. Generate badges using `scripts/generate-badge.sh` per the [badge-standard.md](./badge-standard.md).

**Badge Format:**

| Component | Label (category) | Value (name) | Color | Example |
|-----------|-----------------|-------------|-------|---------|
| AI Model | `model` | Full model name + tier in parens if subtier | Per-model color (below) | `model` / `DeepSeek V4 Flash (Max)` on `#4f46e5` |
| Harness | `harness` | Harness display name | `#7f52ff` (purple) | `harness` / `Oh My OpenAgent` on `#7f52ff` |
| Platform | `platform` | Platform name | `#64748b` (slate) | `platform` / `OpenCode` on `#64748b` |

**Per-Model Colors:** DeepSeek = `#4f46e5`, GPT = `#10a37f`, Claude = `#d97706`, MiMo = `#0891b2`, Kimi = `#7c3aed`, Qwen = `#0ea5e9`, MiniMax = `#f43f5e`, GLM = `#f97316`.

**Badge Placement in README:** AI model badges go **after** the "Built with AI assistance" attribution line, **not mixed in with tech badges** (CI status, language, license). Per badge-standard.md density rules (max 6 total badges):
```
Tech badge header:  CI > Tech > License             (max 3-4)
AI attribution:     Model(s) > Harness > Platform    (max 3-4)
```
Use the `<picture>` pattern for dark mode support when badge contrast is insufficient on dark backgrounds.

## Enforcement

This standard is **recommended** for all repos. Reviews should check:
1. **Author field**: Is the human the author? (Must not be AI.)
2. **Committer field**: If AI-assisted, is the committer set to the harness with a `.local` email?
3. **Generated-By trailer**: Is the model identifier specific enough to be useful?
4. **CREDITS.md**: Does it exist and track all three layers (platform, harness, model)?
5. **Badges**: Are AI badges present under the attribution line in README?
6. **No Co-Authored-By for AI**: Is `Co-Authored-By:` reserved for humans only?

## Updates to Other Standards

- `commit-conventions-standard.md` — references this standard for committer-based attribution.
- `badge-standard.md` — AI badge conventions consolidated here; retains generator tooling and generic format rules.
- `CREDITS.md` — should include all three layers (platform, harness, model) in the attribution table.
