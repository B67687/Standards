# SVG Diagram Standards

A design system for hand-crafted technical diagrams, built on established graph drawing and information visualization research.

**Sources:** Sugiyama algorithm (1981), Graphviz DOT, ELK (Eclipse Layout Kernel), Colin Ware's _Information Visualization: Perception for Design_, Edward Tufte, UML 2.5 conventions, orthogonal graph drawing (Di Battista et al.).

---

## Part 1: Design System

### 1. File Format

- Hand-crafted inline SVG (no automated tool output)
- `viewBox="0 0 800 N"` where N = content bottom + `--graph-padding` (12px)
- No JavaScript, no external dependencies
- Self-contained with inline `<defs>` and `<style>`
- `<defs>` order: `<marker>` then `<style>` (marker must be defined before reference)
- All coordinates must be even integers — no fractional pixels

### 2. Boilerplate & CSS Vocabulary

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 300"
     font-family="-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Arial,sans-serif" font-size="12">
<defs>
<marker id="a" viewBox="0 0 10 10" refX="10" refY="5"
        markerWidth="8" markerHeight="8" orient="auto">
  <path d="M0,0 L10,5 L0,10Z" fill="#666"/>
</marker>
<style>
rect.bx{fill:#e8f4f8;stroke:#4a90d9;stroke-width:1.5;rx:5px}
rect.i,.ci{fill:#d4e8f0;stroke:#4a90d9;stroke-width:1;rx:3px}
rect.gr{fill:#d4edda;stroke:#5cb85c;stroke-width:1.5;rx:5px}
rect.or{fill:#fdf0d5;stroke:#f0ad4e;stroke-width:1;rx:3px}
rect.dc{fill:#f0f0f0;stroke:#999;stroke-width:1;rx:3px}
text.t{fill:#2c6fa0;font-weight:bold;font-size:14px;text-anchor:middle}
text.l{fill:#333;text-anchor:middle;font-size:12px}
text.s{fill:#555;text-anchor:middle;font-size:11px}
path.e{stroke:#666;stroke-width:1.5;fill:none;marker-end:url(#a)}
</style>
</defs>
<!-- diagram elements here -->
</svg>
```

| Class        | Fill           | Stroke    | Stroke-W | rx  | Semantics                                   |
| ------------ | -------------- | --------- | -------- | --- | ------------------------------------------- |
| `.bx`        | `#e8f4f8`      | `#4a90d9` | 1.5px    | 5px | **Container** — groups related components   |
| `.i` / `.ci` | `#d4e8f0`      | `#4a90d9` | 1px      | 3px | **Inner** — sub-items within a container    |
| `.gr`        | `#d4edda`      | `#5cb85c` | 1.5px    | 5px | **Primary** — key components, active steps  |
| `.or`        | `#fdf0d5`      | `#f0ad4e` | 1px      | 3px | **Transition** — network, build, transform  |
| `.dc`        | `#f0f0f0`      | `#999`    | 1px      | 3px | **Annotation** — notes, constraints, labels |
| `.t`         | text `#2c6fa0` | —         | —        | —   | **Title** — container headings, bold 14px   |
| `.l`         | text `#333`    | —         | —        | —   | **Label** — sub-box names, 12px             |
| `.s`         | text `#555`    | —         | —        | —   | **Small** — annotations, metadata, 11px     |
| `.e`         | fill none      | `#666`    | 1.5px    | —   | **Edge** — directional arrow path           |

**Color usage rules (from Ware, visual variable ranking):**

- **Position** (x,y) encodes structure — most important variable
- **Hue** (blue/green/orange/grey) encodes semantic role — max 7 distinct hues
- **Intensity** (stroke width 1.5px vs 1px) encodes hierarchy
- **Shape** (border radius: 5px containers vs 3px sub-boxes) is serial — use sparingly
- Never use **red** for anything non-error
- Never use **pure black** (`#000`) for text
- No complementary pairs adjacent at full saturation
- `.s` text uses `#555` not `#666` (WCAG 4.5:1 contrast)

### 2.1 Color Semantics

Every color must be documented in a **diagram key/legend**. Without a legend, the reader must guess what each color means. C4 model mandates that every diagram includes a key/legend explaining the notation.

| Class | Color | Meaning | When to Use |
|-------|-------|---------|-------------|
| `.bx` | Blue container | Structure, containment | Modules, packages, layers |
| `.i` / `.ci` | Light blue | Inner items, sub-components | Non-primary items, CI steps |
| `.gr` | Green | Primary/active | Core components, key workflow steps |
| `.or` | Orange | Transition/boundary | Network calls, build steps, transforms |
| `.dc` | Grey | Annotation/metadata | Notes, constraints, version info |
| `.t` | Dark blue text | Title | Section headings |
| `.l` | Dark grey text | Label | Box names |
| `.s` | Grey text | Small/annotation | Footnotes, metadata |

Add a legend block to every diagram — a compact box in the bottom-right or bottom-left corner showing the color → meaning mapping.

### 3. Spacing System

Established from Graphviz DOT, ELK, and Sugiyama conventions.

#### 3.1 Base Spacing Values

| Token              | Value    | Source                               |
| ------------------ | -------- | ------------------------------------ |
| `--layer-gap`      | **48px** | Graphviz `ranksep` = 0.5in at 96dpi  |
| `--node-gap`       | **24px** | Graphviz `nodesep` = 0.25in at 96dpi |
| `--edge-gap`       | **10px** | ELK `spacing.edgeEdge`               |
| `--edge-node-gap`  | **10px** | ELK `spacing.edgeNode`               |
| `--container-pad`  | **12px** | ELK `padding`                        |
| `--label-pad`      | **8px**  | ELK `nodeLabels.padding`             |
| `--graph-padding`  | **12px** | Graphviz `pad` ≈ 8pt at 96dpi        |
| `--sub-h`          | **28px** | Standard sub-box height              |
| `--sub-h-sm`       | **26px** | Compact sub-box height (data flow)   |
| `--sub-h-dc`       | **20px** | Annotation box height                |
| `--text-offset-28` | **18**   | Text y offset for 28px boxes         |
| `--text-offset-26` | **16**   | Text y offset for 26px boxes         |
| `--text-offset-20` | **13**   | Text y offset for 20px boxes         |
| `--text-offset-t`  | **20**   | Title y offset from container top    |

#### 3.2 Spacing Ratio Chain

From ELK defaults: `container-pad : node-gap : edge-gap : label-pad = 12 : 24 : 10 : 8`

- `node-gap` (24px) = 2× container-pad — related-group gap is half of unrelated gap (Gestalt proximity)
- `edge-gap` (10px) = `node-gap` / 2.4 — parallel edges need less separation than nodes
- `label-pad` (8px) = label visually groups with its container

#### 3.3 Spaciousness Scale

All spacing values can be scaled uniformly using a multiplier:

- **Tight** (1.0x): dense information display
- **Normal** (1.5x): standard readability
- **Relaxed** (2.0x): presentation/slide-friendly

---

## Part 2: Layout Formulas

Based on Sugiyama layered graph drawing (layer assignment → crossing minimization → coordinate assignment → edge routing) adapted for hand-crafted diagrams.

### 4. Container Sizing

#### 4.1 Container Height

Container height is determined by its CONTENTS, never hardcoded:

```
box_h = --container-pad + (N × --sub-h) + ((N-1) × --node-gap) + --container-pad
```

Where N = number of regular sub-boxes in the column.

For columns with a `.dc` annotation at the end:

```
box_h = --container-pad + (R × --sub-h) + ((R-1) × --node-gap) + --node-gap + --sub-h-dc + --container-pad
```

Where R = number of regular sub-boxes before the annotation.
Note: the gap before `.dc` uses the same `--node-gap` as regular gaps. There is no separate "dc gap" — the dc box gets 20px height and standard spacing.

#### 4.2 Column Alignment (Same Section)

**All containers in the same horizontal section must have the same height.**
The tallest container (by sub-box count) determines the height for all peers.

Shorter containers get EXTRA BOTTOM PADDING to match the tallest — never extra top padding.
Extra padding = `tallest_h - computed_h` (distributed to bottom only).

The `box_y` of all containers in a section is identical.

#### 4.3 Container Width

Container width is chosen by column type but must satisfy:

```
sub_w = box_w - (2 × --container-pad)
sub_w >= longest_label_width + (2 × --label-pad)
```

Where `longest_label_width ≈ label_chars × font_size × 0.6` (approximate).

**Never let text extend beyond the sub-box border.** If a label is too long:

1. Shorten the label (acronym + annotation)
2. Widen the container
3. Use multi-line (two `<tspan>` elements)

### 5. Sub-Box Positioning

Given a container at `(box_x, box_y)` with dimensions `(box_w, box_h)`:

```
sub_w  = box_w - (2 × --container-pad)
sub_x  = box_x + --container-pad
first_y = box_y + --container-pad
```

For the i-th sub-box (0-indexed):

```
sub_y[i]    = first_y + i × (--sub-h + --node-gap)
text_y[i]   = sub_y[i] + --text-offset-28     (for 28px boxes)
```

For mixed heights (regular + dc):

```
All regular: same formula as above using --sub-h
dc annotation: y = last_regular_y + --sub-h + --node-gap
```

Arrow path from sub-box i to sub-box i+1 (same column):

```
M{sub_x + sub_w/2},{sub_y[i] + sub_height} L{sub_x + sub_w/2},{sub_y[i+1]}
```

### 6. Column Layout & Centering

#### 6.1 Horizontal Distribution

Given M containers with widths `w_0, w_1, ..., w_{M-1}` and gaps between them:

```
total_span = sum(w_i) + (M-1) × --node-gap
start_x = (--viewbox-w - total_span) / 2
```

Container x positions:

```
x_0 = start_x
x_1 = x_0 + w_0 + --node-gap
x_2 = x_1 + w_1 + --node-gap
...
```

#### 6.2 Vertical Center (Cross-Column Arrows)

Cross-column arrows connect at the vertical center of each container:

```
cross_y = box_y + (box_h / 2)   // rounded to nearest even integer
```

Arrow path from left container's right edge to right container's left edge:

```
M{x_left + w_left},{cross_y} L{x_right},{cross_y}
```

### 7. Section Stacking

When a diagram has multiple horizontal sections stacked vertically:

```
next_section_y = current_section_y + current_section_h + --layer-gap
```

Where `--layer-gap` = 48px (between section bottoms and next section tops).

---

## Part 3: Edge Routing Rules

From orthogonal graph drawing conventions.

### 8. Arrow Conventions

| Edge Type                              | Style                                 | Source              |
| -------------------------------------- | ------------------------------------- | ------------------- |
| Sub-box → sub-box (same column)        | **Straight vertical**                 | Orthogonal: 0 bends |
| Cross-column (same section)            | **Straight horizontal** at cross_y    | Orthogonal: 0 bends |
| Sub-box → external (outside container) | **Straight vertical** or **90° bend** | ≤1 bend preferred   |
| Cross-section (vertical)               | **Straight vertical**                 | Orthogonal: 0 bends |

**Maximum bends per edge:**

- 0 bends: preferred (straight orthogonal)
- 1-2 bends: acceptable
- 3-4 bends: consider re-layering
- 5+ bends: redesign diagram (Ware: each bend reduces traceability ~15%)

**Arrow shape:**

```svg
<path d="M{cx},{source_y} L{cx},{target_y}" class="e"/>
```

- Arrow head length: 10px (defined in marker viewBox)
- Arrow head width: 8px (at widest point)
- `refX="10"` ensures arrow tip stops at exact target boundary
- Arrow head ≥ 3× line width (Tufte minimum effective difference)

---

## Part 4: Validation

### 9. Pre-Commit Checklist

- [ ] Every container's height is COMPUTED from its contents, not hardcoded
- [ ] All containers in the same horizontal section have IDENTICAL height
- [ ] Cross-column arrows align to vertical center of both containers
- [ ] No text extends beyond its box boundary
- [ ] All arrows connect at exact source bottom / target top coordinates
- [ ] Arrow marker `refX="10"` doesn't leave a gap to the target
- [ ] All coordinates are even integers
- [ ] ViewBox height = last element bottom + `--graph-padding` (12px)
- [ ] ≤7 distinct hues used
- [ ] ≤2 stroke widths used (1.5px + 1px)
- [ ] ≤2 arrow styles (solid + optionally dashed)
- [ ] No gradients, shadows, or 3D effects
- [ ] No dead CSS class definitions
- [ ] Root `<svg>` has explicit `font-size`
- [ ] SVG has `<title>` and `<desc>` for accessibility (screen reader support)
- [ ] Diagram includes a **legend block** (color → meaning mapping)
- [ ] Color is NOT the only differentiator — all colored elements have text labels

### 10. Complexity Limits

| Metric               | Max                                  | Source                                |
| -------------------- | ------------------------------------ | ------------------------------------- |
| Total nodes          | **20**                               | Ware: working memory limit            |
| Hierarchy depth      | **7±2**                              | Miller's Law                          |
| Bends per edge       | **4**                                | Ware: 15% readability drop per bend   |
| Distinct hues        | **7**                                | Ware: pre-attentive limit             |
| Font sizes           | **2** per diagram                    | Tufte: data-ink ratio                 |
| Stroke widths        | **2** (1.5px primary, 1px secondary) | Tufte: smallest effective difference  |
| Sub-boxes per column | **6**                                | Derived from 20 nodes / 3 avg columns |

### 11. Common Pitfalls

1. **Hardcoded height instead of computed**: Container height must use the formula: `pad + N×sub_h + (N-1)×gap + pad`. Never write `height="225"` without computing it.

2. **Unmatched column heights**: One column with 4 items and another with 2 items — the shorter column gets extra bottom padding to match the taller. If you skip this, cross-column arrows won't align.

3. **Cross-arrow at sub-box y instead of center**: Cross-column arrows connect at `box_y + box_h/2`, not at the y of any particular sub-box.

4. **Text overflow**: Label longer than `sub_w - 2×label_pad` will overflow. Measure before positioning.

5. **Tiny arrow body**: If gap between two connected boxes is < 12px, the arrow marker (10px) consumes almost the entire gap — leaving no visible arrow shaft. Minimum gap between connected box edges: **24px**.

6. **Dead CSS classes**: Remove any class not referenced by a diagram element.

7. **Fractional coordinates**: Odd pixel values cause sub-pixel rendering. Always round to even.

8. **ViewBox truncation**: After computing all positions, verify the lowest element + 12px fits within the viewBox height.

9. **Over-nesting**: More than 7 levels of nested containers violates Miller's Law. Flatten or split.

10. **Stale viewBox when adding elements**: Every time you add a row, annotation, or section, re-check the viewBox height.
