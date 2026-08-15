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
| L0    | Secrets scan   | gitleaks or trivy       | ✅        |
| L0    | Format/lint    | pre-commit or lefthook  | ✅        |
| L0    | Commit message | commitlint              | ✅        |
| L1    | Build          | Language toolchain      | ✅        |
| L1    | Test           | Test runner             | ✅        |
| L1    | SAST           | Semgrep                 | ✅        |
| L1    | Secrets scan   | gitleaks or trivy       | ✅        |
| L2    | Security       | CodeQL                  | ✅        |
| L2    | Dependencies   | Dependency review       | ✅        |
| L2    | Links          | Lychee                  | 🟡        |
| L2    | Release        | Release workflow        | 🟡        |

### Application (e.g. bus-hop)

| Layer | Check        | Tool                      | Required? |
| ----- | ------------ | ------------------------- | --------- |
| L0    | Secrets scan | gitleaks or trivy         | ✅        |
| L0    | Format/lint  | pre-commit or lefthook    | ✅        |
| L1    | Build        | Gradle / toolchain        | ✅        |
| L1    | Test         | Test runner               | ✅        |
| L1    | SAST         | Semgrep                   | ✅        |
| L1    | Secrets      | gitleaks or trivy         | ✅        |
| L2    | Security     | CodeQL                    | ✅        |
| L2    | Dependencies | Dependency review         | ✅        |

### Harness / Config (e.g. agentic-workflows, agent-harness)

| Layer | Check        | Tool                      | Required? |
| ----- | ------------ | ------------------------- | --------- |
| L0    | Secrets scan | gitleaks or trivy         | ✅        |
| L0    | Shell lint   | shellcheck                | ✅        |
| L0    | Format/lint  | lefthook (parallel hooks) | 🟡        |
| L1    | SAST         | Semgrep (shell rules)     | ✅        |
| L1    | Secrets scan | gitleaks or trivy         | ✅        |
| L2    | Dependencies | Dependabot                | ✅        |

### Docs / Notes (e.g. CS-Notes)

| Layer | Check         | Tool                     | Required? |
| ----- | ------------- | ------------------------ | --------- |
| L0    | Secrets scan  | gitleaks or trivy        | ✅        |
| L1    | Links         | Lychee                   | ✅        |
| L1    | Markdown lint | markdownlint             | ✅        |
| L1    | Secrets scan  | gitleaks or trivy        | ✅        |

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

### L0: `lefthook.yml` (Alternative to pre-commit)

When using lefthook instead of pre-commit, configure it with parallel hooks for maximum speed:

```yaml
# lefthook.yml — Minimal setup
pre-commit:
  parallel: true
  commands:
    secrets:
      run: trivy fs --scanners secrets --severity HIGH,CRITICAL .
      skip: true  # enable by un-skipping
    format:
      run: pre-commit run --all-files
      skip: true
    commitlint:
      run: commitlint --edit {1}

commit-msg:
  commands:
    commitlint:
      run: commitlint --edit {1}
```

Lefthook runs hooks in parallel by default (`parallel: true`), which is faster than pre-commit's sequential model. Use lefthook when you want:
- Parallel hook execution
- Simpler YAML config (no external repo references)
- Direct shell commands instead of pre-commit hook IDs

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

## Secret Scanning: Gitleaks vs Trivy

The most important addition across all repos is **secret scanning**. Two tools serve this role:

### Gitleaks

| Aspect | Detail |
|--------|--------|
| Focus | Git-native secret scanning — hunts secrets in git history |
| Detection | Regex + entropy-based, ~170 built-in rules |
| CI | `gitleaks/gitleaks-action@v2` — detects secrets in PR diffs |
| Pre-commit hook | Available from `https://github.com/gitleaks/gitleaks` |
| Best for | Repos with active git history; CI integration is mature |

### Trivy (`fs --scanners secrets`)

| Aspect | Detail |
|--------|--------|
| Focus | Multi-fs scanner — filesystem (not git-specific) |
| Detection | Regex + entropy, covers same secret patterns as gitleaks |
| CI | `aquasecurity/trivy-action@master` with `scan-type: fs --scanners secrets` |
| Pre-commit hook | Via lefthook (run `trivy fs --scanners secrets .` as a hook command) |
| Best for | Repos that already use trivy for image/fs scanning — one tool, two jobs |

**Recommendation:** Use gitleaks for git-focused scanning (CI on PR diffs). Use trivy as an alternative when you already have trivy in your toolchain (reduces tool count). Either tool is acceptable; both detect the same class of secrets.

### Trivy CI Workflow Template

```yaml
# .github/workflows/secrets.yml — Using Trivy instead of Gitleaks
name: Secrets
on:
  pull_request:
    branches: [main]

jobs:
  trivy-secrets:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - name: Trivy secret scan
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: fs
          scan-ref: .
          scanners: secrets
          exit-code: 1
```

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
## No-PR Variant: Push-Triggered Workflows

Repos that disable pull requests entirely (Settings → General → Features →
"Pull requests" off — the deepseek-harness model, see the push-workflow
standard) still need L1 CI. **The fix: trigger on `push` to `main` instead of
`pull_request`.** The dev repo (`<Project>-Dev`) becomes the gate: pushes there
run CI before anything reaches the public repo. Dependabot is NOT required —
its PR-automation is replaced by the repo owner's own dependency-update
process, and PR-triggered workflow sections become dead code (harmless, but
strippable).

### L1: `.github/workflows/test.yml` (push-only)

```yaml
name: Test
on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build
        run: <build command>
      - name: Test
        run: <test command>
```

### L1: `.github/workflows/secrets.yml` (push-only, gitleaks full-history)

```yaml
name: Secrets
on:
  push:
    branches: [main]

jobs:
  gitleaks:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - name: Gitleaks scan (full history)
        run: |
          curl -sSfL https://github.com/gitleaks/gitleaks/releases/download/v8.24.3/gitleaks_8.24.3_linux_x64.tar.gz | tar -xz -C /tmp
          /tmp/gitleaks git --no-banner --log-opts="--no-merges --all" --exit-code 1
```

### L2: `.github/workflows/codeql.yml` (push-only + schedule)

```yaml
name: CodeQL
on:
  push:
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
          languages: <language>
      - run: <build command>
      - uses: github/codeql-action/analyze@v3
```

**Local parity (L0)**: keep the pre-commit hook (gitleaks + lint + tests) so
nothing leaks from the dev loop — CI is the second gate, not the first. Reference
executions: ithmb-codec (gitleaks-action + cargo audit), ithmb-codec-web
(manual-download gitleaks + 3-browser Playwright), ithmb-plugin (gitleaks CI
job). The `pull_request:` triggers left in existing workflows become dead code
once PRs are disabled — safe to leave, cleaner to strip.
