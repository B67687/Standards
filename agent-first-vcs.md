# Agent-First VCS: Design Sketch

## The Problem

Git was designed (2005) for a workflow where a **human** writes code, one file at a time, with full intent. Everything in the working directory was put there deliberately. The question was "what should I exclude from tracking?"

AI agents (2026+) change this fundamentally:

| Old Assumption                             | New Reality                                               |
| ------------------------------------------ | --------------------------------------------------------- |
| Human writes every file with intent        | Agent generates files, intermediates, caches              |
| Working directory is deliberate            | Working directory is a mix of intent + ephemera           |
| `git add -A` stages intentional work       | `git add -A` sweeps unknown generated files               |
| Threat: accidentally committing `.o` files | Threat: leaking conversation traces, tool output, secrets |
| Blacklist is sufficient (known file types) | Blacklist is leaky (unknown file types proliferate)       |

## Requirements for an Agent-First VCS

### 1. Whitelist-Native by Default

A `git accept <pattern>` command that inverts the default: nothing is tracked unless explicitly accepted. The tracking database is `./.gitaccept` (analogous to `.gitignore` but inverted).

```
# ./.gitaccept — only these patterns are tracked
/src/**/*.py
/docs/**/*.md
/README.md
/Makefile
```

Everything else is invisible to `git status`, `git add -A`, `git add .`.

**The perf objection:** git's current directory-skip optimization assumes most dirs are INTENTIONAL content. An agent-first VCS's performance model assumes most dirs are ARTIFACTS. The file listing primitive fetches from the index/accept-list, not from the filesystem. The working tree is a sparse view of tracked paths.

### 2. Session-Aware Commits

An agent session generates multiple file changes. Each commit should carry provenance:

```bash
git commit --agent-session "session-abc123" \
  --model "DeepSeek V4 Flash" \
  --prompt "refactor the bus repository"
```

This metadata is queryable: `git log --grep="agent-session: abc123"`. The diff-tools can filter by:

- `git diff --agent-generated` — only AI-produced changes
- `git diff --human-written` — only manually authored
- `git blame --source ai` / `git blame --source human`

### 3. Provenance Tracking per File

Each tracked file carries a provenance attribute:

```ini
# .gitattributes equivalently
*.py provenance=ai-generated
*.md provenance=human-authored
**/config/*.yaml provenance=human-reviewed
```

This enables:

- CI to reject AI-written files in security-critical paths
- Code review to prioritise human-written diffs
- Blame to filter by source type
- Audit trail for compliance (which parts of this codebase are AI-generated?)

### 4. Ephemeral File Sandbox

A `.gitsandbox/` directory where agents can write ephemeral files without affecting `git status`. Files here are never tracked unless explicitly moved out:

```
.gitsandbox/
  analysis-temp/
  conversation-logs/
  search-cache/
  agent-state/
```

This removes the "noise" problem entirely — agents have a scratch space that's invisible to git by design.

### 5. Intent Signalling

Before an agent modifies a file, it must signal intent:

```bash
git claim docs/api.md  # "I'm about to edit this"
git release docs/api.md # "Done, ready for review"
```

This prevents two agents from editing the same file. The lock is advisory (can be overridden) but prevents silent conflicts.

### 6. Rolling Commits

An agent's work is automatically committed at configurable intervals (every N seconds, every M changes) with auto-generated messages. The human reviews the rollup before pushing.

```bash
git auto-commit --interval 60s --message "WIP: bus route refactoring"
```

---

## Existing Tools vs Greenfield

| Existing                         | What It Does                              | What It's Missing                                   |
| -------------------------------- | ----------------------------------------- | --------------------------------------------------- |
| **Git** + whitelist `.gitignore` | `/*` + `!` patterns                       | No native accept-command, no provenance, no sandbox |
| **Jujutsu (jj)**                 | Working copy as commit, undo, auto-rebase | Still uses git's ignore system                      |
| **gittuf** (OpenSSF)             | Repository security policy, verification  | Not a VCS replacement — policy layer on git         |
| **Fossil**                       | Built-in wiki, bug tracker, forum         | Same ignore model as git                            |
| **Pijul**                        | Patch theory, conflict management         | Different math, same ignore system                  |
| **Git LFS**                      | Large file pointer storage                | Extends git, doesn't change tracking model          |

**Gap:** No existing tool combines whitelist-native tracking, agent session awareness, and provenance metadata. The closest is `jj`'s working-copy model, but it still inherits git's ignore semantics.

---

## Open Questions

- **How does whitelist scale to 500k-file repos?** The performance model swaps filesystem-walk-for-status for index-lookup, which is O(tracked files) instead of O(all files). This is strictly better in the agent context where most files are ephemeral.
- **Should provenance be in git metadata or a separate database?** Git's existing `notes` mechanism could carry provenance. But query performance (`git blame --source ai`) would need index support.
- **Is the agent session concept VCS-level or tool-level?** If it's VCS-level, any agent tool can use it. If it's tool-level, each tool has its own convention.
- **Who manages the accept list?** The human, an agent at project init, or a convention shared across agents?

---

## Next Steps

This is a design sketch, not a spec. To move forward:

1. Validate the performance assumptions (benchmark file-walk vs index-lookup at repo scale)
2. Prototype a `git accept` command as a git wrapper (not core git — too slow to get in)
3. Define the provenance data schema (what fields, where stored, how queried)
4. Build a thin VCS layer on top of git that implements these features via existing git primitives

The goal is not to replace git — it's to build a **git-compatible agent layer** that sits on top and provides whitelist-native, provenance-aware, session-aware version control for AI-assisted development.
