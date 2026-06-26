#!/usr/bin/env bash
# checks/svg-screenshots.sh — SVG Screenshot Standard checks.
#
# Sourced by audit.sh. Uses the framework from audit-lib.sh.
#
# Checks:
#   1. docs/screenshots/ directory exists at repo root
#   2. At least 1 SVG screenshot file present in docs/screenshots/
#   3. SVG screenshot quality assessment (agent eval)
#   4. Dark mode support via <picture> tags in README (agent eval)
#   5. viewBox proportions in SVG screenshots (agent eval)

set -euo pipefail

# ── Register this standard ────────────────────────────────────────────────
ALL_STANDARDS+=("svg-screenshots")
STANDARD_DOMAINS["svg-screenshots"]="docs"

# ── Standard entry point: checks ──────────────────────────────────────────
checks_svg_screenshots() {
  local repo="$1"
  # shellcheck disable=SC2034 # used by _check/_check_fail via audit-lib.sh
  CURR_STANDARD="svg-screenshots"

  _check_header "SVG Screenshot Standard"

  # ── Check 1: screenshots dir exists ─────────────────────────────────────
  _check "screenshots-dir-exists" \
    "docs/screenshots/ directory exists at repo root" \
    test -d "${repo}/docs/screenshots"

  # ── Check 2: at least one SVG screenshot present ────────────────────────
  local svg_count=0
  if [ -d "${repo}/docs/screenshots" ]; then
    svg_count=$(find "${repo}/docs/screenshots" -maxdepth 1 -name '*.svg' 2>/dev/null | wc -l)
    svg_count=$((svg_count))
  fi
  _check "screenshot-naming" \
    "SVG screenshots present (${svg_count} files)" \
    test "${svg_count}" -ge 1

  # ── Build screenshot file list for agent eval JSONs ─────────────────────
  local eval_dir
  eval_dir="$(_agent_eval_dir)"
  local ss_list="[]"
  if [ -d "${repo}/docs/screenshots" ]; then
    ss_list="["
    local first=true
    local f
    for f in "${repo}"/docs/screenshots/*.svg; do
      [ -f "${f}" ] || continue
      ${first} || ss_list+=","
      first=false
      ss_list+="$(jq -c -n --arg s "$(basename "${f}")" '$s')"
    done
    ss_list+="]"
  fi

  # ── Check 3: SVG quality (agent eval) ───────────────────────────────────
  cat > "${eval_dir}/svg-screenshots-svg-quality.json" << AGENTJSON
{
  "schema_version": 1,
  "standard": "svg-screenshots",
  "check": "svg-quality",
  "repo": $(jq -c -n --arg s "${repo}" '$s'),
  "target": "docs/screenshots/",
  "prompt": "Evaluate the quality of SVG screenshots in docs/screenshots/. For CLI terminal SVGs: are they captured with svg-term-cli or vhs? Do they have dark backgrounds (#1a1a2e) with light text? For mobile/UI SVGs: are they at appropriate resolution? For web SVGs: are they 1200px standard width? Overall quality assessment: pass/fail.",
  "context": {
    "screenshots_dir": "${repo}/docs/screenshots",
    "screenshot_files": ${ss_list}
  }
}
AGENTJSON
  _agent_eval_check "${CURR_STANDARD}" "svg-quality" "SVG screenshot quality assessment"

  # ── Check 4: Dark mode via <picture> tags (agent eval) ──────────────────
  cat > "${eval_dir}/svg-screenshots-dark-mode.json" << AGENTJSON
{
  "schema_version": 1,
  "standard": "svg-screenshots",
  "check": "dark-mode",
  "repo": $(jq -c -n --arg s "${repo}" '$s'),
  "target": "README.md",
  "prompt": "Evaluate whether screenshots in README.md support dark mode via the <picture> tag with prefers-color-scheme media query. Check: (1) Does README use <picture> tags for screenshots? (2) Are both light and dark variants provided? (3) Is the prefers-color-scheme media query used correctly? Standard pattern: <picture><source media=\"(prefers-color-scheme: dark)\" srcset=\"...dark.svg\"><img src=\"...svg\" alt=\"...\"></picture>",
  "context": {
    "readme_path": "${repo}/README.md"
  }
}
AGENTJSON
  _agent_eval_check "${CURR_STANDARD}" "dark-mode" "Screenshot dark mode via <picture> tags"

  # ── Check 5: viewBox proportions (agent eval) ───────────────────────────
  cat > "${eval_dir}/svg-screenshots-viewbox-proportions.json" << AGENTJSON
{
  "schema_version": 1,
  "standard": "svg-screenshots",
  "check": "viewbox-proportions",
  "repo": $(jq -c -n --arg s "${repo}" '$s'),
  "target": "docs/screenshots/",
  "prompt": "Evaluate viewBox proportions in SVG screenshots. Check: (1) Does each SVG have a viewBox attribute? (2) Are the proportions realistic for the content type (tall for phone screens ~1080x2302, wide for web ~1200x800, standard for terminal ~800x600)? (3) Are there any SVGs with zero-width or zero-height viewBox? List any issues.",
  "context": {
    "screenshots_dir": "${repo}/docs/screenshots",
    "screenshot_files": ${ss_list}
  }
}
AGENTJSON
  _agent_eval_check "${CURR_STANDARD}" "viewbox-proportions" "SVG viewBox proportions"
}
