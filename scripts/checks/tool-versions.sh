#!/usr/bin/env bash
# checks/tool-versions.sh — Tool Version Standard audit checks.
#
# Sourced by audit.sh. Uses the framework from audit-lib.sh.
#
# Checks:
#   1. mise.toml or .mise.toml exists at repo root
#   2. File contains [tools] section header
#   3. File has min_version setting
#   4. File has [env] section (optional but nice-to-have)
#   5. mise.toml is tracked by git

set -euo pipefail

# ── Register this standard ────────────────────────────────────────────────
ALL_STANDARDS+=("tool-versions")

# ── Standard entry point: checks ──────────────────────────────────────────
checks_tool_versions() {
  local repo="$1"
  # shellcheck disable=SC2034 # used by _check/_check_fail via audit-lib.sh
  CURR_STANDARD="tool-versions"

  _check_header "Tool Version Standard"

  # ── Determine which mise config file exists ────────────────────────────
  # mise.toml is canonical; .mise.toml is also accepted for backward compat.
  local mise_file=""
  local mise_basename=""
  if [ -f "${repo}/mise.toml" ]; then
    mise_file="${repo}/mise.toml"
    mise_basename="mise.toml"
  elif [ -f "${repo}/.mise.toml" ]; then
    mise_file="${repo}/.mise.toml"
    mise_basename=".mise.toml"
  fi

  # ── Check 1: mise.toml exists ──────────────────────────────────────────
  _check "mise-toml-exists" \
    "mise.toml (or .mise.toml) exists at repo root" \
    test -f "${repo}/mise.toml" -o -f "${repo}/.mise.toml"

  # ── Check 2: [tools] section ───────────────────────────────────────────
  if [ -n "${mise_file}" ]; then
    _check "tools-section" \
      "mise.toml contains [tools] section" \
      grep -qE '^\[tools\]' "${mise_file}"
  else
    _check_fail "tools-section" "mise.toml not found"
  fi

  # ── Check 3: min_version ───────────────────────────────────────────────
  if [ -n "${mise_file}" ]; then
    _check "min-version" \
      "mise.toml has min_version setting" \
      grep -qE '^min_version\s*=' "${mise_file}"
  else
    _check_fail "min-version" "mise.toml not found"
  fi

  # ── Check 4: [env] section ─────────────────────────────────────────────
  if [ -n "${mise_file}" ]; then
    _check "env-section" \
      "mise.toml has [env] section (optional)" \
      grep -qE '^\[env\]' "${mise_file}"
  else
    _check_fail "env-section" "mise.toml not found"
  fi

  # ── Check 5: tracked by git ────────────────────────────────────────────
  if [ -n "${mise_basename}" ]; then
    # Use wrapper to suppress git error messages without redirecting _check output
    _check "mise-toml-tracked" \
      "mise.toml is tracked by git" \
      bash -c 'git -C "$1" ls-files --error-unmatch "$2" >/dev/null 2>&1' _ "${repo}" "${mise_basename}"
  else
    _check_fail "mise-toml-tracked" "mise.toml not found"
  fi
}
