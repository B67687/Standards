# .gitignore Standard — Whitelist ("gitaccept") Approach

## Philosophy

The traditional `.gitignore` uses a **blacklist**: allow everything, ignore specific patterns.
The whitelist approach ("gitaccept") inverts this: **ignore everything, accept specific patterns**.

```gitignore
# Blacklist (traditional):
# Everything tracked by default, ignore specific artifacts
node_modules/
.env
__pycache__/

# Whitelist (gitaccept):
# Nothing tracked by default, accept specific patterns
/*
!/src
!/src/*.py   # (after !/src and /src/*)
```

**Why whitelist?** It prevents accidental commits of secrets, build artifacts, session data, and AI agent output that you'd otherwise need `git filter-repo` (with signing preservation) to remove from history.

## Why Git Uses Blacklist (Historical Context)

Git uses blacklist by design, not oversight. The reason is **performance**:

> _"Git doesn't list excluded directories for performance reasons, so any patterns on contained files have no effect."_ — git-scm.com/docs/gitignore

When a directory like `node_modules/` matches an ignore pattern, git **stops descending** — it never calls `opendir()`, `readdir()`, or `stat()` on anything inside. A typical `node_modules/` contains 50k-200k files. Without this optimization, `git status` on a Node project would take **2-10 seconds** instead of **0.03 seconds** — a ~200x slowdown.

This optimization is more important today than in 2005 because dependency trees have exploded in size (npm, pip, cargo). The blacklist model is a **deliberate tradeoff**: convenience and speed vs absolute safety.

**The `!` negation pattern was added later** as a concession to whitelist-style needs, but within the constraint of not breaking the directory-skip optimization. No git maintainer has ever formally proposed a native whitelist mechanism. The official stance is: "Use `/*` + `!` if you need whitelist."

**What this means for you:** At your current project scale (agent harnesses, config files, documentation — a few thousand files), the performance cost of whitelist patterns is zero. The tradeoff changes at ~50k+ files inside ignored directories (large monorepos, JS megaprojects). Below that threshold, whitelist is strictly safer with no downside.

## When to Use Whitelist vs Blacklist

| Factor              | Whitelist ("gitaccept")                                                 | Blacklist (traditional)                                          |
| ------------------- | ----------------------------------------------------------------------- | ---------------------------------------------------------------- |
| Safety              | ✅ **Best** — new file types silently ignored until explicitly accepted | ❌ Risk — new file types committed unless blacklisted            |
| Friction            | ❌ High — every new extension needs a `.gitignore` edit                 | ✅ Low — just works                                              |
| Performance         | ✅ Same for repos under ~50k files                                      | ✅ Same, scales to millions of files                             |
| Security model      | ✅ Default-deny                                                         | ❌ Default-allow                                                 |
| Repo size threshold | ✅ Good up to ~50k total files                                          | ✅ Good at any scale                                             |
| Best for            | Agentic/harness repos, security-hardened projects, small-team repos     | Open-source with many contributors, monorepos, rapid prototyping |

**Recommendation:** Use whitelist for your harness repos and agent projects. Use blacklist for large open-source projects or polyglot monorepos.

---

## 1. Mechanics

### 1.1 How `*` + `!` Works

From `git-scm.com/docs/gitignore`:

```
# The golden rule:
# It is not possible to re-include a file if a parent directory
# of that file is excluded.
```

This means:

```gitignore
# Phase 1: Ignore everything at root level
/*

# Phase 2: Un-ignore a directory
!/src

# Phase 3: Re-ignore everything inside src
/src/*

# Phase 4: Un-ignore specific file types inside src
!/src/*.py
!/src/*.rs
!/src/*.ts
```

Without Phase 2, git never inspects inside `src/`.

### 1.2 Anchoring

- `/*` matches top-level entries only (one level deep)
- `**/*.py` matches any `.py` file at any depth (but only if parent directory is visible)
- Always use leading `/` at repo root

### 1.3 Evaluation

- Patterns evaluated top-to-bottom, last match wins
- `!` negates the most recent matching ignore pattern

---

## 2. Classification

| Tier   | Classification            | Handling             | Examples                                 |
| ------ | ------------------------- | -------------------- | ---------------------------------------- |
| **T1** | Always tracked            | Whitelisted with `!` | Source code, config, docs                |
| **T3** | Generated / never tracked | Listed in blacklist  | Build output, caches, agent session data |
| **T4** | External / never tracked  | Listed in blacklist  | OS files, editor state                   |

T1 is enforced by the whitelist. T3 and T4 are caught implicitly but also listed explicitly for documentation and edge cases.

---

## 3. Whitelist Template

### Phase 1: Block everything — un-ignore root files by type

```gitignore
# =============================================================================
# .gitignore — Whitelist (gitaccept) Pattern
# =============================================================================

/*

# Root-level files (generic — matches any markdown, text, shell, or config)
!/*.md
!/*.txt
!/*.sh
!/*.bash
!/*.json
!/*.yaml
!/*.yml
!/*.toml
!/*.ini
!/*.cfg
!/*.conf
!.gitignore
!.gitattributes
!.editorconfig
!Dockerfile
!Makefile
!Justfile
```

