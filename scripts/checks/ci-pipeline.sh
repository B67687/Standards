#!/usr/bin/env bash
# checks/ci-pipeline.sh — CI Pipeline Standard checks.
#
# Sourced by audit.sh. Uses the framework from audit-lib.sh.
#
# Checks:
#   1. .pre-commit-config.yaml exists at repo root
#   2. .github/workflows/ directory exists
#   3. At least one workflow file (.yml/.yaml) in .github/workflows/
#   4. .commitlintrc.json exists at repo root
#   5. Gitleaks referenced in .pre-commit-config.yaml or .github/workflows/
#   6. At least one workflow file contains both build and test steps

set -euo pipefail

# ── Register this standard ────────────────────────────────────────────────
ALL_STANDARDS+=("ci-pipeline")
# shellcheck disable=SC2034 # consumed by audit-lib.sh via source
STANDARD_DOMAINS["ci-pipeline"]="backend,infra"

# ── Standard entry point: checks (audit-only, no fix functions) ───────────
checks_ci_pipeline() {
  local repo="$1"
  # shellcheck disable=SC2034 # used by _check/_check_fail via audit-lib.sh
  CURR_STANDARD="ci-pipeline"

  _check_header "CI Pipeline Standard"

  # ── Check 1: .pre-commit-config.yaml or lefthook.yml exists ───────────
  local has_hook_manager=false
  if [ -f "${repo}/.pre-commit-config.yaml" ] || [ -f "${repo}/lefthook.yml" ]; then
    has_hook_manager=true
  fi
  _check "hook-manager-config" \
    ".pre-commit-config.yaml or lefthook.yml exists at repo root" \
    test "${has_hook_manager}" = true

  # ── Check 2: .github/workflows/ directory exists ───────────────────────
  _check "github-workflows-dir" ".github/workflows/ directory exists" \
    test -d "${repo}/.github/workflows"

  # ── Check 3: Workflow files present ────────────────────────────────────
  local wf_count=0
  if [ -d "${repo}/.github/workflows" ]; then
    while IFS= read -r -d '' f; do
      wf_count=$((wf_count + 1))
    done < <(find "${repo}/.github/workflows" -maxdepth 1 \( -name '*.yml' -o -name '*.yaml' \) -print0 2>/dev/null || true)
    _check "workflow-files-present" \
      "At least one workflow file in .github/workflows/ (found ${wf_count})" \
      test "${wf_count}" -ge 1
  else
    _check_fail "workflow-files-present" \
      "At least one workflow file in .github/workflows/ — directory not found"
  fi

  # ── Check 4: .commitlintrc.json exists ─────────────────────────────────
  _check "commitlint-config" ".commitlintrc.json exists at repo root" \
    test -f "${repo}/.commitlintrc.json"

  # ── Check 5: Secrets scanning configured (gitleaks or trivy) ───────────
  local secrets_found=false
  # Check in pre-commit config
  if [ -f "${repo}/.pre-commit-config.yaml" ] && \
     grep -qi 'gitleaks' "${repo}/.pre-commit-config.yaml" 2>/dev/null; then
    secrets_found=true
  fi
  # Check in lefthook config
  if [ "${secrets_found}" = false ] && [ -f "${repo}/lefthook.yml" ] && \
     grep -qiE '(gitleaks|trivy.*secret)' "${repo}/lefthook.yml" 2>/dev/null; then
    secrets_found=true
  fi
  # Check in CI workflows
  if [ "${secrets_found}" = false ] && [ -d "${repo}/.github/workflows" ]; then
    while IFS= read -r -d '' f; do
      if grep -qiE '(gitleaks|trivy.*secret)' "$f" 2>/dev/null; then
        secrets_found=true
        break
      fi
    done < <(find "${repo}/.github/workflows" -maxdepth 1 \( -name '*.yml' -o -name '*.yaml' \) -print0 2>/dev/null || true)
  fi
  _check "secrets-scanning-configured" \
    "Secrets scanning (gitleaks or trivy) configured in hooks or CI" \
    test "${secrets_found}" = true

  # ── Check 6: L1 build + test in workflows ──────────────────────────────
  local has_build_test=false
  if [ -d "${repo}/.github/workflows" ]; then
    while IFS= read -r -d '' f; do
      if grep -qE '(run.*build|dotnet\s+build)' "$f" 2>/dev/null && \
         grep -qE '(run.*test|dotnet\s+test)' "$f" 2>/dev/null; then
        has_build_test=true
        break
      fi
    done < <(find "${repo}/.github/workflows" -maxdepth 1 \( -name '*.yml' -o -name '*.yaml' \) -print0 2>/dev/null || true)
    _check "l1-build-test" \
      "At least one workflow file contains both build and test steps" \
      test "${has_build_test}" = true
  else
    _check_fail "l1-build-test" \
      "At least one workflow file contains both build and test steps — directory not found"
  fi
}
