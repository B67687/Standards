# AI Attribution Standard

## Why

AI-assisted development is the norm across all projects in this org. Commits should be **transparent** about which tool and model produced them, but **never pollute** GitHub contributor stats with fake accounts or co-authors that aren't real people.

## Principles

1. **Author is always the human.** The `Author` field in every commit is the real person. GitHub uses the author for contributor stats, contribution graphs, and profile activity feeds.

2. **Committer is the harness.** The `Committer` field records the AI *harness* that applied the work (e.g. `OhMyOpenAgent`). This follows Git's design — the committer is "the person who last applied the work." The harness is the direct orchestrating agent, not the runtime platform (see layers below).

3. **Three layers, two in commits, one in credit system:**

   | Layer | Example | Where credited |
   |-------|---------|----------------|
   | **Platform** | OpenCode | CREDITS.md + badges |
   | **Harness** | OhMyOpenAgent | Git committer field |
   | **Model** | DeepSeek-V4-Flash | `Generated-By:` commit trailer |

   The platform is the runtime environment — like "I wrote this in VS Code." It doesn't belong in commit metadata. The harness is the direct actor ("the tool that applied the commit"). The model is the intelligence source.

4. **Model in a trailer.** The specific AI model is recorded in an `Generated-By:` trailer for machine parseability and fine-grained provenance.

5. **No fake co-authors.** `Co-Authored-By:` is reserved for human pair-programming partners. Using it for AI dilutes its meaning and has stirred community controversy.

6. **Non-routable identifiers.** All AI-related emails use the `.local` domain (RFC 6761 — never resolves in DNS). No AI email can ever map to a real GitHub account.

7. **Visual as well as textual.** AI attribution appears both as commit metadata (for provenance) and as README badges (for project visibility).

## Committer Field Format

Every AI-assisted commit sets the committer to the harness name and a `.local` email:

```
GIT_COMMITTER_NAME="<Harness>"
GIT_COMMITTER_EMAIL="<harness-slug>@local"
```

### Components

| Part | Value | Example |
|------|-------|---------|
| Harness | The orchestrating tool | `OhMyOpenAgent` |
| Email slug | Lowercased kebab-case harness name | `ohmyopenagent` |
| Domain | `.local` (RFC 6761 reserved TLD) | `@local` |

### Examples

```
Committer: OhMyOpenAgent <ohmyopenagent@local>
Committer: Claude Code <claude-code@local>
Committer: Codex CLI <codex-cli@local>
```

### Rationale

- **`.local`** — Reserved by RFC 6761, never resolves in DNS, legally safe. No GitHub account can ever claim it.
- **No `(AI)` suffix** — The harness is not AI. The harness is a tool that orchestrates AI. The model is the AI component, credited in the trailer.
- **Kebab-case slug** — Consistent with repository naming conventions.

## Model Trailer Format

The specific AI model is recorded as a Git trailer on the last line of the commit body:

```
Generated-By: <model-name>
```

### Components

| Part | Value | Example |
|------|-------|---------|
| Generated-By | Trailer key | `Generated-By` |
| Value | Full model name as branded by provider | `DeepSeek V4 Flash` |

### Examples

```
Generated-By: DeepSeek V4 Flash
Generated-By: Claude Sonnet 4.5
Generated-By: GPT 5.4
Generated-By: DeepSeek V4 Flash (Max)
```

The reasoning level or variant (if applicable) is included in parentheses, e.g. `DeepSeek V4 Flash (Max)`.

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

In `git log`:

```
$ git log --format="%an (%ae) vs %cn (%ce)" -1
B67687 (111849193+B67687@users.noreply.github.com) vs
  OhMyOpenAgent (ohmyopenagent@local)
```

The committer appears differently in GitHub's UI:
- **Contribution graph**: The commit attributes to the author (human). The committer is shown in the commit details but does **not** create a GitHub user or pollute stats.
- **Commit page**: Shows both author and committer. The `.local` email renders as an unlinked, unresolvable identity.

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

### Via environment variables (preferred)

The harness sets these before invoking `git commit`:

```bash
export GIT_COMMITTER_NAME="OhMyOpenAgent"
export GIT_COMMITTER_EMAIL="ohmyopenagent@local"
git commit -m "feat: add rate limiting" \
  -m "Implementation details..." \
  --trailer "Generated-By: DeepSeek V4 Flash"
```

### Via git config (per-repo)

For repos that use the same harness consistently:

```bash
git config committer.name "OhMyOpenAgent"
git config committer.email "ohmyopenagent@local"
```

Then each commit automatically uses the harness committer. The `Generated-By:` trailer still needs to be set per-commit.

### Via prepare-commit-msg hook (automated)

If the harness sets `AI_HARNESS` and `AI_MODEL` environment variables, a `prepare-commit-msg` hook can automatically set the committer and append the trailer. See `scripts/prepare-commit-msg` in this repo.

