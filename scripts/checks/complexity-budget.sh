#!/usr/bin/env bash
# checks/complexity-budget.sh — Architecture Fitness: Complexity Budget check.
#
# Sourced by audit.sh. Uses the framework from audit-lib.sh.
#
# Checks:
#   1. No file exceeds 250 non-blank, non-comment lines
#   2. No function exceeds 40 lines
#
# Based on McConnell's Code Complete complexity research: 250 LOC is the
# cognitive load limit for a single file, and 40 LOC is the threshold
# where function comprehension degrades.

set -euo pipefail

# ── Register this standard ────────────────────────────────────────────────
ALL_STANDARDS+=("complexity-budget")

# ── Count non-blank, non-comment lines in a file ──────────────────────────
# Strips blank lines and common comment prefixes (//, #, --, /*, *)
_count_effective_lines() {
  local file="$1"
  awk '
    /^[[:space:]]*$/          { next }   # skip blank lines
    /^[[:space:]]*\/\//       { next }   # skip // comments
    /^[[:space:]]*#/          { next }   # skip # comments
    /^[[:space:]]*--/         { next }   # skip -- comments
    /^[[:space:]]*\/\*/       { next }   # skip /* block comment start
    /^[[:space:]]*\*/         { next }   # skip */ block comment lines
    { count++ }
    END { print count+0 }
  ' "${file}"
}

# ── Count lines in a function body ────────────────────────────────────────
# Detects function/method boundaries by matching common patterns:
#   func_name() {    (shell, go, rust, typescript)
#   def func_name    (python)
#   function name    (javascript/typescript)
#   fn name          (rust)
_count_function_lines() {
  local file="$1"
  local ext="${2:-}"

  # Detect language from extension or content
  local lang=""
  case "${ext}" in
    py)             lang="python" ;;
    rs)             lang="rust" ;;
    ts|tsx|js|jsx)  lang="typescript" ;;
    go)             lang="go" ;;
    cs)             lang="csharp" ;;
    java)           lang="java" ;;
    *)
      # Auto-detect from shebang or content
      if head -1 "${file}" 2>/dev/null | grep -q "python"; then
        lang="python"
      elif grep -qE "^(fn |impl )" "${file}" 2>/dev/null; then
        lang="rust"
      elif grep -qE "^(func |func\t)" "${file}" 2>/dev/null; then
        lang="go"
      elif grep -qE "^(def |class )" "${file}" 2>/dev/null; then
        lang="python"
      fi
      ;;
  esac

  case "${lang}" in
    python)
      # Python: def/class blocks — count indented lines after signature
      awk '
        /^[[:space:]]*(def |class )/ {
          if (in_func && lines > 0) printf "%d %s\n", lines, func_name
          in_func = 1; lines = 0; func_name = $0
          sub(/^[[:space:]]*/, "", func_name)
          next
        }
        in_func {
          if (/^[[:space:]]/ || /^[[:space:]]*$/) { lines++ }
          else if (/^[[:space:]]*$/) { next }
          else {
            if (lines > 0) printf "%d %s\n", lines, func_name
            in_func = 0; lines = 0
          }
        }
        END { if (in_func && lines > 0) printf "%d %s\n", lines, func_name }
      ' "${file}" ;;
    rust|go|csharp|java|typescript)
      # Brace-languages: count lines between opening { and closing }
      awk -v lang="${lang}" '
        BEGIN { depth = 0; lines = 0; func_name = "" }
        /[{]/ {
          if (depth == 0) {
            # Potential function start — grab the signature
            func_name = $0
            sub(/^[[:space:]]*/, "", func_name)
          }
          depth += gsub(/[{]/, "&")
        }
        /[}]/ {
          depth -= gsub(/[}]/, "&")
          if (depth == 0 && lines > 0) {
            printf "%d %s\n", lines, func_name
            lines = 0; func_name = ""
          }
        }
        depth > 0 { lines++ }
      ' "${file}" ;;
    *)
      # Fallback: no function-level analysis
      ;;
  esac
}

