#!/usr/bin/env bash
# checks/ai-attribution.sh — AI Attribution Standard checks and fixes.
#
# Sourced by audit.sh. Uses the framework from audit-lib.sh.
#
# Checks:
#   1. CREDITS.md exists at repo root
#   2. CREDITS.md has correct 4-column table (Phase | Model | Harness | Role)
#   3. docs/badges/ directory exists
#   4. At least one badge SVG in docs/badges/
#   5. README.md mentions AI assistance
#   6. README.md references docs/badges/ SVGs
#
# Fixes (--fix / --force):
#   - Generate CREDITS.md from standard template
#   - Generate missing badge SVGs for models in CREDITS.md
#   - Insert AI attribution line in README.md

set -euo pipefail

# ── Register this standard ────────────────────────────────────────────────
ALL_STANDARDS+=("ai-attribution")
STANDARD_DOMAINS["ai-attribution"]="ai,universal"

# ── Per-model badge colours (from docs/standards/ai-attribution-standard.md) ─────────────
# Keys are lowercase prefix matches; longer prefixes tried first.
declare -A MODEL_COLORS
MODEL_COLORS["deepseek"]="4f46e5"   # indigo
MODEL_COLORS["gpt"]="10a37f"        # green
MODEL_COLORS["claude"]="d97706"     # amber
MODEL_COLORS["mimo"]="0891b2"       # cyan
MODEL_COLORS["kimi"]="7c3aed"       # violet
MODEL_COLORS["qwen"]="0ea5e9"       # sky
MODEL_COLORS["minimax"]="f43f5e"    # rose
MODEL_COLORS["glm"]="f97316"        # orange
MODEL_COLORS["harness"]="7f52ff"    # purple (for harness badges)

# ── Helper: look up badge colour by model text ────────────────────────────
_model_color() {
  local model_name="$1"
  local lower
  lower="$(echo "${model_name}" | tr '[:upper:]' '[:lower:]')"
  # Try longest prefix matches first
  for prefix in minimax deepseek claude; do
    if echo "${lower}" | grep -q "^${prefix}"; then
      echo "${MODEL_COLORS[${prefix}]}"
      return 0
    fi
  done
  # Single-word prefixes
  local first_word
  first_word="$(echo "${lower}" | awk '{print $1}')"
  if [ -n "${MODEL_COLORS[${first_word}]:-}" ]; then
    echo "${MODEL_COLORS[${first_word}]}"
    return 0
  fi
  # Default fallback colour
  echo "6b7280"  # gray-500
  return 0
}

# ── Helper: extract model list from CREDITS.md ────────────────────────────
# Returns one line per model: "brand|variant|color"
_parse_credits_models() {
  local credits_file="$1"
  local line model variant color
  while IFS= read -r line; do
    # Match table data rows: | text | text | text | text |
    # Skip header and separator rows (contain only ---, Phase, Model)
    # Match 4+ data columns: Phase | Platform | Model | Harness | Role
    if echo "${line}" | grep -qE '^\|([^|]+\|){4,}$'; then
      # Skip if it's the header row or separator row
      if echo "${line}" | grep -qiE 'Phase.*Model.*Harness.*Role|---'; then
        continue
      fi
      # Extract column 3 (model) — remove leading/trailing whitespace
      # Table format: Phase | Platform | Model | Harness | Role
      model="$(echo "${line}" | cut -d'|' -f4 | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
      [ -z "${model}" ] && continue

      # Strip reasoning level: "(max)", "(high reasoning)" etc.
      # shellcheck disable=SC2001 # sed is clearer than bash pattern for paren matching
      variant="$(echo "${model}" | sed 's/[[:space:]]*(.*)//')"
      # Extract first word as brand
      brand="$(echo "${variant}" | awk '{print $1}')"
      # Get colour
      color="$(_model_color "${model}")"
      echo "${brand}|${variant}|${color}"
    fi
  done < "${credits_file}"
}

# ── CREDITS.md template ───────────────────────────────────────────────────
_readme_credits_template() {
  cat <<'TEMPLATE'
# Credits

This project was built collaboratively. I defined the vision, architecture, and
strategic direction; AI systems contributed to implementation, research, and
design discussions, with continuous back-and-forth that often shaped the final
outcome in ways neither of us predicted alone.

## AI Contributions

| Phase | Platform | Model | Harness | Role |
|-------|----------|-------|---------|------|
| Full development | (platform name) | (model name) | (harness name) | AI: implementation, research, & discussion · Human: oversight & goals |
TEMPLATE
}

