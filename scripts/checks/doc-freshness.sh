#!/usr/bin/env bash
# checks/doc-freshness.sh — Documentation Freshness audit checks.
#
# Sourced by audit.sh. Uses the framework from audit-lib.sh.
#
# Checks:
#   1. README.md was updated within last 20 commits (if code changed)
#   2. CHANGELOG.md has recent entries (if commits exist since last tag)
#   3. No doc files are older than 50 commits while source files changed
#   4. SECURITY.md exists if repo is public
#
# Uses _check_warn for stale-doc warnings (not failures).

set -euo pipefail

# ── Register this standard ────────────────────────────────────────────────
ALL_STANDARDS+=("doc-freshness")

# ── Standard entry point: checks ──────────────────────────────────────────
checks_doc_freshness() {
  local repo="$1"
  CURR_STANDARD="doc-freshness"

  _check_header "Documentation Freshness"

  # Skip if not a git repo
  if [ ! -d "${repo}/.git" ]; then
    _check_skip "doc-freshness-git" "Not a git repository"
    return 0
  fi

  # ── Check 1: README freshness relative to code changes ────────────────
  # If source files changed in last 20 commits, README should also have changed
  local recent_source_commits recent_readme_commits
  recent_source_commits=$(git -C "${repo}" log --oneline -20 --diff-filter=ACMR -- '*.rs' '*.ts' '*.py' '*.go' '*.js' '*.jsx' '*.tsx' '*.cs' 2>/dev/null | wc -l)
  recent_readme_commits=$(git -C "${repo}" log --oneline -20 -- README.md 2>/dev/null | wc -l)

  if [ "${recent_source_commits}" -gt 3 ] && [ "${recent_readme_commits}" -eq 0 ]; then
    _check_warn "readme-stale" \
      "README.md not updated in last 20 commits but ${recent_source_commits} source commits exist"
  else
    _check "readme-fresh" \
      "README.md is recent relative to code changes (${recent_readme_commits} updates in last 20 commits)" \
      true
  fi

  # ── Check 2: CHANGELOG freshness ──────────────────────────────────────
  # If commits exist since the last tag, CHANGELOG [Unreleased] should have content
  local changelog="${repo}/CHANGELOG.md"
  if [ -f "${changelog}" ]; then
    local last_tag commits_since_tag
    last_tag=$(git -C "${repo}" describe --tags --abbrev=0 2>/dev/null || echo "")
    if [ -n "${last_tag}" ]; then
      commits_since_tag=$(git -C "${repo}" rev-list "${last_tag}..HEAD" --count 2>/dev/null || echo "0")
    else
      commits_since_tag=$(git -C "${repo}" rev-list HEAD --count 2>/dev/null || echo "0")
    fi

    if [ "${commits_since_tag}" -gt 5 ]; then
      # Check if [Unreleased] has content beyond just a header
      local unreleased_content
      unreleased_content=$(sed -n '/^## \[Unreleased\]/,/^## \[/p' "${changelog}" 2>/dev/null | grep -c '^###' || echo "0")
      if [ "${unreleased_content}" -eq 0 ]; then
        _check_warn "changelog-stale" \
          "CHANGELOG.md [Unreleased] empty but ${commits_since_tag} commits since last tag"
      else
        _check "changelog-fresh" \
          "CHANGELOG.md [Unreleased] has ${unreleased_content} sections (${commits_since_tag} commits since tag)" \
          true
      fi
    else
      _check "changelog-fresh" \
        "CHANGELOG.md checked (${commits_since_tag} commits since last tag, within threshold)" \
        true
    fi
  else
    _check_skip "changelog-stale" "CHANGELOG.md does not exist"
  fi

  # ── Check 3: No significantly stale doc files ─────────────────────────
  # Find doc files whose last commit is >50 commits ago while source changed recently
  local stale_docs=()
  local doc_files
  doc_files=$(git -C "${repo}" ls-files '*.md' 2>/dev/null | grep -vE '(node_modules|target|\.omo/|test-results)' || true)

  if [ -n "${doc_files}" ]; then
    local total_commits
    total_commits=$(git -C "${repo}" rev-list HEAD --count 2>/dev/null || echo "0")

    if [ "${total_commits}" -gt 20 ]; then
      while IFS= read -r doc_file; do
        [ -z "${doc_file}" ] && continue
        # Skip generated/metadata files
        case "${doc_file}" in
          LICENSE|CREDITS.md|.omo/*) continue ;;
        esac

        local doc_age
        doc_age=$(git -C "${repo}" log -1 --format="%H" -- "${doc_file}" 2>/dev/null || echo "")
        if [ -n "${doc_age}" ]; then
          local doc_commit_num
          doc_commit_num=$(git -C "${repo}" rev-list "${doc_age}" --count 2>/dev/null || echo "0")
          local age_diff=$((total_commits - doc_commit_num))
          if [ "${age_diff}" -gt 50 ]; then
            stale_docs+=("${doc_file} (${age_diff} commits old)")
          fi
        fi
      done <<< "${doc_files}"
    fi
  fi

  if [ ${#stale_docs[@]} -gt 0 ]; then
    local stale_list
    stale_list=$(printf ', %s' "${stale_docs[@]}")
    stale_list="${stale_list:2}"  # Remove leading ", "
    _check_warn "stale-docs" \
      "${#stale_docs[@]} doc(s) older than 50 commits: ${stale_list}"
  else
    _check "docs-fresh" \
      "No significantly stale documentation files detected" \
      true
  fi

  # ── Check 4: SECURITY.md for public code repos ─────────────────────────
  # Only check if repo has source code (not docs-only)
  local has_source=false
  for src_dir in src/ lib/ app/ cmd/ crates/ workers/; do
    if [ -d "${repo}/${src_dir}" ]; then
      has_source=true
      break
    fi
  done
  # Also check for language-specific source files at root
  if ! ${has_source}; then
    for ext in rs ts py go js jsx tsx cs; do
      if ls "${repo}"/*."${ext}" 1>/dev/null 2>&1; then
        has_source=true
        break
      fi
    done
  fi

  if ${has_source} && [ -d "${repo}/.github/workflows" ]; then
    local security_file="${repo}/SECURITY.md"
    _check "security-md-exists" \
      "SECURITY.md exists" \
      test -f "${security_file}"
  elif [ -d "${repo}/.github/workflows" ]; then
    _check_skip "security-md-exists" "SECURITY.md skipped (docs-only repo)"
  fi
}
