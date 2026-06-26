# .gitignore Standard — Whitelist ("gitaccept") Approach

## Domains

universal,infra


## Philosophy
The traditional `.gitignore` uses a **blacklist**: allow everything, ignore specific patterns.
The whitelist approach ("gitaccept") inverts this: **ignore everything, accept specific patterns**.

```gitignore
# Whitelist (gitaccept):
# Nothing tracked by default, accept specific patterns
/*
!/src
!/src/*.py
```

**Why whitelist?** Prevents accidental commits of secrets, build artifacts, session data, and AI agent output.

## When to Use Whitelist vs Blacklist
| Factor              | Whitelist ("gitaccept")                                                 | Blacklist (traditional)                                          |
| ------------------- | ----------------------------------------------------------------------- | ---------------------------------------------------------------- |
| Safety              | ✅ **Best** — new file types silently ignored until explicitly accepted | ❌ Risk — new file types committed unless blacklisted            |
| Friction            | ❌ High — every new extension needs a `.gitignore` edit                 | ✅ Low — just works                                              |
| Performance         | ✅ Same for repos under ~50k files                                      | ✅ Same, scales to millions of files                             |
| Security model      | ✅ Default-deny                                                         | ❌ Default-allow                                                 |
| Repo size threshold | ✅ Good up to ~50k total files                                          | ✅ Good at any scale                                             |
| Best for            | Agentic/harness repos, security-hardened projects, small-team repos     | Open-source with many contributors, monorepos, rapid prototyping |

**Recommendation:** Use whitelist for harness repos and agent projects. Use blacklist for large open-source projects or polyglot monorepos.

## 1. Mechanics

Key rule: *It is not possible to re-include a file if a parent directory of that file is excluded.*

```gitignore
/*
!/src
/src/*
!/src/*.py
!/src/*.rs
```

**Anchoring:** `/*` matches top-level entries only (one level deep). `**/*.py` matches any `.py` at any depth (parent directory must be visible). Always use leading `/` at repo root.

**Evaluation:** Patterns evaluated top-to-bottom, last match wins. `!` negates the most recent matching ignore pattern.

## 2. Classification
| Tier   | Classification            | Handling             | Examples                                 |
| ------ | ------------------------- | -------------------- | ---------------------------------------- |
| **T1** | Always tracked            | Whitelisted with `!` | Source code, config, docs                |
| **T3** | Generated / never tracked | Listed in blacklist  | Build output, caches, agent session data |
| **T4** | External / never tracked  | Listed in blacklist  | OS files, editor state                   |

## 3. Whitelist Template
```gitignore
/*
!/*.md
!/*.sh
!/*.json
!.gitignore
!Dockerfile
!/src
/src/*
!/src/**/*.py
!/src/**/*.rs
!/src/**/*.ts
!/src/**/*.go
!/docs
/docs/*
!/docs/**/*.md
!/docs/**/*.svg
!/scripts
/scripts/*
!/scripts/**/*.sh
!/scripts/**/*.py
!/tests
/tests/*
!/tests/**/*.py
!/tests/**/*.ts
!/.github
/.github/*
!/.github/workflows
!/.github/dependabot.yml
!/config
/config/*
!/config/**/*
!/assets
/assets/*
!/assets/**/*.svg
!/assets/**/*.png
```

## 4. Blacklist Supplement
```gitignore
.env .env.* *.pem *.key *.cert *.keystore **/secrets*/ **/credentials*
node_modules/ __pycache__/ *.pyc *.pyo target/ build/ dist/ bin/ obj/ .venv/
.opencode/ *.mcp.json .runtime/ **/sessions/ AGENTS.md CLAUDE.md
.vscode/ *.swp *.swo *~ .DS_Store Thumbs.db *.log
.repo-map.cache/ *.index *.idx
```

## 5. Common Pitfalls
| Mistake                           | Why It Fails                                 | Fix                              |
| --------------------------------- | -------------------------------------------- | -------------------------------- |
| `!src/*.py` without `!/src`       | Parent dir excluded → git never looks inside | Add `!/src` then `/src/*` first  |
| `*` without leading `/`           | Matches anywhere in tree                     | Use `/*`                         |
| `!` before the pattern it negates | Last match wins                              | Put `!` AFTER the pattern        |
| Missing `/` on directories        | Pattern matches both files and dirs          | Use `/src/` for dirs             |
| Forgetting `**/` for nested paths | Only matches one level                       | Use `!/src/**/*.py`              |
| Not committing `.gitignore` first | First `git add` sweeps up everything         | Commit `.gitignore` before files |

## 6. References
- [git-scm.com/docs/gitignore](https://git-scm.com/docs/gitignore) — official docs
- [github/gitignore](https://github.com/github/gitignore) — official templates
- [git filter-repo](https://github.com/newren/git-filter-repo) — history cleanup
