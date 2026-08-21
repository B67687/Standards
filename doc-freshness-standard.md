# Documentation Freshness Standard

**Purpose:** Detect when documentation drifts out of sync with code changes. Stale docs mislead users and agents.

**Scope:** Every repo with source code and documentation.

## Rules

### 1. README must track code changes
If source files (`.rs`, `.ts`, `.py`, `.go`, `.js`) changed in the last 20 commits, `README.md` should also have been updated. A README untouched while code evolves signals stale documentation.

### 2. CHANGELOG must reflect recent work
If 5+ commits exist since the last tag, `CHANGELOG.md` should have content under `## [Unreleased]`. An empty Unreleased section with pending work means the changelog is not being maintained.

### 3. No significantly stale doc files
Documentation files that haven't been touched in 50+ commits while the project evolves are flagged as warnings. This catches files like `docs/SETUP.md` or `ARCHITECTURE.md` that drift silently.

### 4. SECURITY.md required for public repos
Any repo with GitHub Actions workflows (indicating a public or shared project) should have a `SECURITY.md` documenting vulnerability reporting.

## Severity

All freshness checks are **warnings** (not failures). Stale docs are a quality signal, not a blocking issue. The exception is `SECURITY.md` which is a hard check for repos with CI.

## Check IDs

| Check | Description | Type |
|-------|-------------|------|
| `readme-fresh` / `readme-stale` | README updated relative to code changes | warn |
| `changelog-fresh` / `changelog-stale` | CHANGELOG has recent entries | warn |
| `docs-fresh` / `stale-docs` | No significantly stale doc files | warn |
| `security-md-exists` | SECURITY.md present for repos with CI | check |
