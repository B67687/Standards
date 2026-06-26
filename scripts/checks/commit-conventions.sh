#!/usr/bin/env bash
# checks/commit-conventions.sh — Commit Conventions Standard checks.
#
# Sourced by audit.sh. Uses the framework from audit-lib.sh.
#
# Checks:
#   1. Branch name matches type/description format (feat|fix|refactor|docs|chore|experiment)
#   2. Last 5 commit subjects each ≤ 100 characters
#   3. Last 5 commit types are in allowed set
#   4. Last 5 commit subjects don't end with a period
#   5. Breaking changes are properly marked with '!' or BREAKING CHANGE:
#   6. At least one recent commit is signed (GPG/SSH)

set -euo pipefail

# ── Register this standard ────────────────────────────────────────────────
ALL_STANDARDS+=("commit-conventions")
# shellcheck disable=SC2034 # consumed by audit-lib.sh via source
STANDARD_DOMAINS["commit-conventions"]="universal"

# ── Standard entry point: checks ──────────────────────────────────────────
checks_commit_conventions() {
  local repo="$1"
  # shellcheck disable=SC2034 # used by _check/_check_fail via audit-lib.sh
  CURR_STANDARD="commit-conventions"

  _check_header "Commit Conventions Standard"

  # ── Check 1: Branch naming ─────────────────────────────────────────────
  # Branch must match: type/description-kebab-case
  local branch_name
  branch_name="$(cd "${repo}" && git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
  if [ "${branch_name}" = "HEAD" ] || [ -z "${branch_name}" ]; then
    _check_fail "branch-naming" \
      "Branch name matches 'type/description-kebab-case' — detached HEAD or unable to determine"
  else
    _check "branch-naming" \
      "Branch name '${branch_name}' matches 'type/description-kebab-case'" \
      bash -c '[[ "$1" =~ ^(main|master|develop)$|^(feat|fix|refactor|docs|chore|experiment)/[a-z0-9-]+$ ]]' -- "${branch_name}"
  fi

  # ── Check 2: Subject length ≤ 100 chars ────────────────────────────────
  local subjects
  subjects="$(cd "${repo}" && git log --format="%s" -5 2>/dev/null || true)"
  if [ -z "${subjects}" ]; then
    _check_fail "subject-length" "Commit subject length ≤ 100 characters — no commits found"
  else
    local has_long=false
    while IFS= read -r subject; do
      [ -z "${subject}" ] && continue
      if [ "${#subject}" -gt 100 ]; then
        has_long=true
        break
      fi
    done <<< "${subjects}"
    _check "subject-length" \
      "Last 5 commit subjects each ≤ 100 characters" \
      test "${has_long}" = false
  fi

  # ── Check 3: Commit type in allowed set ────────────────────────────────
  local subjects2
  subjects2="$(cd "${repo}" && git log --format="%s" -5 2>/dev/null || true)"
  if [ -z "${subjects2}" ]; then
    _check_fail "commit-type" "Commit type in allowed set — no commits found"
  else
    local invalid_found=false
    while IFS= read -r subject; do
      [ -z "${subject}" ] && continue
      # Skip merge commits (e.g. "Merge branch 'feature'")
      if echo "${subject}" | grep -qE '^Merge '; then
        continue
      fi
      # Extract type: first lowercase word before '(' or ':' (case-insensitive)
      local ctype
      ctype="$(echo "${subject}" | tr '[:upper:]' '[:lower:]' | sed -n 's/^\([a-z]\+\).*/\1/p')"
      if [ -n "${ctype}" ]; then
        if ! echo "${ctype}" | grep -qE '^(feat|fix|docs|refactor|perf|test|chore|cleanup|security|revert)$'; then
          invalid_found=true
        fi
      else
        # No parseable type — invalid
        invalid_found=true
      fi
    done <<< "${subjects2}"
    _check "commit-type" \
      "Last 5 commit types in allowed set (feat|fix|docs|refactor|perf|test|chore|cleanup|security|revert)" \
      test "${invalid_found}" = false
  fi

  # ── Check 4: No trailing period ────────────────────────────────────────
  local subjects3
  subjects3="$(cd "${repo}" && git log --format="%s" -5 2>/dev/null || true)"
  if [ -z "${subjects3}" ]; then
    _check_fail "no-trailing-period" "No trailing period in subjects — no commits found"
  else
    local has_trailing_dot=false
    while IFS= read -r subject; do
      [ -z "${subject}" ] && continue
      if echo "${subject}" | grep -qE '\.$'; then
        has_trailing_dot=true
        break
      fi
    done <<< "${subjects3}"
    _check "no-trailing-period" \
      "Last 5 commit subjects don't end with '.'" \
      test "${has_trailing_dot}" = false
  fi

  # ── Check 5: Breaking change marker ────────────────────────────────────
  # Look for '!' before ':' in subject (e.g. "feat(scope)!:") or
  # "BREAKING CHANGE:" in the full commit body.
  local has_breaking=false
  if (cd "${repo}" && git log --format="%s" -5 2>/dev/null | grep -qE '!:' 2>/dev/null); then
    has_breaking=true
  fi
  if ! ${has_breaking}; then
    if (cd "${repo}" && git log --format="%B" -5 2>/dev/null | grep -q 'BREAKING CHANGE:' 2>/dev/null); then
      has_breaking=true
    fi
  fi
  if ${has_breaking}; then
    _check "breaking-change-marker" \
      "Breaking changes are properly marked with '!' or 'BREAKING CHANGE:'" \
      true
  else
    _check "breaking-change-marker" \
      "No breaking changes detected (or no commits in range)" \
      true
  fi

  # ── Check 6: Signed commits ────────────────────────────────────────────
  # At least one recent commit should be GPG/SSH signed.
  if [ -n "${CI:-}" ]; then
    _check "signed-commits" "At least one recent commit is signed (skipped in CI)" true
  else
    local sig_check
    sig_check="$(cd "${repo}" && git log --format="%GG" -1 2>/dev/null || true)"
    if [ -n "${sig_check}" ]; then
      if echo "${sig_check}" | grep -qiE "(Signature made|Good.*signature)" 2>/dev/null; then
        _check "signed-commits" "At least one recent commit is signed" true
      else
        _check "signed-commits" "At least one recent commit is signed" false
      fi
    else
      _check "signed-commits" "At least one recent commit is signed" false
    fi
  fi
}
