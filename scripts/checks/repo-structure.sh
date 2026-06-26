#!/usr/bin/env bash
# checks/repo-structure.sh — Repository Structure Standard checks.
#
# Sourced by audit.sh. Uses the framework from audit-lib.sh.
#
# Checks:
#   1. docs/ directory exists at repo root
#   2. scripts/ directory exists at repo root
#   3. .editorconfig file exists at repo root
#   4. docs/badges/ directory exists
#   5. docs/adr/ directory exists
#   6. Taskfile.yml or Makefile exists at repo root (task runner)
#   7. Repo type detection (informational)

set -euo pipefail

# ── Register this standard ────────────────────────────────────────────────
ALL_STANDARDS+=("repo-structure")
STANDARD_DOMAINS["repo-structure"]="universal"

# ── Standard entry point: checks ──────────────────────────────────────────
checks_repo_structure() {
  local repo="$1"
  # shellcheck disable=SC2034 # used by _check/_check_fail via audit-lib.sh
  CURR_STANDARD="repo-structure"

  _check_header "Repository Structure Standard"

  # ── Check 1: docs/ exists ──────────────────────────────────────────────
  _check "docs-dir-exists" "docs/ directory exists at repo root" \
    test -d "${repo}/docs"

  # ── Check 2: scripts/ exists ───────────────────────────────────────────
  _check "scripts-dir-exists" "scripts/ directory exists at repo root" \
    test -d "${repo}/scripts"

  # ── Check 3: .editorconfig exists ──────────────────────────────────────
  _check "editorconfig-exists" ".editorconfig file exists at repo root" \
    test -f "${repo}/.editorconfig"

  # ── Check 4: docs/badges/ exists ───────────────────────────────────────
  _check "badges-dir-exists" "docs/badges/ directory exists" \
    test -d "${repo}/docs/badges"

  # ── Check 5: docs/adr/ exists ──────────────────────────────────────────
  _check "adr-dir-exists" "docs/adr/ directory exists" \
    test -d "${repo}/docs/adr"

  # ── Check 6: Taskfile.yml or Makefile exists ──────────────────────────
  _check "task-runner" \
    "Taskfile.yml or Makefile exists at repo root (task runner)" \
    test -f "${repo}/Taskfile.yml" -o -f "${repo}/Makefile"

  # ── Check 7: Repo type detection (informational) ───────────────────────
  local repo_type="Config/Shell"
  local type_hint=""
  if [ -d "${repo}/src" ]; then
    repo_type="Library"
    type_hint="has src/"
  elif [ -d "${repo}/app" ] && [ -d "${repo}/gradle" ]; then
    repo_type="Application"
    type_hint="has app/ and gradle/"
  elif [ -d "${repo}/.github/workflows" ]; then
    repo_type="CI-enabled"
    type_hint="has .github/workflows/"
  elif [ -d "${repo}/content" ] && [ -d "${repo}/themes" ]; then
    repo_type="Documentation"
    type_hint="has content/ and themes/"
  else
    type_hint="no specific indicators"
  fi
  _check "repo-type-detection" \
    "Repo type detected: ${repo_type} (${type_hint})" \
    test 1 = 1
}
