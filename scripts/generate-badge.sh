#!/usr/bin/env bash
# generate-badge.sh — Generate shields.io-style SVG badge
#
# Usage:
#   bash scripts/generate-badge.sh --label "tests" --value "161" --color "34A853"
#   bash scripts/generate-badge.sh --label "license" --value "MIT" --color "d8b800" --out docs/badges/license.svg
#   bash scripts/generate-badge.sh --label "Kotlin" --value "2.4" --color "7F52FF" --icon "kotlin"
#
# Options:
#   --label       Left-side text (required)
#   --value       Right-side text (required)
#   --color       Right-side hex color without # (required)
#   --label-color Left-side hex color (default: 555)
#   --out         Output path (default: docs/badges/{label}.svg)
#   --icon        Optional: embedded icon name (supported: kotlin, java, compose, python)

set -euo pipefail

# Parse args
LABEL=""
VALUE=""
COLOR=""
LABEL_COLOR="555"
OUT=""
ICON=""

while [[ $# -gt 0 ]]; do
  case "$1" in
  --label)
    LABEL="$2"
    shift 2
    ;;
  --value)
    VALUE="$2"
    shift 2
    ;;
  --color)
    COLOR="$2"
    shift 2
    ;;
  --label-color)
    LABEL_COLOR="$2"
    shift 2
    ;;
  --out)
    OUT="$2"
    shift 2
    ;;
  --icon)
    ICON="$2"
    shift 2
    ;;
  *)
    echo "Unknown option: $1"
    exit 1
    ;;
  esac
done

if [[ -z "$LABEL" || -z "$VALUE" || -z "$COLOR" ]]; then
  echo "Usage: $0 --label <text> --value <text> --color <hex> [--icon <name>] [--out <path>]"
  exit 1
fi

