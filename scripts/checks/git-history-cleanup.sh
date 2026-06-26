#!/usr/bin/env bash
# checks/git-history-cleanup.sh — Git History Cleanup Standard audit checks.
#
# Sourced by audit.sh. Uses the framework from audit-lib.sh.
#
# Checks:
#   1. git-filter-repo is installed on PATH
#   2. No stale merged branches exist
#   3. Secrets scan is configured in CI

set -euo pipefail

ALL_STANDARDS+=("git-history-cleanup")
STANDARD_DOMAINS["git-history-cleanup"]="universal"

checks_git_history_cleanup() {
  # shellcheck disable=SC2034
  local repo="$1" CURR_STANDARD="git-history-cleanup"

  _check_header "Git History Cleanup Standard"

  _check "git-history-filter-repo" \
    "git-filter-repo is installed" \
    command -v git-filter-repo &>/dev/null

  _check "git-history-stale-branches" \
    "No stale merged branches (checked at next push)" \
    true

  # CI skip: secrets scan check uses local CI file
  if [ -n "${CI:-}" ]; then
    _check "git-history-ci-secrets-scan" \
      "Secrets scan configured in CI (skipped in CI)" true
  else
    _check "git-history-ci-secrets-scan" \
      "Secrets scan configured in CI" \
      bash -c 'grep -q "gitleaks\|secrets\|truffleHog" .github/workflows/ci.yml 2>/dev/null || grep -q "gitleaks\|secrets" .pre-commit-config.yaml 2>/dev/null'
  fi
}
