#!/usr/bin/env bash
# checks/github-topics.sh — GitHub Topics Standard audit checks.
#
# Sourced by audit.sh. Uses the framework from audit-lib.sh.
#
# Checks:
#   1. gh CLI is installed
#   2. Repository has 4-8 GitHub topics
#   3. All topics are lowercase kebab-case
#   4. Repo name appears in the topics list
#   5. No empty or whitespace-only topics
#
# Audit-only — no fix functions.

set -euo pipefail

# ── Register this standard ────────────────────────────────────────────────
ALL_STANDARDS+=("github-topics")
# shellcheck disable=SC2034 # consumed by audit-lib.sh via source
STANDARD_DOMAINS["github-topics"]="docs"

# ── Standard entry point: checks ──────────────────────────────────────────
checks_github_topics() {
  local repo="$1"
  # shellcheck disable=SC2034 # used by _check/_check_fail via audit-lib.sh
  CURR_STANDARD="github-topics"

  _check_header "GitHub Topics Standard"

  # CI skip: gh CLI is not available on CI runners, and topics can't be
  # managed from CI — skip all checks.
  if [ -n "${CI:-}" ]; then
    _check "gh-cli-installed" "gh CLI is installed (skipped in CI)" true
    _check "topics-count" "Repository has 4-8 topics (skipped in CI)" true
    _check "topics-format" "All topics are lowercase kebab-case (skipped in CI)" true
    _check "first-topic-name" "Repo name appears in topics (skipped in CI)" true
    _check "no-empty-topics" "No empty or whitespace-only topics (skipped in CI)" true
    return 0
  fi

  # ── Prerequisites ─────────────────────────────────────────────────────
  local gh_available=false
  local remote_available=false
  local repo_full_name=""
  local repo_name=""

  command -v gh &>/dev/null && gh_available=true

  local remote_url=""
  remote_url="$(git -C "$repo" remote get-url origin 2>/dev/null || true)"
  if [ -n "$remote_url" ]; then
    remote_available=true
    # Strip .git suffix
    remote_url="${remote_url%.git}"
    # Extract owner/repo (handles both SSH: git@github.com:owner/repo and HTTPS: https://github.com/owner/repo)
    repo_full_name="$(echo "$remote_url" | sed 's|.*[/:]\([^/]*/[^/]*\)$|\1|')"
    # Extract repo name (last path component)
    repo_name="$(echo "$repo_full_name" | sed 's|.*/||')"
  fi

  # ── Fetch remote topics via gh ─────────────────────────────────────────
  local topics=()
  if $gh_available && [ -n "$repo_full_name" ]; then
    while IFS= read -r topic; do
      [ -n "$topic" ] && topics+=("$topic")
    done < <(gh repo view --json repositoryTopics --jq '.repositoryTopics[].name' "${repo_full_name}" 2>/dev/null || true)
  fi
  local topics_count="${#topics[@]}"

  # Determine graceful-skip messages
  local skip_reason=""
  if ! $gh_available; then
    skip_reason="gh CLI not installed"
  elif ! $remote_available; then
    skip_reason="No git remote origin found"
  fi

  # ── Check 1: gh CLI installed ─────────────────────────────────────────
  _check "gh-cli-installed" "gh CLI is installed" hash gh 2>/dev/null

  # ── Check 2: topics-count (4-8) ───────────────────────────────────────
  if [ -n "$skip_reason" ]; then
    _check_fail "topics-count" "Repository has 4-8 topics (${skip_reason})"
  else
    _check "topics-count" \
      "Repository has 4-8 topics (found ${topics_count})" \
      test "${topics_count}" -ge 4 -a "${topics_count}" -le 8
  fi

  # ── Check 3: topics-format (lowercase kebab-case) ──────────────────────
  if [ -n "$skip_reason" ]; then
    _check_fail "topics-format" "All topics are lowercase kebab-case (${skip_reason})"
  else
    local all_valid=true
    local invalid_topic=""
    for topic in "${topics[@]}"; do
      if ! [[ "$topic" =~ ^[a-z][a-z0-9-]*$ ]]; then
        all_valid=false
        invalid_topic="$topic"
        break
      fi
    done
    if $all_valid; then
      _check "topics-format" \
        "All topics are lowercase kebab-case" \
        true
    else
      _check_fail "topics-format" \
        "Topic '${invalid_topic}' is not lowercase kebab-case"
    fi
  fi

  # ── Check 4: first-topic-name (repo name in topics) ────────────────────
  if [ -n "$skip_reason" ]; then
    _check_fail "first-topic-name" "Repo name appears in topics (${skip_reason})"
  else
    local has_name=false
    local repo_name_lower
    repo_name_lower="$(echo "$repo_name" | tr '[:upper:]' '[:lower:]')"
    for topic in "${topics[@]}"; do
      if [ "$topic" = "$repo_name_lower" ]; then
        has_name=true
        break
      fi
    done
    _check "first-topic-name" \
      "Repo name '${repo_name_lower}' appears in topics list" \
      test "$has_name" = true
  fi

  # ── Check 5: no-empty-topics ──────────────────────────────────────────
  if [ -n "$skip_reason" ]; then
    _check_fail "no-empty-topics" "No empty or whitespace-only topics (${skip_reason})"
  else
    local has_empty=false
    for topic in "${topics[@]}"; do
      if [ -z "$(echo "$topic" | tr -d '[:space:]')" ]; then
        has_empty=true
        break
      fi
    done
    _check "no-empty-topics" \
      "No empty or whitespace-only topics" \
      test "$has_empty" = false
  fi
}
