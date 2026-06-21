# AI Attribution Pattern

A lightweight convention for crediting AI model + tool contributions in GitHub repos.
Discoverable but not intrusive — honest about the human/AI dynamic.

## Convention

**Badge = identity** — model name + reasoning level where applicable.
**CREDITS.md = detail** — phase · model · harness · role.

Badges are static SVGs committed to the repo. No external badge service dependency.

---

## Badges (README)

Centred row of linked badges, placed near the project header.

```markdown
<p align="center">
  <sub>Built with AI assistance — see <a href="./CREDITS.md">CREDITS.md</a></sub>
  <br>
  <a href="./CREDITS.md"><img src="docs/badges/gpt5.4.svg" alt="GPT 5.4"></a>
  <a href="./CREDITS.md"><img src="docs/badges/deepseek.svg" alt="DeepSeek V4 Flash"></a>
</p>
```

**Badge naming rules:**

- Reasoning level on right side (coloured) if the model has a configurable reasoning effort
- No reasoning level if the model doesn't expose one (single-field badge)
- Neutral `base` label for models without a reasoning knob, for visual consistency
- Colour palette: each model gets a distinct colour (brand association or neutral)

---

## CREDITS.md

### Boilerplate

```markdown
# Credits

This project was built collaboratively. I defined the vision, architecture, and
strategic direction; AI systems contributed to implementation, research, and
design discussions, with continuous back-and-forth that often shaped the final
outcome in ways neither of us predicted alone.

## AI Contributions

| Phase               | Model                    | Harness       | Role                                                                                                |
| ------------------- | ------------------------ | ------------- | --------------------------------------------------------------------------------------------------- |
| Early prototyping   | GPT 5.4 (high reasoning) | Codex Desktop | AI: implementation, research, & discussion · Human: direction, architecture, oversight, & meta-work |
| Middle exploration  | MiniMax M2.5 (base)      | OpenCode TUI  | AI: implementation, research, & discussion · Human: direction, refinement                           |
| Primary development | DeepSeek V4 Flash (max)  | OpenCode TUI  | AI: implementation, research, & discussion · Human: oversight & goals                               |
```

**Phase** indicates the project stage where a model was active.
Use `Full development` for single-model repos that never switched.

**Model** includes the reasoning effort level in parentheses, where applicable.
Valid values: `max`, `high`, `medium`, `low` (configurable); `base` (no knob, built-in default).

**Harness** is the tool/platform used to interact with the model.
Examples: `OpenCode TUI`, `Codex Desktop`, `Claude Code`, `OpenAI Playground`.

**Role** describes the division of labour. The human always covers direction, architecture, oversight, and meta-work (hardening, workflows, retroactive fixes, git filter-repo, etc.). AI covers raw implementation, research, and participative discussion that shapes strategy.

### Single-model table example

For a repo that used one model throughout, the table has a single row:

```markdown
| Phase            | Model                   | Harness      | Role                                                                  |
| ---------------- | ----------------------- | ------------ | --------------------------------------------------------------------- |
| Full development | DeepSeek V4 Flash (max) | OpenCode TUI | AI: implementation, research, & discussion · Human: oversight & goals |
```

### Multi-model table example

For repos with chronological model changes, each phase gets its own row
to show which model was active when:

```markdown
| Phase               | Model                    | Harness       | Role                                                                        |
| ------------------- | ------------------------ | ------------- | --------------------------------------------------------------------------- |
| Early prototyping   | GPT 5.4 (high reasoning) | Codex Desktop | AI: implementation, research, & discussion · Human: architecture & steering |
| Primary development | DeepSeek V4 Flash (max)  | OpenCode TUI  | AI: implementation, research, & discussion · Human: oversight & goals       |
```

### When to use which

- **Single-model:** one row, `Phase` = `Full development`.
  Used when every phase of the project used the same model.
- **Multi-model:** one row per distinct model period.
  Used when the model changed materially (e.g. upgraded from GPT 5.4 to DeepSeek V4 Flash).

---

## Static SVGs (docs/badges/)

All badges are fetched once from shields.io and committed as static SVGs to `docs/badges/`.
This avoids GitHub camo proxy timeouts and external dependency at render time.

### Gradle task (for Android/Kotlin projects)

Add to root `build.gradle.kts`:

```kotlin
tasks.register("updateBadges") {
    notCompatibleWithConfigurationCache("fetches external SVGs from shields.io")
    description = "Refresh static badge SVGs from shields.io into docs/badges/"
    group = "Development"

    val badges = listOf(
        "Kotlin-2.4-7F52FF?logo=kotlin&logoColor=white"       to "kotlin",
        "DeepSeek_V4_Flash-max-4F46E5" to "deepseek",
        "GPT_5.4-high-10a37f"          to "gpt5.4",
    )

    doLast {
        val t = providers.gradleProperty("testCount")
            .orElse(/* auto-detect or fallback logic */).get()
        // ... fetch logic
    }
}
```

Usage:

```
./gradlew updateBadges -PtestCount=NNN
```

### Shell script (for non-Gradle projects)

See `scripts/update-badges.sh` in the bus-hop repo for a bash equivalent.

---

## Pipeline wording

One-liner in the README pipeline section:

> **Development** — AI-driven implementation steered by human architectural direction.

This captures the dynamic without overselling or underselling either side.

---

## Rationale

| Decision                                        | Why                                                                                 |
| ----------------------------------------------- | ----------------------------------------------------------------------------------- |
| Static SVGs over shields.io URLs                | GitHub camo proxy times out on external fetches. SVGs render instantly.             |
| Badge = identity, CREDITS = detail              | Badges are for recognition; tables are for context. Separation of concerns.         |
| Reasoning level tucked into model name          | Preserves the info without wasting a column. Succinct.                              |
| Harness instead of "Interface"                  | Communicates the tool/platform, not the UI surface. More accurate semantic.         |
| Plan column removed                             | Billing info adds no attribution value and risks privacy leakage.                   |
| Role broadened to include research & discussion | AI influences strategy through collaborative discussion, not just raw coding.       |
| Phase column kept                               | Honest chronology — different models may dominate different stages.                 |
| Human role includes meta-work                   | Hardening, workflows, retroactive fixes, git filter-repo — all still human-managed. |
| Table format for all repos (single + multi)     | Consistent structure regardless of row count. Cleaner than mixing prose + tables.   |
