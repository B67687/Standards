#!/usr/bin/env bash
_check_header "Secrets Management (sops/age)"

if [ -f "${repo}/.gitignore" ]; then
  _check "gitignore-env" \
    ".sops.yaml exists in repo" \
    test -f "${repo}/.sops.yaml"
else
  _check_fail "gitignore-env" ".gitignore not found"
fi

_check "sops-config" ".sops.yaml exists" \
  test -f "${repo}/.sops.yaml"

_check "env-encrypted" ".env.encrypted exists" \
  test -f "${repo}/.env.encrypted"

# Check .env excluded from git (explicitly or via whitelist)
if [ -f "${repo}/.gitignore" ]; then
  local has_env=false has_wl=false
  grep -qE '[.]env([^a-z]|$)' "${repo}/.gitignore" 2>/dev/null && has_env=true
  grep -qE '^[*]$|^/[*]$' "${repo}/.gitignore" 2>/dev/null && has_wl=true
  _check "env-in-gitignore" \
    ".env is excluded from git (explicit or whitelist)" \
    test "${has_env}" = true -o "${has_wl}" = true
else
  _check_fail "env-in-gitignore" ".gitignore not found"
fi

_check "age-key" "age key file exists for decryption" \
  test -f "${repo}/.age.key"
