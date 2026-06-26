#!/usr/bin/env bash
# checks/license.sh — License Standard checks.
#
# Sourced by audit.sh. Uses the framework from audit-lib.sh.
#
# Checks:
#   1. LICENSE file exists at repo root
#   2. LICENSE contains MIT License text
#   3. Copyright holder is valid (not opaque/placeholder)
#   4. Copyright year is within 2020-2026 range
#
# Audit-only — no fixes.

set -euo pipefail

# ── Register this standard ────────────────────────────────────────────────
ALL_STANDARDS+=("license")
# shellcheck disable=SC2034 # consumed by audit-lib.sh via source
STANDARD_DOMAINS["license"]="universal"

# ── Standard entry point: checks ──────────────────────────────────────────
checks_license() {
  local repo="$1"
  # shellcheck disable=SC2034 # used by _check/_check_fail via audit-lib.sh
  CURR_STANDARD="license"

  _check_header "License Standard"

  # ── Check 1: LICENSE exists at repo root ──────────────────────────────
  _check "license-file-exists" "LICENSE file exists at repo root" \
    test -f "${repo}/LICENSE"

  # ── Check 2: LICENSE contains MIT License text ────────────────────────
  if [ -f "${repo}/LICENSE" ]; then
    _check "mit-license-text" "LICENSE contains MIT License text" \
      grep -qE 'MIT License' "${repo}/LICENSE"
  else
    _check_fail "mit-license-text" "LICENSE not found"
  fi

  # ── Check 3: Copyright holder is not an opaque/placeholder name ───────
  # Rejects: B67687, "Your Name", "Author" (standalone, not "Authors")
  # Accepts: "The Agentic Workflows Authors" and any other meaningful holder
  if [ -f "${repo}/LICENSE" ]; then
    _check "copyright-holder" \
      "Copyright holder is not an opaque/placeholder name" \
      grep -vqE 'Copyright.*B67687|Copyright.*Your Name|Copyright.*\bAuthor\b' \
        "${repo}/LICENSE"
  else
    _check_fail "copyright-holder" "LICENSE not found"
  fi

  # ── Check 4: Copyright year is within valid range ─────────────────────
  if [ -f "${repo}/LICENSE" ]; then
    local year
    year="$(grep -i 'Copyright' "${repo}/LICENSE" 2>/dev/null | grep -oE '[0-9]{4}' | head -1 || true)"
    if [ -n "${year}" ] && [ "${year}" -ge 2020 ] 2>/dev/null && [ "${year}" -le 2026 ] 2>/dev/null; then
      _check "license-year" "Copyright year ${year} is within 2020-2026 range" true
    else
      _check_fail "license-year" "Copyright year '${year:-}' is not in valid range (2020-2026)"
    fi
  else
    _check_fail "license-year" "LICENSE not found"
  fi
}
