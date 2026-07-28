#!/usr/bin/env bash
# install-ai-commit-hooks.sh --- One-liner to deploy AI commit automation.
#
# Usage: bash scripts/install-ai-commit-hooks.sh
#
# What it does:
#   1. Copies hooks (pre-commit, commit-msg, pre-push, prepare-commit-msg)
#      to ~/.config/git/ai-commit-hooks/
#   2. Sets core.hooksPath globally to that directory
#   3. Sets git aliases: ca, car, rb, ai-commit
#   4. Enables commit.gpgsign globally if not already set

set -euo pipefail

HOOKS_DIR="${HOME}/.config/git/ai-commit-hooks"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "==> Creating hooks directory..."
mkdir -p "$HOOKS_DIR"

echo "==> Deploying hooks..."
cp "$REPO_ROOT/scripts"/*.sh "$HOOKS_DIR/" 2>/dev/null || true
for hook in pre-commit commit-msg pre-push prepare-commit-msg; do
  src="$REPO_ROOT/scripts/$hook"
  if [ -f "$src" ]; then
    cp "$src" "$HOOKS_DIR/$hook"
    chmod +x "$HOOKS_DIR/$hook"
    echo "  $hook deployed"
  fi
done

echo "==> Setting core.hooksPath globally..."
git config --global core.hooksPath "$HOOKS_DIR"

echo "==> Setting git aliases..."
git config --global alias.ca '!f() { AI_COMMIT=1 AI_MODEL="${AI_MODEL:-DeepSeek V4 Flash (Max)}" AI_HARNESS="${AI_HARNESS:-oh-my-openagent (Sisyphus)}" GIT_COMMITTER_DATE="$(git log -1 --format=%aD HEAD 2>/dev/null || date)" git commit --amend "$@"; }; f'
git config --global alias.car '!f() { AI_COMMIT=1 AI_MODEL="${AI_MODEL:-DeepSeek V4 Flash (Max)}" AI_HARNESS="${AI_HARNESS:-oh-my-openagent (Sisyphus)}" GIT_COMMITTER_DATE="$(git log -1 --format=%aD HEAD 2>/dev/null || date)" git commit --amend --no-edit "$@"; }; f'
git config --global alias.rb 'rebase --committer-date-is-author-date'
git config --global alias.ai-commit '!f() { AI_COMMIT=1 AI_MODEL="${AI_MODEL:-DeepSeek V4 Flash (Max)}" AI_HARNESS="${AI_HARNESS:-oh-my-openagent (Sisyphus)}" git commit "$@"; }; f'

echo "==> Enabling commit.gpgsign..."
git config --global commit.gpgsign true

echo "==> Done! Summary:"
echo "  Hooks dir:  $HOOKS_DIR"
echo "  Hooks:      $(ls "$HOOKS_DIR" 2>/dev/null | tr '\n' ' ')"
echo "  Aliases:    ca (amend), car (amend-noedit), rb (rebase), ai-commit"
echo "  Signing:    commit.gpgsign = true"
echo ""
echo "  For AI tools: set AI_COMMIT=1 AI_MODEL=... AI_HARNESS=... before git commit"
echo "  Or use:       git ai-commit -m \"message\""
