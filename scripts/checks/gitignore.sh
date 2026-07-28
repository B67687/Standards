#!/usr/bin/env bash
# checks/gitignore.sh — .gitignore (gitaccept) Standard audit checks.
#
# Sourced by audit.sh. Uses the framework from audit-lib.sh.
#
# Audit-only — no fixes.
#
# Checks:
#   1. .gitignore exists at repo root
#   2. Contains /* whitelist pattern (block everything at root)
#   3. Has at least 3 negation (!) patterns — whitelisting common files
#   4. Contains secret/cert patterns (.env, *.pem, secrets, *.key)
#   5. Contains build artifact patterns (build/, dist/, target/, node_modules/)
#   6. .gitignore is tracked by git
#   7. .env.enc is NOT in .gitignore (should be tracked for sops/age)

set -euo pipefail

# ── Register this standard ────────────────────────────────────────────────
ALL_STANDARDS+=("gitignore")

# ── Standard entry point: checks ──────────────────────────────────────────
checks_gitignore() {
  local repo="$1"
  # shellcheck disable=SC2034 # used by _check/_check_fail via audit-lib.sh
  CURR_STANDARD="gitignore"

  _check_header ".gitignore Standard"

  # ── Check 1: .gitignore exists at repo root ────────────────────────────
  _check "gitignore-exists" ".gitignore file exists at repo root" \
    test -f "${repo}/.gitignore"

  # ── Check 2: Whitelist /* pattern ──────────────────────────────────────
  if [ -f "${repo}/.gitignore" ]; then
    _check "whitelist-pattern" \
      ".gitignore contains /* whitelist pattern (block everything at root)" \
      grep -qE '^\*$|^/\*$' "${repo}/.gitignore"
  else
    _check_fail "whitelist-pattern" ".gitignore not found"
  fi

  # ── Check 3: Root files whitelisted via negation patterns ──────────────
  if [ -f "${repo}/.gitignore" ]; then
    local neg_count
    neg_count="$(grep -c '^!' "${repo}/.gitignore" || true)"
    if [ "${neg_count}" -ge 3 ] 2>/dev/null; then
      _check "root-files-whitelisted" \
        "Has ${neg_count} negation (!) patterns — whitelisting root-level files" \
        true
    else
      _check_fail "root-files-whitelisted" \
        "Only ${neg_count:-0} negation (!) patterns found, need at least 3"
    fi
  else
    _check_fail "root-files-whitelisted" ".gitignore not found"
  fi

  # ── Check 4: Secret/cert patterns are excluded (explicitly or via whitelist) ──
  if [ -f "${repo}/.gitignore" ]; then
    local has_blocklist
    has_blocklist=false
    grep -qE '\\.env|\\*\\.pem|\\*\\*/secrets\\*|\\*\\.key' "${repo}/.gitignore" && has_blocklist=true
    local has_whitelist
    has_whitelist=false
    grep -qE '^\\*$|^/\\*$' "${repo}/.gitignore" && has_whitelist=true
    _check "secret-blacklist" \
      ".gitignore excludes secret/cert patterns (.env, *.pem, secrets, *.key)" \
      test "${has_blocklist}" = true -o "${has_whitelist}" = true
  else
    _check_fail "secret-blacklist" ".gitignore not found"
  fi

  # ── Check 5: Build artifact patterns are excluded (whitelist or explicit) ─
  if [ -f "${repo}/.gitignore" ]; then
    local has_artifacts
    has_artifacts=false
    grep -qE 'build/|dist/|target/|node_modules/' "${repo}/.gitignore" && has_artifacts=true
    local wl
    wl=false
    grep -qE '^\\*$|^/\\*$' "${repo}/.gitignore" && wl=true
    _check "build-blacklist" \
      ".gitignore excludes build artifact patterns (build/, dist/, ...)" \
      test "${has_artifacts}" = true -o "${wl}" = true
  else
    _check_fail "build-blacklist" ".gitignore not found"
  fi

  # ── Check 6: .gitignore is tracked by git ──────────────────────────────
  if [ -f "${repo}/.gitignore" ]; then
    _check "gitignore-committed" ".gitignore is tracked by git" \
      bash -c "cd '${repo}' && git ls-files --error-unmatch .gitignore &>/dev/null"
  else
    _check_fail "gitignore-committed" ".gitignore not found"
  fi

  # ── Check 7: .env.enc is NOT in .gitignore (should be tracked for sops) ──
  if [ -f "${repo}/.gitignore" ]; then
    local env_enc_count
    env_enc_count="$(grep -wcF '.env.enc' "${repo}/.gitignore" 2>/dev/null || true)"
    _check "env-enc-not-ignored" \
      ".env.enc is NOT in .gitignore (should be tracked for sops/age encryption)" \
      test "${env_enc_count}" -eq 0
  fi
}
