# SVG Diagram Approach: Decision Guide

There are two SVG diagram standards in this workspace. This document explains when to use each.

## Mermaid Pipeline (`agentic-workflows/docs/svg-diagram-standards.md`)

**When to use:**
- Quick diagrams for documentation, READMEs, issue comments
- Diagrams that don't need pixel-perfect control
- When you want markdown-embedded diagrams that render on GitHub natively
- Flowcharts, sequence diagrams, state diagrams, ER diagrams

**Workflow:** Write `.mmd` → run `scripts/tools/render-mermaid.sh` → commit `.svg`

**Advantages:** Fast to author, zero pixel math, GitHub-native rendering

## Hand-Crafted SVG (`bus-hop/docs/svg-standards.md`)

**When to use:**
- Architecture and pipeline diagrams for READMEs where visual design matters
- Diagrams with custom colors, spacing, and layout that Mermaid can't produce
- When you want the bus-hop design language (`.bx`, `.gr`, `.or` classes) applied

**Workflow:** Write SVG by hand following the standard's formulas → commit `.svg`

**Advantages:** Complete visual control, consistent design language across all diagrams

## Rules

1. **Start with Mermaid.** If Mermaid produces acceptable output, use it.
2. **Only hand-craft if Mermaid can't achieve the layout you need.** The formulas in the hand-crafted standard are there for those cases.
3. **Never hand-edit a Mermaid-generated SVG.** If you need to modify the output, change the `.mmd` source and re-render.
4. **Both use `docs/diagrams/`** for output files.
