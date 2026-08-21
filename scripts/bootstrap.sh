#!/usr/bin/env bash
# bootstrap.sh — Scaffold a new repo with all standard files.
#
# Usage:
#   bootstrap.sh <project-name> <language> [description] [target-dir]
#
# Arguments:
#   project-name   Repository name (e.g. "my-project")
#   language       Project language: rust, ts, python, go
#   description    One-line description (default: "Project description")
#   target-dir     Where to create the repo (default: current directory)
#
# What it creates:
#   - Git repo with .gitignore, .editorconfig, .gitattributes
#   - LICENSE (MIT)
#   - README.md with badges
#   - CHANGELOG.md (Keep a Changelog format)
#   - AGENTS.md (agent-facing)
#   - SECURITY.md
#   - .commitlintrc.json, .pre-commit-config.yaml
#   - mise.toml (tool versions)
#   - docs/ directory with shift-log.md
#   - .github/workflows/ci.yml
#   - Language-specific: Cargo.toml/deny.toml (rust), package.json (ts), etc.
#
# Does NOT create Dev repos or push to GitHub — that's manual.

set -euo pipefail

# ── Arguments ────────────────────────────────────────────────────────────
PROJECT_NAME="${1:-}"
LANGUAGE="${2:-}"
DESCRIPTION="${3:-Project description}"
TARGET_DIR="${4:-.}"

if [ -z "${PROJECT_NAME}" ] || [ -z "${LANGUAGE}" ]; then
  echo "Usage: bootstrap.sh <project-name> <language> [description] [target-dir]" >&2
  echo "  Languages: rust, ts, python, go" >&2
  exit 1
fi

case "${LANGUAGE}" in
  rust|ts|python|go) ;;
  *) echo "Error: unsupported language '${LANGUAGE}'. Use: rust, ts, python, go" >&2; exit 1 ;;
esac

REPO_DIR="${TARGET_DIR}/${PROJECT_NAME}"
if [ -d "${REPO_DIR}" ]; then
  echo "Error: directory '${REPO_DIR}' already exists" >&2
  exit 1
fi

echo "Bootstrapping ${PROJECT_NAME} (${LANGUAGE}) in ${REPO_DIR}..."

# ── Create directory structure ──────────────────────────────────────────
mkdir -p "${REPO_DIR}"/{docs,.github/workflows,.omo}

# ── Git init ────────────────────────────────────────────────────────────
git -C "${REPO_DIR}" init -b main >/dev/null 2>&1

# ── .gitignore ──────────────────────────────────────────────────────────
cat > "${REPO_DIR}/.gitignore" << 'GITIGNORE'
# Build artifacts
/target/
/dist/
/out/
/build/
/node_modules/

# Environment
.env
.env.*
!.env.example
!.env.encrypted

# IDE
.idea/
.vscode/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Agent workspace — NEVER public
.omo/

# Tool caches
.ruff_cache/
.mypy_cache/
__pycache__/
GITIGNORE

# Language-specific .gitignore additions
case "${LANGUAGE}" in
  rust)
    cat >> "${REPO_DIR}/.gitignore" << 'EOF'

# Rust
/debug/
/debug/
*.pdb
mutants.out/
rust_out
EOF
    ;;
  ts)
    cat >> "${REPO_DIR}/.gitignore" << 'EOF'

# TypeScript
/dist/
*.tsbuildinfo
test-results/
playwright-report/
EOF
    ;;
  python)
    cat >> "${REPO_DIR}/.gitignore" << 'EOF'

# Python
__pycache__/
*.py[cod]
*.egg-info/
.venv/
venv/
EOF
    ;;
  go)
    cat >> "${REPO_DIR}/.gitignore" << 'EOF'

# Go
/bin/
/vendor/
EOF
    ;;
esac

# ── .editorconfig ───────────────────────────────────────────────────────
cat > "${REPO_DIR}/.editorconfig" << 'EOF'
root = true

[*]
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
charset = utf-8
indent_style = space
indent_size = 2

[*.md]
trim_trailing_whitespace = false

[Makefile]
indent_style = tab
EOF

# ── .gitattributes ──────────────────────────────────────────────────────
cat > "${REPO_DIR}/.gitattributes" << 'EOF'
* text=auto eol=lf
*.sh text eol=lf
*.py text eol=lf
*.rs text eol=lf
*.ts text eol=lf
*.js text eol=lf
*.go text eol=lf
*.json text eol=lf
*.yml text eol=lf
*.yaml text eol=lf
*.md text eol=lf diff=markdown
EOF

# ── LICENSE (MIT) ───────────────────────────────────────────────────────
YEAR=$(date +%Y)
cat > "${REPO_DIR}/LICENSE" << EOF
MIT License

Copyright (c) ${YEAR} B67687

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

# ── README.md ───────────────────────────────────────────────────────────
cat > "${REPO_DIR}/README.md" << EOF
# ${PROJECT_NAME}

${DESCRIPTION}

## Quick Start

