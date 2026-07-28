#!/usr/bin/env bash
# dashboard.sh — Compliance dashboard generator.
#
# Reads aggregated audit results from audit-all.sh and produces:
#   1. .omo/dashboard/index.html — Self-contained HTML compliance dashboard
#   2. .omo/dashboard/compliance-matrix.json — Machine-readable export
#
# Usage:
#   dashboard.sh                              # uses .omo/dashboard/audit-results.json
#   dashboard.sh /path/to/audit-results.json  # custom input file
#   dashboard.sh --output /custom/dir/        # custom output dir
#   dashboard.sh --json-only                  # skip HTML generation
#   dashboard.sh --html-only                  # skip JSON matrix export
#   dashboard.sh --help
#
# Dependencies: bash, python3 or jq for JSON parsing

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

INPUT_FILE="${BASE_DIR}/.omo/dashboard/audit-results.json"
OUT_DIR="${BASE_DIR}/.omo/dashboard"
MODE_ALL=true
MODE_HTML=true
MODE_JSON=true

usage() {
  sed -n '3,14p' "${BASH_SOURCE[0]}"
  echo ""
  echo "  -i, --input FILE   Input JSON (default: .omo/dashboard/audit-results.json)"
  echo "  -o, --output DIR   Output directory (default: .omo/dashboard/)"
  echo "      --json-only    Only export compliance-matrix.json"
  echo "      --html-only    Only generate index.html"
  echo "      --help         Show this help"
}

log() { echo "[dashboard] $*" >&2; }
warn() { echo "[dashboard] WARNING: $*" >&2; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    -i|--input)   INPUT_FILE="$2"; shift 2 ;;
    -o|--output)  OUT_DIR="$2"; shift 2 ;;
    --json-only)  MODE_HTML=false; MODE_ALL=false; shift ;;
    --html-only)  MODE_JSON=false; MODE_ALL=false; shift ;;
    --help)       usage; exit 0 ;;
    *)
      if [[ "${MODE_ALL}" == true ]] && [[ "${INPUT_FILE}" == "${BASE_DIR}/.omo/dashboard/audit-results.json" ]]; then
        INPUT_FILE="$1"
        shift
      else
        echo "Unknown: $1" >&2
        usage >&2
        exit 1
      fi ;;
  esac
done

if ! command -v python3 &>/dev/null; then
  log "python3 is required for the dashboard"
  exit 1
fi

if [[ ! -f "${INPUT_FILE}" ]]; then
  log "Input file not found: ${INPUT_FILE}"
  log "Run audit-all.sh first to generate audit results."
  exit 1
fi

mkdir -p "${OUT_DIR}"

# ── Parse audit data and generate outputs via python3 ──────────────────────
python3 -c "
import json, os

with open('${INPUT_FILE}') as f:
    data = json.load(f)

repos = data.get('repos', [])
timestamp = data.get('timestamp', 'unknown')

# Re-compute (same logic as above)
standards_set = set()
standard_results = {}
for repo in repos:
    repo_name = repo['name']
    results = repo.get('audit', {}).get('results', [])
    for r in results:
        std = r['standard']
        status = r['status']
        standards_set.add(std)
        if std not in standard_results:
            standard_results[std] = {}
        if repo_name not in standard_results[std]:
            standard_results[std][repo_name] = []
        standard_results[std][repo_name].append(status)

standards = sorted(standards_set)
repo_names = [r['name'] for r in repos]

def aggregate_status(statuses):
    if not statuses:
        return 'skip'
    if all(s == 'pass' for s in statuses):
        return 'pass'
    if any(s == 'pending' for s in statuses):
        return 'pending'
    if any(s == 'fail' for s in statuses):
        return 'fail'
    return 'skip'

matrix = {}
for std in standards:
    matrix[std] = {}
    for repo_name in repo_names:
        statuses = standard_results.get(std, {}).get(repo_name, [])
        matrix[std][repo_name] = aggregate_status(statuses)

total_cells = len(standards) * len(repo_names)
pass_cells = sum(1 for std in standards for repo_name in repo_names if matrix[std][repo_name] == 'pass')
fail_cells = sum(1 for std in standards for repo_name in repo_names if matrix[std][repo_name] == 'fail')
pending_cells = sum(1 for std in standards for repo_name in repo_names if matrix[std][repo_name] == 'pending')
skip_cells = sum(1 for std in standards for repo_name in repo_names if matrix[std][repo_name] == 'skip')
scored = total_cells - skip_cells
compliance_pct = round(pass_cells / scored * 100) if scored > 0 else 0