# Determine output path
if [[ -z "$OUT" ]]; then
  SAFE_LABEL=$(echo "$LABEL" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')
  OUT="docs/badges/${SAFE_LABEL}.svg"
fi

# Calculate widths (approximate: 7px per char for Verdana at scale .1, + padding)
LABEL_WIDTH=$((${#LABEL} * 7 + 20))
VALUE_WIDTH=$((${#VALUE} * 7 + 20))
TOTAL_WIDTH=$((LABEL_WIDTH + VALUE_WIDTH))

# Text positions (centered in each half)
LABEL_CENTER=$((LABEL_WIDTH / 2))
VALUE_CENTER=$((LABEL_WIDTH + VALUE_WIDTH / 2))

# Generate SVG
cat >"$OUT" <<SVGEOF
<svg xmlns="http://www.w3.org/2000/svg" width="${TOTAL_WIDTH}" height="20" role="img" aria-label="${LABEL}: ${VALUE}">
  <title>${LABEL}: ${VALUE}</title>
  <filter id="blur"><feGaussianBlur stdDeviation="16"/></filter>
  <linearGradient id="s" x2="0" y2="100%"><stop offset="0" stop-color="#bbb" stop-opacity=".1"/><stop offset="1" stop-opacity=".1"/></linearGradient>
  <clipPath id="r"><rect width="${TOTAL_WIDTH}" height="20" rx="3"/></clipPath>
  <g clip-path="url(#r)">
    <rect width="${LABEL_WIDTH}" height="20" fill="#${LABEL_COLOR}"/>
    <rect x="${LABEL_WIDTH}" width="${VALUE_WIDTH}" height="20" fill="#${COLOR}"/>
    <rect width="${TOTAL_WIDTH}" height="20" fill="url(#s)"/>
  </g>
  <g fill="#fff" text-anchor="middle" font-family="Verdana,Geneva,DejaVu Sans,sans-serif" text-rendering="geometricPrecision" font-size="110">
SVGEOF

# Add icon if specified (base64-encoded SVG data URIs)
case "$ICON" in
kotlin)
  cat >>"$OUT" <<'ICONEOF'
<image x="5" y="3" width="14" height="14" href="data:image/svg+xml;base64,PHN2ZyBmaWxsPSJ3aGl0ZSIgcm9sZT0iaW1nIiB2aWV3Qm94PSIwIDAgMjQgMjQiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PHRpdGxlPktvdGxpbjwvdGl0bGU+PHBhdGggZD0iTTI0IDI0SDBWMGgyNEwxMiAxMloiLz48L3N2Zz4="/>
ICONEOF
  ;;
java)
  cat >>"$OUT" <<'ICONEOF'
<image x="5" y="3" width="14" height="14" href="data:image/svg+xml;base64,PHN2ZyBmaWxsPSJ3aGl0ZSIgcm9sZT0iaW1nIiB2aWV3Qm94PSIwIDAgMjQgMjQiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PHRpdGxlPk9wZW5KREs8L3RpdGxlPjxwYXRoIGQ9Ik0xMS45MTUgMCAxMS43LjIxNUM5LjUxNSAyLjQgNy40NyA2LjM5IDYuMDQ2IDEwLjQ4M2MtMS4wNjQgMS4wMjQtMy42MzMgMi44MS0zLjcxMSAzLjU1MS0uMDkzLjg3IDEuNzQ2IDIuNjExIDEuNTUgMy4yMzUtLjE5OC42MjUtMS4zMDQgMS40MDgtMS4wMTQgMS45MzkuMS4xODguODIzLjAxMSAxLjI3Ny0uNDkxYTEzLjM4OSAxMy4zODkgMCAwIDAtLjAxNyAyLjE0Yy4wNzYuOTA2LjI3IDEuNjY4LjY0MyAyLjIzMi4zNzIuNTYzLjk1Ni45MTEgMS42NjcuOTExLjM5NyAwIC43MjctLjExNCAxLjAyNC0uMjY0LjI5OC0uMTQ5LjU3MS0uMzMuOTEtLjUuNjgtLjM0IDEuNjM0LS42NjYgMy41My0uNjA0IDEuOTAzLjA2MiAyLjg3Mi4zOSAzLjU1OS43MDQuNjg3LjMxNCAxLjE1LjY2NCAxLjkyNS42NjQuNzY3IDAgMS4zOTUtLjMzNiAxLjgwNy0uOS40MTItLjU2My42MzEtMS4zMy43Mi0yLjI0LjA2LS42MjMuMDU1LTEuMzIgMC0yLjA2Ni40NTQuNDUgMS4xMTcuNjA0IDEuMjEzLjQyNC4yOS0uNTMtLjgxNi0xLjMxNC0xLjAxMy0xLjkzNy0uMTk4LS42MjQgMS42NDItMi4zNjYgMS41NDktMy4yMzYtLjA4LS43NDgtMi43MDctMi41NjgtMy43NDgtMy41ODZDMTYuNDI4IDYuMzc0IDE0LjMwOCAyLjM5NCAxMi4xMy4yMTV6bS4xNzUgNi4wMzhhMi45NSAyLjk1IDAgMCAxIDIuOTQzIDIuOTQyIDIuOTUgMi45NSAwIDAgMS0yLjk0MyAyLjk0M0EyLjk1IDIuOTUgMCAwIDEgOS4xNDggOC45OGEyLjk1IDIuOTUgMCAwIDEgMi45NDItMi45NDJ6TTguNjg1IDcuOTgzYTMuNTE1IDMuNTE1IDAgMCAwLS4xNDUuOTk3YzAgMS45NTEgMS42IDMuNTUgMy41NSAzLjU1IDEuOTUgMCAzLjU1LTEuNTk4IDMuNTUtMy41NSAwLS4zMjktLjA0Ni0uNjQ4LS4xMzItLjk1MS4zMzQuMDk1LjY0LjIwOC45MTUuMzM2YTQyLjY5OSA0Mi42OTkgMCAwIDEgMi4wNDIgNS44MjljLjY3OCAyLjU0NSAxLjAxIDQuOTIuODQ2IDYuNjA3LS4wODIuODQ0LS4yOSAxLjUxLS42MDYgMS45NC0uMzE1LjQzMS0uNzEzLjY1MS0xLjMxNS42NTEtLjU5MyAwLS45MzItLjI3LTEuNjczLS42MS0uNzQxLS4zMzgtMS44MjUtLjY5NC0zLjc5Mi0uNzU4LTEuOTc0LS4wNjQtMy4wNzMuMjkzLTMuODIxLjY2OS0uMzc1LjE4OC0uNjU5LjM3My0uOTExLjVzLS40NjYuMi0uNzUyLjJjLS41MyAwLS44NzYtLjIwOS0xLjE2LS42NC0uMjg1LS40My0uNDc0LTEuMTAxLS41NDUtMS45NDgtLjE0MS0xLjY5My4xNzYtNC4wNjkuODIzLTYuNjE0YTQzLjE1NSA0My4xNTUgMCAwIDEgMS45MzQtNS43ODNjLjM0OC0uMTY3Ljc0OS0uMzEgMS4xOTItLjQyNXptLTMuMzgyIDQuMzYyYS4yMTYuMjE2IDAgMCAxIC4xMy4wMzFjLS4xNjYuNTYtLjMyMyAxLjExNi0uNDYzIDEuNjY1YTMzLjg0OSAzMy44NDkgMCAwIDAtLjU0NyAyLjU1NSAzLjkgMy45IDAgMCAwLS4yLS4zOWMtLjU4LTEuMDEyLS45MTQtMS42NDItMS4xNi0yLjA4LjMxNS0uMjQgMS42NzktMS43NTUgMi4yNC0xLjc4MXptMTMuMzk0LjAxYy41NjIuMDI3IDEuOTI2IDEuNTQzIDIuMjQgMS43ODMtLjI0Ni40MzgtLjU4IDEuMDY4LTEuMTYgMi4wOGE0LjQyOCA0LjQyOCAwIDAgMC0uMTYzLjMwOSAzMi4zNTQgMzIuMzU0IDAgMCAwLS41NjItMi40OSA0MC41NzkgNDAuNTc5IDAgMCAwLS40ODItMS42NTIuMjE2LjIxNiAwIDAgMSAuMTI3LS4wM3oiLz48L3N2Zz4="/>
ICONEOF
  ;;
esac

# Text output
cat >>"$OUT" <<SVGEOF
    <g transform="scale(.1)">
      <g aria-hidden="true" fill="#010101">
        <text x="$((LABEL_CENTER * 10))" y="150" fill-opacity=".8" filter="url(#blur)" textLength="$((${#LABEL} * 70))">${LABEL}</text>
        <text x="$((LABEL_CENTER * 10))" y="150" fill-opacity=".3" textLength="$((${#LABEL} * 70))">${LABEL}</text>
      </g>
      <text x="$((LABEL_CENTER * 10))" y="140" textLength="$((${#LABEL} * 70))">${LABEL}</text>
    </g>
    <g transform="scale(.1)">
      <g aria-hidden="true" fill="#010101">
        <text x="$((VALUE_CENTER * 10))" y="150" fill-opacity=".8" filter="url(#blur)" textLength="$((${#VALUE} * 70))">${VALUE}</text>
        <text x="$((VALUE_CENTER * 10))" y="150" fill-opacity=".3" textLength="$((${#VALUE} * 70))">${VALUE}</text>
      </g>
      <text x="$((VALUE_CENTER * 10))" y="140" textLength="$((${#VALUE} * 70))">${VALUE}</text>
    </g>
  </g>
</svg>
SVGEOF

mkdir -p "$(dirname "$OUT")"
echo "Generated: $OUT"
