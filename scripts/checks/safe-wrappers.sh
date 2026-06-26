#!/usr/bin/env bash
# checks/safe-wrappers.sh — Safe Wrappers Standard audit checks.
#
# Sourced by audit.sh. Uses the framework from audit-lib.sh.
# Sources in scripts/wrappers/, deployed to ~/.local/bin/.
#
# Checks:
#   1. All wrapper scripts exist in ~/.local/bin/
#   2. Each wrapper is executable
#   3. ~/.local/bin is on PATH
#   4. Canonical wrapper sources exist in scripts/wrappers/

set -euo pipefail

ALL_STANDARDS+=("safe-wrappers")
STANDARD_DOMAINS["safe-wrappers"]="security"

checks_safe_wrappers() {
  # shellcheck disable=SC2034 # used by audit-lib.sh
  local repo="$1" CURR_STANDARD="safe-wrappers"

  WRAPPERS=(git-safe-commit git-safe-push git-safe-normalize gh-safe-pr-create gh-ensure-signed-rules)
  CANONICAL_DIR="${repo}/scripts/wrappers"

  _check_header "Safe Wrappers Standard"

  # CI skip: ~/.local/bin/wrappers are workstation-only
  if [ -n "${CI:-}" ]; then
    _check "safe-wrappers-exist" "All safe wrappers exist in ~/.local/bin/ (skipped in CI)" true
    _check "safe-wrappers-executable" "All safe wrappers are executable (skipped in CI)" true
    _check "safe-wrappers-on-path" "\$HOME/.local/bin is on PATH (skipped in CI)" true
  else
    _check "safe-wrappers-exist" \
      "All safe wrappers exist in ~/.local/bin/" \
      bash -c "for w in ${WRAPPERS[*]}; do [ -x \"\${HOME}/.local/bin/\$w\" ] || exit 1; done"

    _check "safe-wrappers-executable" \
      "All safe wrappers are executable" \
      bash -c "for w in ${WRAPPERS[*]}; do [ -x \"\${HOME}/.local/bin/\$w\" ] || exit 1; done"

    _check "safe-wrappers-on-path" \
      "\$HOME/.local/bin is on PATH" \
      bash -c 'echo "$PATH" | tr ":" "\n" | grep -qx "${HOME}/.local/bin"'
  fi

  # Check 4: Canonical wrapper sources exist
  local all_exist=true
  for w in "${WRAPPERS[@]}"; do
    if [ ! -f "${CANONICAL_DIR}/$w" ]; then
      all_exist=false
      break
    fi
  done
  if [ "$all_exist" = true ]; then
    _check "safe-wrappers-canonical" \
      "Canonical wrapper sources exist in scripts/wrappers/" true
  else
    _check_fail "safe-wrappers-canonical" \
      "Some canonical wrapper sources missing from scripts/wrappers/"
  fi
}
