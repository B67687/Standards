#!/usr/bin/env bash
# checks/lefthook.sh — Lefthook Git Hook Manager Standard audit checks.
#
# Sourced by audit.sh. Uses the framework from audit-lib.sh.
#
# Audit-only — no fixes.
#
# Checks:
#   1. lefthook.yml or .lefthook.yml exists at repo root
#   2. Lefthook config has a pre-commit section with commands
#   3. Lefthook config has a commit-msg section
#   4. Lefthook config has parallel: true in pre-commit
#   5. lefthook binary is on PATH
#   6. Lefthook commit-msg references commitlint or conventional commit check

set -euo pipefail

# ── Register this standard ────────────────────────────────────────────────
ALL_STANDARDS+=("lefthook")

# ── Helper: resolve config path ────────────────────────────────────────────
_lefthook_config() {
  local repo="$1"
  if [ -f "${repo}/lefthook.yml" ]; then
    echo "${repo}/lefthook.yml"
  elif [ -f "${repo}/.lefthook.yml" ]; then
    echo "${repo}/.lefthook.yml"
  elif [ -f "${repo}/lefthook.yaml" ]; then
    echo "${repo}/lefthook.yaml"
  elif [ -f "${repo}/.lefthook.yaml" ]; then
    echo "${repo}/.lefthook.yaml"
  else
    echo ""
  fi
}

# ── Standard entry point: checks (audit-only, no fix functions) ───────────
checks_lefthook() {
  local repo="$1"
  # shellcheck disable=SC2034 # used by _check/_check_fail via audit-lib.sh
  CURR_STANDARD="lefthook"

  _check_header "Lefthook Standard"

  # ── Check 1: Config file exists ─────────────────────────────────────────
  local config
  config="$(_lefthook_config "${repo}")"
  _check "lefthook-config-exists" \
    "lefthook.yml or .lefthook.yml exists at repo root" \
    test -n "${config}"

  # ── Check 2: Pre-commit hooks section ───────────────────────────────────
  config="$(_lefthook_config "${repo}")"
  if [ -n "${config}" ]; then
    _check "pre-commit-hooks" \
      "Lefthook config has a pre-commit section with commands" \
      grep -qE '^pre-commit:' "${config}"
  else
    _check_fail "pre-commit-hooks" "Lefthook config not found"
  fi

  # ── Check 3: Commit-msg hook section ────────────────────────────────────
  if [ -n "${config}" ]; then
    _check "commit-msg-hook" \
      "Lefthook config has a commit-msg section" \
      grep -qE '^commit-msg:' "${config}"
  else
    _check_fail "commit-msg-hook" "Lefthook config not found"
  fi

  # ── Check 4: Parallel mode in pre-commit ────────────────────────────────
  if [ -n "${config}" ]; then
    _check "parallel-mode" \
      "Lefthook config has parallel: true in pre-commit" \
      grep -qE 'parallel:\s*true' "${config}"
  else
    _check_fail "parallel-mode" "Lefthook config not found"
  fi

  # ── Check 5: Lefthook binary installed ──────────────────────────────────
  _check "lefthook-installed" "lefthook binary is on PATH" \
    command -v lefthook &>/dev/null

  # ── Check 6: Commitlint integration ─────────────────────────────────────
  if [ -n "${config}" ]; then
    _check "commitlint-integration" \
      "Lefthook commit-msg references commitlint or conventional commit check" \
      grep -qiE 'commitlint|conventional' "${config}"
  else
    _check_fail "commitlint-integration" "Lefthook config not found"
  fi
}
