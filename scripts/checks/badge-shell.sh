#!/usr/bin/env bash
# checks/badge-shell.sh — Badge Standard shell-checkable checks.
#
# Sourced by audit.sh. Uses the framework from audit-lib.sh.
#
# Checks:
#   1. docs/badges/ directory exists at repo root
#   2. Badge count ≤ 6
#   3. All SVG file names are kebab-case
#   4. README.md contains a dynamic shields.io CI badge URL
#   5. No empty SVG files (0 bytes)

set -euo pipefail

# ── Register this standard ────────────────────────────────────────────────
ALL_STANDARDS+=("badge-shell")
STANDARD_DOMAINS["badge-shell"]="docs"

# ── Standard entry point: checks ──────────────────────────────────────────
checks_badge_shell() {
  local repo="$1"
  # shellcheck disable=SC2034 # used by _check/_check_fail via audit-lib.sh
  CURR_STANDARD="badge-shell"

  _check_header "Badge Standard"

  # ── Check 1: docs/badges/ exists ────────────────────────────────────────
  _check "badges-dir-exists" "docs/badges/ directory exists at repo root" \
    test -d "${repo}/docs/badges"

  # ── Check 2: badge count ≤ 6 ────────────────────────────────────────────
  if [ -d "${repo}/docs/badges" ]; then
    local badge_count
    badge_count=$(find "${repo}/docs/badges" -maxdepth 1 -name '*.svg' 2>/dev/null | wc -l)
    badge_count=$((badge_count))
    _check "badge-count" \
      "Badge count: ${badge_count} (max 6)" \
      test "${badge_count}" -le 6
  else
    _check_fail "badge-count" \
      "Badge count: cannot check (docs/badges/ not found)"
  fi

  # ── Check 3: SVG names are kebab-case (^[a-z][a-z0-9-]*\.svg$) ──────────
  if [ -d "${repo}/docs/badges" ]; then
    local invalid_names=0
    local svg_file basename
    while IFS= read -r svg_file; do
      basename=$(basename "${svg_file}")
      if ! [[ "${basename}" =~ ^[a-z][a-z0-9-]*\.svg$ ]]; then
        invalid_names=$((invalid_names + 1))
      fi
    done < <(find "${repo}/docs/badges" -maxdepth 1 -name '*.svg' 2>/dev/null || true)
    _check "badge-names-kebab" \
      "All SVG file names are kebab-case" \
      test "${invalid_names}" -eq 0
  else
    _check_fail "badge-names-kebab" \
      "SVG file names: cannot check (docs/badges/ not found)"
  fi

  # ── Check 4: CI badge URL in README ─────────────────────────────────────
  if [ -f "${repo}/README.md" ]; then
    _check "ci-badge-url" \
      "README.md contains dynamic shields.io CI badge URL" \
      grep -qE 'github\.com.*actions/workflows.*badge\.svg' "${repo}/README.md" 2>/dev/null
  else
    _check_fail "ci-badge-url" \
      "CI badge URL: cannot check (README.md not found)"
  fi

  # ── Check 5: no empty SVGs (0 bytes) ────────────────────────────────────
  if [ -d "${repo}/docs/badges" ]; then
    local empty_count
    empty_count=$(find "${repo}/docs/badges" -name '*.svg' -empty 2>/dev/null | wc -l)
    empty_count=$((empty_count))
    _check "no-empty-svgs" \
      "No empty SVG files (0 bytes)" \
      test "${empty_count}" -eq 0
  else
    _check_fail "no-empty-svgs" \
      "Empty SVG check: cannot check (docs/badges/ not found)"
  fi
}
