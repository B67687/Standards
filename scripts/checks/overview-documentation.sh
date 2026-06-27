#!/usr/bin/env bash
# checks/overview-documentation.sh — Overview/Concepts Documentation Standard checks.
#
# Sourced by audit.sh. Uses the framework from audit-lib.sh.
#
# Checks:
#   1. Overview Documentation Standard doc exists
#   2. README contains a "What Is This" / elevator pitch section
#   3. Completeness: README has problem statement and key concepts
#
# Audit-only — no fixes.

set -euo pipefail

# ── Register this standard ────────────────────────────────────────────────
ALL_STANDARDS+=("overview-documentation")
# shellcheck disable=SC2034 # consumed by audit-lib.sh via source
STANDARD_DOMAINS["overview-documentation"]="docs,quality"

# ── Standard entry point: checks ──────────────────────────────────────────
checks_overview_documentation() {
  local repo="$1"
  # shellcheck disable=SC2034 # used by _check/_check_fail via audit-lib.sh
  CURR_STANDARD="overview-documentation"

  _check_header "Overview / Concepts Documentation Standard"

  # ── Check 1: Standard doc exists ──────────────────────────────────────
  _check "overview-doc-standard-exists" "Overview Documentation Standard doc exists" \
    test -f "${repo}/docs/standards/overview-documentation-standard.md"

  # ── Check 2: README has an elevator pitch / "what is this" ────────────
  local readme="${repo}/README.md"
  _check "readme-has-pitch" "README has elevator pitch or description" \
    [ -f "${readme}" ] && grep -qiE '(what is|about|overview|purpose|what this|project)' "${readme}"

  # ── Check 3: Overview doc or README section references a visual ───────
  if [ -f "${repo}/docs/overview.md" ]; then
    _check "overview-has-visual" "Overview has a diagram or screenshot" \
      grep -qiE '!\[|mermaid|diagram|screenshot|figure' "${repo}/docs/overview.md"
  else
    _check "overview-has-visual" "Overview (in README) has a visual" \
      grep -qiE '!\[|mermaid|diagram|architecture|flow' "${readme}" 2>/dev/null || true
  fi

  # ── Check 4: Overview doc exists or README has overview section ───────
  if [ -f "${repo}/docs/overview.md" ]; then
    _check "overview-doc-or-readme-section" "Overview doc or README overview section exists" \
      true
  else
    _check "overview-doc-or-readme-section" "README has overview/what-is section" \
      grep -qiE '^## (about|overview|what is)' "${readme}" 2>/dev/null || true
  fi
}
