.PHONY: audit audit-exit shellcheck check test lint help

# ── Self-audit ─────────────────────────────────────────────────────────────
audit:   ## Run self-audit (standards compliance check)
	./scripts/audit.sh .

audit-exit:  ## Run self-audit with exit code (CI gate: exit 1 on failure)
	./scripts/audit.sh --exit-code .

# ── Linting ────────────────────────────────────────────────────────────────
shellcheck:  ## Shellcheck all scripts
	shellcheck --severity=warning scripts/*.sh scripts/checks/*.sh

# ── Tests ────────────────────────────────────────────────────────────────
test:  ## Run test suite (tests/check-framework.test.sh)
	bash tests/check-framework.test.sh

# ── Convenience ────────────────────────────────────────────────────────────
check: audit-exit shellcheck test  ## Run full self-check (audit + shellcheck + tests)
lint: shellcheck              ## Alias for shellcheck

help:  ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'
