# Link Rot Standard

## Motivation

Documentation links degrade over time — domains expire, pages are restructured, projects are archived. Automated link checking prevents stale references from accumulating in READMEs, documentation, and code comments.

## Tool: lychee

[lychee](https://github.com/lycheeverse/lychee) is the recommended link checker (Rust, 3.7k stars).

| Feature | lychee |
|---------|--------|
| Language | Rust — single static binary, no dependencies |
| File types | Markdown, HTML, reStructuredText, plain text |
| Anchor fragments | ✅ Local file fragment validation |
| Caching | ✅ `--cache --max-cache-age 1d` |
| Pre-commit hook | ✅ Native via `.pre-commit-hooks.yaml` (3 variants) |
| GitHub Action | ✅ Official `lycheeverse/lychee-action@v2` |
| Config | `lychee.toml` |
| Output formats | JSON, Markdown, Colored |

## Enforcement

- `scripts/checks/link-rot.sh` verifies lychee is installed and configured
- CI runs `lychee --no-progress './**/*.md'` on push
- Optional: scheduled weekly full scan with `lychee-action` + cache

## Pre-commit Setup

```yaml
# .pre-commit-config.yaml
- repo: https://github.com/lycheeverse/lychee
  rev: v0.24.0
  hooks:
    - id: lychee
      args: ["--no-progress", "./**/*.md"]
```

## CI Setup

```yaml
- name: Link Checker
  uses: lycheeverse/lychee-action@v2
  with:
    args: '--verbose --no-progress "./**/*.md"'
    fail: true
    jobSummary: true
```

## Exclusions

Create a `.lycheeignore` file at repo root for known-broken but intentional links:

```text
https://localhost:*
https://example.com
```

## Related Standards

- [README Standard](README-standard.md) — documentation format with external links
