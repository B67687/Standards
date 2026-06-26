# Repository Structure Standard

## Domains

universal


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
  badges/       # SVG badge images
  screenshots/  # App/CLI screenshots
  diagrams/     # SVG architecture/pipeline diagrams
  adr/          # Architecture Decision Records
  solutions/    # Structured solution capture docs
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

**Key structural rules:**
- Primary content: shell scripts, YAML/JSON config files, markdown docs
- Source lives at root level (no `src/` directory)
- No build step — scripts are run directly; tests are shell-based or absent
- `.github/workflows/` for CI, `propagation/` for template files, `scripts/hooks/` for git hooks

### Type B: Library (C#, Kotlin, Go, etc.)
For repos like ithmb-codec, bus-hop (library portion).

**Key structural rules:**
- Source code in `src/`, tests in `tests/` (one directory per project/module)
- Each module/project has its own directory; build output (bin/, obj/) in .gitignore
- README focuses on API, installation, build from source

**Go-specific layout** (Go conventions differ from C#/Kotlin):
- `cmd/appname/main.go` for entry points, `pkg/` for public library code, `internal/` for private code
- `go.mod` (module definition) and `go.sum` (committed checksums) at root

### Type C: Application (Android)
For repos like bus-hop.

**Key structural rules:**
- Gradle-based, module-per-layer; `app/` for main application, `library/` for library modules
- Screenshots in `docs/screenshots/`; README focuses on download, features, screenshots

### Type D: Documentation (Hugo/Hextra)
For repos like CS-Notes.

**Key structural rules:**
- Hugo Hextra structure: `content/` for markdown, `assets/` for images/CSS/JS
- `data/` for structured data, `layouts/` for custom templates, `static/` for favicon
- `themes/` as submodule or vendored; `config/` or `hugo.toml` at root
- Build output (`public/`, `resources/`) in .gitignore

### Type E: Learning Notes (Jupyter/Markdown)
For repos like math-learning-notes, python-learning-notes.

**Key structural rules:**
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

File extensions follow language conventions: `.md` (never `.markdown`), `.yaml`/`.yml` (`.yml` for GitHub Actions), `.sh` (`.bash` only if Bash-specific features needed), `.py`, `.cs`. Config files use standard names (`Dockerfile` capital D, `Makefile` capital M, `.editorconfig` dotfile).

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

**Key structural rules:**
- `apps/` for deployable applications, `packages/` for shared libraries
- Root workspace config: `package.json`, `pnpm-workspace.yaml` (or `lerna.json`, `nx.json`)
- Shared config at root: `tsconfig.base.json`, `.eslintrc.js`, `jest.config.js` — each package overrides via extension
- CI scoped to affected packages only (Turborepo `--filter`, Nx affected graph)
- Each package follows Type B (Library) or Type C (App) conventions internally

### Type G: Polyglot (Multiple Languages)
For repos with backend + frontend or multiple runtimes.

**Key structural rules:**
- Segregated by language: `backend/` (e.g. Python), `frontend/` (e.g. TypeScript)
- Each segment has its own build system and dependencies
- Root `scripts/` handles orchestration (`build-all.sh`, `lint-all.sh`)
- Multiple CI matrices per language

### Type H: Fork
For repos that are forks of upstream projects (e.g. Scoop).

**Key structural rules:**
- Do NOT restructure a fork's directory layout — makes `git merge upstream` impossible
- Only add top-level additive directories: `FORK.md`, `patches/`, `docs/fork/`
- Document divergence in `FORK.md` (upstream URL, branch strategy, divergence notes)

### Generated Code
Generated code falls into two categories:
- **Build artifacts** (`out/`, `dist/`, `build/`): never committed, always in `.gitignore`
- **Downstream codegen** (`gen/` at consumption level): sometimes committed if needed

If generated code is checked in, use `gen/` at the level where it's consumed. Always add a `@generated` header. Use `scripts/regenerate.sh` to document the exact invocation.

---

## What Goes in .gitignore

See `docs/standards/gitignore-standard.md` for the full whitelist pattern. At minimum:

```
bin/  obj/  build/  dist/  node_modules/  __pycache__/  .env  *.log  .DS_Store
```

Per-type additions:
- **Harness:** `.runtime/`, session files, agent state
- **Library:** `bin/`, `obj/`, build artifacts per language
- **Hugo:** `public/`, `resources/`
- **Docusaurus:** `build/`
- **Jupyter:** `.ipynb_checkpoints/`
