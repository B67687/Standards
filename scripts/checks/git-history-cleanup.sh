#!/usr/bin/env bash
# checks/git-history-cleanup.sh — Git History Cleanup Standard checks.
#
# Sourced by audit.sh. Uses the framework from audit-lib.sh.
#
# This standard is primarily a workflow guide, but these checks verify
# that the tooling infrastructure and prevention layers are in place.
#
# Checks:
#   1. git-filter-repo is available (the primary cleanup tool)
#   2. Gitleaks is configured in pre-commit or CI (prevention layer)
#   3. Pre-commit is installed and configured (prevention layer)
#   4. No obsolete filter-branch references in repo config
#   5. No obviously large files in git history (potential bloat signal)

set -euo pipefail

# ── Register this standard ────────────────────────────────────────────────
ALL_STANDARDS+=("git-history-cleanup")

# ── Standard entry point: checks ──────────────────────────────────────────
checks_git_history_cleanup() {
  local repo="$1"
  # shellcheck disable=SC2034 # used by _check/_check_fail via audit-lib.sh
  CURR_STANDARD="git-history-cleanup"
  local precommit_config="${repo}/.pre-commit-config.yaml"

  _check_header "Git History Cleanup Standard"

  # ── Check 1: git-filter-repo available ─────────────────────────────────
  local filter_repo_found=false
  if command -v git-filter-repo &>/dev/null; then
    filter_repo_found=true
  elif python3 -c "import git_filter_repo" 2>/dev/null; then
    filter_repo_found=true
  fi
  _check "filter-repo-available" \
    "git-filter-repo is available for history cleanup" \
    "${filter_repo_found}"

  # ── Check 2: Gitleaks in pre-commit ────────────────────────────────────
  if [ -f "${precommit_config}" ]; then
    _check "gitleaks-precommit" \
      "Gitleaks configured in .pre-commit-config.yaml" \
      grep -qE 'gitleaks' "${precommit_config}"
  else
    _check_fail "gitleaks-precommit" \
      "No .pre-commit-config.yaml found — missing gitleaks prevention layer"
  fi

  # ── Check 3: Pre-commit or lefthook installed ──────────────────────────
  _check "precommit-installed" \
    "Pre-commit or lefthook is installed" \
    bash -c 'command -v pre-commit &>/dev/null || command -v lefthook &>/dev/null'

  # ── Check 4: No filter-branch references ───────────────────────────────
  # git filter-branch is deprecated; warn if it's referenced anywhere
  local has_filter_branch=false
  if [ -d "${repo}/.git" ]; then
    if git -C "${repo}" config --get-regexp 'filter-branch' &>/dev/null 2>&1; then
      has_filter_branch=true
    fi
  fi
  _check "no-filter-branch" \
    "No deprecated git filter-branch references in config" \
    test "${has_filter_branch}" = false

  # ── Check 5: No large objects in git history ───────────────────────────
  # Quick signal: check for any single object >10MB in recent history
  local has_large_objects=false
  if command -v git &>/dev/null && [ -d "${repo}/.git" ]; then
    local large_count
    large_count="$(git -C "${repo}" rev-list --all --objects 2>/dev/null | \
      git -C "${repo}" cat-file --batch-check='%(objecttype) %(objectsize:disk)' 2>/dev/null | \
      awk '/^blob/ { if ($2 > 10485760) print }' | wc -l 2>/dev/null || echo 0)"
    if [ "${large_count}" -gt 0 ]; then
      has_large_objects=true
    fi
  fi
  _check "no-large-objects" \
    "No single object >10MB in git history (potential bloat signal)" \
    test "${has_large_objects}" = false
}
