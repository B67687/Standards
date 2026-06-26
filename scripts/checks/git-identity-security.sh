#!/usr/bin/env bash
# checks/git-identity-security.sh — Git Identity Security Standard audit checks.
#
# Sourced by audit.sh. Uses the framework from audit-lib.sh.
#
# Checks:
#   1. Global user.useConfigOnly is true
#   2. Global user.name is set
#   3. Global user.email is set
#   4. SSH signing key file exists
#   5. Global gpg.format is ssh
#   6. Global commit.gpgsign is true
#   7. SSH allowedSignersFile exists

set -euo pipefail

ALL_STANDARDS+=("git-identity-security")
STANDARD_DOMAINS["git-identity-security"]="security,universal"

checks_git_identity_security() {
  # shellcheck disable=SC2034 # used by audit-lib.sh
  local repo="$1" CURR_STANDARD="git-identity-security"

  _check_header "Git Identity Security Standard"

  # CI skip: no global git identity on runners
  if [ -n "${CI:-}" ]; then
    _check "git-identity-use-config-only" "Global user.useConfigOnly is true (skipped in CI)" true
    _check "git-identity-user-name" "Global user.name is set (skipped in CI)" true
    _check "git-identity-user-email" "Global user.email is set (skipped in CI)" true
    _check "git-identity-signing-key" "SSH signing key file exists (skipped in CI)" true
    _check "git-identity-gpg-format" "Global gpg.format is ssh (skipped in CI)" true
    _check "git-identity-commit-gpgsign" "Global commit.gpgsign is true (skipped in CI)" true
    _check "git-identity-allowed-signers" "SSH allowedSignersFile exists (skipped in CI)" true
    return 0
  fi

  _check "git-identity-use-config-only" \
    "Global user.useConfigOnly is true" \
    bash -c 'git config --global user.useConfigOnly 2>/dev/null | grep -qx "true"'

  _check "git-identity-user-name" \
    "Global user.name is set" \
    bash -c 'git config --global user.name 2>/dev/null | grep -q .'

  _check "git-identity-user-email" \
    "Global user.email is set" \
    bash -c 'git config --global user.email 2>/dev/null | grep -q .'

  _check "git-identity-signing-key" \
    "SSH signing key file exists" \
    bash -c 'key=$(git config --global user.signingkey 2>/dev/null || true); [ -n "$key" ] && [ -f "${key/#\~/$HOME}" ]'

  _check "git-identity-gpg-format" \
    "Global gpg.format is ssh" \
    bash -c 'git config --global gpg.format 2>/dev/null | grep -qx "ssh"'

  _check "git-identity-commit-gpgsign" \
    "Global commit.gpgsign is true" \
    bash -c 'git config --global commit.gpgsign 2>/dev/null | grep -qx "true"'

  _check "git-identity-allowed-signers" \
    "SSH allowedSignersFile exists" \
    bash -c 'file=$(git config --global gpg.ssh.allowedSignersFile 2>/dev/null || true); [ -n "$file" ] && [ -f "${file/#\~/$HOME}" ]'
}
