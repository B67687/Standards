#!/usr/bin/env bash
# checks/link-rot.sh — Link Rot Standard audit checks.
#
# Sourced by audit.sh. Uses the framework from audit-lib.sh.
#
# Checks:
#   1. lychee is installed on PATH
#   2. lychee has been run recently (lychee cache exists, advisory)
#   3. .lycheeignore exists for known exclusions
#   4. Link check is configured in CI (*.yml references lychee)
#
# Audit-only — no fixes.

set -euo pipefail

# ── Register this standard ────────────────────────────────────────────────
ALL_STANDARDS+=("link-rot")
# shellcheck disable=SC2034 # consumed by audit-lib.sh via source
STANDARD_DOMAINS["link-rot"]="docs,infra"

# ── Standard entry point ──────────────────────────────────────────────────
checks_link_rot() {
  local repo="$1"
  # shellcheck disable=SC2034 # used by _check/_check_fail via audit-lib.sh
  CURR_STANDARD="link-rot"

  _check_header "Link Rot Standard"

  # ── Check 1: lychee installed ─────────────────────────────────────────
  _check "lychee-installed" "lychee is installed on PATH" \
    command -v lychee &>/dev/null

  # ── Check 2: lychee cache exists (advisory — shows it's been run) ─────
  _check "lychee-cache" "lychee cache file exists (.lycheecache)" \
    test -f "${repo}/.lycheecache"

  # ── Check 3: .lycheeignore exists ─────────────────────────────────────
  _check "lychee-ignore" ".lycheeignore exists for known exclusions" \
    test -f "${repo}/.lycheeignore"

  # ── Check 4: Link check in CI ─────────────────────────────────────────
  local ci_found=false
  if [ -d "${repo}/.github/workflows" ]; then
    if grep -rq 'lychee' "${repo}/.github/workflows/" 2>/dev/null; then
      ci_found=true
    fi
  fi
  _check "lychee-ci" "Link check is configured in CI" "${ci_found}"
}
