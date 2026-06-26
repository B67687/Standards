#!/usr/bin/env bash
# checks/trivy-secrets.sh — Trivy Secrets Scanning Standard checks.
#
# Sourced by audit.sh. Uses the framework from audit-lib.sh.
#
# Checks:
#   1. .trivyignore exists at repo root (for false positive suppression)
#   2. .trivyignore.yaml exists at repo root (for path-aware suppression)
#   3. trivy referenced in .github/workflows/ workflow files
#   4. --scanners secret flag configured in a workflow file
#   5. --skip-dirs or ignore file path patterns configured

set -euo pipefail

# ── Register this standard ────────────────────────────────────────────────
ALL_STANDARDS+=("trivy-secrets")
STANDARD_DOMAINS["trivy-secrets"]="security"

# ── Helper: detect gitleaks alternative ──────────────────────────────────
_trivy_has_gitleaks() {
  local repo="$1"
  if [ -f "${repo}/.pre-commit-config.yaml" ] && \
     grep -qi 'gitleaks' "${repo}/.pre-commit-config.yaml" 2>/dev/null; then
    return 0
  fi
  local lf_config=""
  for lf in lefthook.yml .lefthook.yml lefthook.yaml .lefthook.yaml; do
    if [ -f "${repo}/${lf}" ]; then
      lf_config="${repo}/${lf}"
      break
    fi
  done
  if [ -n "${lf_config}" ] && grep -qi 'gitleaks' "${lf_config}" 2>/dev/null; then
    return 0
  fi
  if [ -d "${repo}/.github/workflows" ]; then
    while IFS= read -r -d '' f; do
      if grep -qi 'gitleaks' "$f" 2>/dev/null; then
        return 0
      fi
    done < <(find "${repo}/.github/workflows" -maxdepth 1 \( -name '*.yml' -o -name '*.yaml' \) -print0 2>/dev/null || true)
  fi
  return 1
}

# ── Standard entry point: checks (audit-only, no fix functions) ───────────
checks_trivy_secrets() {
  local repo="$1"
  # shellcheck disable=SC2034 # used by _check/_check_fail via audit-lib.sh
  CURR_STANDARD="trivy-secrets"

  _check_header "Trivy Secrets Scanning Standard"

  # ── Alternative: gitleaks is also valid ─────────────────────────────────
  if _trivy_has_gitleaks "${repo}"; then
    _check "trivy-ignore-exists" \
      "gitleaks used for secrets scanning (alternative to trivy)" \
      test 1 = 1
    _check "trivy-ignore-yaml-exists" \
      "gitleaks handles secret suppression natively" \
      test 1 = 1
    _check "trivy-in-ci" \
      "gitleaks configured for secrets scanning in CI or hooks" \
      test 1 = 1
    _check "secrets-scanner-in-ci" \
      "gitleaks configured as secret scanner (alternative to trivy)" \
      test 1 = 1
    _check "skip-dirs-configured" \
      "gitleaks handles path exclusion natively" \
      test 1 = 1
    return 0
  fi

  # ── Check 1: .trivyignore exists ───────────────────────────────────────
  _check "trivy-ignore-exists" \
    ".trivyignore exists at repo root (for false positive suppression)" \
    test -f "${repo}/.trivyignore"

  # ── Check 2: .trivyignore.yaml exists ──────────────────────────────────
  _check "trivy-ignore-yaml-exists" \
    ".trivyignore.yaml exists at repo root (for path-aware suppression)" \
    test -f "${repo}/.trivyignore.yaml"

  # ── Check 3: trivy referenced in CI workflows ──────────────────────────
  local trivy_in_ci=false
  if [ -d "${repo}/.github/workflows" ]; then
    while IFS= read -r -d '' f; do
      if grep -q 'trivy' "$f" 2>/dev/null; then
        trivy_in_ci=true
        break
      fi
    done < <(find "${repo}/.github/workflows" -maxdepth 1 \( -name '*.yml' -o -name '*.yaml' \) -print0 2>/dev/null || true)
    _check "trivy-in-ci" \
      "At least one workflow file in .github/workflows/ references trivy" \
      test "${trivy_in_ci}" = true
  else
    _check_fail "trivy-in-ci" \
      "No .github/workflows/ directory found — trivy likely not configured in CI"
  fi

  # ── Check 4: --scanners secret configured in CI ────────────────────────
  local secrets_scanner_in_ci=false
  if [ -d "${repo}/.github/workflows" ]; then
    while IFS= read -r -d '' f; do
      if grep -q -- '--scanners\s\+secret' "$f" 2>/dev/null; then
        secrets_scanner_in_ci=true
        break
      fi
    done < <(find "${repo}/.github/workflows" -maxdepth 1 \( -name '*.yml' -o -name '*.yaml' \) -print0 2>/dev/null || true)
    _check "secrets-scanner-in-ci" \
      "At least one workflow file uses --scanners secret for trivy secrets scan" \
      test "${secrets_scanner_in_ci}" = true
  else
    _check_fail "secrets-scanner-in-ci" \
      "No .github/workflows/ directory found — secrets scanner likely not configured in CI"
  fi

  # ── Check 5: Skip dirs or ignore path patterns configured ──────────────
  # Check ignore files for content, or workflow for --skip-dirs
  local skip_dirs_configured=false

  # Check .trivyignore for non-empty content (path patterns)
  if [ -f "${repo}/.trivyignore" ] && [ -s "${repo}/.trivyignore" ]; then
    skip_dirs_configured=true
  fi

  # Check .trivyignore.yaml for non-empty content (path patterns)
  if [ "${skip_dirs_configured}" = false ] && \
     [ -f "${repo}/.trivyignore.yaml" ] && [ -s "${repo}/.trivyignore.yaml" ]; then
    skip_dirs_configured=true
  fi

  # Check workflows for --skip-dirs flag
  if [ "${skip_dirs_configured}" = false ] && [ -d "${repo}/.github/workflows" ]; then
    while IFS= read -r -d '' f; do
      if grep -q -- '--skip-dirs' "$f" 2>/dev/null; then
        skip_dirs_configured=true
        break
      fi
    done < <(find "${repo}/.github/workflows" -maxdepth 1 \( -name '*.yml' -o -name '*.yaml' \) -print0 2>/dev/null || true)
  fi

  _check "skip-dirs-configured" \
    "Path exclusions configured via .trivyignore, .trivyignore.yaml, or --skip-dirs in workflow" \
    test "${skip_dirs_configured}" = true
}
