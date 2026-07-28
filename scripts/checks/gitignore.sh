#!/usr/bin/env bash
_check_header ".gitignore Standard"

_check "gitignore-exists" ".gitignore file exists at repo root" \
  test -f "${repo}/.gitignore"

if [ -f "${repo}/.gitignore" ]; then
  _check "whitelist-pattern" \
    ".gitignore has /* whitelist (block all at root)" \
    grep -qE '^\*$|^/\*$' "${repo}/.gitignore"
else
  _check_fail "whitelist-pattern" ".gitignore not found"
fi

if [ -f "${repo}/.gitignore" ]; then
  local neg_count
  neg_count="$(grep -c '^!' "${repo}/.gitignore" || true)"
  if [ "${neg_count}" -ge 3 ] 2>/dev/null; then
    _check "root-files-whitelisted" \
      "Has ${neg_count} negation patterns" true
  else
    _check_fail "root-files-whitelisted" \
      "Only ${neg_count:-0} negation patterns, need at least 3"
  fi
else
  _check_fail "root-files-whitelisted" ".gitignore not found"
fi

# Check 4: Secrets excluded (blocklist or whitelist)
if [ -f "${repo}/.gitignore" ]; then
  local has_blk=false has_wl=false
  grep -qE '[.]env|[*][.]pem|[*][*]/secrets[*]|[*][.]key' "${repo}/.gitignore" 2>/dev/null && has_blk=true
  grep -qE '^[*]$|^/[*]$' "${repo}/.gitignore" 2>/dev/null && has_wl=true
  _check "secret-blacklist" \
    ".gitignore excludes secrets (.env, *.pem, secrets, *.key)" \
    test "${has_blk}" = true -o "${has_wl}" = true
else
  _check_fail "secret-blacklist" ".gitignore not found"
fi

# Check 5: Build artifacts excluded (blocklist or whitelist)
if [ -f "${repo}/.gitignore" ]; then
  local has_art=false has_wl2=false
  grep -qE 'build/|dist/|target/|node_modules/' "${repo}/.gitignore" 2>/dev/null && has_art=true
  grep -qE '^[*]$|^/[*]$' "${repo}/.gitignore" 2>/dev/null && has_wl2=true
  _check "build-blacklist" \
    ".gitignore excludes build artifacts (build/, dist/, ...)" \
    test "${has_art}" = true -o "${has_wl2}" = true
else
  _check_fail "build-blacklist" ".gitignore not found"
fi

# Check 6: .gitignore tracked
if [ -f "${repo}/.gitignore" ]; then
  _check "gitignore-committed" ".gitignore tracked by git" \
    bash -c "cd '${repo}' && git ls-files --error-unmatch .gitignore &>/dev/null"
else
  _check_fail "gitignore-committed" ".gitignore not found"
fi

# Check 7: .env.enc not in gitignore
if [ -f "${repo}/.gitignore" ]; then
  local enc_count
  enc_count="$(grep -wcF '.env.enc' "${repo}/.gitignore" 2>/dev/null || true)"
  _check "env-enc-not-ignored" \
    ".env.enc is NOT in .gitignore (tracked for sops)" \
    test "${enc_count}" -eq 0
fi
