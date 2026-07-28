#!/usr/bin/env bash
# set-repo-topics.sh — Apply standard topic sets to all B67687 repos
# Usage: bash scripts/set-repo-topics.sh [--dry-run]

DRY_RUN=false
[[ "$1" == "--dry-run" ]] && DRY_RUN=true

set_topics() {
    local repo="$1"
    shift
    local topics=("$@")

    if $DRY_RUN; then
        echo "[DRY-RUN] Would set topics for B67687/$repo: ${topics[*]}"
        return
    fi

    echo "Setting topics for B67687/$repo..."
    for topic in "${topics[@]}"; do
        gh repo edit "B67687/$repo" --add-topic "$topic" 2>/dev/null || true
    done
    echo "  Done: ${topics[*]}"
}

# === Harness repos ===
set_topics "Agentic-Workflows" \
    "agentic-workflows" "agent-harness" "ai-agents" "shell" "workflows" "dev-tools" "automation"

set_topics "Agent-Harness" \
    "agent-harness" "minimal" "policy" "shell" "ai-agents" "opencode"

# === Application / Library repos ===
set_topics "Ithmb-Codec" \
    "ithmb-codec" "csharp" "imageglass" "codec" "thumbnail" "plugin" "image-viewer"

set_topics "CS-Notes" \
    "cs-notes" "computer-science" "study-notes" "documentation" "hugo" "reference"

# === Forks (skip — no custom topics needed) ===
# B67687/Scoop — unmodified fork, skip

echo ""
if $DRY_RUN; then
    echo "Dry-run complete. Run without --dry-run to apply."
else
    echo "All topics applied."
fi
