#!/usr/bin/env bash
# checks/self-consistency.sh — Self-Consistency Standard audit check.
#
# Sourced by audit.sh. Uses the framework from audit-lib.sh.
#
# Meta-standard: the standards repo must pass its own audit.
#
# Checks:
#   1. ./scripts/audit.sh --exit-code . exits 0 (self-consistency)
#
# IMPORTANT: Uses SELF_CONSISTENCY_ACTIVE env var to prevent infinite
# recursion — the check runs a full inner audit, and the inner check
# returns early when the env var is set.

set -euo pipefail

# ── Register this standard ────────────────────────────────────────────────
ALL_STANDARDS+=("self-consistency")
# shellcheck disable=SC2034 # consumed by audit-lib.sh via source
STANDARD_DOMAINS["self-consistency"]="quality,ai"

# ── Standard entry point: checks (audit-only, no fix functions) ───────────
checks_self_consistency() {
  local repo="$1"
  # shellcheck disable=SC2034 # used by _check/_check_fail via audit-lib.sh
  CURR_STANDARD="self-consistency"

  _check_header "Self-Consistency Standard"

  # ── Guard: prevent infinite recursion ──────────────────────────────────
  # This check runs a full inner audit. The inner audit sources this file
  # again, which would call checks_self_consistency recursively. The env
  # var guard makes the inner call return early.
  if [ "${SELF_CONSISTENCY_ACTIVE:-}" = "1" ]; then
    return 0
  fi
  export SELF_CONSISTENCY_ACTIVE=1

  # ── Check 1: Self-audit passes ─────────────────────────────────────────
  local audit_result=0 audit_out
  audit_out="$(mktemp)" || audit_out="/tmp/self-consistency-audit"
  bash "${repo}/scripts/audit.sh" --exit-code "${repo}" >"${audit_out}" 2>&1 \
    || audit_result=$?

  if [ "${audit_result}" -ne 0 ]; then
    echo "  Inner audit failed (exit ${audit_result}):" >&2
    tail -10 "${audit_out}" >&2
  fi
  rm -f "${audit_out}"

  _check "self-audit-passes" \
    "Standards repo passes its own audit (./scripts/audit.sh --exit-code .)" \
    test "${audit_result}" -eq 0
}
