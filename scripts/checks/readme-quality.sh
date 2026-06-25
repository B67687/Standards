#!/usr/bin/env bash
# checks/readme-quality.sh — README Quality Standard checks.
#
# Sourced by audit.sh. Uses the framework from audit-lib.sh.
#
# Checks:
#   1. readme-exists:     README.md exists at repo root
#   2. badges-section:    Badge references pointing to docs/badges/
#   3. ai-attribution-line: AI attribution mention present
#   4. quick-start-section: Quick Start or Getting Started section
#   5. license-section:   License section
#   6. centered-title:    Title wrapped in centered div
#   7. section-order:     README section order against standard (agent eval)
#   8. description-quality: Description ≤120 chars and clear (agent eval)
#   9. split-threshold:   README complexity and split threshold (agent eval)

set -euo pipefail

# ── Register this standard ────────────────────────────────────────────────
ALL_STANDARDS+=("readme-quality")

# ── Helper: JSON-encode a string value using jq or manual escaping ────────
# Falls back to sed-based escaping when jq is not available.
_json_str() {
  local val="$1"
  if command -v jq &>/dev/null; then
    jq -c -n --arg s "${val}" '$s'
  else
    # Manual JSON string escaping for when jq is not available
    local escaped
    escaped="$(printf '%s' "${val}" | sed 's/["\\]/\\&/g; s/\t/\\t/g; s/\n/\\n/g')"
    printf '"%s"' "${escaped}"
  fi
}

# ── Standard entry point: checks ──────────────────────────────────────────
checks_readme_quality() {
  local repo="${1:-${REPO_PATH}}"
  [ -n "${repo}" ] || repo="${PWD}"
  # shellcheck disable=SC2034 # used by _check/_check_fail/_check_pending via audit-lib.sh
  CURR_STANDARD="readme-quality"

  _check_header "${CURR_STANDARD}"

  # ── Check 1: README exists ─────────────────────────────────────────────
  _check "readme-exists" "README.md file exists at repo root" \
    test -f "${repo}/README.md"

  # ── Check 2: Badges section references docs/badges/ ────────────────────
  if [ ! -f "${repo}/README.md" ]; then
    _check_fail "badges-section" "Badge section with docs/badges/ references (not found)"
  else
    _check "badges-section" "README.md contains badge references pointing to docs/badges/" \
      grep -q 'docs/badges/' "${repo}/README.md" 2>/dev/null
  fi

  # ── Check 3: AI attribution line ───────────────────────────────────────
  if [ ! -f "${repo}/README.md" ]; then
    _check_fail "ai-attribution-line" "AI attribution mention in README.md (not found)"
  else
    _check "ai-attribution-line" "README.md contains AI attribution mention" \
      grep -qiE 'AI (assistance|attribution|assisted|generated)|CREDITS\.md' "${repo}/README.md" 2>/dev/null
  fi

  # ── Check 4: Quick Start section ───────────────────────────────────────
  if [ ! -f "${repo}/README.md" ]; then
    _check_fail "quick-start-section" "Quick Start or Getting Started section (not found)"
  else
    _check "quick-start-section" "README.md has a Quick Start or Getting Started section" \
      grep -qiE '^## (Quick Start|Getting Started)' "${repo}/README.md" 2>/dev/null
  fi

  # ── Check 5: License section ───────────────────────────────────────────
  if [ ! -f "${repo}/README.md" ]; then
    _check_fail "license-section" "License section in README.md (not found)"
  else
    _check "license-section" "README.md has a License section" \
      grep -qiE '^## License' "${repo}/README.md" 2>/dev/null
  fi

  # ── Check 6: Centered title ──────────────────────────────────────────────
  if [ ! -f "${repo}/README.md" ]; then
    _check_fail "centered-title" "README title wrapped in centered div (not found)"
  else
    _check "centered-title" "README title wrapped in <div align=\"center\">" \
      grep -qE '<div\s+align="?center"?>' "${repo}/README.md" 2>/dev/null
  fi

  # ── Check 7: Section order (agent eval) ────────────────────────────────
  if [ ! -f "${repo}/README.md" ]; then
    _check_fail "section-order" "README section order follows standard (not found)"
  else
    local eval_dir
    eval_dir="$(_agent_eval_dir)"
    cat > "${eval_dir}/readme-quality-section-order.json" << AGENTJSON
{
  "schema_version": 1,
  "standard": "readme-quality",
  "check": "section-order",
  "repo": $(_json_str "${repo}"),
  "target": "README.md",
  "prompt": "Evaluate whether README.md follows the standard section order. The standard order is: 1. Title (H1), 2. Tech Badges (CI, language/tech stack, license), 3. Short Description, 4. AI Attribution + AI Model Badges ('Built with AI assistance' then model/harness badges), 5. Screenshots/Demo (apps only), 6. Table of Contents (>100 lines), 7. Features, 8. Quick Start, 9. Usage, 10. Architecture, 11. Contributing, 12. Optional sections, 13. Changelog link, 14. License (LAST). Which sections are present, which are missing, which are out of order?",
  "context": {
    "readme_path": $(_json_str "${repo}/README.md"),
    "readme_exists": true
  }
}
AGENTJSON
    _agent_eval_check "${CURR_STANDARD}" "section-order" "README section order follows standard"
  fi

  # ── Check 8: Description quality (agent eval) ──────────────────────────
  if [ ! -f "${repo}/README.md" ]; then
    _check_fail "description-quality" "README description is clear and ≤120 chars (not found)"
  else
    local eval_dir
    eval_dir="$(_agent_eval_dir)"
    cat > "${eval_dir}/readme-quality-description-quality.json" << AGENTJSON
{
  "schema_version": 1,
  "standard": "readme-quality",
  "check": "description-quality",
  "repo": $(_json_str "${repo}"),
  "target": "README.md",
  "prompt": "Evaluate the README description: Is it ≤120 characters? Is it clear and actionable? Does it explain what the project does and why it exists? Rate: pass/fail.",
  "context": {
    "readme_path": $(_json_str "${repo}/README.md")
  }
}
AGENTJSON
    _agent_eval_check "${CURR_STANDARD}" "description-quality" "README description is clear and ≤120 chars"
  fi

  # ── Check 9: Split threshold (agent eval) ──────────────────────────────
  if [ ! -f "${repo}/README.md" ]; then
    _check_fail "split-threshold" "README complexity and split threshold (not found)"
  else
    local eval_dir
    eval_dir="$(_agent_eval_dir)"
    cat > "${eval_dir}/readme-quality-split-threshold.json" << AGENTJSON
{
  "schema_version": 1,
  "standard": "readme-quality",
  "check": "split-threshold",
  "repo": $(_json_str "${repo}"),
  "target": "README.md",
  "prompt": "Evaluate whether README.md should be split. Criteria: >300 lines, or has complex architecture/API content that would be better in separate files (ARCHITECTURE.md, API.md, etc.). Should this README be split?",
  "context": {
    "readme_path": $(_json_str "${repo}/README.md"),
    "line_count": $(test -f "${repo}/README.md" && wc -l < "${repo}/README.md" || echo "0")
  }
}
AGENTJSON
    _agent_eval_check "${CURR_STANDARD}" "split-threshold" "README complexity and split threshold"
  fi
}
