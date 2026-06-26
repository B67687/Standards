#!/usr/bin/env bash
# checks/naming-conventions.sh — Naming Conventions Standard checks.
#
# Sourced by audit.sh. Uses the framework from audit-lib.sh.
#
# Checks:
#   1. Top-level directories use kebab-case (excluding standard exceptions)
#   2. Script files in scripts/ use kebab-case with .sh extension
#   3. Badge files in docs/badges/ use kebab-case with .svg extension
#   4. Workflow files in .github/workflows/ use kebab-case with .yml extension
#   5. No directory names contain uppercase letters
#
# Audit-only — no fixes.

set -euo pipefail

# ── Register this standard ────────────────────────────────────────────────
ALL_STANDARDS+=("naming-conventions")
# shellcheck disable=SC2034 # consumed by audit-lib.sh via source
STANDARD_DOMAINS["naming-conventions"]="universal"

# ── Standard entry point: checks ──────────────────────────────────────────
checks_naming_conventions() {
  local repo="$1"
  # shellcheck disable=SC2034 # used by _check/_check_fail via audit-lib.sh
  CURR_STANDARD="naming-conventions"

  _check_header "Naming Conventions Standard"

  # ── Check 1: Top-level directories use kebab-case ──────────────────────
  local violations=false
  local dir
  while IFS= read -r dir; do
    [ "${dir}" = "${repo}" ] && continue
    local base
    base="$(basename "${dir}")"
    # Skip standard exceptions
    case "${base}" in
      .git|.github|.omo|src|app|content|node_modules) continue ;;
    esac
    if ! [[ "${base}" =~ ^[a-z][a-z0-9-]*$ ]]; then
      violations=true
    fi
  done < <(find "${repo}" -maxdepth 1 -type d 2>/dev/null || true)
  _check "top-level-dirs-kebab" \
    "Top-level directories use kebab-case" \
    test "${violations}" = false

  # ── Check 2: Script files in scripts/ use kebab-case ──────────────────
  violations=false
  if [ -d "${repo}/scripts" ]; then
    local script
    while IFS= read -r script; do
      local base
      base="$(basename "${script}")"
      # Allow standard scripts
      [ "${base}" = "audit.sh" ] && continue
      if ! [[ "${base}" =~ ^[a-z][a-z0-9-]*\.sh$ ]]; then
        violations=true
      fi
    done < <(find "${repo}/scripts" -maxdepth 1 -name '*.sh' 2>/dev/null || true)
  fi
  _check "scripts-kebab" \
    "Script files in scripts/ use kebab-case with .sh extension" \
    test "${violations}" = false

  # ── Check 3: Badge files in docs/badges/ use kebab-case ────────────────
  violations=false
  if [ -d "${repo}/docs/badges" ]; then
    local svg
    while IFS= read -r svg; do
      local base
      base="$(basename "${svg}")"
      if ! [[ "${base}" =~ ^[a-z][a-z0-9-]*\.svg$ ]]; then
        violations=true
      fi
    done < <(find "${repo}/docs/badges" -maxdepth 1 -name '*.svg' 2>/dev/null || true)
  fi
  _check "badge-files-kebab" \
    "Badge files in docs/badges/ use kebab-case with .svg extension" \
    test "${violations}" = false

  # ── Check 4: Workflow files in .github/workflows/ use kebab-case ──────
  violations=false
  if [ -d "${repo}/.github/workflows" ]; then
    local wf
    while IFS= read -r wf; do
      local base
      base="$(basename "${wf}")"
      if ! [[ "${base}" =~ ^[a-z][a-z0-9-]*\.yml$ ]]; then
        violations=true
      fi
    done < <(find "${repo}/.github/workflows" -maxdepth 1 -name '*.yml' 2>/dev/null || true)
  fi
  _check "workflow-files-kebab" \
    "Workflow files in .github/workflows/ use kebab-case with .yml extension" \
    test "${violations}" = false

  # ── Check 5: No directory names contain uppercase letters ──────────────
  violations=false
  while IFS= read -r dir; do
    [ "${dir}" = "${repo}" ] && continue
    local base
    base="$(basename "${dir}")"
    # Skip standard source directories
    case "${base}" in
      .git|src|app|content|node_modules) continue ;;
    esac
    if echo "${base}" | grep -qE '[A-Z]'; then
      violations=true
    fi
  done < <(find "${repo}" -maxdepth 2 -type d ! -path '*/.git/*' 2>/dev/null || true)
  _check "no-uppercase-dirs" \
    "No directory names contain uppercase letters" \
    test "${violations}" = false
}
