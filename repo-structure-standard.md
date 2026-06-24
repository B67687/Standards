# Repository Structure Standard

## Common Conventions (All Repos)

All repos SHOULD have these directories at the top level:

| Directory | Purpose | Always? |
|-----------|---------|---------|
| `docs/` | Documentation, diagrams, screenshots, badges | ✅ Yes |
| `scripts/` | Build, test, utility scripts | ✅ Yes |
| `.github/` | GitHub Actions workflows, issue/PR templates | 🟡 Only if using GitHub |

### `docs/` Subdirectory Convention

```
docs/
  badges/         # SVG badge images (shields.io format)
  screenshots/    # App/CLI screenshots
  diagrams/       # SVG architecture and pipeline diagrams
  adr/            # Architecture Decision Records
  solutions/      # Structured solution capture docs
```

### Other Common Root Files

```
README.md         # Project description, badges, quick start
CHANGELOG.md      # Keep a Changelog format
CREDITS.md        # AI attribution
LICENSE           # MIT for public repos
.editorconfig     # Editor settings (indent, charset, line endings)
.gitignore        # Whitelist (gitaccept) pattern
mise.toml         # Tool version management (mise)
Taskfile.yml      # Task runner (go-task) — alternative to Makefile
```

---

## Per-Type Layouts

### Type A: Agent Harness (Shell/Config)

For repos like agentic-workflows, agent-harness, agent-seed, agent-concourse, etc.

```
repo/
  .github/workflows/    # GitHub Actions CI
  docs/
    badges/
    diagrams/
    adr/
    solutions/
  propagation/          # Template files distributed to other repos
  scripts/
    hooks/              # Git hooks (pre-commit, etc.)
    tools/              # Utility scripts
```

Characteristics:
- Primary content: shell scripts, YAML/JSON config files, markdown docs
- Source lives at root level (no `src/` directory)
- No build step — scripts are run directly
- Tests are shell-based or not present

### Type B: Library (C#, Kotlin, Go, etc.)

For repos like ithmb-codec, bus-hop (the library portion).

```
repo/
  src/                  # Source code
    ProjectName/        # One directory per project/module
  tests/
    ProjectName.Tests/  # Test project mirroring src structure
  docs/
    badges/
    diagrams/
  scripts/
```

Characteristics:
- Source code in `src/`, tests in `tests/`
- Each module/project has its own directory
- Build output (bin/, obj/) in .gitignore
- README focuses on API, installation, build from source

### Type C: Application (Android)

For repos like bus-hop.

```
repo/
  app/                  # Application module
  library/              # Library modules (if any)
  gradle/               # Gradle wrapper
  src/                   # (optional additional source)
  docs/
    badges/
    screenshots/
    diagrams/
  scripts/
```

Characteristics:
- Gradle-based, module-per-layer
- `app/` for the main application
- Screenshots in `docs/screenshots/`
- README focuses on download, features, screenshots

### Type D: Documentation (Hugo/Hextra)

For repos like CS-Notes.

```
repo/
  content/              # Markdown content pages
  assets/               # Images, CSS, JS
  data/                 # Structured data files
  layouts/              # Custom Hugo templates
  static/               # Static files (favicon, etc.)
  themes/               # Hugo theme (submodule or vendored)
  config/               # Hugo config (or hugo.toml at root)
  scripts/              # Build/deployment scripts
```

Characteristics:
- Hugo Hextra structure for most docs repos
- Content in `content/`, not at root
- Build output (public/, resources/) in .gitignore

### Type E: Learning Notes (Jupyter/Markdown)

For repos like math-learning-notes, python-learning-notes.

```
repo/
  notebooks/            # Jupyter notebooks
  notes/                # Raw markdown notes
  scripts/              # Any helper scripts
```

Characteristics:
- Notebooks in `notebooks/`, markdown in `notes/`
- Minimal structure — content is the primary artifact
- No CI pipeline needed (but link checking is useful)

---

## Naming Conventions

