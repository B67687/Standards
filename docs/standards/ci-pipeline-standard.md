# CI Pipeline Standard

## Domains

backend,infra


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

Reference implementations live in each repo's `.github/workflows/`. See `.github/workflows/test.yml`:

```yaml
name: Test
on: [pull_request, push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: dotnet build
      - run: dotnet test
```

Hooks via `.pre-commit-config.yaml` (sequential) or `lefthook.yml` (parallel); commit messages via `.commitlintrc.json` (extends `@commitlint/config-conventional`). Minimal `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.30.1
    hooks:
      - id: gitleaks
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

**Recommendation:** Use gitleaks for git-focused scanning (CI on PR diffs). Use trivy as an alternative when you already have trivy in your toolchain. Either tool is acceptable; both detect the same class of secrets. It runs at **L0** (pre-commit) and **L1** (CI) — both layers are needed because pre-commit can be bypassed with `--no-verify`, but CI cannot.

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
