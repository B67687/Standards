#!/usr/bin/env bash
# checks/adr.sh — ADR (Architecture Decision Record) Standard audit checks.
#
# Sourced by audit.sh. Uses the framework from audit-lib.sh.
#
# Checks:
#   1. docs/adr/ directory exists at repo root
#   2. At least one .md ADR file in docs/adr/
#   3. ADR filenames follow YYYY-MM-DD-title-in-kebab-case.md pattern
#   4. Each ADR file contains **Status:** field
#   5. Each ADR file contains ## Context section
#   6. Each ADR file contains **Last Reviewed:** field
#
# Audit-only — no fix functions.

set -euo pipefail

# ── Register this standard ────────────────────────────────────────────────
ALL_STANDARDS+=("adr")
STANDARD_DOMAINS["adr"]="docs"

# ── Standard entry point: checks ──────────────────────────────────────────
checks_adr() {
  local repo="$1"
  # shellcheck disable=SC2034 # used by _check/_check_fail via audit-lib.sh
  CURR_STANDARD="adr"
  local adr_dir="${repo}/docs/adr"
  local adr_files=()
  local adr_count=0

  _check_header "ADR Standard"

  # ── Check 1: docs/adr/ directory exists ────────────────────────────────
  _check "adr-dir-exists" "docs/adr/ directory exists at repo root" \
    test -d "${adr_dir}"

  # Collect ADR files if dir exists
  if [ -d "${adr_dir}" ]; then
    while IFS= read -r -d '' f; do
      adr_files+=("${f}")
    done < <(find "${adr_dir}" -maxdepth 1 -name '*.md' -print0 2>/dev/null || true)
    adr_count="${#adr_files[@]}"
  fi

  # ── Check 2: ADR files present ─────────────────────────────────────────
  if [ -d "${adr_dir}" ]; then
    _check "adr-files-present" \
      "At least one ADR file in docs/adr/ (found ${adr_count})" \
      test "${adr_count}" -ge 1
  else
    _check_fail "adr-files-present" "docs/adr/ not found"
  fi

  # ── Check 3: ADR naming convention ─────────────────────────────────────
  if [ ! -d "${adr_dir}" ]; then
    _check_fail "adr-naming-convention" "docs/adr/ not found"
  elif [ "${adr_count}" -eq 0 ]; then
    _check_fail "adr-naming-convention" "No ADR files found"
  else
    local bad_names=""
    local f b
    for f in "${adr_files[@]}"; do
      b="$(basename "${f}")"
      if ! echo "${b}" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}-[a-z0-9-]+\.md$'; then
        bad_names="${bad_names} ${b}"
      fi
    done
    local naming_desc="All ADR filenames follow YYYY-MM-DD-title-in-kebab-case.md pattern"
    if [ -n "${bad_names}" ]; then
      naming_desc="ADR filenames do not follow naming convention:${bad_names}"
    fi
    _check "adr-naming-convention" "${naming_desc}" \
      test -z "${bad_names}"
  fi

  # ── Check 4: ADR status field ──────────────────────────────────────────
  if [ ! -d "${adr_dir}" ]; then
    _check_fail "adr-status-field" "docs/adr/ not found"
  elif [ "${adr_count}" -eq 0 ]; then
    _check_fail "adr-status-field" "No ADR files found"
  else
    local missing_status=""
    local f
    for f in "${adr_files[@]}"; do
      if ! grep -qE '\*\*Status:\*\*' "${f}" 2>/dev/null; then
        missing_status="${missing_status} $(basename "${f}")"
      fi
    done
    local status_desc="All ADR files contain **Status:** field"
    if [ -n "${missing_status}" ]; then
      status_desc="ADR files missing **Status:** field:${missing_status}"
    fi
    _check "adr-status-field" "${status_desc}" \
      test -z "${missing_status}"
  fi

  # ── Check 5: ADR context section ───────────────────────────────────────
  if [ ! -d "${adr_dir}" ]; then
    _check_fail "adr-context-section" "docs/adr/ not found"
  elif [ "${adr_count}" -eq 0 ]; then
    _check_fail "adr-context-section" "No ADR files found"
  else
    local missing_context=""
    local f
    for f in "${adr_files[@]}"; do
      if ! grep -qE '^## Context' "${f}" 2>/dev/null; then
        missing_context="${missing_context} $(basename "${f}")"
      fi
    done
    local context_desc="All ADR files contain ## Context section"
    if [ -n "${missing_context}" ]; then
      context_desc="ADR files missing ## Context section:${missing_context}"
    fi
    _check "adr-context-section" "${context_desc}" \
      test -z "${missing_context}"
  fi

  # ── Check 6: ADR last-reviewed field ──────────────────────────────────
  if [ ! -d "${adr_dir}" ]; then
    _check_fail "adr-last-reviewed" "docs/adr/ not found"
  elif [ "${adr_count}" -eq 0 ]; then
    _check_fail "adr-last-reviewed" "No ADR files found"
  else
    local missing_reviewed=""
    local f
    for f in "${adr_files[@]}"; do
      if ! grep -qE '\*\*Last Reviewed:\*\*' "${f}" 2>/dev/null; then
        missing_reviewed="${missing_reviewed} $(basename "${f}")"
      fi
    done
    local reviewed_desc="All ADR files contain **Last Reviewed:** field"
    if [ -n "${missing_reviewed}" ]; then
      reviewed_desc="ADR files missing **Last Reviewed:** field:${missing_reviewed}"
    fi
    _check "adr-last-reviewed" "${reviewed_desc}" \
      test -z "${missing_reviewed}"
  fi
}