| Element | Convention | Example | Validated? |
|---------|-----------|---------|-----------|
| Repositories | kebab-case | `agentic-workflows`, `ithmb-codec` | ✅ 76% of GitHub top 100 |
| Directories | kebab-case | `docs/badges/`, `scripts/tools/` | ✅ Industry standard |
| Source files | Language-native | `snake_case.py`, `PascalCase.cs`, `kebab-case.rs` | ✅ Per ecosystem |
| Scripts | kebab-case | `generate-badge.sh`, `setup.sh` | ✅ Industry standard |
| Workflow files | kebab-case | `test.yml`, `secrets.yml` | ✅ GitHub convention |
| Badge files | kebab-case | `deepseek.svg`, `kotlin.svg` | ✅ Consistent |
| Diagram files | kebab-case | `architecture.svg`, `pipeline.svg` | ✅ Consistent |

### File Extensions

| Type | Standard | Notes |
|------|----------|-------|
| Markdown | `.md` | Never `.markdown` — GitHub doesn't render it |
| YAML | `.yaml` or `.yml` | Either is acceptable; `.yml` is GitHub Actions convention |
| Shell scripts | `.sh` | `.bash` only if script requires Bash-specific features |
| Python | `.py` | Standard |
| C# | `.cs` | Standard |
| Config files | Standard name | `Dockerfile` (capital D), `Makefile` (capital M), `.editorconfig` (dotfile) |

### Special Files

| File | Convention | Notes |
|------|-----------|-------|
| `Dockerfile` | Capital D, at root | Docker's build system looks for capital D by default |
| `Makefile` | Capital M, at root | `make` looks for `Makefile` before `makefile` |
| `Taskfile.yml` | Capital T, at root | go-task runner — alternative to Makefile; supports `task --json` |
| `mise.toml` | Lowercase, at root | Tool version management via mise (polyglot version manager) |
| `.editorconfig` | Dotfile, at root | Required by EditorConfig spec |
| `global.json` | At root (C#/.NET) | Pins SDK version for .NET projects |

---

## Edge Cases

### Type F: Monorepo (Node.js/TypeScript)

For repos with multiple packages or apps.

```
repo/
  apps/                 # Deployable applications
    app1/
    app2/
  packages/             # Shared libraries
    lib1/
    lib2/
  docs/
    badges/
    diagrams/
    adr/
  scripts/
  package.json          # Root workspace config
  pnpm-workspace.yaml   # or lerna.json or nx.json
```

**Shared config at root:** `tsconfig.base.json`, `.eslintrc.js`, `jest.config.js` — each package overrides via extension.
**CI must be scoped:** Build/test only packages affected by a change (Turborepo `--filter`, Nx affected graph).
**Per-package structure:** Each package follows Type B (Library) or Type C (App) conventions internally.

### Type G: Polyglot (Multiple Languages)

For repos with backend + frontend or multiple runtimes.

```
repo/
  backend/              # Language A (e.g. Python)
    src/
    tests/
  frontend/             # Language B (e.g. TypeScript)
    src/
    public/
  scripts/
  docs/
```

**Segregated by language.** Each segment has its own build system and dependencies. Root `scripts/` handles orchestration (`build-all.sh`, `lint-all.sh`). Multiple CI matrices per language.

### Type H: Fork

For repos that are forks of upstream projects (e.g. Scoop).

```
repo/
  FORK.md               # Fork metadata: upstream URL, branch strategy, divergence notes
  patches/              # Local patches on top of upstream
  docs/fork/            # Fork-specific documentation
  # Upstream structure — DO NOT MODIFY
```

**Golden rule:** Do NOT restructure a fork's directory layout. Restructuring makes `git merge upstream` impossible. Only add top-level additive directories. Document divergence in `FORK.md`.

### Generated Code

Generated code falls into two categories:

| Category | Committed? | Directory | .gitignore |
|----------|-----------|-----------|------------|
| Build artifacts | Never | `out/`, `dist/`, `build/` | ✅ Ignored |
| Downstream codegen | Sometimes | `gen/` (at consumption level) | ❌ Tracked if needed |

If generated code is checked in, use `gen/` at the level where it's consumed. Always add a `@generated` header. Use `scripts/regenerate.sh` to document the exact invocation.

---

## What Goes in .gitignore

See `docs/gitignore-standard.md` for the full whitelist pattern. At minimum:

```
bin/
obj/
build/
dist/
node_modules/
__pycache__/
.env
*.log
.DS_Store
```

For each type:
- **Harness:** `.runtime/`, session files, agent state
- **Library:** `bin/`, `obj/`, build artifacts per language
- **Hugo:** `public/`, `resources/`
- **Docusaurus:** `build/`
- **Jupyter:** checkpoint files (`.ipynb_checkpoints/`)
