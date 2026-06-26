#!/usr/bin/env bash
# generate-standards-json.sh — Generate machine-readable standards.json
#
# Sources audit-lib.sh and all check files to populate the registry,
# then reads standard docs for descriptions and check counts.
# Outputs a JSON file consumable by tools, CI, and AI agents.
#
# Usage:
#   scripts/generate-standards-json.sh [--output <path>]
#
# If --output is omitted, writes to REPO_ROOT/standards.json

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── Parse args ─────────────────────────────────────────────────────────────
OUTPUT_PATH=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --output) OUTPUT_PATH="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

# ── Source framework — same as audit.sh does ───────────────────────────────
source "${SCRIPT_DIR}/audit-lib.sh"

CHECK_DIR="${SCRIPT_DIR}/checks"
if [ -d "${CHECK_DIR}" ]; then
  for check_file in "${CHECK_DIR}"/*.sh; do
    if [ -f "${check_file}" ]; then
      # shellcheck source=/dev/null
      source "${check_file}"
    fi
  done
fi

# ── Collect metadata ───────────────────────────────────────────────────────
DOCS_DIR="$(cd "${SCRIPT_DIR}/../docs/standards" && pwd)"

first=true
output="{"
output+="\n  \"version\": 1,"
output+="\n  \"generated\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\","
output+="\n  \"standards\": ["

for std_id in "${ALL_STANDARDS[@]}"; do
  ${first} || output+=","
  first=false

  # Find matching standard doc — handle naming mismatches
  doc_path=""
  case "${std_id}" in
    badge-quality|badge-shell) doc_path="${DOCS_DIR}/badge-standard.md" ;;
    readme-quality) doc_path="${DOCS_DIR}/README-standard.md" ;;
    sops-secrets|trivy-secrets) doc_path="${DOCS_DIR}/secrets-management-standard.md" ;;
    *) doc_path="$(find "${DOCS_DIR}" -name "${std_id}-standard.md" -maxdepth 1 2>/dev/null | head -1)" ;;
  esac

  # Extract name from H1
  name=""
  if [ -n "${doc_path}" ]; then
    name="$(sed -n 's/^# //p' "${doc_path}" | head -1)"
  fi
  [ -z "${name}" ] && name="${std_id}"

  # Extract description: first paragraph in the first non-Domains section
  description=""
  if [ -n "${doc_path}" ]; then
    capture=false
    while IFS= read -r line; do
      # Start capture when we hit a ## section that's not Domains
      if echo "${line}" | grep -qE "^## " && ! echo "${line}" | grep -q "^## Domains"; then
        capture=true
        continue
      fi
      # Stop at next ## section
      if ${capture} && echo "${line}" | grep -qE "^## "; then
        break
      fi
      # Skip blank lines, headings (###, ####), and table lines
      if ${capture} && [ -n "${description}" ] && [ -z "${line}" ]; then
        break  # blank line after content = end of paragraph
      fi
      if ${capture} && [ -z "${line}" ]; then
        continue  # skip leading blank lines
      fi
      if ${capture} && echo "${line}" | grep -qE "^\|.*\|"; then
        continue  # skip table lines
      fi
      if ${capture} && echo "${line}" | grep -qE "^###"; then
        continue  # skip sub-headings
      fi
      if ${capture}; then
        if [ -n "${description}" ]; then
          description+=" ${line}"
        else
          description="${line}"
        fi
      fi
    done < "${doc_path}"
  fi
  # Escape JSON
  description="$(printf '%s' "${description}" | sed 's/\\/\\\\/g; s/"/\\"/g; s/	/\\t/g; s/\r//g' | tr -d '\n')"
  name_escaped="$(printf '%s' "${name}" | sed 's/\\/\\\\/g; s/"/\\"/g')"

  # Count checks from the check script (_check, _check_pending, _agent_eval_check calls)
  check_count=0
  check_script="${CHECK_DIR}/${std_id}.sh"
  if [ -f "${check_script}" ]; then
    check_count=$(grep -cE '^\s+_(check|check_pending|agent_eval_check|check_fail)\b' "${check_script}" || true)
  fi

  domains="${STANDARD_DOMAINS[${std_id}]:-}"

  output+="\n    {\"id\":\"${std_id}\",\"name\":\"${name_escaped}\",\"description\":\"${description}\",\"domains\":\"${domains}\",\"check_count\":${check_count},\"doc\":\"${doc_path:-}\"}"
done

output+="\n  ]\n}\n"

# ── Write output ───────────────────────────────────────────────────────────
if [ -z "${OUTPUT_PATH}" ]; then
  OUTPUT_PATH="$(cd "${SCRIPT_DIR}/.." && pwd)/standards.json"
fi

printf "%b" "${output}" > "${OUTPUT_PATH}"
echo "Wrote standards registry to ${OUTPUT_PATH}"
echo "  Standards: ${#ALL_STANDARDS[@]}"
echo "  Domains: $(echo "${ALL_STANDARDS[@]}" | tr ' ' '\n' | while read -r s; do echo "${STANDARD_DOMAINS[$s]:-}"; done | tr ',' '\n' | sort -u | tr '\n' ' ')"
