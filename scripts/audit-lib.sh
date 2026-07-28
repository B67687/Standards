#!/usr/bin/env bash
# audit-lib.sh — Shared check framework for the standards audit system.
#
# Source this from audit.sh and individual standard check files.
# Provides: _check_header, _check, _check_fail, _fix, report_summary, report_json

set -euo pipefail

# ── Color output ──────────────────────────────────────────────────────────
if [ -t 1 ]; then
  GREEN='\033[0;32m'
  RED='\033[0;31m'
  YELLOW='\033[0;33m'
  BOLD='\033[1m'
  NC='\033[0m'
else
  GREEN=''
  RED=''
  YELLOW=''
  BOLD=''
  NC=''
fi

# ── Global state ──────────────────────────────────────────────────────────
ALL_RESULTS=()       # "status|standard|id|description"  status=pass|fail|pending|fix|error
# shellcheck disable=SC2034 # populated by sourced check files
ALL_STANDARDS=()     # Registered by check files via: ALL_STANDARDS+=("my_standard")
CURR_STANDARD=""     # Set by check functions before calling _check
REPO_PATH=""         # Set by audit.sh before sourcing checks
FIX_MODE="check"     # "check" | "fix" | "force"
REPORT_FORMAT="terminal"  # "terminal" | "json" — when json, terminal output → stderr

# ── _out <args...> ──────────────────────────────────────────────────────────
# Output to the appropriate fd: stdout for terminal, stderr for JSON mode.
_out() {
  if [ "${REPORT_FORMAT}" = "json" ]; then
    echo -e "$@" >&2
  else
    echo -e "$@"
  fi
}

# ── _check_header <heading> ───────────────────────────────────────────────
# Print a section heading for a standard.
_check_header() {
  local heading="${1:-}"
  _out ""
  _out "${BOLD}[${heading}]${NC}"
}

# ── _check <id> <description> <command...> ────────────────────────────────
# Run a single check predicate.  If the command succeeds (exit 0) the check
# passes; otherwise it fails.  Always appends to ALL_RESULTS for reporting.
_check() {
  local id="$1" desc="$2"
  shift 2
  if "$@"; then
    _out "  ${GREEN}✓${NC} ${desc}"
    ALL_RESULTS+=("pass|${CURR_STANDARD}|${id}|${desc}")
    return 0
  else
    _out "  ${RED}✗${NC} ${desc}"
    ALL_RESULTS+=("fail|${CURR_STANDARD}|${id}|${desc}")
    return 1
  fi
}

# ── _check_fail <id> <description> ────────────────────────────────────────
# Record a failure without running a predicate (for compound checks where
# a precondition wasn't met).
_check_fail() {
  local id="$1" desc="$2"
  _out "  ${RED}✗${NC} ${desc} (skipped)"
  ALL_RESULTS+=("fail|${CURR_STANDARD}|${id}|${desc} (skipped)")
  return 1
}

# ── _check_pending <id> <description> ─────────────────────────────────────
# Record that a check requires AI judgment and is pending agent review.
_check_pending() {
  local id="$1" desc="$2"
  _out "  ${YELLOW}⟳${NC} ${desc} (pending agent review)"
  ALL_RESULTS+=("pending|${CURR_STANDARD}|${id}|${desc}")
}

# ── _agent_eval_dir ─────────────────────────────────────────────────────
# Return the path to the agent-evals directory, creating it if needed.
_agent_eval_dir() {
  local dir="${REPO_PATH}/.omo/audit/agent-evals"
  mkdir -p "${dir}"
  echo "${dir}"
}

# ── _fix <id> <description> ──────────────────────────────────────────────
# Record that a fix was applied (only used during --fix / --force mode).
_fix() {
  local id="$1" desc="$2"
  _out "  ${YELLOW}→${NC} ${desc}"
  ALL_RESULTS+=("fix|${CURR_STANDARD}|${id}|${desc}")
}

# ── _fix_run <id> <description> <command...> ──────────────────────────────
# Run a fix command.  Only executes if FIX_MODE is fix or force.
# Records the attempt as a fix entry.
_fix_run() {
  local id="$1" desc="$2"
  shift 2
  if [ "${FIX_MODE}" = "check" ]; then
    return 0
  fi
  if "$@"; then
    _fix "${id}" "${desc}"
    return 0
  else
    _out "  ${RED}✗${NC} Fix failed: ${desc}"
    ALL_RESULTS+=("error|${CURR_STANDARD}|${id}|Fix failed: ${desc}")
    return 1
  fi
}

# ── report_summary ────────────────────────────────────────────────────────
# Print a human-readable summary of all checks. Returns number of failures.
report_summary() {
  local pass=0 fail=0 pending=0 fixes=0 errors=0
  local line
  _out ""
  _out "${BOLD}── Report ──────────────────────────────────────────${NC}"
  for line in "${ALL_RESULTS[@]}"; do
    case "${line}" in
      pass*)    pass=$((pass + 1)) ;;
      fail*)    fail=$((fail + 1)) ;;
      pending*) pending=$((pending + 1)) ;;
      fix*)     fixes=$((fixes + 1)) ;;
      error*)   errors=$((errors + 1)) ;;
    esac
  done
  _out "  ${GREEN}${pass} passed${NC}, ${RED}${fail} failed${NC}, ${YELLOW}${pending} pending${NC}, ${YELLOW}${fixes} fixes applied${NC}, ${RED}${errors} errors${NC}"
  _out "  ${BOLD}Total:${NC} $((pass + fail + pending)) checks, $((fixes + errors)) actions"
  _out ""
  return 0
}

# ── report_json ───────────────────────────────────────────────────────────
# Print a JSON summary for machine consumption.
report_json() {
  local first=true
  local line
  echo "{"
  echo "  \"repo\": \"${REPO_PATH}\","
  echo "  \"results\": ["
  for line in "${ALL_RESULTS[@]}"; do
    ${first} || echo ","
    first=false
    IFS='|' read -r status standard id desc <<< "${line}"
    # Escape JSON special chars — backslash first, then quote, to avoid double-escaping
    desc="$(printf '%s' "${desc}" | sed 's/\\/\\\\/g; s/"/\\"/g')"
    local safe_repo
    safe_repo="$(printf '%s' "${REPO_PATH}" | sed 's/\\/\\\\/g; s/"/\\"/g')"
    printf '    {"status":"%s","standard":"%s","id":"%s","description":"%s","repo":"%s"}' \
      "${status}" "${standard}" "${id}" "${desc}" "${safe_repo}"
  done
  echo ""
  echo "  ]"
  echo "}"
}