### Phase 2: Source code directories — whitelist by extension

```gitignore
!/src
/src/*
!/src/**/*.py
!/src/**/*.rs
!/src/**/*.go
!/src/**/*.ts
!/src/**/*.js
!/src/**/*.jsx
!/src/**/*.tsx
!/src/**/*.c
!/src/**/*.h
!/src/**/*.cpp
!/src/**/*.hpp
!/src/**/*.cs
!/src/**/*.fs
!/src/**/*.kt
!/src/**/*.kts
!/src/**/*.java
!/src/**/*.scala
!/src/**/*.clj
!/src/**/*.ex
!/src/**/*.exs
!/src/**/*.rb
!/src/**/*.php
!/src/**/*.swift
!/src/**/*.sh
!/src/**/*.bash
!/src/**/*.zsh
!/src/**/*.ps1
!/src/**/*.sql
!/src/**/*.r
!/src/**/*.lua
!/src/**/*.hs
!/src/**/*.zig
!/src/**/*.nim
!/src/**/*.ml
!/src/**/*.elm
!/src/**/*.json
!/src/**/*.yaml
!/src/**/*.yml
!/src/**/*.toml
!/src/**/*.xml
!/src/**/*.proto
!/src/**/*.gradle
!/src/**/*.gradle.kts
!/src/**/*.csproj
!/src/**/*.sln
!/src/**/*.fsx
!/src/**/*.pyx
!/src/**/*.pxd
```

### Phase 3: Docs

```gitignore
!/docs
!/docs
/docs/*
!/docs/**/*.md
!/docs/**/*.adoc
!/docs/**/*.rst
!/docs/**/*.svg
!/docs/**/*.png
!/docs/**/*.jpg
!/docs/**/*.webp
!/docs/**/*.gif
!/docs/**/*.ico
!/docs/**/*.drawio
!/docs/**/*.puml
!/docs/**/*.mmd
!/docs/**/*.d2
!/docs/**/*.yaml
!/docs/**/*.yml
!/docs/**/*.json
!/docs/**/*.html
!/docs/**/*.css
!/docs/**/*.js
!/docs/**/*.pdf

# Doc subdirectories with special content
!/docs/adr
!/docs/adr/*
!/docs/adr/**/*.md
!/docs/solutions
!/docs/solutions/*
!/docs/solutions/**/*.md
!/docs/diagrams
!/docs/diagrams/*
!/docs/diagrams/**/*
!/docs/badges
!/docs/badges/*
!/docs/badges/**/*.svg
```

### Phase 4: Scripts

```gitignore
!/scripts
!/scripts
/scripts/*
!/scripts/**/*.sh
!/scripts/**/*.bash
!/scripts/**/*.py
!/scripts/**/*.js
!/scripts/**/*.ts
!/scripts/**/*.json
!/scripts/**/*.yaml
!/scripts/**/*.yml
!/scripts/**/*.rb
!/scripts/**/*.rb
!/scripts/**/*.ps1
```

### Phase 5: Tests

```gitignore
!/tests
!/tests
/tests/*
!/tests/**/*.py
!/tests/**/*.rs
!/tests/**/*.go
!/tests/**/*.ts
!/tests/**/*.tsx
!/tests/**/*.js
!/tests/**/*.jsx
!/tests/**/*.kt
!/tests/**/*.kts
!/tests/**/*.java
!/tests/**/*.sh
!/tests/**/*.bash
!/tests/**/*.json
!/tests/**/*.yaml
!/tests/**/*.yml
!/tests/**/*.xml
!/tests/**/*.toml
!/tests/**/*.sql
```

### Phase 6: CI/CD

```gitignore
!/.github
!/.github
/.github/*
!/.github/workflows
!/.github/workflows/*
!/.github/ISSUE_TEMPLATE
!/.github/ISSUE_TEMPLATE/*
!/.github/PULL_REQUEST_TEMPLATE
!/.github/PULL_REQUEST_TEMPLATE/*
!/.github/CODEOWNERS
!/.github/dependabot.yml
!/.github/release.yml
```

### Phase 7: Config

```gitignore
!/config
!/config
/config/*
!/config/**/*
```

### Phase 8: Assets

```gitignore
!/assets
!/assets
/assets/*
!/assets/**/*.svg
!/assets/**/*.png
!/assets/**/*.jpg
!/assets/**/*.ico
!/assets/**/*.css
!/assets/**/*.html
!/assets/**/*.woff
!/assets/**/*.woff2
!/assets/**/*.ttf
!/assets/**/*.eot
```

---

## 4. Blacklist Supplement (Belts + Suspenders)

These are redundant with the whitelist but serve as documentation and catch edge cases.

### 4.1 Secrets & Credentials

