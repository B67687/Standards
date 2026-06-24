#!/usr/bin/env bash
# checks/auto-commit-gitops.sh — Auto-Commit GitOps Standard checks.
#
# Sourced by audit.sh. Uses the framework from audit-lib.sh.
#
# Checks (all operate on GLOBAL git config, NOT per-repo):
#   1. ~/.config/git/ai-commit-hooks/ directory exists
#   2. All 4 hook files present (pre-commit, prepare-commit-msg, commit-msg, pre-push)
#   3. Global core.hooksPath is configured correctly
#   4. Git aliases ca, car, ai-commit exist globally
#   5. Global commit.gpgsign is true
#
# Audit-only — no fix functions.

set -euo pipefail

# ── Register this standard ────────────────────────────────────────────────
ALL_STANDARDS+=("auto-commit-gitops")

# ── Standard entry point: checks ──────────────────────────────────────────
checks_auto_commit_gitops() {
  local repo="$1"
  # shellcheck disable=SC2034 # used by _check/_check_fail via audit-lib.sh
  CURR_STANDARD="auto-commit-gitops"
  # shellcheck disable=SC2034 # $repo is unused — all checks are global
  : "${repo}"

  # Self-consistency guard: skip checks during inner audit to avoid
  # circular dependency (auto-commit-gitops checks hook files that may
  # not exist in a CI/audit-only context).
  if [ "${SELF_CONSISTENCY_ACTIVE:-}" = "1" ]; then
    return 0
  fi

  local hooks_dir="${HOME}/.config/git/ai-commit-hooks"

  _check_header "Auto-Commit GitOps Standard"

  # ── Check 1: hooks directory exists ────────────────────────────────────
  _check "hooks-dir-exists" \
    "${HOME}/.config/git/ai-commit-hooks/ directory exists" \
    test -d "${hooks_dir}"

  # ── Check 2: hook files present ────────────────────────────────────────
  if [ -d "${hooks_dir}" ]; then
    local hook_count=0
    for hook in pre-commit prepare-commit-msg commit-msg pre-push; do
      if [ -f "${hooks_dir}/${hook}" ]; then
        hook_count=$((hook_count + 1))
      fi
    done
    _check "hook-files-present" \
      "All 4 hook files present (found ${hook_count}/4)" \
      test "${hook_count}" -eq 4
  else
    _check_fail "hook-files-present" "Hooks directory not found"
  fi

  # ── Check 3: global core.hooksPath configured ──────────────────────────
  _check "hooks-path-configured" \
    "Global core.hooksPath points to ai-commit-hooks directory" \
    bash -c 'h="$(git config --global --get core.hooksPath 2>/dev/null)"; expanded="${h/#\~/${HOME}}"; [ "${expanded}" = "${HOME}/.config/git/ai-commit-hooks" ]'

  # ── Check 4: git aliases configured ────────────────────────────────────
  _check "git-aliases-configured" \
    "Git aliases ca, car, ai-commit configured globally" \
    bash -c 'git config --global --get-regexp "^alias\." 2>/dev/null | grep -q "^alias\.ca " && git config --global --get-regexp "^alias\." 2>/dev/null | grep -q "^alias\.car " && git config --global --get-regexp "^alias\." 2>/dev/null | grep -q "^alias\.ai-commit "'

  # ── Check 5: commit signing enabled ────────────────────────────────────
  _check "commit-signing-enabled" \
    "Global commit.gpgsign is true" \
    test "$(git config --global --get commit.gpgsign 2>/dev/null || true)" = "true"
}