abbrev = {
    'adr': 'ADR', 'ai-attribution': 'Attrib', 'auto-commit-gitops': 'GitOps',
    'badge-quality': 'BadgeQ', 'badge-shell': 'Badge', 'changelog': 'CLog',
    'ci-pipeline': 'CI', 'commit-conventions': 'Commit', 'github-topics': 'Topics',
    'gitignore': 'GitIgn', 'license': 'License', 'naming-conventions': 'Naming',
    'readme-quality': 'ReadmeQ', 'repo-structure': 'Struct', 'svg-screenshots': 'SVGSS'
}
full_names = {k: k.replace('-', ' ').title() for k in abbrev}

# Build HTML
html = []

html.append('''<!DOCTYPE html>
<html lang=\"en\">
<head>
<meta charset=\"UTF-8\">
<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
<title>Standards Compliance Dashboard</title>
<style>
  *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
  body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #0d1117; color: #e6edf3; padding: 24px; }
  h1 { font-size: 24px; margin-bottom: 8px; }
  .timestamp { color: #8b949e; font-size: 13px; margin-bottom: 24px; }
  .summary { display: flex; gap: 16px; margin-bottom: 24px; flex-wrap: wrap; }
  .stat { background: #161b22; border: 1px solid #30363d; border-radius: 8px; padding: 16px 24px; text-align: center; min-width: 100px; }
  .stat .num { font-size: 28px; font-weight: 600; }
  .stat .label { font-size: 12px; color: #8b949e; margin-top: 4px; }
  .pass { color: #2ea44f; }
  .fail { color: #cf222e; }
  .pending { color: #d8b800; }
  .skip { color: #6e7681; }
  .matrix-wrap { overflow-x: auto; margin-bottom: 32px; }
  table { border-collapse: collapse; font-size: 12px; }
  th, td { border: 1px solid #30363d; padding: 6px 8px; text-align: center; white-space: nowrap; }
  th { background: #161b22; font-weight: 600; position: sticky; top: 0; }
  th.repo-name { text-align: left; min-width: 140px; }
  td.cell { min-width: 28px; font-size: 14px; }
  td.cell.pass { background: rgba(46, 164, 79, 0.15); }
  td.cell.fail { background: rgba(207, 34, 46, 0.15); }
  td.cell.pending { background: rgba(216, 184, 0, 0.15); }
  td.cell.skip { background: transparent; }
  .legend { display: flex; gap: 16px; margin-bottom: 24px; font-size: 12px; color: #8b949e; }
  .legend span { display: flex; align-items: center; gap: 4px; }
  .legend .box { width: 14px; height: 14px; border-radius: 3px; display: inline-block; }
  .section { margin-bottom: 32px; }
  .section h2 { font-size: 18px; margin-bottom: 12px; border-bottom: 1px solid #30363d; padding-bottom: 8px; }
  .repo-detail { background: #161b22; border: 1px solid #30363d; border-radius: 8px; margin-bottom: 12px; overflow: hidden; }
  .repo-detail summary { padding: 12px 16px; cursor: pointer; font-weight: 600; font-size: 14px; }
  .repo-detail summary:hover { background: #1c2128; }
  .repo-detail .details { padding: 0 16px 16px; }
  .repo-detail .standard-group { margin-bottom: 12px; }
  .repo-detail .standard-group h4 { font-size: 13px; margin-bottom: 4px; color: #8b949e; }
  .repo-detail .check { display: flex; align-items: center; gap: 6px; font-size: 12px; padding: 2px 0; }
  .repo-detail .check .icon { font-size: 14px; width: 16px; text-align: center; }
  .per-std-breakdown { width: 100%; font-size: 12px; }
  .per-std-breakdown td { padding: 6px 8px; }
  td.repo-label { max-width: 140px; overflow: hidden; text-overflow: ellipsis; }
</style>
</head>
<body>
''')

# Title & timestamp
html.append(f'<h1>Standards Compliance Dashboard</h1>')
html.append(f'<p class=\"timestamp\">Generated: {timestamp} &middot; {len(repos)} repos &middot; {len(standards)} standards</p>')

