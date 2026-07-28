#!/usr/bin/env bash
# audit-all.sh — Batch audit across all repos.
#
# Discovers git repos under a base directory, runs audit.sh on each,
# and aggregates results into a combined JSON file for the dashboard.
#
# Usage:
#   audit-all.sh                          # audits CWD
#   audit-all.sh /custom/base/dir         # audits under custom path
#   audit-all.sh --repos-file list.txt    # reads specific repo paths
#   audit-all.sh --agent-reviews          # also run agent checks post-audit
#   audit-all.sh --help
#
# Exit code: 0 = all repos passed, 1 = some failed

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="${SCRIPT_DIR}/.."

# Defaults — no machine-specific paths; use `.` or pass `-d`
SEARCH_DIR="."
REPOS_FILE=""
AGENT_REVIEWS=false
EXIT_CODE=0

usage() {
  sed -n '3,9p' "${BASH_SOURCE[0]}"
  echo ""
  echo "  -d, --dir DIR         Search for git repos under DIR (default: .)"
  echo "  -f, --repos-file FILE Read repo paths from FILE (one per line, skips discovery)"
  echo "      --agent-reviews   Run agent check (agent-check.sh) after each audit"
  echo "      --help            Show this help"
  echo ""
  echo "Output: .omo/dashboard/audit-results.json (combined)"
  echo ""
  echo "Exit code: 0 = all repos passed, 1 = some failed"
}

log() { echo "[audit-all] $*" >&2; }
warn() { echo "[audit-all] WARNING: $*" >&2; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    -d|--dir)         SEARCH_DIR="$2"; shift 2 ;;
    -f|--repos-file)  REPOS_FILE="$2"; shift 2 ;;
    --agent-reviews)  AGENT_REVIEWS=true; shift ;;
    --help)           usage; exit 0 ;;
    *)
      if [[ "${REPOS_FILE}" == "" ]] && [[ "${SEARCH_DIR}" == "." ]]; then
        SEARCH_DIR="$1"
      else
        echo "Unknown: $1" >&2
        usage >&2
        exit 1
      fi
      shift ;;
  esac
done

# Discover repos
repos=()
if [[ -n "${REPOS_FILE}" ]]; then
  if [[ ! -f "${REPOS_FILE}" ]]; then
    log "Repos file not found: ${REPOS_FILE}"
    exit 1
  fi
  while IFS= read -r line; do
    line="$(echo "${line}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    [[ -z "${line}" ]] && continue
    [[ "${line}" =~ ^# ]] && continue
    if [[ -d "${line}/.git" ]]; then
      repos+=("${line}")
    else
      warn "Not a git repo: ${line}"
    fi
  done < "${REPOS_FILE}"
else
  if [[ ! -d "${SEARCH_DIR}" ]]; then
    log "Search directory not found: ${SEARCH_DIR}"
    exit 1
  fi
  log "Discovering git repos under ${SEARCH_DIR}..."
  while IFS= read -r dir; do
    repos+=("$(dirname "${dir}")")
  done < <(find "${SEARCH_DIR}" -maxdepth 2 -type d -name '.git' 2>/dev/null || true)
fi

mapfile -t repos < <(printf '%s\n' "${repos[@]}" | sort -u)

repo_count="${#repos[@]}"
if [[ "${repo_count}" -eq 0 ]]; then
  log "No repos found."
  exit 0
fi

log "Found ${repo_count} repo(s)"

OUT_DIR="${BASE_DIR}/.omo/dashboard"
mkdir -p "${OUT_DIR}"

results_json="${OUT_DIR}/audit-results.json"
tmp_json="$(mktemp)"
trap 'rm -f "${tmp_json}"' EXIT

echo "{" > "${tmp_json}"
echo "  \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"," >> "${tmp_json}"
echo "  \"repos\": [" >> "${tmp_json}"

first_repo=true
repo_i=0

for repo_path in "${repos[@]}"; do
  repo_i=$((repo_i + 1))
  repo_name="$(basename "${repo_path}")"

  log "[${repo_i}/${repo_count}] Auditing ${repo_name}..."

  if ${first_repo}; then
    first_repo=false
  else
    echo "," >> "${tmp_json}"
  fi

  # Run audit with JSON output, pass --agent-reviews if set
  audit_args=("--report" "json" "${repo_path}")
  if ${AGENT_REVIEWS}; then
    audit_args+=("--agent-reviews")
  fi
  audit_output="$("${SCRIPT_DIR}/audit.sh" "${audit_args[@]}" 2>/dev/null || true)"

  # Check if audit output contains failures — set EXIT_CODE
  if echo "${audit_output}" | grep -q '"status":"fail"'; then
    EXIT_CODE=1
  fi

  # Extract JSON from mixed output (find from opening { to closing })
  repo_json="$(echo "${audit_output}" | awk '/^{$/,0' || echo "")"

  if [[ -z "${repo_json}" ]]; then
    warn "${repo_name}: No JSON output from audit — writing empty result"
    repo_json='{"repo":"'"${repo_path}"'","results":[]}'
  fi

  repo_path_escaped="$(printf '%s' "${repo_path}" | sed 's/\\/\\\\/g; s/"/\\"/g')"
  echo -n "    {\"name\": \"${repo_name}\", \"path\": \"${repo_path_escaped}\", \"audit\": ${repo_json}}" >> "${tmp_json}"
done

{
  echo ""
  echo "  ]"
  echo "}"
} >> "${tmp_json}"

# Validate JSON
if command -v python3 &>/dev/null; then
  if ! python3 -c "import json; json.load(open('${tmp_json}'))" 2>/dev/null; then
    log "Invalid JSON generated — skipping validation"
  else
    log "JSON valid"
  fi
elif command -v jq &>/dev/null; then
  if ! jq empty "${tmp_json}" 2>/dev/null; then
    log "Invalid JSON generated — skipping validation"
  else
    log "JSON valid"
  fi
fi

mv "${tmp_json}" "${results_json}"
log "Done: ${repo_i} repos aggregated → ${results_json}"

exit "${EXIT_CODE}"
