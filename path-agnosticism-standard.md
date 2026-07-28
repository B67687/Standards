# Path Agnosticism Standard

## Overview

All scripts and configuration in this repository MUST be **path-agnostic** — they must work on any machine without modification. Absolute paths, user-specific paths, and machine-specific assumptions break portability.

## File: `path-agnosticism`

| Field | Value |
|-------|-------|
| ID | `path-agnosticism` |
 | Type | shell-checkable |
 | Category | CI / Portability |
 | Since | 2026-06-23 |

## Rules

### 1. No Hardcoded Absolute Paths

Scripts MUST NOT contain bare absolute paths that reference specific user or system directories.

✅ Acceptable:
- Environment variables: `$HOME`, `$PWD`, `$SCRIPT_DIR`
- Relative paths: `./scripts/`, `"${repo}/docs/"`
- System paths: `/tmp/`, `/dev/null`, `/usr/bin/env`, `#!/path/to/interpreter`
- Redirect targets: `2>/dev/null`, `/dev/null`

❌ Not acceptable:
- `/home/username/...`
- `/Users/username/...`
- `/root/...`

### 2. Use Path Variables

All repo-internal file references MUST use relative paths or `$SCRIPT_DIR`:

| Context | Correct | Wrong |
|---------|---------|-------|
| Script sourcing | `SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"` | `/home/user/repo/scripts/` |
| Repo reference | `"${repo}/docs/badges/"` | `~/projects/repo/docs/` |
| Dashboard output | `DASHBOARD_DIR="\${SCRIPT_DIR}/../.omo/dashboard"` | `/srv/www/dashboard/` |

### 3. Configurable Search Paths

Any script that searches directories MUST accept the search path as an argument or environment variable with a sensible fallback.

✅ `SEARCH_DIR="${1:-.}"` or `SEARCH_DIR="${MY_CUSTOM_PATH:-.}"`
❌ `SEARCH_DIR="${HOME}/projects/dev"`

## Example

Instead of:
```bash
SEARCH_DIR="${HOME}/projects/dev"
```

Write:
```bash
SEARCH_DIR="${1:-.}"
```

## Audit

| # | Check | Description | Type |
|---|-------|-------------|------|
| 1 | `no-hardcoded-home` | No `/home/` or `/Users/` in scripts | shell |
| 2 | `no-hardcoded-absolute` | No bare absolute paths in scripts | shell |
| 3 | `uses-script-dir` | Scripts use `$SCRIPT_DIR` for relative sourcing | shell |
| 4 | `search-path-configurable` | Search paths accept arguments/env vars | shell |
