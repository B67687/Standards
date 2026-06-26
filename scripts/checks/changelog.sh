#!/usr/bin/env bash
# checks/changelog.sh — Changelog Standard audit checks.
#
# Sourced by audit.sh. Uses the framework from audit-lib.sh.
#
# Checks:
#   1. CHANGELOG.md exists at repo root
#   2. Has ## [Unreleased] section
#   3. Has at least 2 of the standard Keep a Changelog sections
#   4. Version headers use ISO 8601 dates (YYYY-MM-DD)
#   5. Has version comparison links at bottom
#   6. cliff.toml exists if git-cliff is referenced in CHANGELOG.md
#
# Audit-only — no fix functions.

set -euo pipefail

# ── Register this standard ────────────────────────────────────────────────
ALL_STANDARDS+=("changelog")
# shellcheck disable=SC2034 # consumed by audit-lib.sh via source
STANDARD_DOMAINS["changelog"]="docs,universal"

# ── Standard entry point: checks ──────────────────────────────────────────
checks_changelog() {
  local repo="$1"
  # shellcheck disable=SC2034 # used by _check/_check_fail via audit-lib.sh
  CURR_STANDARD="changelog"
  local changelog_file="${repo}/CHANGELOG.md"

  _check_header "Changelog Standard"

  # ── Check 1: CHANGELOG.md exists ──────────────────────────────────────
  _check "changelog-exists" "CHANGELOG.md exists at repo root" \
    test -f "${changelog_file}"

  # ── Check 2: Has [Unreleased] section ─────────────────────────────────
  if [ -f "${changelog_file}" ]; then
    _check "unreleased-section" \
      "CHANGELOG.md has ## [Unreleased] section" \
      grep -qE '^## \[Unreleased\]' "${changelog_file}"
  else
    _check_fail "unreleased-section" "CHANGELOG.md not found"
  fi

  # ── Check 3: Has at least 2 standard sections ─────────────────────────
  if [ -f "${changelog_file}" ]; then
    local section_count=0
    for section in "Added" "Fixed" "Changed" "Deprecated" "Removed" "Security"; do
      if grep -qE "^### ${section}" "${changelog_file}"; then
        section_count=$((section_count + 1))
      fi
    done
    _check "standard-sections" \
      "CHANGELOG.md has at least 2 of the standard sections (found ${section_count})" \
      test "${section_count}" -ge 2
  else
    _check_fail "standard-sections" "CHANGELOG.md not found"
  fi

  # ── Check 4: Version headers use ISO 8601 dates ───────────────────────
  if [ -f "${changelog_file}" ]; then
    _check "iso-dates" \
      "Version headers use ISO 8601 dates (YYYY-MM-DD)" \
      grep -qE '^## \[[0-9]+\.[0-9]+\.[0-9]+\] - [0-9]{4}-[0-9]{2}-[0-9]{2}' \
        "${changelog_file}"
  else
    _check_fail "iso-dates" "CHANGELOG.md not found"
  fi

  # ── Check 5: Has version comparison links ─────────────────────────────
  if [ -f "${changelog_file}" ]; then
    _check "version-links" \
      "CHANGELOG.md has version comparison links ([#.#.#]:)" \
      grep -qE '^\[[0-9]+\.[0-9]+\.[0-9]+\]:' "${changelog_file}"
  else
    _check_fail "version-links" "CHANGELOG.md not found"
  fi

  # ── Check 6: cliff.toml exists if CHANGELOG references git-cliff ──────
  if [ -f "${changelog_file}" ] && grep -qi 'cliff' "${changelog_file}" 2>/dev/null; then
    _check "cliff-config" \
      "cliff.toml exists at repo root (CHANGELOG.md references git-cliff)" \
      test -f "${repo}/cliff.toml"
  fi
}
