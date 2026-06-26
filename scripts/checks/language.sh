#!/usr/bin/env bash
# Language Standard check — enforces American English spelling.
set -euo pipefail

ALL_STANDARDS+=("language")
STANDARD_DOMAINS["language"]="docs"

checks_language() {
  local repo="${1:-${REPO_PATH}}"
  [ -n "${repo}" ] || repo="${PWD}"
  CURR_STANDARD="language"
  _check_header "${CURR_STANDARD}"

  # Scan markdown files, excluding standard doc itself, .omo plans, research, node_modules, .git
  local find_expr=( -name '*.md' ! -path '*/node_modules/*' ! -path '*/.git/*' ! -path '*/docs/standards/language-standard.md' ! -path '*/.omo/*' ! -path '*/docs/research/*' )

  # ── British -our → American -or ──────────────────────────────────────────
  local our_hits
  our_hits="$(find "${repo}" "${find_expr[@]}" -exec grep -HnE '\b(colour|behaviour|favour|honour|neighbour|rumour|labour|vapour|harbour|flavour)\b' {} + 2>/dev/null || true)"
  if [ -n "${our_hits}" ]; then
    local brief; brief="$(echo "${our_hits}" | head -3 | tr '\n' ' ')"
    _check_fail "american-or" "British -our spelling found (use -or): ${brief}"
  else
    _check "american-or" "No British -our spellings detected" true
  fi

  # ── British -re → American -er ───────────────────────────────────────────
  local re_hits
  re_hits="$(find "${repo}" "${find_expr[@]}" -exec grep -HnE '\b(centre|metre|litre|theatre|calibre|fibre|spectre|sombre)\b' {} + 2>/dev/null || true)"
  if [ -n "${re_hits}" ]; then
    local brief2; brief2="$(echo "${re_hits}" | head -3 | tr '\n' ' ')"
    _check_fail "american-er" "British -re spelling found (use -er): ${brief2}"
  else
    _check "american-er" "No British -re spellings detected" true
  fi

  # ── British -ise → American -ize ─────────────────────────────────────────
  local ise_hits
  ise_hits="$(find "${repo}" "${find_expr[@]}" -exec grep -HnE '\b(standardise|organise|recognise|customise|optimise|minimise|maximise|utilise|authorise|visualise)\b' {} + 2>/dev/null || true)"
  if [ -n "${ise_hits}" ]; then
    local brief3; brief3="$(echo "${ise_hits}" | head -3 | tr '\n' ' ')"
    _check_fail "american-ize" "British -ise spelling found (use -ize): ${brief3}"
  else
    _check "american-ize" "No British -ise spellings detected" true
  fi

  # ── British -ogue → American -og ─────────────────────────────────────────
  local ogue_hits
  ogue_hits="$(find "${repo}" "${find_expr[@]}" -exec grep -HnE '\b(dialogue|catalogue|analogue|monologue|prologue|epilogue)\b' {} + 2>/dev/null || true)"
  if [ -n "${ogue_hits}" ]; then
    local brief4; brief4="$(echo "${ogue_hits}" | head -3 | tr '\n' ' ')"
    _check_fail "american-og" "British -ogue spelling found (use -og): ${brief4}"
  else
    _check "american-og" "No British -ogue spellings detected" true
  fi

  # ── British -ce (noun) → American -se ────────────────────────────────────
  local ce_hits
  ce_hits="$(find "${repo}" "${find_expr[@]}" -exec grep -HnE '\b(defence|pretence|offence|licence)\b' {} + 2>/dev/null || true)"
  if [ -n "${ce_hits}" ]; then
    local brief5; brief5="$(echo "${ce_hits}" | head -3 | tr '\n' ' ')"
    _check_fail "american-se" "British -ce (noun) spelling found (use -se): ${brief5}"
  else
    _check "american-se" "No British noun -ce spellings detected" true
  fi

  # ── British -t → American -ed ────────────────────────────────────────────
  local ed_hits
  ed_hits="$(find "${repo}" "${find_expr[@]}" -exec grep -HnE '\b(learnt|spelt|burnt|dreamt|leapt|knelt)\b' {} + 2>/dev/null || true)"
  if [ -n "${ed_hits}" ]; then
    local brief6; brief6="$(echo "${ed_hits}" | head -3 | tr '\n' ' ')"
    _check_fail "american-ed" "British -t past tense found (use -ed): ${brief6}"
  else
    _check "american-ed" "No British -t past tense spellings detected" true
  fi

  # ── British misc ─────────────────────────────────────────────────────────
  local misc_hits
  misc_hits="$(find "${repo}" "${find_expr[@]}" -exec grep -HnE '\b(towards|amongst|whilst|programme|colourise|aluminium)\b' {} + 2>/dev/null || true)"
  if [ -n "${misc_hits}" ]; then
    local brief7; brief7="$(echo "${misc_hits}" | head -3 | tr '\n' ' ')"
    _check_fail "american-misc" "British misc spelling found: ${brief7}"
  else
    _check "american-misc" "No British misc spellings detected" true
  fi
}
