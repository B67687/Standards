# AI Attribution Standard

## Why

AI-assisted development is the norm across all projects in this org. Commits should be **transparent** about which model and tooling produced them, but **never pollute** GitHub contributor stats with fake accounts or co-authors that aren't real people.

## Principles

1. **Author is always the human.** The `Author` field in every commit is the real person (`B67687`). GitHub uses the author for contributor stats, contribution graphs, and profile activity feeds.
2. **Models are tools, not collaborators.** AI models get a `Co-Authored-By` trailer with a `.local` email that cannot map to a GitHub account.
3. **Uniquely identifiable.** Each model + harness combination has a distinct, non-routable email so provenance is clear.
4. **Machine-parseable.** Trailers follow the `Co-Authored-By: Name <email>` convention so tooling can extract them.
5. **Visual as well as textual.** AI attribution appears both as commit trailers (for provenance) and as README badges (for project visibility).

## Trailer Format

Every AI-assisted commit carries a single trailer at the bottom of the commit body:

```
Co-Authored-By: <Model> via <Harness> <model+harness@models.local>
```

### Components

| Part | Value | Example |
|------|-------|---------|
| Model | The LLM model name (as branded by provider) | `DeepSeek V4 Flash` |
| via | Literal separator | `via` |
| Harness | The orchestrating tool | `oh-my-openagent` |
| Email | `model+harness@models.local` | `deepseek-v4-flash+oh-my-openagent@models.local` |

### Rationale

- **`.local`** — Reserved by RFC 6761, never resolves in DNS, legally safe.
- **`+` subaddressing** — Separates model and harness for parsing (RFC 5233).
- **`Co-Authored-By:`** — Standard Git trailer recognized by GitHub. The `.local` email ensures **no GitHub account can claim the contribution**, keeping the contributor graph clean.

### Examples

```
Co-Authored-By: DeepSeek V4 Flash via oh-my-openagent
  <deepseek-v4-flash+oh-my-openagent@models.local>

Co-Authored-By: Claude Sonnet 4.5 via oh-my-openagent
  <claude-sonnet-4.5+oh-my-openagent@models.local>

Co-Authored-By: GPT-5.4 via oh-my-openagent
  <gpt-5.4+oh-my-openagent@models.local>

Co-Authored-By: DeepSeek V4 Pro via opencode
  <deepseek-v4-pro+opencode@models.local>
```

### Not Just the Model — Model + Harness

The harness is included because the same model produces measurably different results depending on the orchestration layer. A model alone is not as powerful as model + harness.

## Full Commit Example

```
Author:     B67687 <111849193+B67687@users.noreply.github.com>
Commit:     B67687 <111849193+B67687@users.noreply.github.com>

feat(core): add bus route caching

Bus arrival data is fetched on every screen load.
Caching responses for 30s reduces API calls by ~80%
and makes the UI feel instant on repeated lookups.

Co-Authored-By: DeepSeek V4 Flash via oh-my-openagent
  <deepseek-v4-flash+oh-my-openagent@models.local>
```

## When to Use

| Level | When | Required? |
|-------|------|-----------|
| **Major contribution** | AI generated >50% of the commit content | SHOULD |
| **Minor contribution** | AI assisted with debugging, refactoring, or documentation | MAY |
| **No AI contribution** | Human-only commit | MUST NOT add |

## What NOT To Do

| Anti-pattern | Why |
|---|---|
| `Co-authored-by: DeepSeek <deepseek@example.com>` | Email could resolve to a real GitHub account, polluting stats |
| `Co-authored-by: Copilot <account@users.noreply.github.com>` | Maps directly to a real GitHub user — worst case |
| AI model name in subject line | Clutters the log, not machine-parseable |
| `X-AI-Model:` prefix | Non-standard, some tools strip `X-` headers |

## Badge Implementation

AI attribution is also **visual** — badges grouped under the "Built with AI assistance" line in the README show which models and harnesses a project uses at a glance.

### Badge Format

Generate badges using `scripts/generate-badge.sh` per the [badge-standard.md](./badge-standard.md):

| Component | Badge Label | Color | Example |
|-----------|-------------|-------|---------|
| AI Model | Model name | Per-model color (below) | `DeepSeek V4 Flash` on `#4f46e5` |
| Harness | Harness name | `#7f52ff` (purple) | `oh-my-openagent` on `#7f52ff` |

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
AI attribution:     AI Model(s) > AI Harness(s)      (max 2-3)
```

Example in README:

```html
<div align="center">

# Project Name

<!-- Tech badges (what it is) -->
<p align="center">
  <img src="docs/badges/rust.svg" alt="Rust" />
  <img src="docs/badges/license.svg" alt="MIT" />
  <img src="https://github.com/org/repo/actions/.../badge.svg" alt="CI">
</p>

Short description (≤120 chars)

</div>

Built with AI assistance — see [CREDITS.md](./CREDITS.md).

<p align="center">

<!-- AI model badges (how it was made) -->
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/badges/deepseek-dark.svg">
  <img src="docs/badges/deepseek.svg" alt="DeepSeek V4 Flash" />
</picture>
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/badges/opencode-harness-dark.svg">
  <img src="docs/badges/opencode-harness.svg" alt="OpenCode harness" />
</picture>

</p>
```

### Generator Commands

```bash
# Model badge
bash scripts/generate-badge.sh \
  --label "DeepSeek" \
  --value "V4 Flash" \
  --color "4f46e5"

# Harness badge
bash scripts/generate-badge.sh \
  --label "oh-my-openagent" \
  --value "v4.12.1" \
  --color "7f52ff"
```

### Dark Mode Support

For badges that may be invisible on dark backgrounds, use the `<picture>` pattern:

```html
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/badges/deepseek-dark.svg">
  <img src="docs/badges/deepseek.svg" alt="DeepSeek V4 Flash">
</picture>
```

### Badge Sets by Repo

| Repo | AI Badges |
|------|-----------|
| bus-hop | `deepseek`, `opencode` |
| ithmb-codec | `deepseek`, `opencode` |
| agentic-workflows | `deepseek`, `minimax-m2.5`, `minimax-m2.7`, `kimi-k2.6`, `opencode` |
| traffic-dashboard | `deepseek` |

## Enforcement

This standard is **recommended** for all repos. Not commitlint-enforced (trailers are freeform), but reviews should check:

- Is `Co-Authored-By:` present in AI-assisted commits?
- Does the email use `.local` domain (not a real GitHub account)?
- Is the model identifier specific enough to be useful?
- Are AI model badges present under the attribution line in README?

## CLI Shortcut

```bash
git commit -m "Summary" \
  -m "Body" \
  --trailer "Co-Authored-By: DeepSeek V4 Flash via oh-my-openagent <deepseek-v4-flash+oh-my-openagent@models.local>"
```

## Updates to Other Standards

- `commit-conventions-standard.md` — its `Co-authored-by` section MUST reference this standard instead of using fake email addresses.
- `badge-standard.md` — its AI model badge conventions are consolidated here. The badge-standard retains the generator tooling and generic format rules.

## Origin

2026-06-22 — Created after the Bus-Hop repo restoration incident where `Co-authored-by: Sisyphus` with a routable email polluted the GitHub contributor graph on B67687's profile. See [GitHub Community #166884](https://github.com/orgs/community/discussions/166884) for the caching issue. Revised same day to use `Co-Authored-By:` with `.local` domain and unified with badge-standard for visual attribution.
