# Dev Workflow Standards — External Research Report

> **Date**: 2026-06-25  
> **Scope**: 5 dev workflow standards researched against authoritative external projects  
> **Constraint**: No search of B67687/* repos or local files  

---

## Table of Contents

1. [Commit Conventions](#1-commit-conventions)
2. [Changelog Standards](#2-changelog-standards)
3. [ADR (Architecture Decision Record)](#3-adr-architecture-decision-record)
4. [Naming Conventions](#4-naming-conventions)
5. [Repository Structure](#5-repository-structure)

---

## 1. Commit Conventions

### Authoritative Source

| Source | URL | Authority |
|--------|-----|-----------|
| **Conventional Commits v1.0.0** | https://www.conventionalcommits.org/en/v1.0.0/ | **The specification** — de facto industry standard |
| **Angular Commit Convention** | https://github.com/angular/angular/blob/main/contributing-docs/commit-message-guidelines.md | **Original inspiration** for Conventional Commits |
| **SemVer** | https://semver.org/ | Underlying versioning contract |

### Core Specification

The Conventional Commits specification defines a lightweight structure:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Required types**: `feat` (minor), `fix` (patch)  
**BREAKING CHANGE**: triggers major version bump (via `!` or footer text)  
**Optional types** (from Angular/community convention): `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`

**Angular divergences from Conventional Commits**:
- Scope is **required** (not optional)
- Breaking changes use footer-only format in strict mode
- Added `build` and `ci` as explicit types (not in base spec)
- Stricter `revert` format

### Ecosystem Tools

| Tool | Role | URL | Stars |
|------|------|-----|-------|
| **semantic-release** | Automated versioning + publishing | https://github.com/semantic-release/semantic-release | ~21k |
| **commitlint** | Lint commit messages | https://github.com/conventional-changelog/commitlint | ~17k |
| **commitizen** | Interactive commit prompts | https://github.com/commitizen/cz-cli | ~17k |
| **standard-version** | Version + changelog from commits | https://github.com/conventional-changelog/standard-version | ~7.5k |
| **Release Please** (Google) | Release PR-based automation | https://github.com/googleapis/release-please | ~7k |
| **python-semantic-release** | Python implementation | https://github.com/relekang/python-semantic-release | ~2k |

### Real-World OSS Usage

| Repo | Convention Used | Confirmation |
|------|----------------|--------------|
| **Angular** (angular/angular) | Angular-specific CC | Source: https://github.com/angular/angular/blob/main/CONTRIBUTING.md |
| **Electron** (electron/electron) | Conventional Commits | Observed via commit history analysis (histogram on conventionalcommits.org/about) |
| **Yargs** (yargs/yargs) | Conventional Commits | Observed via commit history analysis |
| **Jenkins X** (jenkins-x/jx) | Conventional Commits | Observed via commit history analysis |
| **semantic-release** (semantic-release/semantic-release) | Conventional Commits (dogfooding) | Source: https://github.com/semantic-release/semantic-release |

### Common Pitfalls

1. **Squash merge defeats granular commits** — Only the squash commit message matters; enforce CC on PR titles instead
2. **`chore` as a catch-all** — Loses semantic meaning; prefer specific types
3. **Incorrect type scoping** — Using `feat` for internal refactors triggers unwanted minor version bumps in automated tools
4. **Missing `!` or `BREAKING CHANGE` footer** — Breaking changes without annotation bypass major version bumps
5. **Scope overload** — Using overly granular scopes that are inconsistently applied

### Alternatives

- **Conventional Commits + semantic-release** — Full automation, industry default
- **Release Please (Google)** — Release PR model (not push-based); better for controlled releases
- **Angular strict mode** — For large monorepos needing mandatory scope
- **No convention** — Manual versioning; viable only for small/solo projects
- **Emoji-based commits** (gitmoji) — Not machine-parseable, no automated tooling

### Recommendation

> **ADOPT** — Conventional Commits v1.0.0 is the de facto industry standard. Enforce with commitlint + husky + semantic-release or Release Please.

---

## 2. Changelog Standards

### Authoritative Source

| Source | URL | Authority |
|--------|-----|-----------|
| **Keep a Changelog v1.1.0** | https://keepachangelog.com/en/1.1.0/ | **The specification** — de facto standard |
| **GNU Changelog Style** | https://www.gnu.org/prep/standards/html_node/Style-of-Change-Logs.html | Historical reference, less used |
| **GitHub Releases** | https://docs.github.com/en/repositories/releasing-projects-on-github | Platform-specific feature |

### Core Specification (Keep a Changelog)

```
# Changelog
All notable changes to this project will be documented in this file.

## [1.0.0] - 2026-01-01

### Added
- New feature A
### Changed
- Existing behavior B
### Deprecated
- Feature C (will be removed)
### Removed
- Feature D (already removed)
### Fixed
- Bug E
### Security
- Vulnerability F
```

**Key rules**:
- File must be named `CHANGELOG.md` in repository root
- Date format: ISO 8601 (`YYYY-MM-DD`)
- Version linked to diff: `[1.0.0]: https://github.com/owner/repo/compare/v1.0.0...v1.1.0`
- `[YANKED]` tag for pulled releases
- Human-readable, not a git log dump

### Keep a Changelog vs GitHub Releases

| Aspect | Keep a Changelog (`CHANGELOG.md`) | GitHub Releases |
|--------|------------------------------------|-----------------|
| **Discoverability** | High (uppercase files in root) | Lower (hidden in sidebar) |
| **Portability** | Portable (plain text, any host) | Non-portable (GitHub-specific) |
| **Search/Filter** | Full text search | Limited (tag-only search) |
| **Diff between versions** | Via linked compare URLs | Binary search across pages |
| **Automation** | Auto-generated from CC via tools | Manual or via semantic-release |
| **Audience** | All users | GitHub users |

**Major finding**: GitHub Releases alone are **insufficient** for version comparison UX (requires human binary search between pages). CHANGELOG.md is strictly superior for end users.

### Real-World OSS Usage

| Repo | Practice | Evidence |
|------|----------|----------|
| **Keep a Changelog itself** | CHANGELOG.md in root | https://github.com/olivierlacan/keep-a-changelog/blob/main/CHANGELOG.md |
| **React** (facebook/react) | CHANGELOG.md | Repository root convention |
| **Vue** (vuejs/vue) | CHANGELOG.md | Repository root convention |
| **Next.js** (vercel/next.js) | CHANGELOG.md + GitHub Releases | Both maintained |

### Common Pitfalls

1. **Git log dump instead of curated changelog** — Keep a Changelog's original warning: "Don't let your friends dump git logs into changelogs"
2. **Only using GitHub Releases** — Poor discoverability and diff UX (requires manual page navigation)
3. **Forgetting `[YANKED]`** — Yanked versions should be explicitly marked
4. **No linked diffs** — Without `[v1.0.0]: ...compare/...`, users can't see what changed
5. **Inconsistent date format** — Not using ISO 8601
6. **Breaking changes without migration notes** — Critical for OSS adoption

### Alternatives

- **Keep a Changelog** — De facto standard, recommended
- **GitHub Releases only** — Simpler for maintainers, worse for users
- **Auto-generated from CC commits** (via semantic-release) — Best of both worlds
- **GNU NEWS/HISTORY** — Older, less structured
- **Openchangelog** — Newer format based on Keep a Changelog

### Recommendation

> **ADOPT** — Keep a Changelog v1.1.0 with `CHANGELOG.md` in repository root. Auto-generate from Conventional Commits using semantic-release or Release Please. Keep GitHub Releases in sync but treat CHANGELOG.md as canonical.

---

## 3. ADR (Architecture Decision Record)

### Authoritative Source(s)

| Source | URL | Authority |
|--------|-----|-----------|
| **Michael Nygard blog post (2011)** | https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions | **Original definition** |
| **adr.github.io** | https://adr.github.io/ | **Community hub** (ADR organization) |
| **MADR (Markdown ADR) 4.0.0** | https://adr.github.io/madr/ | **Most evolved template** |
| **AWS Prescriptive Guidance** | https://docs.aws.amazon.com/prescriptive-guidance/latest/architectural-decision-records/welcome.html | Enterprise endorsement |
| **GDS Way (UK Government)** | https://gds-way.digital.cabinet-office.gov.uk/standards/architecture-decisions.html | Government standard |

### Core Templates

**Michael Nygard's original template** (simplest, most popular):

```
# Title

## Status
[Proposed | Accepted | Deprecated | Superseded]

## Context
What is the issue motivating this decision?

## Decision
What is the change we're proposing?

## Consequences
What becomes easier or more difficult?
```

**MADR 4.0.0 template** (more structured, includes tradeoff analysis):

```
# {short title}

## Context and Problem Statement

## Decision Drivers
- {driver 1}
- {driver 2}

## Considered Options
- {option 1}
- {option 2}

## Decision Outcome
Chosen option: "{option 1}", because {justification}.

### Consequences
- Good, because {positive}
- Bad, because {negative}

### Confirmation
How compliance will be verified.

## Pros and Cons of the Options

## More Information
```

**Other templates**:
- **Y-Statement** (Zdun et al.): "In the context of `<use case>`, facing `<concern>`, we decided for `<option>` to achieve `<quality>`, accepting `<downside>`"
- **Business Case ADR**: More MBA-oriented, with costs and SWOT
- **Planguage ADR**: Quality-assurance oriented

### Tools

| Tool | Type | Stars | URL |
|------|------|-------|-----|
| **adr-tools** (npryce) | Bash CLI | ~5.5k | https://github.com/npryce/adr-tools |
| **Log4Brains** (thomvaill) | CLI + static site | ~1.5k | https://github.com/thomvaill/log4brains |
| **adr-manager** | Web UI over GitHub | — | N/A |
| **dotnet-adr** | .NET global tool | — | N/A |
| **Plain Markdown** | Convention only | N/A | `docs/adr/` folder |

### Real-World OSS Usage

| Org/Project | Practice | Evidence |
|-------------|----------|----------|
| **UK Government GDS** (alphagov) | ADRs in `docs/architecture/decisions/` | https://github.com/alphagov/govuk-aws/tree/master/docs/architecture/decisions |
| **Spotify** | Uses ADRs internally | https://engineering.atspotify.com/2020/04/14/when-should-i-write-an-architecture-decision-record/ |
| **arc42** | Recommends Nygard ADRs | https://docs.arc42.org/tips/9-5 |
| **adr-tools** itself | ADRs in `doc/adr/` | https://github.com/npryce/adr-tools/tree/master/doc/adr |
| **MADR** project | ADRs in MADR format | https://adr.github.io/madr/decisions/ |

### Common Pitfalls

1. **Writing ADRs as long essays** — They become unread and unused. Keep to 1-2 pages.
2. **Skipping rejected options** — Future teams won't know what was ruled out or why.
3. **Quietly editing history** — Always supersede; never delete. Immutability preserves context.
4. **ADRs going stale** — Decisions change in Slack/PRs/Jira but never update the ADR.
5. **Not writing ADRs early enough** — Written after implementation, they become pointless ceremony.
6. **Over-classifying decisions** — Not every decision needs an ADR. Reserve for costly-to-reverse or cross-team decisions.

### Alternatives

- **Plain Markdown in `docs/adr/`** — Simple, zero-dependency starting point (recommended default)
- **MADR 4.0.0** — More structured; better for complex tradeoff analysis
- **Y-Statements** — One-liner format; best for small/simple decisions
- **RFCs (Request for Comments)** — Broader scope, more process-heavy
- **Design Docs** — More detailed, less structured than ADRs
- **Confluence/Notion** — Searchable but not version-controlled with code

### Recommendation

> **ADOPT** — Use `docs/adr/` with Michael Nygard's template for simplicity, or MADR 4.0.0 for more structure. Follow the convention: numbered files (`0001-*`), immutable entries, supersede rather than delete. Do NOT let ADRs go stale — make them reviewable in PRs.

---

## 4. Naming Conventions

### Authoritative Sources

**Git Branch Naming**: No single authoritative specification exists. The industry follows conventions codified by Git workflows:

| Source | URL | Authority |
|--------|-----|-----------|
| **Git Flow** (nvie) | https://nvie.com/posts/a-successful-git-branching-model/ | Original branch model (2010) |
| **GitHub Flow** | https://docs.github.com/en/get-started/using-github/github-flow | Simplified model |
| **GitLab Flow** | https://docs.gitlab.com/ee/topics/gitlab_flow.html | Environment-branch model |

**File Naming**: No single authoritative spec. Language ecosystems have implicit conventions:

| Language/Framework | Convention | Source |
|--------------------|------------|--------|
| **JavaScript/TypeScript (React)** | `kebab-case` for files, `PascalCase` for components | Community consensus (Next.js, create-react-app) |
| **Go** | `snake_case` for files | Official Go style https://go.dev/doc/modules/layout |
| **Python** | `snake_case` for files/modules | PEP 8: https://peps.python.org/pep-0008/ |
| **Java** | `PascalCase` for classes, `camelCase` for methods | Java Language Spec + Google Style |
| **Rust** | `snake_case` for files/modules | Rust API Guidelines |
| **Dart** | `snake_case` for files | Effective Dart: https://dart.dev/effective-dart/style |

### Git Branch Naming: Industry Standard Conventions

The de facto standard prefix system (compiled from multiple sources):

| Prefix | Purpose | Example |
|--------|---------|---------|
| `feature/` | New features | `feature/user-auth` |
| `bugfix/` | Non-urgent bug fixes | `bugfix/login-redirect` |
| `hotfix/` | Urgent production fixes | `hotfix/payment-crash` |
| `release/` | Release preparation | `release/v2.1.0` |
| `chore/` | Maintenance tasks | `chore/update-deps` |
| `docs/` | Documentation | `docs/api-reference` |
| `experiment/` | Experimental | `experiment/new-algorithm` |

**Format rules** (widely agreed):
1. **Lowercase** with hyphens — `feature/user-auth` not `Feature/UserAuth`
2. **Ticket numbers** when available — `feature/JIRA-123-user-auth`
3. **No spaces** — Use hyphens for word separation
4. **Short but descriptive** — Not `fix-the-null-pointer-exception-in-user-service`
5. **Forward slash delimiters** for hierarchy

### File Naming: Conventions by Language

**TypeScript/JavaScript ecosystem** (most relevant):
- **Files**: kebab-case — `user-service.ts`, `api-client.ts`
- **Components (React)**: PascalCase files — `UserProfile.tsx`
- **Hooks**: camelCase prefixed with `use` — `useAuth.ts`, `useDebounce.ts`
- **Tests**: Match source file + `.test`/`.spec` — `user-service.test.ts`
- **Constants**: UPPER_SNAKE_CASE — `API_BASE_URL`

**Sources**:
- React naming conventions: https://react.dev/learn — components use PascalCase
- TypeScript style guide (Google): https://google.github.io/styleguide/tsguide.html
- Community convention (kebab-case for files): https://dev.to/adarshasnah/kebab-case-filenames-and-pascalcase-classes-naming-conventions-that-scale-7dp

### Real-World OSS Examples

| Repo | Branch Convention | Evidence |
|------|------------------|----------|
| **Angular** (angular/angular) | `main` + `feature/` branches | CONTRIBUTING.md |
| **Next.js** (vercel/next.js) | `main` + `canary` + PR-based | GitHub flow |
| **React** (facebook/react) | `main` + `pr` prefixed | GitHub flow |
| **GitLab** (gitlabhq/gitlabhq) | `master` + `feature/*` + `fix/*` | Public workflow docs |

| Repo | File Name Convention | Evidence |
|------|---------------------|----------|
| **Next.js** (vercel/next.js) | kebab-case for files | https://github.com/vercel/next.js |
| **NestJS** (nestjs/nest) | kebab-case for files | https://github.com/nestjs/nest |
| **TypeScript** (microsoft/TypeScript) | PascalCase for source files | https://github.com/microsoft/TypeScript |
| **React** (facebook/react) | PascalCase for components, camelCase for utils | https://github.com/facebook/react |

### Common Pitfalls

1. **Case-insensitive file system issues** — `UserService.ts` vs `userService.ts` is ambiguous on macOS/Windows
2. **Overly generic branch names** — `feature/update`, `bugfix/fix` provide no information
3. **Mixing cases** — `feature/My-Feature` alongside `feature/my-feature` creates confusion
4. **Long branch names** — Branches should be descriptive but not paragraphs
5. **No stable file naming convention** — Using kebab-case in some dirs and snake_case in others
6. **Not enforcing naming via CI** — Without automated checks, conventions drift

### Alternatives

- **Git Flow** — Full `feature/release/hotfix/support` branch model; heavyweight
- **GitHub Flow** — Minimal: only `main` + feature branches; lightweight
- **Trunk-Based Development** — Short-lived branches, no `develop` branch; continuous integration
- **GitLab Flow** — Environment branches (`production`, `pre-production`) + feature branches
- **No convention** — Works for solo devs, fails for teams

### Recommendation

> **ADOPT** — Git branches: `feature/`, `bugfix/`, `hotfix/`, `release/` prefixes with kebab-case descriptions. Files: kebab-case for non-component files (TypeScript/JS), PascalCase for React components. Enforce with CI hooks. For Python/Go/Rust, use the ecosystem convention (snake_case).

---

## 5. Repository Structure

### Authoritative Sources

| Source | URL | Authority |
|--------|-----|-----------|
| **Go Standard Project Layout** (golang-standards) | https://github.com/golang-standards/project-layout | **Most cited** (NOT official Go standard — community convention) |
| **Official Go Module Layout** | https://go.dev/doc/modules/layout | Official Go team guidance |
| **Folder Structure Conventions** (kriasoft) | https://github.com/kriasoft/Folder-Structure-Conventions | Language-agnostic convention (~2k stars) |
| **Cookiecutter** | https://github.com/cookiecutter/cookiecutter | Project template framework (~22k stars) |
| **IBM z/DevOps Guide** | https://www.ibm.com/docs/en/z-devops-guide | Enterprise perspective |
| **Next.js Project Structure** | https://nextjs.org/docs/app/getting-started/project-structure | Framework-specific |

### Most Common Top-Level Layout (Language-Agnostic)

```
.
├── src/              # Source files (alternatively `lib` or `app`)
├── test/             # Automated tests (alternatively `spec` or `tests`)
├── docs/             # Documentation
├── build/            # Build scripts/config (alternatively `dist/` for outputs)
├── scripts/          # Automation scripts
├── config/           # Configuration templates
├── .github/          # GitHub Actions workflows
├── README.md
├── LICENSE
├── .gitignore
└── package.json / go.mod / Cargo.toml / pyproject.toml
```

**Source**: https://github.com/kriasoft/Folder-Structure-Conventions — references 30+ major OSS projects using `src/`: jQuery, Node.js, D3.js, AngularJS, React, Rust, MongoDB, Bitcoin, etc.

### Go-Specific Layout (golang-standards/project-layout)

```
.
├── cmd/              # Application entry points
├── internal/         # Private code (not importable externally)
├── pkg/              # Public library code
├── api/              # OpenAPI/Swagger specs, protobuf definitions
├── web/              # Web app static assets
├── configs/          # Configuration file templates
├── scripts/          # Build scripts
├── build/            # Packaging + CI
├── deploy/           # Deployment configs
├── test/             # External test data
├── docs/             # Documentation
├── examples/         # Usage examples
├── go.mod
└── Makefile
```

**Important caveat**: The creators explicitly state this is **not an official Go standard** and recommend starting with just `main.go` + `go.mod` for simple projects. See https://github.com/golang-standards/project-layout/issues/117.

### Monorepo vs Polyrepo

**Industry context (2026)**:

| Factor | Monorepo | Polyrepo |
|--------|----------|----------|
| **Best for** | Shared code, atomic changes | Independent teams, different stacks |
| **Tools** | Turborepo, Nx, Bazel, pnpm workspaces | Standard CI per repo |
| **CI complexity** | Needs affected detection + caching | One pipeline per repo |
| **Code sharing** | Import directly | Must publish to registry |
| **Git performance** | Slower at scale (needs sparse checkout) | Fast (small repos) |
| **Team autonomy** | Needs CODEOWNERS + module boundaries | Fully autonomous |

**Source**: https://daily.dev/blog/monorepo-turborepo-vs-nx-vs-bazel-modern-development-teams/ (2026 analysis)

**Monorepo tool popularity (2026)**:
- **Turborepo** (~26k stars, 1.8M weekly npm downloads) — Simple, fast, minimal config
- **Nx** (~23k stars, 2.5M weekly npm downloads) — Full platform, code generation, plugins
- **Bazel** — Multi-language, massive scale (Google)

**Recommendation**: Monorepo with Turborepo for JS/TS projects with 5-50 packages; Nx for larger or multi-framework needs.

### Cookiecutter Templates

| Template | Language | Stars | URL |
|----------|----------|-------|-----|
| **cookiecutter-django** | Python/Django | ~12k | https://github.com/cookiecutter/cookiecutter-django |
| **cookiecutter-golang** | Go | ~600 | https://github.com/lacion/cookiecutter-golang |
| **cookiecutter-flask** | Python/Flask | ~4.6k | https://github.com/cookiecutter/cookiecutter-flask |
| **create-react-app** | React | — | Built-in scaffolding |
| **create-next-app** | Next.js | — | Built-in scaffolding |

### Real-World OSS Examples

| Repo | Structure Pattern | Evidence |
|------|-------------------|----------|
| **React** (facebook/react) | `src/` based, `scripts/`, `packages/` (monorepo) | https://github.com/facebook/react |
| **Next.js** (vercel/next.js) | Monorepo (`packages/`, `examples/`, `crates/`) | https://github.com/vercel/next.js |
| **TypeScript** (microsoft/TypeScript) | `src/compiler/`, `src/services/`, `tests/` | https://github.com/microsoft/TypeScript |
| **Go** (golang/go) | `src/` with multiple `cmd/` subdirectories | https://github.com/golang/go |
| **Rust** (rust-lang/rust) | `src/`, `compiler/`, `library/`, `tests/` | https://github.com/rust-lang/rust |
| **Django** (django/django) | `django/` (src), `tests/` | https://github.com/django/django |
| **NestJS** (nestjs/nest) | Monorepo (`packages/`, `integration/`, `samples/`) | https://github.com/nestjs/nest |

### Common Pitfalls

1. **Over-structuring early** — Starting with `cmd/`, `internal/`, `pkg/` for a 3-file project (Go anti-pattern)
2. **Mixing source and build outputs** — Committing `dist/` or `build/` unnecessarily
3. **Deep nesting** — More than 3-4 levels deep makes navigation painful
4. **No README** at project root — Loses first impression for new contributors
5. **Bad `.gitignore`** — Committing node_modules, .env files, build artifacts
6. **Monorepo without tooling** — Slow CI and no affected-detection defeats the purpose
7. **Polyrepo without version strategy** — Dependency drift between microservices

### Recommendation

> **ADAPT** — Use `src/` + `test/` + `docs/` at the top level (de facto standard across languages). For Go, use `cmd/` + `internal/` + `pkg/` when project is medium-to-large. For monorepos, adopt Turborepo (JS/TS) or workspace-based structure. Do not over-structure early — grow layout with project complexity.

---

## Summary: Adoption Recommendations

| Standard | Recommendation | Key Action |
|----------|---------------|------------|
| **Commit Conventions** | ✅ **ADOPT** | Implement Conventional Commits v1.0.0 with commitlint + semantic-release |
| **Changelog** | ✅ **ADOPT** | Keep a Changelog v1.1.0, auto-generate from commits, keep `CHANGELOG.md` canonical |
| **ADR** | ✅ **ADOPT** | Use `docs/adr/` with Nygard or MADR 4.0.0 template, supersede don't delete |
| **Naming Conventions** | ✅ **ADOPT** | Kebab-case for files (TS/JS), PascalCase for components, `feature/`+`bugfix/` branch prefixes |
| **Repository Structure** | 🔄 **ADAPT** | Standard `src/`+`test/`+`docs/` layout; monorepo with Turborepo if multi-package; don't over-structure early |

---

## Sources Index

- https://www.conventionalcommits.org/en/v1.0.0/
- https://github.com/angular/angular/blob/main/contributing-docs/commit-message-guidelines.md
- https://semver.org/
- https://github.com/semantic-release/semantic-release
- https://keepachangelog.com/en/1.1.0/
- https://docs.github.com/en/repositories/releasing-projects-on-github
- https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions
- https://adr.github.io/
- https://adr.github.io/madr/
- https://github.com/npryce/adr-tools
- https://github.com/thomvaill/log4brains
- https://github.com/golang-standards/project-layout
- https://go.dev/doc/modules/layout
- https://github.com/kriasoft/Folder-Structure-Conventions
- https://github.com/cookiecutter/cookiecutter
- https://nvie.com/posts/a-successful-git-branching-model/
- https://nextjs.org/docs/app/getting-started/project-structure
- https://github.com/googleapis/release-please
- https://docs.aws.amazon.com/prescriptive-guidance/latest/architectural-decision-records/welcome.html
- https://gds-way.digital.cabinet-office.gov.uk/standards/architecture-decisions.html
- https://peps.python.org/pep-0008/
- https://google.github.io/styleguide/tsguide.html
