# SVG Screenshot Standard

## Purpose

Screenshots in READMEs are currently PNG/JPEG — raster images that don't scale, look blurry on retina displays, and can't adapt to dark mode. SVG screenshots solve all three problems.

## Screenshot Types

### 1. Mobile App UI

**Use case:** bus-hop, any future Android/iOS app.

**Approach:**
- Capture screenshots as PNG from emulator/device at 3× resolution
- Convert to SVG via vectorization (or embed PNG as base64 inside SVG wrapper — smaller file, still scales well)
- Add optional device frame (phone outline) drawn in SVG shapes

**Convention:**
- Directory: `docs/screenshots/`
- File: `{screen-name}.svg`
- Size: viewBox proportional to original (e.g., 1080×2302 → `0 0 1080 2302`)
- Dark mode: use `<picture>` with `prefers-color-scheme` in README

### 2. CLI Terminal Output

**Use case:** harness repos showing agent interactions, review.sh output, git commands.

**Approach:**
- Record terminal session using `svg-term-cli` or `vhs` (charmbracelet)
- Output is natively SVG — terminal text as styled elements
- No conversion needed

**Convention:**
- Directory: `docs/screenshots/`
- File: `{command-name}-terminal.svg`
- Width: 800px standard
- Font: native terminal font (JetBrains Mono, Fira Code, or monospace)
- Dark background (`#1a1a2e`) with light text — standard terminal look

### 3. Web / Dashboard

**Use case:** traffic-dashboard, any future web project.

**Approach:**
- Capture using Playwright or Puppeteer screenshot as PNG
- Embed the PNG as base64 inside an SVG wrapper (SVG provides scaling and `<picture>` support)
- For dashboard data (charts, graphs) — prefer generating the SVG directly from data rather than screenshotting

**Convention:**
- Directory: `docs/screenshots/`
- File: `{page-name}-web.svg`
- Width: 1200px standard (desktop viewport)
- Dark mode: capture both light and dark variants, use `<picture>` tag in README

## Directory Structure

```
docs/
  screenshots/
    bus-hop-main.svg          # Mobile app
    bus-hop-search.svg        # Mobile app
    review-run.svg            # CLI terminal
    traffic-dashboard.svg     # Web / dashboard
```

## README Integration

```html
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/screenshots/app-main-dark.svg">
  <img src="docs/screenshots/app-main.svg" alt="App main screen">
</picture>
```

## Tools

| Type | Tool | Notes |
|------|------|-------|
| CLI terminal | `svg-term-cli` | Native SVG output from terminal recordings |
| CLI terminal | `vhs` (charmbracelet) | Record/script terminal sessions to GIF/SVG |
| Web screenshot | Playwright | Capture PNG, embed as base64 in SVG wrapper |
| Mobile screenshot | Android emulator + converter | Capture PNG, embed in SVG wrapper |
