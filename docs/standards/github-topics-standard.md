# GitHub Repo Topics Standard

## Domains

docs


## Why Topics Matter

GitHub repo topics are the primary **discoverability** mechanism. They appear in:

- Repo sidebar and header
- GitHub Explore / Trending pages
- GitHub search results
- Topic pages (github.com/topics/{topic})

Without topics, repos are invisible to anyone browsing by category. They only appear in direct searches or if someone knows the repo name.

## Convention

- Topics are **lowercase**, hyphen-separated
- 4-8 topics per repo (GitHub allows up to 20)
- First topic is always the **project name** (if it's a standalone project)
- Followed by: **language(s)** → **domain** → **key technologies** → **purpose**

## Topic Sets by Repo Type

### Harness / Workflow Repos

| Repo              | Topics                                                                                             |
| ----------------- | -------------------------------------------------------------------------------------------------- |
| Agentic-Workflows | `agentic-workflows`, `agent-harness`, `ai-agents`, `shell`, `workflows`, `dev-tools`, `automation` |
| Agent-Harness     | `agent-harness`, `minimal`, `policy`, `shell`, `ai-agents`, `opencode`                             |

### Application / Library Repos

| Repo              | Topics                                                                                |
| ----------------- | ------------------------------------------------------------------------------------- |
| Ithmb-Codec       | `ithmb-codec`, `csharp`, `imageglass`, `codec`, `thumbnail`, `plugin`, `image-viewer` |
| CS-Notes          | `cs-notes`, `computer-science`, `study-notes`, `documentation`, `hugo`, `reference`   |
| Bus-Hop           | `bus-hop`, `kotlin`, `android`, `jetpack-compose`, `transit`, `singapore`             |
| Traffic-Dashboard | `traffic-dashboard`, `github-traffic`, `badges`, `analytics`, `web`, `stats`          |

### Learning / Notes Repos

| Repo                  | Topics                                                                      |
| --------------------- | --------------------------------------------------------------------------- |
| Python-Learning-Notes | `python-learning-notes`, `python`, `study-notes`, `learning`, `programming` |
| Math-Learning-Notes   | `math-learning-notes`, `mathematics`, `jupyter`, `study-notes`, `notebook`  |
| Password-Generator    | `password-generator`, `python`, `cs50`, `security`, `tool`                  |

### Forks & Private

| Repo         | Topics                   |
| ------------ | ------------------------ |
| Scoop        | (skip — unmodified fork) |
| 2002-Combat  | (private — skip)         |
| CS50p        | (private — skip)         |
| H2-Computing | (private — skip)         |

## Setting Topics

Topics are **not part of the repo** — they're GitHub metadata. Set them via:

### CLI (one-time setup per repo)

```bash
gh repo edit B67687/Agentic-Workflows \
  --add-topic "agentic-workflows" \
  --add-topic "agent-harness" \
  --add-topic "ai-agents" \
  --add-topic "shell" \
  --add-topic "workflows" \
  --add-topic "dev-tools"
```

### Web UI

1. Navigate to `github.com/B67687/{repo}`
2. Click the gear icon next to "Topics" in the right sidebar
3. Add topics (comma or enter-separated)
4. Click "Save"

## Maintenance

- Update topics when the repo's primary language or purpose changes
- Use `gh repo edit {repo} --remove-topic "old" --add-topic "new"` to update
- Keep the first topic as the project name for branding