> **Exception:** Encrypted secret files (e.g. `.env.enc`, `.env.production.enc` via sops/age) are deliberately NOT ignored — they are the encrypted, commit-safe form. Track them so collaborators can decrypt with the right key. See [secrets-management-standard.md](./secrets-management-standard.md).

```gitignore
# Secrets (never tracked — ever)
.env
.env.*
*.pem
*.key
*.cert
*.p12
*.pfx
*.keystore
**/secrets*/
**/credentials*
**/tokens*
*.secret
**/*.secret.*
**/service-account*
```

### 4.2 Build Artifacts

```gitignore
# Build / compiled output
node_modules/
__pycache__/
*.pyc
*.pyo
.pytest_cache/
.ruff_cache/
.mypy_cache/
target/
build/
dist/
bin/
obj/
*.egg-info/
.cache/
.vendor/
.bundle/
.gradle/
.idea/
*.iml
.venv/
.venv*/
```

### 4.3 AI Agent & Tool Artifacts

```gitignore
# AI agent traces (conversation logs, tool outputs, sessions)
# OpenCode (current primary tool)
.opencode/
.opencode/node_modules/

# Future / alternative tools — uncomment as needed
# .zcode/
# .zentry/
# .codex/

# Generic agent artifacts that appear across tools
*.mcp.json
.*-mcp
.runtime/
**/sessions/
*.session
workflow-state.json.bak

# Agent config files — tracked only in repos explicitly created to share config
AGENTS.md
CLAUDE.md
STRATEGY.md
constitution.md
prd.json
```

### 4.4 Editor & IDE

```gitignore
# IDE
.vscode/
*.swp
*.swo
*~
*.stackdump
```

### 4.5 OS Files

```gitignore
# OS
.DS_Store
Thumbs.db
Desktop.ini
*.log
```

### 4.6 Generated Indexes & Caches

```gitignore
# Generated search / index files
.repo-map.cache/
skills/.skill-index.json
*.index
*.idx
```

---

## 5. Repo-Specific Customization

Every repo needs repo-specific additions. After copying the template:

```gitignore
# --- Repo-specific entries ---
# Add repo-specific whitelist overrides here:
# !/src/**/*.special_ext

# Add repo-specific blacklist entries here:
# special-tool-output/
# generated-report/
```

---

## 6. Hygiene Rules

### 6.1 Commit `.gitignore` First

```bash
git init
# COPY .gitignore into the repo
git add .gitignore
git commit -m "chore: add whitelist .gitignore"
```

### 6.2 Forcing New File Types

```bash
git add -f new-type/file.ext    # force-add
```

Then add the pattern to the appropriate whitelist phase.

### 6.3 Debugging

```bash
git check-ignore -v path/to/file    # what pattern is ignoring this?
git status --ignored                 # list all ignored files
git ls-files --cached                # show tracked files
```

---

## 7. Common Pitfalls

| Mistake                           | Why It Fails                                 | Fix                              |
| --------------------------------- | -------------------------------------------- | -------------------------------- |
| `!src/*.py` without `!/src`       | Parent dir excluded → git never looks inside | Add `!/src` then `/src/*` first  |
| `*` without leading `/`           | Matches anywhere in tree                     | Use `/*`                         |
| `!` before the pattern it negates | Last match wins                              | Put `!` AFTER the pattern        |
| Missing `/` on directories        | Pattern matches both files and dirs          | Use `/src/` for dirs             |
| Forgetting `**/` for nested paths | Only matches one level                       | Use `!/src/**/*.py`              |
| Not committing `.gitignore` first | First `git add` sweeps up everything         | Commit `.gitignore` before files |

---

## 8. Defense-in-Depth: Beyond .gitignore

A whitelist `.gitignore` is the first layer. For real security, layer multiple defenses:

| Layer | Tool                                                       | Stage                 | Bypassable?               |
| ----- | ---------------------------------------------------------- | --------------------- | ------------------------- |
| 1     | **Whitelist .gitignore**                                   | At `git add`          | Edit .gitignore           |
| 2     | **Pre-commit secret scanning** (Gitleaks / detect-secrets) | Before commit         | `--no-verify`             |
| 3     | **Pre-push hooks** (Talisman)                              | Before push           | `--no-verify`             |
| 4     | **CI scanning** (Gitleaks action)                          | On push               | ❌ Cannot bypass          |
| 5     | **GitHub secret scanning**                                 | Post-push server-side | ❌ Automatic              |
| 6     | **Periodic history audits** (quarterly)                    | Scheduled             | Manual                    |
| 7     | **git filter-repo** (incident response)                    | Reactive              | N/A — for history cleanup |

**The real enforcement point is Layer 4 (CI).** Pre-commit hooks can be skipped with `--no-verify`, but CI scanning catches everything. Combined with branch protection (signed commits, required reviews), this creates a defense-in-depth safety net around the whitelist.

## 9. References

- [git-scm.com/docs/gitignore](https://git-scm.com/docs/gitignore) — official docs
- [github/gitignore](https://github.com/github/gitignore) — official templates
- [git filter-repo](https://github.com/newren/git-filter-repo) — history cleanup
