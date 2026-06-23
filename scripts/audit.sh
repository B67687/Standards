#!/usr/bin/env bash
# audit.sh — AI-native standards enforcement
#
# Audit any repo against applicable standards and optionally auto-fix.
# Centralized: lives in standards repo, audits any target repo.
#
# Usage:
#   audit.sh                          # Audit current directory
#   audit.sh ~/projects/dev/bus-hop   # Audit specific repo
#   audit.sh --fix .                  # Audit + auto-fix CWD
#   audit.sh --standard ai-attribution --report json --exit-code
#
# Options:
#   --check              Run audit only (default)
#   --fix                Apply additive, safe auto-fixes
#   --force              Apply all fixes including destructive
#   --standard <id>      Only check specific standard(s)
#   --report <format>    Output format: terminal (default), json, quiet
#   --list-standards     List available standards and exit
#   --exit-code          Exit 1 on any failure (for CI gating)
#   --agent-reviews      Run agent-check.sh after audit to process pending evals
#   --help               Show this help and exit

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── Defaults ──────────────────────────────────────────────────────────────
REPO_PATH=""
MODE="check"
REPORT="terminal"
EXIT_CODE=false
LIST_ONLY=false
FILTER_STANDARD=""
AGENT_REVIEWS=false

# ── Parse arguments ───────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --check) MODE="check"; shift ;;
    --fix) MODE="fix"; shift ;;
    --force) MODE="force"; shift ;;
    --standard)
      FILTER_STANDARD="$2"
      shift 2
      ;;
    --report)
      REPORT="$2"
      shift 2
      ;;
    --list-standards) LIST_ONLY=true; shift ;;
    --exit-code) EXIT_CODE=true; shift ;;
    --agent-reviews) AGENT_REVIEWS=true; shift ;;
    --help)
      sed -n '2,22p' "$0" | sed 's/^# //'
      exit 0
      ;;
    --)
      shift
      REPO_PATH="${1:-}"
      break
      ;;
    -*)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
    *)
      REPO_PATH="$1"
      shift
      ;;
  esac
done

# ── Resolve repo path ─────────────────────────────────────────────────────
if [ -z "${REPO_PATH}" ]; then
  REPO_PATH="${PWD}"
fi
REPO_PATH="$(cd "${REPO_PATH}" 2>/dev/null && pwd)" || {
  echo "Error: cannot access '${REPO_PATH}'" >&2
  exit 1
}

if [ ! -d "${REPO_PATH}/.git" ] && [ ! -f "${REPO_PATH}/.git" ]; then
  echo "Warning: '${REPO_PATH}' does not appear to be a git repository" >&2
fi

# ── Source framework ──────────────────────────────────────────────────────
# Save first because audit-lib.sh declares REPO_PATH="" on source
_TMP_REPO="${REPO_PATH}"
_TMP_MODE="${MODE}"
source "${SCRIPT_DIR}/audit-lib.sh"
REPO_PATH="${_TMP_REPO}"
# shellcheck disable=SC2034 # used by sourced check files
FIX_MODE="${_TMP_MODE}"
unset _TMP_REPO _TMP_MODE

# ── Discover and source check files ───────────────────────────────────────
CHECK_DIR="${SCRIPT_DIR}/checks"
if [ -d "${CHECK_DIR}" ]; then
  for check_file in "${CHECK_DIR}"/*.sh; do
    if [ -f "${check_file}" ]; then
      # shellcheck source=/dev/null
      source "${check_file}"
    fi
  done
fi

# ── List mode ─────────────────────────────────────────────────────────────
if ${LIST_ONLY}; then
  echo "Available standards:"
  for std in "${ALL_STANDARDS[@]}"; do
    echo "  ${std}"
  done
  exit 0
fi

if [ ${#ALL_STANDARDS[@]} -eq 0 ]; then
  echo "No standard check files found in ${CHECK_DIR}" >&2
  exit 1
fi

# ── Run checks ────────────────────────────────────────────────────────────
ANY_FAILURE=false
for standard_id in "${ALL_STANDARDS[@]}"; do
  if [ -n "${FILTER_STANDARD}" ] && [ "${standard_id}" != "${FILTER_STANDARD}" ]; then
    continue
  fi
  # Convert standard ID (kebab-case) to function name (snake_case)
  func_name="${standard_id//-/_}"
  if ! "checks_${func_name}" "${REPO_PATH}"; then
    # shellcheck disable=SC2034 # used by exit-code logic below
    ANY_FAILURE=true
  fi
done

# ── Report ────────────────────────────────────────────────────────────────
case "${REPORT}" in
  json) report_json ;;
  quiet) ;;
  *) report_summary ;;
esac

# ── Agent reviews ─────────────────────────────────────────────────────────
if ${AGENT_REVIEWS}; then
  echo ""
  "${SCRIPT_DIR}/agent-check.sh" "${REPO_PATH}" || true
fi

# ── Exit code ─────────────────────────────────────────────────────────────
if ${EXIT_CODE}; then
  for _result in "${ALL_RESULTS[@]}"; do
    case "${_result}" in
      fail*|error*) exit 1 ;;
    esac
  done
fi
exit 0
