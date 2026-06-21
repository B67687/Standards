# CI Pipeline Standard

## Three-Stage Model

| Stage                 | Where          | Trigger                  | Time   | Purpose                                                               |
| --------------------- | -------------- | ------------------------ | ------ | --------------------------------------------------------------------- |
| **L0: Pre-commit**    | Local machine  | `git commit`             | <30s   | Catch secrets, formatting, simple bugs before they leave your machine |
| **L1: Pre-merge**     | GitHub Actions | PR opened/updated        | <10min | Required checks: lint, build, test, SAST, secrets                     |
| **L2: Deep analysis** | GitHub Actions | Push to main + scheduled | <30min | CodeQL, full SAST, dependency audit, link check                       |

## Profiles by Repo Type

### Library (e.g. ithmb-codec, bus-hop)

| Layer | Check          | Tool                    | Required? |
| ----- | -------------- | ----------------------- | --------- |
| L0    | Secrets scan   | gitleaks (staged files) | ✅        |
| L0    | Format/lint    | pre-commit hooks        | ✅        |
| L0    | Commit message | commitlint              | ✅        |
| L1    | Build          | Language toolchain      | ✅        |
| L1    | Test           | Test runner             | ✅        |
| L1    | SAST           | Semgrep                 | ✅        |
| L1    | Secrets scan   | gitleaks (full history) | ✅        |
| L2    | Security       | CodeQL                  | ✅        |
| L2    | Dependencies   | Dependency review       | ✅        |
| L2    | Links          | Lychee                  | 🟡        |
| L2    | Release        | Release workflow        | 🟡        |

### Application (e.g. bus-hop)

| Layer | Check        | Tool               | Required? |
| ----- | ------------ | ------------------ | --------- |
| L0    | Secrets scan | gitleaks           | ✅        |
| L0    | Format/lint  | pre-commit         | ✅        |
| L1    | Build        | Gradle / toolchain | ✅        |
| L1    | Test         | Test runner        | ✅        |
| L1    | SAST         | Semgrep            | ✅        |
| L1    | Secrets      | gitleaks           | ✅        |
| L2    | Security     | CodeQL             | ✅        |
| L2    | Dependencies | Dependency review  | ✅        |

### Harness / Config (e.g. agentic-workflows, agent-harness)

| Layer | Check        | Tool                  | Required? |
| ----- | ------------ | --------------------- | --------- |
| L0    | Secrets scan | gitleaks              | ✅        |
| L0    | Shell lint   | shellcheck            | ✅        |
| L1    | SAST         | Semgrep (shell rules) | ✅        |
| L1    | Secrets scan | gitleaks              | ✅        |
| L2    | Dependencies | Dependabot            | ✅        |

### Docs / Notes (e.g. CS-Notes)

| Layer | Check         | Tool         | Required? |
| ----- | ------------- | ------------ | --------- |
| L1    | Links         | Lychee       | ✅        |
| L1    | Markdown lint | markdownlint | ✅        |

## Template Files

### L0: `.pre-commit-config.yaml`

```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v5.0.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-json
      - id: check-merge-conflict
      - id: detect-private-key
      - id: debug-statements
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.30.1
    hooks:
      - id: gitleaks
```

### L0: `.commitlintrc.json`

```json
{
  "extends": ["@commitlint/config-conventional"],
  "rules": {
    "type-enum": [
      2,
      "always",
      ["feat", "fix", "docs", "refactor", "perf", "test", "chore", "cleanup", "security", "revert"]
    ],
    "subject-case": [0],
    "subject-full-stop": [0]
  }
}
```

### L1: `.github/workflows/test.yml`

```yaml
name: Test
on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-dotnet@v4
        with:
          dotnet-version: '10.0.x'
      - name: Build
        run: dotnet build --configuration Release --no-restore
      - name: Test
        run: dotnet test --configuration Release --no-build --verbosity normal
```

### L1: `.github/workflows/secrets.yml`

```yaml
name: Secrets
on:
  pull_request:
    branches: [main]

jobs:
  gitleaks:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### L2: `.github/workflows/codeql.yml`

```yaml
name: CodeQL
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  schedule:
    - cron: "0 6 * * 1"

jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: github/codeql-action/init@v3
        with:
          languages: csharp
      - run: dotnet build
      - uses: github/codeql-action/analyze@v3

# Language quick reference:
#   csharp       → dotnet build
#   python       → (no build step needed)
#   javascript   → (no build step needed)
#   go           → go build
#   kotlin       → ./gradlew build
#   java         → ./gradlew build or mvn compile
#   ruby         → (no build step needed)
```

## The Privacy Gap: Gitleaks

The most important addition across all repos is **secret scanning**. Gitleaks detects:

- API keys (AWS, GitHub, Slack, Stripe, etc.)
- Private keys (`BEGIN RSA PRIVATE KEY`)
- High-entropy strings that look like tokens
- Credentials in `.env` files or config

It runs at **L0** (pre-commit, staged files only — fast) and **L1** (CI, full git history — thorough). Both layers are needed because pre-commit can be bypassed with `--no-verify`, but CI cannot.

## Existing Reference

ithmb-codec has the best existing setup. To bring it to full standard, add:

1. **Gitleaks** — `.pre-commit-config.yaml` hook + `secrets.yml` workflow
2. **Dependency review** — add to existing workflows
3. **Release workflow** — optional, for when publishing is needed

## Implementation Order

1. Add `.pre-commit-config.yaml` + gitleaks hook to every active repo
2. Add `secrets.yml` workflow to every active repo
3. Add CodeQL workflow to library/app repos
4. Add Semgrep workflow (already in ithmb-codec, propagate)
5. Add conventional commits workflow
6. Add dependency review
7. Add release workflow (when needed)