# ── Standard entry point: checks ──────────────────────────────────────────
checks_complexity_budget() {
  local repo="$1"
  # shellcheck disable=SC2034 # used by _check/_check_fail via audit-lib.sh
  CURR_STANDARD="complexity-budget"

  _check_header "Architecture Fitness: Complexity Budget"

  # ── Detect source directories ──────────────────────────────────────────
  local search_dirs=()
  if [ -d "${repo}/src" ]; then
    search_dirs+=("src")
  fi
  if [ -d "${repo}/app" ]; then
    search_dirs+=("app")
  fi
  if [ -d "${repo}/lib" ]; then
    search_dirs+=("lib")
  fi
  # Also check scripts/ for shell scripts (audit scripts themselves)
  if [ -d "${repo}/scripts" ]; then
    search_dirs+=("scripts")
  fi

  if [ ${#search_dirs[@]} -eq 0 ]; then
    _check_skip "file-size-budget" "No source directories found (not applicable)"
    _check_skip "function-size-budget" "No source directories found (not applicable)"
    return 0
  fi

  # ── Check 1: No file exceeds 250 non-blank, non-comment lines ──────────
  local file_violations=""
  local file_violation_count=0

  for search_dir in "${search_dirs[@]}"; do
    # Find source files (exclude common non-source directories)
    while IFS= read -r -d '' source_file; do
      local effective_lines
      effective_lines=$(_count_effective_lines "${source_file}")

      if [ "${effective_lines}" -gt 250 ]; then
        local rel_path="${source_file#"${repo}/"}"
        file_violations="${file_violations}  ${rel_path}: ${effective_lines} lines (max 250)"$'\n'
        file_violation_count=$((file_violation_count + 1))
      fi
    done < <(find "${repo}/${search_dir}" \
      -type f \
      \( -name "*.py" -o -name "*.pyi" -o -name "*.rs" \
         -o -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" \
         -o -name "*.go" -o -name "*.cs" -o -name "*.java" \
         -o -name "*.sh" -o -name "*.bash" \) \
      ! -path "*/node_modules/*" \
      ! -path "*/.git/*" \
      ! -path "*/dist/*" \
      ! -path "*/build/*" \
      ! -path "*/__pycache__/*" \
      ! -path "*/scripts/checks/*" \
      ! -name "bootstrap.sh" \
      -print0 2>/dev/null || true)
  done

  if [ "${file_violation_count}" -gt 0 ]; then
    _check "file-size-budget" \
      "No file exceeds 250 non-blank/non-comment lines (${file_violation_count} violations)" \
      test 1 = 0
  else
    _check "file-size-budget" \
      "All files within 250-line budget" \
      test 1 = 1
  fi

  # ── Check 2: No function exceeds 40 lines ──────────────────────────────
  local func_violations=""
  local func_violation_count=0

  for search_dir in "${search_dirs[@]}"; do
    while IFS= read -r -d '' source_file; do
      local ext="${source_file##*.}"
      local func_lines
      func_lines=$(_count_function_lines "${source_file}" "${ext}")

      if [ -z "${func_lines}" ]; then
        continue
      fi

      while IFS=' ' read -r count signature; do
        if [ "${count}" -gt 40 ]; then
          local rel_path="${source_file#"${repo}/"}"
          # Trim signature for display
          local short_sig="${signature:0:80}"
          func_violations="${func_violations}  ${rel_path}: ${count} lines — ${short_sig}"$'\n'
          func_violation_count=$((func_violation_count + 1))
        fi
      done <<< "${func_lines}"
    done < <(find "${repo}/${search_dir}" \
      -type f \
      \( -name "*.py" -o -name "*.pyi" -o -name "*.rs" \
         -o -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" \
         -o -name "*.go" -o -name "*.cs" -o -name "*.java" \) \
      ! -path "*/node_modules/*" \
      ! -path "*/.git/*" \
      ! -path "*/dist/*" \
      ! -path "*/build/*" \
      ! -path "*/__pycache__/*" \
      -print0 2>/dev/null || true)
  done

  if [ "${func_violation_count}" -gt 0 ]; then
    _check "function-size-budget" \
      "No function exceeds 40 lines (${func_violation_count} violations)" \
      test 1 = 0
  else
    _check "function-size-budget" \
      "All functions within 40-line budget" \
      test 1 = 1
  fi
}
