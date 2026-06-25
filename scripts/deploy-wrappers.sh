#!/usr/bin/env bash
# deploy-wrappers.sh — Install safe wrappers from scripts/wrappers/ to ~/.local/bin/.
#
# This makes the standards repo the authoritative source for safe wrappers.
# Run after updating wrappers to deploy system-wide.

set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "$0")/wrappers" && pwd)"
TARGET_DIR="${HOME}/.local/bin"

if [ ! -d "$SOURCE_DIR" ]; then
  echo "ERROR: Source wrappers directory not found: $SOURCE_DIR" >&2
  exit 1
fi

mkdir -p "$TARGET_DIR"

echo "Deploying wrappers from $SOURCE_DIR → $TARGET_DIR"
echo ""

count=0
for wrapper in "$SOURCE_DIR"/*; do
  wrapper_name="$(basename "$wrapper")"
  target="$TARGET_DIR/$wrapper_name"

  install -m 0755 "$wrapper" "$target"
  echo "  Installed: $wrapper_name"
  count=$((count + 1))
done

echo ""
echo "Done. $count wrappers deployed."
echo ""
echo "Verify with: ls -la ~/.local/bin/git-* ~/.local/bin/gh-*"