### Manual one-liner

```bash
GIT_COMMITTER_NAME="OhMyOpenAgent" \
GIT_COMMITTER_EMAIL="ohmyopenagent@local" \
git commit -m "Subject" -m "Body" --trailer "Generated-By: DeepSeek V4 Flash"
```

## Badge Implementation

AI attribution is also **visual** — badges grouped under the "Built with AI assistance" line in the README show which models, harnesses, and platforms a project uses at a glance.

### Badge Format

Generate badges using `scripts/generate-badge.sh` per the [badge-standard.md](./badge-standard.md):

| Component | Label (category) | Value (name) | Color | Example |
|-----------|-----------------|-------------|-------|---------|
| AI Model | `model` | Full model name + tier in parens if subtier | Per-model color (below) | `model` / `DeepSeek V4 Flash (Max)` on `#4f46e5` |
| Harness | `harness` | Harness display name | `#7f52ff` (purple) | `harness` / `Oh My OpenAgent` on `#7f52ff` |
| Platform | `platform` | Platform name | `#64748b` (slate) | `platform` / `OpenCode` on `#64748b` |

### Per-Model Colors

| Model | Color |
|-------|-------|
| DeepSeek (all variants) | `#4f46e5` (indigo) |
| GPT (all variants) | `#10a37f` (green) |
| Claude (all variants) | `#d97706` (amber) |
| MiMo | `#0891b2` (cyan) |
| Kimi | `#7c3aed` (violet) |
| Qwen | `#0ea5e9` (sky) |
| MiniMax | `#f43f5e` (rose) |
| GLM | `#f97316` (orange) |

### Badge Placement in README

AI model badges go **after** the "Built with AI assistance" attribution line, **not mixed in with tech badges** (CI status, language, license). This separates *what the project is* (tech badges in header) from *how it was made* (AI badges under attribution).

Per badge-standard.md density rules (max 6 total badges across both groups):

```
Tech badge header:  CI > Tech > License             (max 3-4)
AI attribution:     Model(s) > Harness > Platform    (max 3-4)
```

Example in README:

```html
<div align="center">

# Project Name

<!-- Tech badges (what it is) -->
<p align="center">
  <img src="docs/badges/ci.svg" alt="CI" />
  <img src="docs/badges/license.svg" alt="MIT" />
</p>

Short description (≤120 chars)

</div>

Built with AI assistance — see [CREDITS.md](./CREDITS.md).

<p align="center">

<!-- AI badges (how it was made) -->
<img src="docs/badges/deepseek.svg" alt="DeepSeek V4 Flash" />
<img src="docs/badges/oh-my-openagent-harness.svg" alt="Oh My OpenAgent" />
<img src="docs/badges/opencode-platform.svg" alt="OpenCode" />

</p>
```

### Generator Commands

```bash
# Model badge
bash scripts/generate-badge.sh \
  --label "model" \
  --value "DeepSeek V4 Flash (Max)" \
  --color "4f46e5"

# Harness badge
bash scripts/generate-badge.sh \
  --label "harness" \
  --value "Oh My OpenAgent" \
  --color "7f52ff"

# Platform badge
bash scripts/generate-badge.sh \
  --label "platform" \
  --value "OpenCode" \
  --color "64748b"
```

### Dark Mode Support

For badges that may be invisible on dark backgrounds, use the `<picture>` pattern:

```html
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/badges/deepseek-dark.svg">
  <img src="docs/badges/deepseek.svg" alt="DeepSeek V4 Flash">
</picture>
```

## Enforcement

This standard is **recommended** for all repos. Reviews should check:

1. **Author field**: Is the human the author? (Must not be AI.)
2. **Committer field**: If AI-assisted, is the committer set to the harness with a `.local` email?
3. **Generated-By trailer**: Is the model identifier specific enough to be useful?
4. **CREDITS.md**: Does it exist and track all three layers (platform, harness, model)?
5. **Badges**: Are AI badges present under the attribution line in README?
6. **No Co-Authored-By for AI**: Is `Co-Authored-By:` reserved for humans only?

## Updates to Other Standards

- `commit-conventions-standard.md` — its "Co-authored-by" section now references this standard for committer-based attribution.
- `badge-standard.md` — its AI model badge conventions are consolidated here. The badge-standard retains the generator tooling and generic format rules.
- `CREDITS.md` — should include all three layers (platform, harness, model) in the attribution table.

## Origin

2026-06-22 — Created after the Bus-Hop repo restoration incident where `Co-authored-by: Sisyphus` with a routable email polluted the GitHub contributor graph. Revised 2026-06-25 — moved from `Co-Authored-By` trailers to committer-based attribution with harness-as-committer and `Generated-By:` trailer. See `HANDOVER.md` for the full discussion history.
