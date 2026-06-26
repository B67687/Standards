# README Standard

## Title Format

The title is an H1 heading wrapped in a centered `<div>` tag, followed by the badge row and summary line inside the same centered block:

```html
<div align="center">

# Project Name

<picture>
  <img src="docs/badges/..." alt="...">
</picture>
...

Short description (≤120 chars, no heading)

</div>
```

## Section Order

```
 1. Title (H1)
 2. Tech Badges (centered row — CI status, language/tech stack, license)
 3. Short Description (≤120 chars, no heading, on its own line)
  4. AI Attribution + AI Model Badges ("Built with AI assistance" + model/harness badges)
  5. Acknowledgements Callout (if applicable — see §Acknowledgements)
  6. Screenshots / Demo (apps only — near top)
  7. Table of Contents (required if >100 lines)
  8. Features / What It Does
  9. Quick Start / Installation
 10. Usage / Examples
 11. Architecture (libraries/harnesses — with SVG diagram)
 12. Contributing (required — state PR policy, where to ask questions)
 13. Optional sections (any order): Development, Testing, API, Config, Privacy, FAQ
 14. Changelog link ("See CHANGELOG.md")
 15. Acknowledgements Section (detailed — see §Acknowledgements)
 16. License (ALWAYS LAST)
```

## Tech Badge Header

Tech badges (CI status, language/tech stack, license) are centered `<img>` tags, placed directly under the title. AI model badges go under the attribution line (see next section).

```html
<div align="center">

# Project Name

<p align="center">
  <img src="docs/badges/kotlin.svg" alt="Kotlin" />
  <img src="docs/badges/license.svg" alt="MIT" />
  <img src="https://github.com/org/repo/actions/workflows/ci.yml/badge.svg" alt="CI">
</p>

Short description (≤120 chars, no heading)

</div>
```

Tech badge SVGs live in `docs/badges/` and are generated via `scripts/generate-badge.sh`. All badges on the same line must be the same height (20px standard).

## AI Attribution Badges

AI model and harness badges go directly under the "Built with AI assistance" line, separating the how-it-was-made badges from the what-it-is tech badges.

```html
Built with AI assistance — see [CREDITS.md](./CREDITS.md).

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/badges/deepseek-dark.svg">
    <img src="docs/badges/deepseek.svg" alt="model: DeepSeek V4 Flash (Max)" />
  </picture>
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/badges/oh-my-openagent-harness-dark.svg">
    <img src="docs/badges/oh-my-openagent-harness.svg" alt="harness: Oh My OpenAgent" />
  </picture>
</p>
```

This keeps the badge header clean (2-4 tech badges) while still giving AI attribution visible presence in the README. The AI badge row is centered (`<p align="center">`) to match the tech badge header, creating a unified top section.

## Acknowledgements

Acknowledgements follow a **two-tier** system matching visibility to contribution significance:

**Tier 1 — Callout (top, optional):** For individuals or orgs who specifically requested attribution, or for significant sponsors. Place immediately after the description, before any other content. Use a GitHub alert for visibility:

```markdown
> [!NOTE]
> **Special thanks to [name](link) from [org](link)** for [specific contribution].
```

The callout tier keeps the promise of visible attribution without cluttering the badge row.

**Tier 2 — Section (bottom, optional):** For all credits, contributors, inspirations, and tools. Place before License as `## Acknowledgements` (or `## Credits`). May include:

- Individual contributors (name + link + contribution)
- Orgs / sponsors (logo + link)
- Libraries or tools the project depends on
- Inspirations or related projects

```markdown
## Acknowledgements

- [savi](https://github.com/savi) from [iopenpod](https://iopenpod.com) — [reason]
- [Other contributor] — [reason]
```

**Rule of thumb:** If someone asks to be credited, use at minimum the Tier 1 callout. A Tier 2-only placement does not satisfy an explicit attribution request.

The template for repos with acknowledgements:

```md
> [!NOTE]
> **Special thanks to [name](link)** for [contribution].

## Acknowledgements

Special thanks to:
- [name](link) — [detail]
```

## Dark Mode

GitHub supports dark mode. Images in the README should work in both themes:

**For logos / brand images:** Use GitHub's `#gh-dark-mode-only` / `#gh-light-mode-only` URL fragments:

