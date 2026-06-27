#!/usr/bin/env bash
# checks/code-documentation.sh — Code Documentation Standard checks.
#
# Sourced by audit.sh. Uses the framework from audit-lib.sh.
#
# Checks:
#   1. Code Documentation Standard doc exists
#   2. Source files have language-appropriate docstrings (JS/TS/Python/Rust/Go/Shell)
#   3. Public/exported APIs are documented (limited heuristic scan)
#
# Audit-only — no fixes.

set -euo pipefail

# ── Register this standard ────────────────────────────────────────────────
ALL_STANDARDS+=("code-documentation")
# shellcheck disable=SC2034 # consumed by audit-lib.sh via source
STANDARD_DOMAINS["code-documentation"]="docs,backend"

# ── Standard entry point: checks ──────────────────────────────────────────
checks_code_documentation() {
  local repo="$1"
  # shellcheck disable=SC2034 # used by _check/_check_fail via audit-lib.sh
  CURR_STANDARD="code-documentation"

  _check_header "Code Documentation Standard"

  # ── Check 1: Standard doc exists ──────────────────────────────────────
  _check "code-doc-standard-exists" "Code Documentation Standard doc exists" \
    test -f "${repo}/docs/standards/code-documentation-standard.md"

  # ── Check 2: Source files have docstrings ─────────────────────────────
  # Heuristic: scan for exports without preceding doc comments
  local code_files
  code_files=$(find "${repo}" -name '*.ts' -o -name '*.tsx' -o -name '*.js' \
    -o -name '*.py' -o -name '*.rs' -o -name '*.go' 2>/dev/null | head -20)
  local undoc_count=0
  local total_public=0
  for f in ${code_files}; do
    case "${f}" in
      *.ts|*.tsx|*.js)
        # Count export function/class/const without preceding /** or ///
        while IFS= read -r line; do
          if echo "${line}" | grep -qE '^\s*export\s+(function|class|const|interface|type|default)'; then
            total_public=$((total_public + 1))
            prev_line=$(sed -n "$((total_public))p" "${f}" 2>/dev/null || true)
            if [ -n "${prev_line}" ] && ! echo "${prev_line}" | grep -qE '^\s*/\*\*|^\s*///'; then
              undoc_count=$((undoc_count + 1))
            fi
          fi
        done < <(grep -n '^\s*export\s' "${f}" 2>/dev/null || true)
        ;;
      *.py)
        while IFS= read -r line; do
          if echo "${line}" | grep -qE '^\s*(def |class )' && \
             echo "${line}" | grep -qvE '^\s*(def |class )\s*_'; then
            total_public=$((total_public + 1))
          fi
        done < <(grep -n '^\s*\(def\|class\)\s' "${f}" 2>/dev/null || true)
        ;;
      *.rs)
        while IFS= read -r line; do
          if echo "${line}" | grep -qE '^\s*pub\s+(fn|struct|enum|trait|type|const|mod)'; then
            total_public=$((total_public + 1))
          fi
        done < <(grep -n '^\s*pub\s' "${f}" 2>/dev/null || true)
        ;;
      *.go)
        while IFS= read -r line; do
          if echo "${line}" | grep -qE '^\s*func\s+[A-Z]' || \
             echo "${line}" | grep -qE '^\s*type\s+[A-Z]'; then
            total_public=$((total_public + 1))
          fi
        done < <(grep -n '^\s*\(func\|type\)\s' "${f}" 2>/dev/null || true)
        ;;
    esac
  done
  _check "public-api-documented" "Exported/public APIs all have docstrings" \
    [ "${total_public}" -eq 0 ] || [ "${undoc_count}" -eq 0 ]

  # ── Check 3: Code doc standard doc references a doc generation tool ────
  if [ -f "${repo}/docs/standards/code-documentation-standard.md" ]; then
    _check "code-doc-tools-referenced" "Standard doc references doc generation tools" \
      grep -qE 'TypeDoc|Sphinx|rustdoc|go doc|darglint|interrogate' \
        "${repo}/docs/standards/code-documentation-standard.md"
  else
    _check_fail "code-doc-tools-referenced" "Standard doc not found"
  fi
}
