#!/usr/bin/env bash
# agent-check.sh — Agent evaluation dispatcher
#
# Reads agent evaluation requests from agent-evals/ (JSON), dispatches
# them (initial version: stdout + pending_review stubs), and writes
# results to agent-results/.
#
# The eval request format is designed to be consumed by an LLM in a
# future iteration. This initial version documents the format and
# provides the plumbing.
#
# Usage:
#   agent-check.sh                              # process evals in CWD's .omo/audit/
#   agent-check.sh --eval-dir <path> --result-dir <path>
#   agent-check.sh --process-pending            # stub results with pending_review
#   agent-check.sh --help

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Default paths relative to CWD
EVAL_DIR=""
RESULT_DIR=""
MODE="process-pending"

usage() {
  sed -n '2,14p' "${BASH_SOURCE[0]}"
  echo ""
  echo "  -e, --eval-dir DIR     Agent eval directory (default: CWD/.omo/audit/agent-evals)"
  echo "  -r, --result-dir DIR   Agent result directory (default: CWD/.omo/audit/agent-results)"
  echo "  -p, --process-pending  Write pending_review results (default)"
  echo "      --help             Show this help"
  echo ""
  echo "Exit code: 0 = all evals have results, 1 = some evals still pending"
}

log() { echo "[agent-check] $*" >&2; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    -e|--eval-dir)    EVAL_DIR="$2"; shift 2 ;;
    -r|--result-dir)  RESULT_DIR="$2"; shift 2 ;;
    -p|--process-pending) MODE="process-pending"; shift ;;
    --help)           usage; exit 0 ;;
    *)
      if [[ -z "${EVAL_DIR}" ]]; then
        EVAL_DIR="$1"
      elif [[ -z "${RESULT_DIR}" ]]; then
        RESULT_DIR="$1"
      else
        echo "Unknown: $1" >&2
        usage >&2
        exit 1
      fi
      shift ;;
  esac
done

# Default to .omo/audit/ relative to CWD or BASE_DIR
if [[ -z "${EVAL_DIR}" ]]; then
  if [[ -d ".omo/audit/agent-evals" ]]; then
    EVAL_DIR=".omo/audit/agent-evals"
  elif [[ -d "${BASE_DIR}/.omo/audit/agent-evals" ]]; then
    EVAL_DIR="${BASE_DIR}/.omo/audit/agent-evals"
  else
    log "No agent-evals directory found (tried .omo/audit/agent-evals from CWD and BASE_DIR)"
    log "Use --eval-dir to specify explicitly, or create evals first"
    exit 0
  fi
fi

if [[ -z "${RESULT_DIR}" ]]; then
  RESULT_DIR="$(dirname "${EVAL_DIR}")/agent-results"
fi

# Normalize to absolute paths
EVAL_DIR="$(cd "${EVAL_DIR}" 2>/dev/null && pwd || echo "${EVAL_DIR}")"
mkdir -p "${RESULT_DIR}"
RESULT_DIR="$(cd "${RESULT_DIR}" && pwd)"

if [[ ! -d "${EVAL_DIR}" ]]; then
  log "Eval directory does not exist: ${EVAL_DIR}"
  exit 0
fi

# Count eval files
shopt -s nullglob
eval_files=("${EVAL_DIR}"/*.json)
shopt -u nullglob

if [[ ${#eval_files[@]} -eq 0 ]]; then
  log "No eval files found in ${EVAL_DIR}"
  exit 0
fi

log "Found ${#eval_files[@]} eval request(s) in ${EVAL_DIR}"

processed=0
pending=0

for eval_file in "${eval_files[@]}"; do
  basename_eval="$(basename "${eval_file}")"
  result_file="${RESULT_DIR}/${basename_eval}"

  # Skip if result already exists
  if [[ -f "${result_file}" ]]; then
    log "  result exists — skipping: ${basename_eval}"
    continue
  fi

  # Validate JSON
  if ! jq empty "${eval_file}" 2>/dev/null; then
    log "  invalid JSON: ${basename_eval} — writing error result"
    echo '{"schema_version":1,"status":"error","summary":"Invalid JSON in eval request"}' > "${result_file}"
    continue
  fi

  # Extract metadata
  standard="$(jq -r '.standard // "unknown"' "${eval_file}")"
  check="$(jq -r '.check // "unknown"' "${eval_file}")"

  if [[ "${MODE}" == "process-pending" ]]; then
    # Write pending_review result (extract values before heredoc to avoid read/write collision)
    std_val="$(jq -c '.standard // "unknown"' "${eval_file}")"
    chk_val="$(jq -c '.check // "unknown"' "${eval_file}")"
    # shellcheck disable=SC2094
    cat > "${result_file}" <<JSONEOF
{
  "schema_version": 1,
  "standard": ${std_val},
  "check": ${chk_val},
  "status": "pending_review",
  "summary": "Agent review not yet performed — eval request recorded",
  "eval_file": $(jq -c -n --arg f "${eval_file}" '$f'),
  "result_file": $(jq -c -n --arg f "${result_file}" '$f')
}
JSONEOF
    log "  pending: ${standard}/${check} → ${basename_eval}"
    pending=$((pending + 1))
  fi

  processed=$((processed + 1))
done

log "Done: ${processed} processed (${pending} pending, $((processed - pending)) skipped)"

if [[ ${pending} -gt 0 ]]; then
  exit 1
fi
exit 0
