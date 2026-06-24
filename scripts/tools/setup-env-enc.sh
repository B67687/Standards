#!/usr/bin/env bash
# setup-env-enc.sh — Bootstrap SOPS + age encrypted .env workflow.
#
# Usage: bash scripts/tools/setup-env-enc.sh [--sops-key <public-key>]
#
# If --sops-key is omitted, generates a new age keypair and uses that.
# Creates:
#   - .sops.yaml (if not exists)
#   - .env → .env.encrypted (if .env exists and .env.encrypted missing)
#   - .gitignore entries for .env (if missing)
#   - .gitattributes for cleartext diff (if missing)
#
# Run from repo root.

set -euo pipefail

SELF_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
cd "${SELF_DIR}"

# ── Check prerequisites ──────────────────────────────────────────────
command -v sops >/dev/null 2>&1 || { echo "ERROR: sops not found. Install: brew install sops or https://getsops.io"; exit 1; }
command -v age-keygen >/dev/null 2>&1 || { echo "ERROR: age not found. Install: brew install age or https://age-encryption.org"; exit 1; }

# ── Parse arguments ──────────────────────────────────────────────────
SOPS_KEY="${1:-}"
if [ -n "${SOPS_KEY}" ] && [ "${SOPS_KEY}" = "--sops-key" ]; then
  SOPS_KEY="$2"
fi

# ── Step 1: Ensure age key exists ────────────────────────────────────
AGE_KEY_DIR="${HOME}/.config/sops/age"
AGE_KEY_FILE="${AGE_KEY_DIR}/keys.txt"
SOPS_AGE_KEY=""

if [ -n "${SOPS_KEY}" ]; then
  # Use provided key
  if echo "${SOPS_KEY}" | grep -q '^age1'; then
    SOPS_AGE_KEY="${SOPS_KEY}"
  else
    echo "ERROR: Invalid age public key. Must start with 'age1'."
    exit 1
  fi
elif [ -f "${AGE_KEY_FILE}" ]; then
  echo "  ✓ Existing age key found at ${AGE_KEY_FILE}"
  SOPS_AGE_KEY="$(grep -oP '(?<=public key: ).*' "${AGE_KEY_FILE}" 2>/dev/null || true)"
  if [ -z "${SOPS_AGE_KEY}" ]; then
    # Try to extract from the key file directly
    SOPS_AGE_KEY="$(cat "${AGE_KEY_FILE}" | grep -v '^#' | head -1 || true)"
  fi
else
  echo "  → Generating age keypair..."
  mkdir -p "${AGE_KEY_DIR}"
  age-keygen -o "${AGE_KEY_FILE}"
  chmod 600 "${AGE_KEY_FILE}"
  echo "  ✓ Key saved to ${AGE_KEY_FILE}"
  echo "  ⚠ Keep this file SAFE. It can decrypt any secrets encrypted for its public key."
  SOPS_AGE_KEY="$(grep -oP '(?<=public key: ).*' "${AGE_KEY_FILE}")"
fi

if [ -z "${SOPS_AGE_KEY}" ]; then
  echo "ERROR: Could not determine age public key. Check ${AGE_KEY_FILE}."
  exit 1
fi
echo "  Public key: ${SOPS_AGE_KEY}"

# ── Step 2: Create .sops.yaml ────────────────────────────────────────
SOPS_CONFIG=".sops.yaml"
if [ -f "${SOPS_CONFIG}" ]; then
  echo "  ✓ ${SOPS_CONFIG} already exists"
else
  echo "  → Creating ${SOPS_CONFIG}..."
  cat > "${SOPS_CONFIG}" <<-SOPSEOF
# .sops.yaml — sops encryption configuration
creation_rules:
  - age: >-
      ${SOPS_AGE_KEY}
SOPSEOF
  echo "  ✓ Created ${SOPS_CONFIG}"
fi

# ── Step 3: Add .env to .gitignore ──────────────────────────────────
GITIGNORE=".gitignore"
IGNORE_ENTRIES=(
  ".env"
  ".env.*"
  "age-key.txt"
  "*.age"
)

for entry in "${IGNORE_ENTRIES[@]}"; do
  if [ -f "${GITIGNORE}" ] && grep -qF "${entry}" "${GITIGNORE}" 2>/dev/null; then
    :  # already present
  else
    echo "${entry}" >> "${GITIGNORE}"
    echo "  → Added '${entry}' to ${GITIGNORE}"
  fi
done

# ── Step 4: Create .gitattributes for cleartext diff ──────────────────
GITATTRIBUTES=".gitattributes"
if [ -f "${GITATTRIBUTES}" ] && grep -q 'sopsdiffer' "${GITATTRIBUTES}" 2>/dev/null; then
  echo "  ✓ git diff config already in ${GITATTRIBUTES}"
else
  echo "  → Adding sops cleartext diff config to ${GITATTRIBUTES}..."
  cat >> "${GITATTRIBUTES}" <<-ATTRSEOF

# sops-encrypted files — show decrypted content in diffs
*.encrypted diff=sopsdiffer
ATTRSEOF
  echo "  ✓ Run: git config diff.sopsdiffer.textconv 'sops decrypt'"
fi

# ── Step 5: Encrypt existing .env if needed ──────────────────────────
if [ -f ".env" ] && [ ! -f ".env.encrypted" ]; then
  echo "  → Encrypting .env → .env.encrypted..."
  sops encrypt .env > .env.encrypted
  echo "  ✓ Created .env.encrypted"
  echo "  ⚠ Verify .env.encrypted does NOT contain plaintext secrets:"
  echo "     grep -v '^#' .env.encrypted | head -20"
elif [ -f ".env.encrypted" ]; then
  echo "  ✓ .env.encrypted already exists"
else
  echo "  → No .env found. Create one, then run:"
  echo "     sops encrypt .env > .env.encrypted"
fi

# ── Summary ──────────────────────────────────────────────────────────
echo ""
echo "── Setup complete ────────────────────────────────────────"
echo ""
echo "Next steps:"
echo "  1. Add SOPS_AGE_KEY to your CI secrets:"
echo "     cat ${AGE_KEY_FILE} | pbcopy  # copy the whole file"
echo "     → GitHub: Settings → Secrets → Actions → SOPS_AGE_KEY"
echo ""
echo "  2. In CI workflows, add a step:"
echo "     - name: Decrypt secrets"
echo "       env:"
echo "         SOPS_AGE_KEY: \${{ secrets.SOPS_AGE_KEY }}"
echo "       run: sops decrypt --output-type dotenv .env.encrypted > .env"
echo ""
echo "  3. Decrypt locally:"
echo "     sops decrypt .env.encrypted > .env"
echo ""
echo "  4. Edit encrypted file:"
echo "     sops edit .env.encrypted"
