#!/usr/bin/env bash
# checks/architecture-documentation.sh — Architecture Documentation Standard checks.
#
# Sourced by audit.sh. Uses the framework from audit-lib.sh.
#
# Checks:
#   1. Architecture Documentation Standard doc exists
#   2. ARCHITECTURE.md or equivalent exists for code-heavy repos
#   3. Architecture doc contains a diagram
#   4. Architecture doc references technology stack
#
# Audit-only — no fixes.

set -euo pipefail

# ── Register this standard ────────────────────────────────────────────────
ALL_STANDARDS+=("architecture-documentation")
# shellcheck disable=SC2034 # consumed by audit-lib.sh via source
STANDARD_DOMAINS["architecture-documentation"]="docs,backend,infra"

# ── Standard entry point: checks ──────────────────────────────────────────
checks_architecture_documentation() {
  local repo="$1"
  # shellcheck disable=SC2034 # used by _check/_check_fail via audit-lib.sh
  CURR_STANDARD="architecture-documentation"

  _check_header "Architecture Documentation Standard"

  # ── Check 1: Standard doc exists ──────────────────────────────────────
  _check "arch-doc-standard-exists" "Architecture Documentation Standard doc exists" \
    test -f "${repo}/docs/standards/architecture-documentation-standard.md"

  # ── Check 2: Architecture doc exists for code-heavy repos ─────────────
  # Heuristic: if source dir exists, expect ARCHITECTURE.md
  local has_source=false
  for d in src app cmd pkg internal lib; do
    [ -d "${repo}/${d}" ] && has_source=true && break
  done
  if ${has_source}; then
    _check "architecture-doc-exists" "ARCHITECTURE.md or arch diagram exists" \
      test -f "${repo}/docs/ARCHITECTURE.md" || \
      grep -qiE 'architecture|component|system context' "${repo}/README.md" 2>/dev/null || true
  else
    _check "architecture-doc-exists" "ARCHITECTURE.md (not required — no source code)" \
      true
  fi

  # ── Check 3: Architecture doc contains a diagram ──────────────────────
  local arch_doc=""
  [ -f "${repo}/docs/ARCHITECTURE.md" ] && arch_doc="${repo}/docs/ARCHITECTURE.md"
  if [ -n "${arch_doc}" ]; then
    _check "arch-doc-has-diagram" "Architecture doc has a diagram" \
      grep -qiE '```(mermaid|plantuml)|!\[.*diagram\]|!\[architecture\]' "${arch_doc}"
  else
    _check "arch-doc-has-diagram" "Architecture doc (not applicable)" true
  fi

  # ── Check 4: Architecture doc references tech stack ───────────────────
  if [ -n "${arch_doc}" ]; then
    _check "arch-doc-has-tech-stack" "Architecture doc references tech stack" \
      grep -qiE '(language|framework|stack|backend|frontend|database|built with|uses|powered by)' "${arch_doc}"
  else
    _check "arch-doc-has-tech-stack" "Architecture doc (not applicable)" true
  fi
}
