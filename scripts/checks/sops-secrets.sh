#!/usr/bin/env bash
# checks/sops-secrets.sh — SOPS/age Secrets Management Standard checks.
#
# Sourced by audit.sh. Uses the framework from audit-lib.sh.
#
# Checks:
#   1. .sops.yaml exists at repo root (sops config)
#   2. .gitignore contains .env pattern (so .env is never committed)
#   3. .env.encrypted (or any .sops / .enc.yaml / .encrypted file) is tracked by git
#   4. .gitattributes contains sopsdiffer or textconv config (cleartext diffs)
#   5. sops binary is on PATH (informational)
#   6. age binary is on PATH (informational)
#
# Audit-only — no fixes.

set -euo pipefail

# ── Register this standard ────────────────────────────────────────────────
ALL_STANDARDS+=("sops-secrets")
# shellcheck disable=SC2034 # consumed by audit-lib.sh via source
STANDARD_DOMAINS["sops-secrets"]="security"

# ── Standard entry point: checks ──────────────────────────────────────────
checks_sops_secrets() {
  local repo="$1"
  # shellcheck disable=SC2034 # used by _check/_check_fail via audit-lib.sh
  CURR_STANDARD="sops-secrets"

  _check_header "SOPS/age Secrets Management Standard"

  # ── Check 1: .sops.yaml exists at repo root ───────────────────────────
  _check "sops-config-exists" ".sops.yaml exists at repo root" \
    test -f "${repo}/.sops.yaml"

  # ── Check 2: .gitignore contains .env pattern ─────────────────────────
  if [ -f "${repo}/.gitignore" ]; then
    _check "env-in-gitignore" \
      ".gitignore contains .env pattern (to prevent committing secrets)" \
      grep -qE '(^|/)\.env([^a-z]|$)' "${repo}/.gitignore"
  else
    _check_fail "env-in-gitignore" ".gitignore not found"
  fi

  # ── Check 3: Encrypted env file tracked by git ────────────────────────
  # Searches for any tracked file matching .sops, .enc.yaml, .encrypted patterns.
  local enc_count=0
  if [ -d "${repo}/.git" ]; then
    # shellcheck disable=SC2034 # f used only for counting
    while IFS= read -r -d '' f; do
      enc_count=$((enc_count + 1))
    done < <(bash -c "cd '${repo}' && git ls-files -z -- '*.sops*' '*.enc.yaml' '*.encrypted' '.env.encrypted' 2>/dev/null || true")
    _check "encrypted-env-tracked" \
      "Encrypted secrets file tracked by git (found ${enc_count})" \
      test "${enc_count}" -ge 1
  else
    _check_fail "encrypted-env-tracked" "Not a git repository"
  fi

  # ── Check 4: .gitattributes contains sopsdiffer or textconv ───────────
  if [ -f "${repo}/.gitattributes" ]; then
    _check "gitattributes-diff" \
      ".gitattributes contains sopsdiffer or textconv config for cleartext diffs" \
      grep -qE 'sopsdiffer|textconv' "${repo}/.gitattributes"
  else
    _check_fail "gitattributes-diff" ".gitattributes not found"
  fi

  # ── Check 5: sops binary on PATH (informational) ──────────────────────
  _check "sops-installed" "sops binary is on PATH (tool availability)" \
    bash -c 'command -v sops &>/dev/null'

  # ── Check 6: age binary on PATH (informational) ───────────────────────
  _check "age-installed" "age binary is on PATH (tool availability)" \
    bash -c 'command -v age &>/dev/null'
}
