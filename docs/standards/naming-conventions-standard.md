# Naming Conventions Standard

## Domains

universal


## Repositories

- kebab-case: `agentic-workflows`, `ithmb-codec`, `bus-hop`, `cs-notes`
- No underscores. No uppercase. No spaces.
- Short but meaningful — avoid abbreviations unless well-known (CS, UI, API)
- **Validated:** 76% of the top 100 most-starred GitHub repos use kebab-case. snake_case is completely absent (0%).

## Top-Level Directories

All repos use kebab-case: `docs/`, `scripts/`, `config/`, `assets/`, `tests/`

Exception: language-mandated directories keep their convention:
- `src/` — lowercase, no separator (convention in C#, Rust, Java)
- `app/` — lowercase (Android/Gradle convention)
- `content/` — lowercase (Hugo convention)

## Subdirectory Names

kebab-case everywhere: `docs/badges/`, `docs/screenshots/`, `docs/diagrams/`, `scripts/tools/`, `scripts/hooks/`

## Source Files

Follow language-native convention:

| Language | Convention | Examples |
|----------|-----------|----------|
| Python | snake_case | `bus_repository.py`, `route_fetcher.py` |
| C# | PascalCase | `BusRouteService.cs`, `IthmbDecoder.cs` |
| Kotlin | PascalCase | `MainViewModel.kt`, `BusStopRepository.kt` |
| Go | snake_case | `bus_route.go`, `arrival_time.go` |
| Java | PascalCase | `BusRouteService.java`, `MainActivity.java` |
| Rust | snake_case | `bus_route.rs`, `arrival_time.rs` |
| TypeScript/JS | kebab-case | `bus-route-service.ts`, `route-fetcher.js` |
| Shell | kebab-case | `generate-badge.sh`, `setup-environment.sh` |

## Scripts

kebab-case with extension:

| Type | Extension | Example |
|------|-----------|---------|
| Shell scripts | `.sh` | `generate-badge.sh`, `deploy-site.sh` |
| Python scripts | `.py` | `convert-vault.py` |
| Node scripts | `.js` / `.mjs` | `build-site.mjs` |

## Configuration Files

Config files use their standard names:

| File | Convention |
|------|-----------|
| `.editorconfig` | Dotfile, lowercase |
| `.gitignore` | Dotfile, lowercase |
| `.commitlintrc.json` | Dotfile, kebab-case + json extension |
| `.pre-commit-config.yaml` | Dotfile, kebab-case |
| `.semgrep.yml` | Dotfile, lowercase |
| `.lycheeignore` | Dotfile, lowercase |
| `pyproject.toml` | Language standard name |
| `build.gradle.kts` | Language standard name |
| `*.csproj` | PascalCase, project name matches directory name |

## Workflow Files (`.github/workflows/`)

kebab-case: `test.yml`, `codeql.yml`, `secrets.yml`, `semgrep.yml`, `commits.yml`, `links.yml`, `release.yml`

Name by purpose, not tool — `secrets.yml` (not `gitleaks.yml`), `commits.yml` (not `commitlint.yml`).

## Badge & Diagram Files

kebab-case: `deepseek.svg`, `kotlin.svg`, `architecture.svg`, `pipeline.svg`

## Image / Asset Files

kebab-case: `screenshot-main.png`, `app-icon.svg`, `banner.webp`

## Abbreviations

- Keep common abbreviations: `API`, `UI`, `CLI`, `JSON`, `YAML`, `CSV`, `HTML`, `CSS`
- Write out domain-specific abbreviations on first use in docs
- No mixed case: `UiManager` → `UIManager` or `UiManager` (follow language convention)