# Summary stats
html.append(f'''<div class=\"summary\">
  <div class=\"stat\"><div class=\"num pass\">{compliance_pct}%</div><div class=\"label\">Compliance</div></div>
  <div class=\"stat\"><div class=\"num\">{total_cells}</div><div class=\"label\">Total Checks</div></div>
  <div class=\"stat\"><div class=\"num pass\">{pass_cells}</div><div class=\"label\">Pass</div></div>
  <div class=\"stat\"><div class=\"num fail\">{fail_cells}</div><div class=\"label\">Fail</div></div>
  <div class=\"stat\"><div class=\"num pending\">{pending_cells}</div><div class=\"label\">Pending Review</div></div>
  <div class=\"stat\"><div class=\"num skip\">{skip_cells}</div><div class=\"label\">N/A</div></div>
</div>
<div class=\"legend\">
  <span><span class=\"box\" style=\"background:#2ea44f\"></span> Pass</span>
  <span><span class=\"box\" style=\"background:#cf222e\"></span> Fail</span>
  <span><span class=\"box\" style=\"background:#d8b800\"></span> Pending</span>
  <span><span class=\"box\" style=\"background:#6e7681\"></span> N/A</span>
</div>
''')

# Compliance matrix
html.append('<div class=\"matrix-wrap\"><table><thead><tr><th class=\"repo-name\">Repo</th>')
for std in standards:
    abv = abbrev.get(std, std[:8])
    html.append(f'<th title=\"{full_names.get(std, std)}\">{abv}</th>')
html.append('<th>Score</th></tr></thead><tbody>')

for repo_name in repo_names:
    pass_std = sum(1 for std in standards if matrix[std][repo_name] == 'pass')
    fail_std = sum(1 for std in standards if matrix[std][repo_name] == 'fail')
    pending_std = sum(1 for std in standards if matrix[std][repo_name] == 'pending')
    scored_std = len(standards) - sum(1 for std in standards if matrix[std][repo_name] == 'skip')
    pct = round(pass_std / scored_std * 100) if scored_std > 0 else 0

    html.append(f'<tr><td class=\"repo-label\">{repo_name}</td>')
    for std in standards:
        status = matrix[std][repo_name]
        symbol = '&#10003;' if status == 'pass' else '&#10007;' if status == 'fail' else '&#8987;' if status == 'pending' else '&#8212;'
        html.append(f'<td class=\"cell {status}\">{symbol}</td>')
    html.append(f'<td><span class={\"pass\" if pct >= 70 else \"fail\" if pct < 50 else \"pending\"}>{pct}%</span></td>')
    html.append('</tr>')

html.append('</tbody></table></div>')

# Per-repo details
html.append('<div class=\"section\"><h2>Per-Repo Details</h2>')

for repo in repos:
    repo_name = repo['name']
    results = repo.get('audit', {}).get('results', [])

    # Group results by standard
    groups = {}
    for r in results:
        std = r['standard']
        if std not in groups:
            groups[std] = []
        groups[std].append(r)

    html.append(f'<details class=\"repo-detail\"><summary>{repo_name} ({len(results)} checks)</summary><div class=\"details\">')

    for std in sorted(groups.keys()):
        html.append(f'<div class=\"standard-group\"><h4>{full_names.get(std, std)}</h4>')
        for check in groups[std]:
            s = check['status']
            icon = '&#10003;' if s == 'pass' else '&#10007;' if s == 'fail' else '&#8987;' if s == 'pending' else '&#8212;'
            cls = s
            html.append(f'<div class=\"check\"><span class=\"icon {cls}\">{icon}</span> {check[\"description\"]}</div>')
        html.append('</div>')

    html.append('</div></details>')

html.append('</div>')

# Footer
html.append('''<div style=\"text-align:center;color:#8b949e;font-size:12px;padding:24px 0\">
Generated by <a href=\"./compliance-matrix.json\" style=\"color:#58a6ff\">Standards Audit System</a>
</div>
</body>
</html>''')

# Export compliance-matrix.json
compliance = {
    'timestamp': timestamp,
    'repos': {},
    'summary': {
        'total': total_cells,
        'pass': pass_cells,
        'fail': fail_cells,
        'pending': pending_cells,
        'skip': skip_cells,
        'pass_percent': compliance_pct
    }
}
for repo_name in repo_names:
    compliance['repos'][repo_name] = {}
    for std in standards:
        compliance['repos'][repo_name][std] = matrix[std][repo_name]

if '${MODE_JSON}' == 'true':
    matrix_path = os.path.join('${OUT_DIR}', 'compliance-matrix.json')
    with open(matrix_path, 'w') as f:
        json.dump(compliance, f, indent=2)
    print(f'[dashboard] Written: {matrix_path}')

if '${MODE_HTML}' == 'true':
    html_path = os.path.join('${OUT_DIR}', 'index.html')
    with open(html_path, 'w') as f:
        f.writelines(html)
    print(f'[dashboard] Written: {html_path}')
" 2>&1
