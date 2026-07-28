#!/usr/bin/env bash
# checks/cs-project-architecture.sh — CS Team Project Architecture Standard audit checks.
#
# Sourced by audit.sh. Uses the framework from audit-lib.sh.
#
# Checks:
#   1. architecture-template-match — At least one template directory pattern is identifiable
#   2. template-required-dirs — Required directories for the identified template exist
#   3. no-mega-files — No source file exceeds 250 lines (single-responsibility principle)
#   4. main-entry-point — Entry point (Main.java, main.py, etc.) exists at expected location
#

ALL_STANDARDS+=("cs-project-architecture")
set -euo pipefail

checks_cs_project_architecture() {
  CURR_STANDARD="cs-project-architecture"
  _check_header "${CURR_STANDARD}"

  local repo="${1:-${REPO_PATH}}"
  [ -n "${repo}" ] || repo="${PWD}"

  # Look for source root — common locations
  local src_root=""
  for candidate in "${repo}/src" "${repo}/app" "${repo}/source" "${repo}"; do
    if [ -d "${candidate}" ]; then
      src_root="${candidate}"
      break
    fi
  done

  if [ -z "${src_root}" ] || [ "${src_root}" = "${repo}" ]; then
    # No source dir found — try repo root
    src_root="${repo}"
  fi

  # ── Early exit: no source code files → not a code project ─────────────
  local src_files
  src_files="$(find "${src_root}" \( -name '*.java' -o -name '*.kt' -o -name '*.py' \
    -o -name '*.cs' -o -name '*.ts' -o -name '*.go' -o -name '*.rs' \) \
    2>/dev/null | head -5)"
  if [ -z "${src_files}" ]; then
    _check "architecture-template-match" "No source code project detected — not applicable" true
    _check "template-required-dirs" "Not applicable — no source code project" true
    _check "no-mega-files" "Not applicable — no source code project" true
    _check "main-entry-point" "Not applicable — no source code project" true
    return
  fi

  # ── Check 1: Architecture template identification ──────────────────────
  # Identify which of the 4 templates the project uses by directory patterns.
  # A template "matches" if 2+ of its characteristic directories exist.
  local layered_match=0 three_tier_match=0 mvc_match=0 hex_match=0
  local identified="none"

  # Layered:  api/, model/, engine/, ui/
  for d in api model engine ui; do [ -d "${src_root}/${d}" ] && ((layered_match++)) || true; done
  # Three-Tier:  presentation/, business/, data/
  for d in presentation business data; do [ -d "${src_root}/${d}" ] && ((three_tier_match++)) || true; done
  # MVC:  controller/, model/, view/
  for d in controller model view; do [ -d "${src_root}/${d}" ] && ((mvc_match++)) || true; done
  # Hexagonal:  domain/, application/, adapter/
  for d in domain application adapter; do [ -d "${src_root}/${d}" ] && ((hex_match++)) || true; done

  # Pick the best match (highest score, or first with 2+)
  if [ "${layered_match}" -ge 2 ]; then identified="layered"
  elif [ "${three_tier_match}" -ge 2 ]; then identified="three-tier"
  elif [ "${mvc_match}" -ge 2 ]; then identified="mvc"
  elif [ "${hex_match}" -ge 2 ]; then identified="hexagonal"
  fi

  # Track whether template was identified (check 2 depends on it)
  local template_identified=false
  [ "${identified}" != "none" ] && template_identified=true

  _check "architecture-template-match" \
    "Architecture template identified (${identified})" \
    test "${identified}" != "none"

  # ── Check 2: Required directories for identified template ──────────────
  # Each template has specific required directories. Check they all exist.
  local missing_dirs=""
  if [ "${template_identified}" != "true" ]; then
    _check "template-required-dirs" \
      "Not applicable — no architecture template identified" true
  else
    case "${identified}" in
      layered)
        for d in api model engine; do
          [ ! -d "${src_root}/${d}" ] && missing_dirs+=" ${d}"
        done
        # ui/ is optional in layered (console apps may use engine for I/O)
        ;;
      three-tier)
        for d in presentation business data; do
          [ ! -d "${src_root}/${d}" ] && missing_dirs+=" ${d}"
        done
        ;;
      mvc)
        for d in controller view; do
          [ ! -d "${src_root}/${d}" ] && missing_dirs+=" ${d}"
        done
        [ ! -d "${src_root}/model" ] && missing_dirs+=" model"
        ;;
      hexagonal)
        for d in domain application adapter; do
          [ ! -d "${src_root}/${d}" ] && missing_dirs+=" ${d}"
        done
        ;;
    esac

    if [ -n "${missing_dirs}" ]; then
      _check_fail "template-required-dirs" \
        "Missing required directories:${missing_dirs}"
    else
      _check "template-required-dirs" \
        "All required directories present for ${identified} template" true
    fi
  fi

  # ── Check 3: No mega-files (>250 lines) ────────────────────────────────
  # Single-responsibility principle enforced by layer boundaries.
  local mega_count=0 mega_files=""
  while IFS= read -r -d '' srcfile; do
    local lines
    lines="$(wc -l < "${srcfile}" 2>/dev/null || echo 0)"
    if [ "${lines}" -gt 250 ]; then
      ((mega_count++)) || true
      mega_files+=" $(basename "${srcfile}")"
    fi
  done < <(find "${src_root}" -name '*.java' -o -name '*.kt' -o -name '*.py' \
    -o -name '*.cs' -o -name '*.ts' -o -name '*.go' -o -name '*.rs' 2>/dev/null | head -100)

  if [ "${mega_count}" -gt 0 ]; then
    _check_fail "no-mega-files" \
      "${mega_count} file(s) exceed 250 lines:${mega_files}"
  else
    _check "no-mega-files" \
      "No source file exceeds 250 lines" true
  fi

  # ── Check 4: Main entry point ──────────────────────────────────────────
  # Entry point should be at project root or top of src/.
  local entry_found=false entry_path=""
  for candidate in \
    "${repo}/Main.java" \
    "${repo}/src/Main.java" \
    "${repo}/main.py" \
    "${repo}/src/main.py" \
    "${repo}/Program.cs" \
    "${repo}/src/Program.cs" \
    "${repo}/main.go" \
    "${repo}/src/main.go"; do
    if [ -f "${candidate}" ]; then
      entry_found=true
      entry_path="${candidate#${repo}/}"
      break
    fi
  done

  _check "main-entry-point" \
    "Entry point found${entry_found:+ (${entry_path})}" \
    test "${entry_found}" = true
}

# No fixes for this standard — architecture is a design decision, not auto-fixable.
