#!/usr/bin/env bash
# checks/badge-quality.sh — Badge Quality Standard checks (agent-based).
#
# Sourced by audit.sh. Uses the framework from audit-lib.sh.
#
# All checks require AI judgment — no direct shell pass/fail.
# Companion to badge-shell.sh (which has the shell-checkable checks).
#
# Checks:
#   1. color-accessibility — WCAG AA contrast compliance
#   2. badge-quality — SVG structure and visual quality
#   3. badge-ordering — README priority ordering compliance

set -euo pipefail

# ── Register this standard ────────────────────────────────────────────────
ALL_STANDARDS+=("badge-quality")
STANDARD_DOMAINS["badge-quality"]="docs,quality"

# ── Standard entry point: checks ──────────────────────────────────────────
checks_badge_quality() {
  local repo="$1"
  # shellcheck disable=SC2034 # used by _check/_check_fail via audit-lib.sh
  CURR_STANDARD="badge-quality"

  _check_header "${CURR_STANDARD}"

  local eval_dir
  eval_dir="$(_agent_eval_dir)"

  # Build list of badge files for agent context
  local badge_list="[]"
  if [ -d "${repo}/docs/badges" ]; then
    badge_list="["
    local first=true
    for f in "${repo}"/docs/badges/*.svg; do
      [ -f "${f}" ] || continue
      ${first} || badge_list+=","
      first=false
      badge_list+="$(jq -c -n --arg s "$(basename "${f}")" '$s')"
    done
    badge_list+="]"
  fi

  # ── Check 1: Color accessibility (WCAG AA) ─────────────────────────────
  if [ -d "${repo}/docs/badges" ]; then
    cat > "${eval_dir}/badge-quality-color-accessibility.json" << AGENTJSON
{
  "schema_version": 1,
  "standard": "badge-quality",
  "check": "color-accessibility",
  "repo": $(jq -c -n --arg s "${repo}" '$s'),
  "target": "docs/badges/",
  "prompt": "Evaluate color accessibility of SVG badges in docs/badges/. The standard convention: green #2ea44f for tech/metrics, yellow #d8b800 for license, purple #4f46e5 for DeepSeek, green #10a37f for GPT, purple #7f52ff for harness. Check: (1) Do text colors have sufficient contrast against background (WCAG AA ≥4.5:1 for normal text)? (2) Are the standard colors used for their intended categories? (3) Are there any invisible or near-invisible combinations?",
  "context": {
    "badge_dir": "${repo}/docs/badges",
    "badge_files": ${badge_list}
  }
}
AGENTJSON
    _agent_eval_check "${CURR_STANDARD}" "color-accessibility" "Badge color accessibility (WCAG AA)"
  else
    _check_fail "color-accessibility" "Missing docs/badges/ directory"
  fi

  # ── Check 2: SVG structure quality ─────────────────────────────────────
  if [ -d "${repo}/docs/badges" ]; then
    cat > "${eval_dir}/badge-quality-badge-quality.json" << AGENTJSON
{
  "schema_version": 1,
  "standard": "badge-quality",
  "check": "badge-quality",
  "repo": $(jq -c -n --arg s "${repo}" '$s'),
  "target": "docs/badges/",
  "prompt": "Evaluate the visual quality of SVG badges in docs/badges/. Check: (1) Do all badges have a proper viewBox attribute for responsive scaling? (2) Are label and value text elements correctly aligned (label left/dark, value right/colored)? (3) Are badge heights consistent across the set? (4) Is font rendering clean and readable (no clipping, proper sizing)? (5) Are there any malformed SVGs that may not render correctly?",
  "context": {
    "badge_dir": "${repo}/docs/badges",
    "badge_files": ${badge_list}
  }
}
AGENTJSON
    _agent_eval_check "${CURR_STANDARD}" "badge-quality" "SVG badge structure and visual quality"
  else
    _check_fail "badge-quality" "Missing docs/badges/ directory"
  fi

  # ── Check 3: Priority ordering in README ───────────────────────────────
  if [ -d "${repo}/docs/badges" ]; then
    cat > "${eval_dir}/badge-quality-badge-ordering.json" << AGENTJSON
{
  "schema_version": 1,
  "standard": "badge-quality",
  "check": "badge-ordering",
  "repo": $(jq -c -n --arg s "${repo}" '$s'),
  "target": "README.md",
  "prompt": "Evaluate whether badges in README.md follow the standard priority order: 1. CI status (dynamic shields.io URL), 2. Language/tech stack, 3. License, 4. AI model(s), 5. Harness/platform, 6. Metrics (tests, version, downloads). Check: (1) Is the ordering correct according to this priority? (2) Are there more than 6 badges total (violating the maximum)? (3) Is the first badge a dynamic CI status URL?",
  "context": {
    "readme_path": "${repo}/README.md",
    "badge_dir": "${repo}/docs/badges",
    "badge_files": ${badge_list}
  }
}
AGENTJSON
    _agent_eval_check "${CURR_STANDARD}" "badge-ordering" "Badge priority ordering in README"
  else
    _check_fail "badge-ordering" "Missing docs/badges/ directory"
  fi
}