# ── Standard entry point: checks ──────────────────────────────────────────
checks_ai_attribution() {
  local repo="$1"
  # shellcheck disable=SC2034 # used by _check/_check_fail via audit-lib.sh
  CURR_STANDARD="ai-attribution"
  local credits_file="${repo}/CREDITS.md"
  local readme_file="${repo}/README.md"
  local badges_dir="${repo}/docs/badges"

  _check_header "AI Attribution Standard"

  # ── Check 1: CREDITS.md exists ─────────────────────────────────────────
  _check "credits-md-exists" "CREDITS.md exists at repo root" \
    test -f "${credits_file}"

  # ── Check 2: CREDITS.md has 5-column table ─────────────────────────────
  if [ -f "${credits_file}" ]; then
    _check "credits-md-format" \
      "CREDITS.md has 5-column table (Phase, Platform, Model, Harness, Role)" \
      grep -qE '^\|.*[Pp]hase.*\|.*[Pp]latform.*\|.*[Mm]odel.*\|.*[Hh]arness.*\|.*[Rr]ole.*\|' \
        "${credits_file}"
  else
    _check_fail "credits-md-format" "CREDITS.md not found"
  fi

  # ── Check 3: Badges directory exists ───────────────────────────────────
  _check "badges-dir" "docs/badges/ directory exists" \
    test -d "${badges_dir}"

  # ── Check 4: Badge SVGs present ────────────────────────────────────────
  local badge_count=0
  if [ -d "${badges_dir}" ]; then
    badge_count="$(find "${badges_dir}" -maxdepth 1 -name '*.svg' 2>/dev/null | wc -l)"
  fi
  _check "badge-svgs" \
    "At least one badge SVG in docs/badges/ (found ${badge_count})" \
    test "${badge_count}" -gt 0

  # ── Check 5: README mentions AI assistance ─────────────────────────────
  if [ -f "${readme_file}" ]; then
    _check "readme-attribution" \
      "README.md mentions AI assistance" \
      grep -qiE 'built with ai|ai assistance|ai attribution|credits\.md|ai-assisted' \
        "${readme_file}"
  else
    _check_fail "readme-attribution" "README.md not found"
  fi

  # ── Check 6: README references badge SVGs ──────────────────────────────
  if [ -f "${readme_file}" ]; then
    _check "readme-badges" \
      "README.md references docs/badges/ SVGs" \
      grep -qE 'docs/badges/' "${readme_file}"
  else
    _check_fail "readme-badges" "README.md not found"
  fi

  # ── Check 7: AI badges appear after attribution line ───────────────────
  # Verifies that docs/badges/ references appear on or after the first
  # "Built with AI assistance" line — not just in the tech badge header.
  if [ -f "${readme_file}" ]; then
    local attr_line="" after_has_badges=false
    attr_line="$(grep -ni 'built with ai\|ai assistance\|credits\.md\|ai attribution' \
      "${readme_file}" 2>/dev/null | head -1 | cut -d: -f1)"
    if [ -n "${attr_line}" ]; then
      after_has_badges=false
      while IFS= read -r line; do
        case "${line}" in *docs/badges/*) after_has_badges=true; break ;; esac
      done < <(sed -n "${attr_line},\$p" "${readme_file}" 2>/dev/null)
    fi
    _check "ai-badges-under-attribution" \
      "AI model badges appear after 'Built with AI assistance' line" \
      test "${after_has_badges}" = true
  else
    _check_fail "ai-badges-under-attribution" "README.md not found"
  fi

  # ── Run fixes if --fix or --force mode ──────────────────────────────────
  if [ "${FIX_MODE}" != "check" ]; then
    fixes_ai_attribution "${repo}"
  fi
}

# ── Fixes ─────────────────────────────────────────────────────────────────
fixes_ai_attribution() {
  local repo="$1"
  local credits_file="${repo}/CREDITS.md"
  local readme_file="${repo}/README.md"
  local badges_dir="${repo}/docs/badges"
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  local badge_gen="${script_dir}/generate-badge.sh"

  echo ""
  echo -e "${BOLD}[AI Attribution — Fixes]${NC}"

  # ── Fix 1: Generate CREDITS.md if missing ──────────────────────────────
  if [ ! -f "${credits_file}" ]; then
    _readme_credits_template > "${credits_file}" && chmod 644 "${credits_file}"
    _fix "credits-md-generate" "Generated CREDITS.md from template"
  fi

  # ── Fix 1.5: Migrate old CREDITS.md format to 4-column (--force only) ──
  if [ "${FIX_MODE}" = "force" ] && [ -f "${credits_file}" ]; then
    # Detect old format: any data row with 6+ pipe-separated data columns
    if grep -qE '^\|.*\|.*\|.*\|.*\|.*\|.*\|$' "${credits_file}"; then
      local bak_file="${credits_file}.bak.force"
      cp "${credits_file}" "${bak_file}"
      # Convert old N-column format to 4-column (Phase | Model | Harness | Role)
      # Known old format: Phase | Model | Reasoning | Interface | Plan | Role
      #   → keep cols: Phase(1), Model(2), Interface-as-Harness(4), Role(6)
      # Generic N-column: keep cols 1, 2, N-1 (as Harness), N (as Role)
      awk '
      /^\|.*\|.*\|.*\|.*\|.*\|.*\|$/ {
        split($0, a, "|")
        # Count actual data columns (lines with N+2 fields after pipe-split)
        nf = 0
        for (i in a) nf++
        if (nf >= 8) {
          # 6+ data columns: keep cols 1,2,4,6
          print a[1] "|" a[2] "|" a[3] "|" a[5] "|" a[7] "|" a[8]
        } else if (nf == 7) {
          # 5 data columns: keep cols 1,2,4,5
          print a[1] "|" a[2] "|" a[3] "|" a[5] "|" a[6]
        } else {
          print $0
        }
        next
      }
      { print }
      ' "${bak_file}" > "${credits_file}"
      # Rename Interface column header to Harness (standard column name)
      sed -i 's/|[[:space:]]*Interface[[:space:]]*|/ | Harness |/' "${credits_file}"
      _fix "credits-md-migrate" \
        "Migrated CREDITS.md from old format to 4-column (backup: CREDITS.md.bak.force)"
    fi
  fi

  # ── Fix 2: Generate badges for models in CREDITS.md ────────────────────
  if [ -f "${credits_file}" ] && [ -f "${badge_gen}" ]; then
    while IFS='|' read -r brand variant color; do
      [ -z "${brand}" ] && continue
      local safe_brand
      safe_brand="$(echo "${brand}" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]//g')"
      local badge_file
      badge_file="${badges_dir}/${safe_brand}.svg"
      if [ ! -f "${badge_file}" ]; then
        mkdir -p "${badges_dir}"
        _fix_run "badge-${brand}" "Generating badge for ${brand}" \
          bash "${badge_gen}" \
            --label "${brand}" \
            --value "${variant}" \
            --color "${color}" \
            --out "${badge_file}"
      fi
    done < <(_parse_credits_models "${credits_file}")
  fi

  # ── Fix 3: Insert AI attribution line in README ────────────────────────
  if [ -f "${readme_file}" ]; then
    if ! grep -qiE 'built with ai|ai assistance|credits\.md' "${readme_file}"; then
      # Insert after the first <p> or <h1> block — simple heuristic:
      # Add the attribution line after a badges line or the title
      local tmp_file="${readme_file}.tmp"
      if grep -qE 'docs/badges/' "${readme_file}"; then
        # Insert after badge line
        sed '0,/docs\/badges\//{
          /docs\/badges\//a\
\
<sub>Built with AI assistance — see <a href=".\/CREDITS.md">CREDITS.md<\/a><\/sub>
        }' "${readme_file}" > "${tmp_file}"
      else
        # Insert after first heading
        sed '0,/^# /{
          /^# /a\
\
<sub>Built with AI assistance — see <a href=".\/CREDITS.md">CREDITS.md<\/a><\/sub>
        }' "${readme_file}" > "${tmp_file}"
      fi
      if [ -f "${tmp_file}" ]; then
        mv "${tmp_file}" "${readme_file}"
        _fix "readme-attribution" "Inserted AI attribution line in README.md"
      fi
    fi
  fi

  # ── Fix 4: Insert README badge references if SVGs present but unreferenced ──
  if [ -d "${badges_dir}" ] && [ -f "${readme_file}" ]; then
    if ! grep -qE 'docs/badges/' "${readme_file}"; then
      local svg_files=()
      while IFS= read -r -d '' svg; do
        svg_files+=("${svg}")
      done < <(find "${badges_dir}" -maxdepth 1 -name '*.svg' -print0 2>/dev/null)
      if [ ${#svg_files[@]} -gt 0 ]; then
        local tmp_file="${readme_file}.tmp"
        local badges_file="${badges_dir}/.readme-refs.tmp"
        local svg_name alt_text matched
        local model_alts=""
        if [ -f "${credits_file}" ]; then
          model_alts="$(_parse_credits_models "${credits_file}" 2>/dev/null || true)"
        fi
        true > "${badges_file}"
        for svg in "${svg_files[@]}"; do
          svg_name="$(basename "${svg}" .svg)"
          alt_text="$(echo "${svg_name}" | tr '-' ' ' | sed 's/\b\(.\)/\u\1/g')"
          if [ -n "${model_alts}" ]; then
            matched="$(echo "${model_alts}" | grep -i "^${svg_name}|" | head -1 | cut -d'|' -f2)"
            if [ -n "${matched}" ]; then
              alt_text="${matched}"
            fi
          fi
          printf '<a href="./CREDITS.md"><img src="docs/badges/%s.svg" alt="%s"></a>\n' \
            "${svg_name}" "${alt_text}" >> "${badges_file}"
        done
        # Insert badge links after the attribution line (Fix 3 insertion point)
        if grep -q '</sub>' "${readme_file}"; then
          # Use sed r to read badges file after the last </sub> line
          sed -e '/<\/sub>/r '"${badges_file}" "${readme_file}" > "${tmp_file}"
        else
          # Insert after first heading
          sed -e '0,/^# /{/^# /r '"${badges_file}"'}' "${readme_file}" > "${tmp_file}"
        fi
        rm -f "${badges_file}"
        if [ -f "${tmp_file}" ] && [ -s "${tmp_file}" ]; then
          mv "${tmp_file}" "${readme_file}"
          _fix "readme-badge-refs" "Inserted ${#svg_files[@]} badge references in README.md"
        fi
      fi
    fi
  fi
}
