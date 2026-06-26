# Agent Evaluation Standard

## Domains

ai,quality


## What

Agent evaluation extends deterministic shell checks with LLM-as-judge for subjective quality assessments that cannot be automated purely through shell logic.

## When to Use

Use agent evaluation for checks that require human-level judgment:

- **Visual quality** — badge SVG correctness (viewBox, colors, text legibility)
- **Accessibility** — SVG `aria-labelledby`, `title`, `desc` for screen readers
- **Content quality** — README clarity, description length, section ordering
- **Any subjective criterion** — design taste, UX consistency, prose quality

Do NOT use agent evaluation for checks that a shell script can decide (file exists, pattern matches, line count, exit code).

## Mechanism

Agent-evaluated checks follow this pipeline:

```
check script → _agent_eval_check() → reads agent-results/*.json → pass/fail/pending
```

Check scripts in `scripts/checks/` call `_agent_eval_check()` from [`audit-lib.sh`](scripts/audit-lib.sh). This function reads a JSON result file from `.omo/audit/agent-results/`:

```json
{
  "status": "pass",
  "summary": "All badges include viewBox attribute",
  "checked_by": "gpt-4o",
  "checked_at": "2026-06-25T12:00:00Z"
}
```

If no result file exists, the check is marked **pending** (yellow). The results are produced by an LLM evaluator (in CI or locally via `agent-check.sh`) and committed to `.omo/audit/agent-results/`.

## Bias Mitigation

LLM-as-judge is a recognized methodology but carries inherent biases. The following mitigations are applied:

| Bias | Risk | Mitigation |
|------|------|------------|
| **Position bias** | Judge prefers the first option presented | Randomize or rotate evaluation order. Present options as unordered sets where possible. |
| **Verbosity bias** | Longer answers rated higher | Check against objective criteria (file exists, pattern matches designated field) before subjective judgment. Use yes/no prompts over open-ended scoring. |
| **Self-preference** | AI models favor own outputs | Never ask "is this good?" — instead ask "does this file contain X field?" or "does this SVG have a viewBox attribute?" Objective pass/fail criteria reduce subjectivity. |
| **Calibration drift** | Judgment quality varies by model and version | Pin evaluator model version. Document which model produced each result in `checked_by` field. |

### Verification Cadence

Agent-evaluated results are **snapshots**, not real-time guarantees. They are valid until the evaluated files change. Re-run agent evaluation:

- After any edit to the evaluated file
- When upgrading the evaluator model
- Periodically (monthly) for stale results

### Transparency

Every agent evaluation result records:
- `checked_by` — which model/judge made the assessment
- `checked_at` — when the assessment was made
- `summary` — the evidence or reasoning

This allows tracing which checks were evaluated by which model and when, enabling audits of evaluator consistency over time.

## File Locations

| Path | Purpose |
|------|---------|
| `.omo/audit/agent-evals/` | JSON evaluation requests (prompts for the LLM) |
| `.omo/audit/agent-results/` | JSON evaluation results (pass/fail + evidence) |
| `scripts/agent-check.sh` | Dispatcher — processes evals and produces results |

## See Also

- [`audit-lib.sh`](scripts/audit-lib.sh) — `_agent_eval_check()` implementation
- [`agent-check.sh`](scripts/agent-check.sh) — evaluation dispatcher