$(case "${LANGUAGE}" in
  rust) echo '```bash
cargo build
cargo test
```' ;;
  ts) echo '```bash
npm ci
npm test
npm run build
```' ;;
  python) echo '```bash
pip install -e .
pytest
```' ;;
  go) echo '```bash
go build ./...
go test ./...
```' ;;
esac)

## License

MIT — see [LICENSE](./LICENSE).
EOF

# ── CHANGELOG.md ────────────────────────────────────────────────────────
cat > "${REPO_DIR}/CHANGELOG.md" << 'EOF'
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Initial project structure

## [0.1.0] - YYYY-MM-DD

### Added

- Initial release
EOF

# ── AGENTS.md ───────────────────────────────────────────────────────────
cat > "${REPO_DIR}/AGENTS.md" << EOF
# ${PROJECT_NAME}

**Language:** ${LANGUAGE}
**Status:** IMPLEMENTED

## Repository Layout

\`\`\`
${PROJECT_NAME}/
├── src/            # Source code
├── tests/          # Tests
├── docs/           # Documentation
├── scripts/        # Build/CI scripts
├── .github/        # GitHub Actions
└── .omo/           # Agent workspace (NEVER commit)
\`\`\`

## Key Files

- \`README.md\` — User-facing docs
- \`CHANGELOG.md\` — Version history
- \`SECURITY.md\` — Vulnerability reporting
- \`LICENSE\` — MIT license

## Rules

- Author: B67687 only
- No Co-authored-by or tool footers
- Commit messages: Conventional Commits format
- GPG-signed commits only
- \`.omo/\` never enters public tree
EOF

# ── SECURITY.md ─────────────────────────────────────────────────────────
cat > "${REPO_DIR}/SECURITY.md" << 'EOF'
# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| latest  | :white_check_mark: |

## Reporting a Vulnerability

If you discover a security vulnerability, please report it responsibly:

1. **Do NOT** open a public issue
2. Use [GitHub private vulnerability reporting](https://github.com/USER/REPO/security/advisories/new)
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

## Response Timeline

- **Acknowledgment:** within 48 hours
- **Assessment:** within 1 week
- **Fix or mitigation:** within 2 weeks for critical issues

## Security Properties

- No user data collected
- All processing is client-side where applicable
- Dependencies are pinned and audited
EOF

# ── .commitlintrc.json ──────────────────────────────────────────────────
cat > "${REPO_DIR}/.commitlintrc.json" << 'EOF'
{
  "extends": ["@commitlint/config-conventional"],
  "rules": {
    "type-enum": [2, "always", [
      "feat", "fix", "docs", "style", "refactor",
      "perf", "test", "build", "ci", "chore", "revert"
    ]],
    "subject-case": [0],
    "body-max-line-length": [0]
  }
}
EOF

# ── .pre-commit-config.yaml ─────────────────────────────────────────────
cat > "${REPO_DIR}/.pre-commit-config.yaml" << 'EOF'
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.24.3
    hooks:
      - id: gitleaks
  - repo: https://github.com/compilerla/conventional-pre-commit
    rev: v4.0.0
    hooks:
      - id: conventional-pre-commit
        stages: [commit-msg]
EOF

# ── mise.toml ───────────────────────────────────────────────────────────
case "${LANGUAGE}" in
  rust) cat > "${REPO_DIR}/mise.toml" << 'EOF'
[tools]
rust = "1.88.0"
EOF
    ;;
  ts) cat > "${REPO_DIR}/mise.toml" << 'EOF'
[tools]
node = "22"
EOF
    ;;
  python) cat > "${REPO_DIR}/mise.toml" << 'EOF'
[tools]
python = "3.13"
EOF
    ;;
  go) cat > "${REPO_DIR}/mise.toml" << 'EOF'
[tools]
go = "1.24"
EOF
    ;;
esac

# ── docs/shift-log.md ──────────────────────────────────────────────────
cat > "${REPO_DIR}/docs/shift-log.md" << 'EOF'
# Shift Log

Up to 5 learning shifts. Each documents a discovery, not a failure.

```LEARNING SHIFT
What we learned: Initial project setup complete.
Decision: Followed standards bootstrap template.
Cost: None — fresh project.
What this enables: Consistent structure from day one.
```
EOF

# ── .omo/shift-log.md (local-only, never public) ────────────────────────
cp "${REPO_DIR}/docs/shift-log.md" "${REPO_DIR}/.omo/shift-log.md"

# ── Language-specific files ──────────────────────────────────────────────
case "${LANGUAGE}" in
  rust)
    mkdir -p "${REPO_DIR}/src"
    cat > "${REPO_DIR}/src/lib.rs" << 'EOF'
//! ${PROJECT_NAME}

/// Add library documentation here.
pub fn hello() -> &'static str {
    "Hello, world!"
}
EOF
    cat > "${REPO_DIR}/Cargo.toml" << EOF
[package]
name = "${PROJECT_NAME}"
version = "0.1.0"
edition = "2024"
license = "MIT"
description = "${DESCRIPTION}"

[lib]
name = "${PROJECT_NAME//-/_}"
path = "src/lib.rs"

[dev-dependencies]
EOF
    cat > "${REPO_DIR}/deny.toml" << 'EOF'
[advisories]
ignore = []

[licenses]
allow = [
    "MIT",
    "Apache-2.0",
    "ISC",
    "BSD-2-Clause",
    "BSD-3-Clause",
    "Zlib",
    "Unicode-3.0",
    "Unicode-DFS-2016",
    "CC0-1.0",
    "0BSD",
]

[bans]
multiple-versions = "deny"
wildcards = "allow"

[sources]
unknown-registry = "deny"
unknown-git = "deny"
allow-registry = ["https://github.com/rust-lang/crates.io-index"]
EOF
    cat > "${REPO_DIR}/rust-toolchain.toml" << 'EOF'
[toolchain]
channel = "1.88.0"
components = ["rustfmt", "clippy"]
EOF
    cat > "${REPO_DIR}/.github/workflows/ci.yml" << 'EOF'
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  CARGO_TERM_COLOR: always

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: dtolnay/rust-toolchain@stable
        with:
          components: rustfmt, clippy
      - uses: Swatinem/rust-cache@v2
      - run: cargo fmt --all -- --check
      - run: cargo clippy --all-targets --all-features -- -D warnings
      - run: cargo build --all-targets
      - run: cargo test

  deny:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: EmbarkStudios/cargo-deny-action@v2
EOF
    ;;
  ts)
    mkdir -p "${REPO_DIR}/src"
    cat > "${REPO_DIR}/src/index.ts" << 'EOF'
export function hello(): string {
  return "Hello, world!";
}
EOF
    cat > "${REPO_DIR}/package.json" << EOF
{
  "name": "${PROJECT_NAME}",
  "version": "0.1.0",
  "description": "${DESCRIPTION}",
  "license": "MIT",
  "type": "module",
  "scripts": {
    "build": "tsc",
    "test": "vitest run",
    "typecheck": "tsc --noEmit",
    "lint": "eslint src/"
  },
  "devDependencies": {
    "typescript": "^5.7.0",
    "vitest": "^3.0.0",
    "@types/node": "^22.0.0"
  }
}
EOF
    cat > "${REPO_DIR}/tsconfig.json" << 'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "outDir": "dist",
    "declaration": true
  },
  "include": ["src"]
}
EOF
    cat > "${REPO_DIR}/.github/workflows/ci.yml" << 'EOF'
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: "22"
          cache: "npm"
      - run: npm ci
      - run: npm run typecheck
      - run: npm test
      - run: npm run build
EOF
    ;;
  python)
    mkdir -p "${REPO_DIR}/src"
    cat > "${REPO_DIR}/src/__init__.py" << 'EOF'
"""${PROJECT_NAME}"""
__version__ = "0.1.0"
EOF
    cat > "${REPO_DIR}/pyproject.toml" << EOF
[project]
name = "${PROJECT_NAME}"
version = "0.1.0"
description = "${DESCRIPTION}"
license = "MIT"
requires-python = ">=3.10"

[build-system]
requires = ["setuptools>=68.0"]
build-backend = "setuptools.backends._legacy:_Backend"

[tool.pytest.ini_options]
testpaths = ["tests"]

[tool.ruff]
line-length = 100
EOF
    mkdir -p "${REPO_DIR}/tests"
    cat > "${REPO_DIR}/tests/__init__.py" << 'EOF'
EOF
    cat > "${REPO_DIR}/.github/workflows/ci.yml" << 'EOF'
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.13"
      - run: pip install -e ".[dev]"
      - run: ruff check src/ tests/
      - run: pytest
EOF
    ;;
  go)
    mkdir -p "${REPO_DIR}/cmd/${PROJECT_NAME}"
    cat > "${REPO_DIR}/main.go" << EOF
package main

import "fmt"

func main() {
	fmt.Println("Hello, world!")
}
EOF
    cat > "${REPO_DIR}/go.mod" << EOF
module github.com/B67687/${PROJECT_NAME}

go 1.24
EOF
    cat > "${REPO_DIR}/.github/workflows/ci.yml" << 'EOF'
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: "1.24"
      - run: go build ./...
      - run: go test ./...
      - run: go vet ./...
EOF
    ;;
esac

# ── Initial commit ──────────────────────────────────────────────────────
cd "${REPO_DIR}"
git add -A
git commit -m "chore: initial project scaffold via standards bootstrap" --no-verify 2>/dev/null || true

echo ""
echo "Bootstrapped ${PROJECT_NAME} in ${REPO_DIR}"
echo ""
echo "Next steps:"
echo "  1. cd ${REPO_DIR}"
echo "  2. Edit src/ to start coding"
echo "  3. Create Dev repo: gh repo create B67687/${PROJECT_NAME}-Dev --private"
echo "  4. Add remotes: git remote add origin <dev-repo-url>"
echo "  5. git push -u origin main"