```markdown
![logo-light](docs/images/logo-light.svg#gh-light-mode-only)
![logo-dark](docs/images/logo-dark.svg#gh-dark-mode-only)
```

**For architecture diagrams / screenshots:** Use the `<picture>` tag with `prefers-color-scheme`:

```html
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/diagrams/arch-dark.svg">
  <img src="docs/diagrams/arch-light.svg" alt="Architecture diagram">
</picture>
```

**For badges:** Most badge colors work on both backgrounds. No special handling needed.

## When to Split

If the README exceeds 300 lines, split content into separate files:

| File                | Content                                            |
| ------------------- | -------------------------------------------------- |
| `README.md`         | On-ramp: description, badges, quick start, license |
| `ARCHITECTURE.md`   | Deep architecture, diagrams, design decisions      |
| `DEVELOPMENT.md`    | Build from source, testing, contributing           |
| `CONTRIBUTING.md`   | How to contribute, code standards, PR workflow     |
| `CHANGELOG.md`      | Release history (Keep a Changelog format)          |
| `CREDITS.md`        | AI model attributions                              |
| `API.md`            | Full API reference                                 |
| `HARDWARE_GUIDE.md` | Hardware-specific validation (if applicable)       |

## GitHub-Sponsored Files

These files should exist at repo root alongside README.md (not inside it):

| File | Required? | Content |
|------|-----------|---------|
| `LICENSE` | ✅ Yes | MIT for public repos |
| `CONTRIBUTING.md` | ✅ Yes | PR policy, code standards, workflow |
| `CODE_OF_CONDUCT.md` | 🟡 Recommended | Expected behavior, reporting |
| `SECURITY.md` | 🟡 Recommended | Vulnerability disclosure policy |

## Templates by Repo Type

### Harness / Framework (e.g. agentic-workflows)

```
Title → Tech Badges → Description → AI Attribution + AI Badges →
[Callout] → Quick Start → Workflow / Features → Architecture →
Contributing → Changelog → [Acknowledgements] → License
```

Key features: CLI examples, workflow tree, configuration reference, ecosystem diagram.

### Library (e.g. ithmb-codec)

```
Title → Tech Badges → Description → AI Attribution + AI Badges →
[Callout] → Install → Usage → Architecture → Build → Test →
Contributing → Changelog → [Acknowledgements] → License
```

### Application (e.g. bus-hop)

```
Title → Tech Badges → Description → AI Attribution + AI Badges →
[Callout] → Screenshots → Features → Download → Tech Stack →
Architecture → Contributing → [Acknowledgements] → License
```

## GitHub Alerts

Use GitHub-flavored markdown alerts for callouts. They render as colored boxes:

```markdown
> [!NOTE]
> Key information that users should be aware of.

> [!TIP]
> Helpful advice for doing things better.

> [!IMPORTANT]
> Information that is critical to understanding the project.

> [!WARNING]
> Content that has the potential to cause issues.

> [!CAUTION]
> Potential negative consequences of an action.
```

Use alerts sparingly — they lose impact if overused. One alert per section max.

## Image Paths

All images use relative paths under `docs/`:

```
docs/screenshots/   → screenshots
docs/badges/        → badges
docs/diagrams/      → SVG architecture diagrams
```

## Related Standards

| Component | Standard | Applies To |
|-----------|----------|------------|
| Badges | `docs/standards/badge-standard.md` | README tech badge header |
| AI Attribution | `docs/research/ai-attribution-pattern.md` | CREDITS.md + AI attribution badges |
| SVG Screenshots | `docs/standards/svg-screenshots-standard.md` | Images in Screenshots section |
| SVG Diagrams | `bus-hop/docs/research/svg-standards.md` | Architecture diagram section |
| Changelog | `docs/standards/changelog-standard.md` | Changelog link section |
| Repository Structure | `docs/standards/repo-structure-standard.md` | `docs/` subdirectory layout |

## References

- [Standard Readme](https://github.com/RichardLitt/standard-readme) — formal README spec
- [Make a README](https://www.makeareadme.com/) — practical guide
- [Awesome README](https://github.com/matiassingers/awesome-readme) — curated examples
