#!/usr/bin/env bash
# checks/dependency-management.sh — Dependency Management Standard audit checks.
#
# Sourced by audit.sh. Uses the framework from audit-lib.sh.
#
# Checks:
#   1. Every dependency manifest has a committed lockfile
#   2. The lockfile is tracked by git (never gitignored)
#   3. .dependency-tier marker exists and is valid (T0–T3)
#   4. T2/T3 repos have a dependency bot (renovate.json or dependabot.yml)
#   5. renovate.json (if present) is valid JSON

set -euo pipefail

# ── Register this standard ────────────────────────────────────────────────
ALL_STANDARDS+=("dependency-management")

# ── Standard entry point: checks ──────────────────────────────────────────
checks_dependency_management() {
  local repo="$1"
  # shellcheck disable=SC2034 # used by _check/_check_fail via audit-lib.sh
  CURR_STANDARD="dependency-management"

  _check_header "Dependency Management Standard"

  # ── Detect manifests and their canonical lockfiles ─────────────────────
  # manifest → lockfile mapping. A repo with no manifests is docs-only and
  # the standard explicitly skips it (no lockfile/bot/tier requirements).
  local has_manifest=false


  # ── Check 1: lockfile exists for each manifest ─────────────────────────
  # package.json → package-lock.json (npm), yarn.lock, pnpm-lock.yaml
  if [ -f "${repo}/package.json" ]; then
    has_manifest=true
    _check "npm-lockfile" \
      "package.json has a committed lockfile" \
      bash -c 'test -f "$1/package-lock.json" -o -f "$1/yarn.lock" -o -f "$1/pnpm-lock.yaml"' _ "${repo}"
  fi
  # Cargo.toml → Cargo.lock
  if [ -f "${repo}/Cargo.toml" ]; then
    has_manifest=true
    _check "cargo-lockfile" \
      "Cargo.toml has a committed Cargo.lock" \
      test -f "${repo}/Cargo.lock"
  fi
  # pyproject.toml → uv.lock / poetry.lock / requirements.lock
  if [ -f "${repo}/pyproject.toml" ]; then
    has_manifest=true
    _check "python-lockfile" \
      "pyproject.toml has a committed uv.lock/poetry.lock" \
      bash -c 'test -f "$1/uv.lock" -o -f "$1/poetry.lock"' _ "${repo}"
  fi
  # go.mod → go.sum
  if [ -f "${repo}/go.mod" ]; then
    has_manifest=true
    _check "go-lockfile" \
      "go.mod has a committed go.sum" \
      test -f "${repo}/go.sum"
  fi

  # ── Check 2: lockfile tracked by git (first manifest lockfile) ─────────
  if ${has_manifest}; then
    _check "lockfile-tracked" \
      "lockfile is tracked by git" \
      bash -c 'git -C "$1" ls-files | grep -qE "(package-lock\.json|yarn\.lock|pnpm-lock\.yaml|Cargo\.lock|uv\.lock|poetry\.lock|go\.sum)$"' _ "${repo}"
  else
    _check "lockfile-tracked" \
      "docs-only repo — no lockfile required" \
      true
  fi

  # ── Check 3: .dependency-tier marker ───────────────────────────────────
  if [ -f "${repo}/.dependency-tier" ]; then
    local tier
    tier="$(tr -d '[:space:]' < "${repo}/.dependency-tier")"
    case "${tier}" in
      T0|T1|T2|T3)
        _check "tier-marker" \
          ".dependency-tier declares valid tier ${tier}" \
          true
        ;;
      *)
        _check_fail "tier-marker" ".dependency-tier contains invalid value '${tier}'"
        tier=""
        ;;
    esac
  elif ${has_manifest}; then
    # Manifest present but no marker: default is T1 per the standard.
    _check "tier-marker" \
      ".dependency-tier absent — defaults to T1 (quarterly batch)" \
      true
  else
    _check "tier-marker" \
      "docs-only repo — no tier required" \
      true
  fi

  # ── Check 4: dependency bot for T2/T3 ──────────────────────────────────
  if [ "${tier:-}" = "T2" ] || [ "${tier:-}" = "T3" ]; then
    _check "dep-bot" \
      "${tier} repo has a dependency bot (renovate.json or dependabot.yml)" \
      bash -c 'test -f "$1/renovate.json" -o -f "$1/renovate.json5" -o -f "$1/.github/dependabot.yml"' _ "${repo}"
  elif ${has_manifest}; then
    _check "dep-bot" \
      "tier ${tier:-T1} — bot optional (quarterly batch is manual)" \
      true
  fi

  # ── Check 5: renovate.json valid JSON ──────────────────────────────────
  if [ -f "${repo}/renovate.json" ]; then
    _check "renovate-json-valid" \
      "renovate.json parses as valid JSON" \
      jq empty "${repo}/renovate.json"
  elif [ -f "${repo}/renovate.json5" ]; then
    _check "renovate-json-valid" \
      "renovate.json5 present (JSON5 — skipped, validated by Renovate)" \
      true
  fi
}
