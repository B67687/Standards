#!/usr/bin/env bash
# Path Agnosticism check — ensures no hardcoded machine-specific paths.
set -euo pipefail

ALL_STANDARDS+=("path-agnosticism")
STANDARD_DOMAINS["path-agnosticism"]="universal"

checks_path_agnosticism() {
  local repo="${1:-${REPO_PATH}}"
  [ -n "${repo}" ] || repo="${PWD}"
  CURR_STANDARD="path-agnosticism"
  _check_header "${CURR_STANDARD}"

  local scripts_dir="${repo}/scripts"; local home_hits=""
  if [ -d "${scripts_dir}" ]; then
    home_hits="$(grep -rn '/home/\|/Users/' "${scripts_dir}" --include='*.sh' 2>/dev/null | grep -v 'path-agnosticism\.sh' || true)"
  fi
  if [ -n "${home_hits}" ]; then
    local brief
    brief="$(echo "${home_hits}" | head -3 | tr '\n' ' ')"
    _check_fail "no-hardcoded-home" "Hardcoded /home/ or /Users/ detected: ${brief}"
  else
    _check "no-hardcoded-home" "No hardcoded /home/ or /Users/ paths in scripts" true
  fi

  local abs_hits=""
  if [ -d "${scripts_dir}" ]; then
    abs_hits="$(grep -rnE '^\s*(source|\.)\s+/' "${scripts_dir}" --include='*.sh' 2>/dev/null || true)"
  fi
  if [ -n "${abs_hits}" ]; then
    local brief2
    brief2="$(echo "${abs_hits}" | head -3 | tr '\n' ' ')"
    _check_fail "no-absolute-loads" "Source/load from absolute path: ${brief2}"
  else
    _check "no-absolute-loads" "No source/load from absolute paths" true
  fi

  local missing_sd=""
  if [ -d "${scripts_dir}" ]; then
    while IFS= read -r -d '' f; do
      local bn
      bn="$(basename "${f}")"
      case "${bn}" in
        path-agnosticism.sh|audit-lib.sh|audit.sh|generate-badge.sh|agent-check.sh|audit-all.sh|dashboard.sh) continue ;;
      esac
      if grep -qE '^\s*(source|\.)\s' "${f}" 2>/dev/null; then
        if ! grep -q 'SCRIPT_DIR=' "${f}" 2>/dev/null; then
          missing_sd+=" ${bn}"
        fi
      fi
    done < <(find "${scripts_dir}" -name '*.sh' -print0 2>/dev/null)
  fi
  if [ -n "${missing_sd}" ]; then
    _check_fail "uses-script-dir" "Scripts missing SCRIPT_DIR:${missing_sd}"
  else
    _check "uses-script-dir" "Scripts define SCRIPT_DIR for relative references" true
  fi

  local hardcoded=""
  if [ -d "${scripts_dir}" ]; then
    hardcoded="$(grep -rnE 'SEARCH_DIR="/' "${scripts_dir}" --include='*.sh' 2>/dev/null | grep -v 'path-agnosticism\.sh' || true)"
  fi
  if [ -n "${hardcoded}" ]; then
    local brief4
    brief4="$(echo "${hardcoded}" | head -3 | tr '\n' ' ')"
    _check_fail "search-path-configurable" "Hardcoded SEARCH_DIR: ${brief4}"
  else
    _check "search-path-configurable" "Search paths accept arguments or env vars, not hardcoded" true
  fi
}
