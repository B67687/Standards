# SVG Badge Generator Standard

## Domains

docs


## Why Local SVGs

Badges from shields.io URLs depend on GitHub's camo proxy, which times out on external fetches. Static SVGs committed to `docs/badges/` render instantly, have no external dependency, and never break.

**Exception:** GitHub workflow status badges (CI pass/fail) MUST use dynamic shields.io URLs — they show live status and can't be static. Use the standard inline format:
```
![CI](https://github.com/OWNER/REPO/actions/workflows/ci.yml/badge.svg)
```

## Badge Structure

All badges follow shields.io format — a two-part SVG with a dark label on the left and a colored value on the right:

```
┌────────────┬────────────┐
│  Label     │   Value    │
│  (#555)    │  (colored) │
└────────────┴────────────┘
```

## Color Convention

| Category | Right-Side Color | Example |
|----------|-----------------|---------|
| Tech/metrics | `#2ea44f` (green) | tests: 161, minSdk: 26 |
| License | `#d8b800` (yellow) | license: MIT |
| AI Models | Per-model color | deepseek: `#4f46e5`, gpt: `#10a37f` |
| Harness/Platform | `#7f52ff` (purple) | oh-my-openagent |

## Label Convention

Badges are two-part: **Label** (left, dark gray `#555`) and **Value** (right, colored). The label-value split follows this convention:

| Badge Type | Label (category) | Value (name) | Example |
|------------|-----------------|--------------|---------|
| AI Model | `model` | Full model name + tier in parens if subtier | `model` / `DeepSeek V4 Flash (Max)` |
| Harness | `harness` | Harness display name | `harness` / `Oh My OpenAgent` |
| Language | Language name | Version or `standard` | `Kotlin` / `2.1` |
| License | `license` | SPDX identifier | `license` / `MIT` |
| Metrics | Plural noun | Number | `tests` / `161` |

The label is always the **category** (e.g. `model`, `harness`, `license`), not the individual name. The value is the specific thing — the full model name (with tier parenthesized if it's a subtier, not part of the canonical name), or the harness display name. This makes all badges consistent: type on the left, name on the right.
| Build/CI | `#007ec6` (blue) | actions, html |

Note: `#2ea44f` is slightly darker than standard shields.io green (`#4b0`/`#44BB00`) for better WCAG AA compliance with white text. The shields.io default greens (~2.5:1 contrast) fail accessibility standards; this standard uses contrast-safe alternatives where feasible.

## Icons in Badges

Industry practice (VS Code, Kubernetes, Homebrew): **all major projects use text-only badges without icons.** Icons are not the standard. Our badges follow the same convention — text-only for simplicity and compatibility.

Exception: If a tech logo adds clarity (e.g., Kotlin shield on an Android project), the `--icon` flag in `scripts/generate-badge.sh` supports embedding the icon as an SVG data URI. Supported icons: `kotlin`, `java`, `compose`, `github`.

## Badge Density

Maximum **6 badges per README header.** More than 6 creates visual noise. Priority order:

1. CI status (dynamic URL)
2. Language/tech stack
3. License
4. AI model(s)
5. AI harness/platform
6. Metrics (tests, version, downloads)

Major projects use 3-6 badges. Our current repos are at or above this limit — keep new additions minimal.

## Directory

All static badges: `docs/badges/*.svg`

**Exception:** Standard GitHub badges (license, language, etc.) SHOULD use Shields.io dynamic URLs instead of static SVGs when:
- The badge value is publicly available via GitHub API (license, language, stars, etc.)
- The badge auto-updates without manual intervention
- Example: `![license](https://img.shields.io/github/license/OWNER/REPO)`

## Generator Script

Use `scripts/generate-badge.sh` for any repo:

```bash
# Simple label:value badge
bash scripts/generate-badge.sh --label "tests" --value "161" --color "2EA44F"

# With icon
bash scripts/generate-badge.sh --label "Kotlin" --value "2.4" --color "7F52FF" --icon kotlin

# Output: docs/badges/tests.svg
```

## Dark Mode

Static SVG badges render as `<img>` elements — they cannot use CSS media queries. For badges that need light/dark variants, use the `<picture>` pattern in README:

```html
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/badges/deepseek-dark.svg">
  <img src="docs/badges/deepseek.svg" alt="DeepSeek V4 Flash">
</picture>
```

Most badges work fine in both modes with their existing colors. The `<picture>` tag is only needed if a badge is invisible in dark mode.

## Where Badges Are Used

Badges appear in the README header:

```html
<p align="center">
  <img src="docs/badges/kotlin.svg" alt="Kotlin">
  <img src="docs/badges/license.svg" alt="MIT">
  <img src="docs/badges/deepseek.svg" alt="model: DeepSeek V4 Flash (Max)">
  <img src="docs/badges/oh-my-openagent-harness.svg" alt="harness: Oh My OpenAgent">
</p>
```

## Badge Sets by Repo

| Repo | Badges |
|------|--------|
| bus-hop | kotlin, compose, minsdk, targetsdk, license, tests, gpt5.4, deepseek, oh-my-openagent |
| ithmb-codec | deepseek, tests, license, version, commits, profiles, runtime, oh-my-openagent |
| agentic-workflows | gpt5.4, deepseek, minimax-m2.5, minimax-m2.7, kimi-k2.6, oh-my-openagent |
| traffic-dashboard | actions, deepseek, html, license |
| 2002-Combat | gpt5.4, java, license |

## Simple Icons Reference (for shields.io dynamic badges)

If using shields.io URLs directly (e.g., CI badges), `&logo=` parameter accepts Simple Icons slugs:

| Tool | Slug | Available? |
|------|------|-----------|
| DeepSeek | `deepseek` | ✅ |
| Oh My OpenAgent | `oh-my-openagent` | ✅ |
| Anthropic | `anthropic` | ✅ |
| MiniMax | `minimax` | ✅ |
| OpenAI | (none) | ❌ — must use custom SVG |
| Codex | (none) | ❌ — must use custom SVG |
| Kimi | (none) | ❌ — must use custom SVG |
