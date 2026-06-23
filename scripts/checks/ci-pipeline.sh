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

# ── Standard entry point: checks (audit-only, no fix functions) ───────────
checks_ci_pipeline() {
  local repo="$1"
  # shellcheck disable=SC2034 # used by _check/_check_fail via audit-lib.sh
  CURR_STANDARD="ci-pipeline"

  _check_header "CI Pipeline Standard"

  # ── Check 1: .pre-commit-config.yaml exists ────────────────────────────
  _check "pre-commit-config" ".pre-commit-config.yaml exists at repo root" \
    test -f "${repo}/.pre-commit-config.yaml"

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

  # ── Check 5: Gitleaks configured ───────────────────────────────────────
  local gitleaks_found=false
  if [ -f "${repo}/.pre-commit-config.yaml" ] && \
     grep -q 'gitleaks' "${repo}/.pre-commit-config.yaml" 2>/dev/null; then
    gitleaks_found=true
  fi
  if [ "${gitleaks_found}" = false ] && [ -d "${repo}/.github/workflows" ]; then
    while IFS= read -r -d '' f; do
      if grep -q 'gitleaks' "$f" 2>/dev/null; then
        gitleaks_found=true
        break
      fi
    done < <(find "${repo}/.github/workflows" -maxdepth 1 \( -name '*.yml' -o -name '*.yaml' \) -print0 2>/dev/null || true)
  fi
  _check "gitleaks-configured" \
    "Gitleaks referenced in .pre-commit-config.yaml or .github/workflows/" \
    test "${gitleaks_found}" = true

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
