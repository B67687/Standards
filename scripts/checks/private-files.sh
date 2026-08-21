#!/usr/bin/env bash
# checks/private-files.sh — Private-file (publicness) Standard audit checks.
#
# Sourced by audit.sh. Uses the framework from audit-lib.sh.
#
# Audit-only — no fixes.
#
# Purpose: enforces the public/private boundary so that agent-workspace and
# secret files never leak into a public tree.  A tracked private path here is
# a FAIL because it means the file can be pushed to a public remote.
#
# Private paths detected via `git ls-files`:
#   .omo/           agent workspace (NEVER tracked — zero .omo on public)
#   secrets         .env / .env.* (env config), *.pem, *.key, secrets/
#                   NOTE: .env.enc* (sops/age-encrypted env) is SAFE to track
#                   and excluded; so is .env.example.
#   agent sessions  ses_*.json, .omo/run-continuation
#
# Checks:
#   1. No .omo/ content is tracked (zero .omo on public)
#   2. No secret files are tracked (.env/.env.*, *.pem, *.key, secrets/)
#   3. No agent-session/run-continuation files are tracked (ses_*.json)
#   4. Repo declares the public/private contract (has an AGENTS.md or README note)

set -euo pipefail

# ── Register this standard ────────────────────────────────────────────────
ALL_STANDARDS+=("private-files")

# ── Standard entry point: checks ──────────────────────────────────────────
checks_private_files() {
  local repo="$1"
  # shellcheck disable=SC2034 # used by _check/_check_fail via audit-lib.sh
  CURR_STANDARD="private-files"

  _check_header "Private-File (Publicness) Standard"

  # ── Check 1: No .omo/ content tracked (zero .omo on public) ─────────────
  local omo_leaks
  omo_leaks="$(cd "${repo}" && git ls-files '.omo/' 2>/dev/null || true)"
  _check "omo-private-not-tracked" \
    "No .omo/ content tracked (zero .omo on public)" \
    test -z "${omo_leaks}"

  # ── Check 2: No secret files tracked ────────────────────────────────────
  # Flag .env / .env.* env config, *.pem, *.key, and secrets/ dirs.
  # Allow .env.example and .env.enc* (sops/age encrypted env is safe to track).
  local secret_leaks
  secret_leaks="$(cd "${repo}" && git ls-files 2>/dev/null | \
    grep -E '(^|/)(\.env([.]|$)|secrets/|.*[.]pem$|.*[.]key$)' | \
    grep -v '\.env\.example$' | grep -v '\.env\.enc' || true)"
  _check "secrets-not-tracked" \
    "No secret files tracked (.env/.env.*, *.pem, *.key, secrets/)" \
    test -z "${secret_leaks}"

  # ── Check 3: No agent-session/run-continuation files tracked ───────────
  local session_leaks
  session_leaks="$(cd "${repo}" && git ls-files 2>/dev/null | grep -E 'ses_[A-Za-z0-9]+[.]json|(^|/)run-continuation/' || true)"
  _check "agent-sessions-not-tracked" \
    "No agent-session/run-continuation files tracked (ses_*.json, run-continuation/)" \
    test -z "${session_leaks}"

  # ── Check 4: Public/private contract declared ──────────────────────────
  _check "privacy-contract-declared" \
    "Repo declares public/private contract (AGENTS.md or README privacy note)" \
      bash -c "cd '${repo}' && { [ -f AGENTS.md ] && grep -qiE 'never (commit|public)|\.omo/' AGENTS.md; } || { [ -f README.md ] && grep -qiE 'private|\.omo/|never public' README.md; }"
}
