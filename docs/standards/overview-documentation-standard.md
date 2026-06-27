# Overview / Concepts Documentation Standard

## Domains

docs,quality

## Purpose

Most projects fail to explain themselves to newcomers. A good overview bridges the gap between "never heard of this" and "ready to use it." Without one, potential users hit the repo, scan a wall of technical jargon, and leave. The overview is your project's handshake with the world.

## When Needed

Every repo MUST have at least one of:

- A "What Is This" section in the README, or
- A `docs/overview.md` file linked from the README

Small tools or libraries under 200 LOC may satisfy this with the README description alone provided it covers all required sections below. Larger or multi-audience projects SHOULD use a standalone overview doc.

## Required Sections

These sections tell the story in order. Every overview must cover each one.

### Elevator Pitch

One to two sentences. What is this? Why does it exist? A complete answer you could give someone in an elevator.

> *Example: "Zest is a CLI tool that validates environment variable schemas before your app boots. It catches misconfigured deployments before they reach production."*

### Problem Statement

Two to three sentences. What problem does this solve? For whom? Describe the pain, friction, or gap that motivated the project. Lead with the problem, not the solution.

> *Example: "Every team has been bitten by a production outage caused by a missing env var or a type mismatch in configuration. Existing solutions require runtime checks inside the application or rely on documentation that drifts from reality. Zest moves validation to a standalone preflight step that runs before any application code."*

### Who Is This For

State the target audience plainly. Be specific about which roles the project serves and which it does not.

- **Primary audience:** (developers, designers, analysts, end users, etc.)
- **Secondary audience:** (if applicable)
- **Not for:** (if there is a clear misfit, say so)

Include any prerequisite knowledge a reader needs (e.g., "familiarity with REST APIs," "basic SQL").

### Key Concepts

Domain-specific terms explained in plain language. Define the vocabulary a reader needs to understand the rest of the doc. If the glossary is large, provide a brief summary here and link to a separate `docs/glossary.md`.

| Term | Definition |
|------|-----------|
| *prompt harness* | A structured template that wraps raw prompts with system instructions, output schema, and error handling |
| *audit check* | A single executable test that passes or fails against a convention rule |

### How It Works

A paragraph describing the approach at a high level. No code. Describe the flow, the architecture, or the logical steps that transform input to output. A diagram helps here.

> *Example: "Zest reads a schema file written in TOML, resolves environment variables against that schema, and exits with a clear report of every missing or mistyped value. It never runs application code. The same schema can be checked at deploy time in CI and at boot time in production."*

### What Makes It Different

Why not use the alternative? Acknowledge existing solutions and explain the trade-offs.

> *Example: "Unlike dotenv-safe, which only checks for missing variables, Zest validates types and formats. Unlike a runtime check in your app framework, Zest runs standalone and can be used in CI without booting your application."*

## Tone

Write in plain language. Avoid jargon unless you define it in Key Concepts. Write for a smart non-specialist: someone competent who has never heard of your project. Use active voice. Short sentences. Show, don't sell.

| Do | Don't |
|----|-------|
| "Zest checks that your env vars exist and are the right type." | "Zest leverages runtime introspection to facilitate robust env-aware configuration validation." |
| "You define your schema once in a TOML file." | "The schema definition utilizes a declarative TOML DSL for maximum configurability." |

## Visual

Include at least one diagram or screenshot to illustrate the concept. A diagram is worth a paragraph.

- **Concept diagram:** SVG showing the flow or architecture. Use `<picture>` for dark/light mode support.
- **Screenshot:** For user-facing tools or apps, a terminal recording or UI screenshot.
- **Placement:** After "How It Works" or embedded alongside it.

Store visuals in `docs/diagrams/` or `docs/screenshots/` following the [README Standard](README-standard.md) image path conventions.

## Length

200 to 500 words for the overview section itself. Detailed concepts can expand into linked docs.

| Content | Target |
|---------|--------|
| Elevator Pitch | 1-2 sentences |
| Problem Statement | 2-3 sentences |
| Key Concepts | 3-8 terms max in overview; full glossary in `docs/glossary.md` |
| How It Works | 1 paragraph (50-150 words) |
| Total overview | 200-500 words |

If a concept needs more than 500 words, split it into a separate doc and link from the overview.

## Placement

**In README:** Put the overview content after the badges and description, before Quick Start. It should be the first substantive section a reader encounters.

```
Badges → Description → AI Attribution → [Overview content] → Quick Start → ...
```

**Standalone:** `docs/overview.md`. Link it prominently from the README, ideally in the description area or as the first link in the Table of Contents.

```markdown
> See [Overview](docs/overview.md) for what this project is and who it's for.
```

## Relation to README

The overview can be the README's opening narrative, or it can live in a separate doc if the README is very technical. The rule: a reader should understand what the project is and whether it's for them within 30 seconds of opening the README. If your README leans heavily on setup instructions, API reference, or CI badges, move the narrative to `docs/overview.md` and link it.

**Choose standalone when:**

- README exceeds 300 lines
- The project serves multiple audiences (different overviews per audience)
- The concept requires diagrams that would clutter the README's quick start flow
- The README is primarily technical (API reference, configuration reference)

## Quality Criteria

An overview passes review when:

- A reader unfamiliar with the domain can describe the project in their own words after reading it
- The problem statement rings true to someone who has felt that pain
- The "What Makes It Different" section acknowledges real alternatives
- No undefined jargon appears in the body text
- A diagram or visual is present and renders correctly in both light and dark mode

## Related Standards

| Standard | File | Relevance |
|----------|------|-----------|
| README | `docs/standards/README-standard.md` | README structure, overview placement |
| Badge | `docs/standards/badge-standard.md` | Badge placement relative to overview content |
| SVG Screenshots | `docs/standards/svg-screenshots-standard.md` | Diagram and screenshot format |
| Repo Structure | `docs/standards/repo-structure-standard.md` | `docs/` directory layout |
| Naming Conventions | `docs/standards/naming-conventions-standard.md` | File naming for overview docs |
