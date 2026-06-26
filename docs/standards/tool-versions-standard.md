# Tool Version Standard

## Domains

infra,backend


## Purpose

Keep development tool versions consistent across machines with a version-manager config file. This ensures every contributor and CI runner uses the same toolchain.

## File

`mise.toml` (canonical) or `.mise.toml` at repo root.

## Why mise

**[mise](https://mise.jdx.dev)** (formerly rtx) is a polyglot version manager that replaces asdf, nvm, pyenv, goenv, etc. with a single tool. It handles dev tools available via plugins, cargo, npm, go, pip, and more.

| Feature | Mise | asdf | nvm |
|---------|------|------|-----|
| One config for all languages | ✅ | ✅ | ❌ (one per language) |
| Single binary, no shell hooks | ✅ | ❌ | ❌ |
| Built-in tasks | ✅ | ❌ | ❌ |
| Environment variable management | ✅ | ❌ | ❌ |
| Lockfile for reproducible builds | ✅ | ❌ | ❌ |

## Config File Format

```toml
# mise.toml — Tool version management
# Schema reference: https://mise.jdx.dev/configuration.html

min_version = "2024.1.1"

[tools]
# Loose versions for flexibility
node = "20"
python = "3.12"

# Exact pinning for CI reproducibility
go = "1.22.3"

# Tools from non-default backends
"npm:typescript" = "5.4"
"cargo:ripgrep" = "14"

[env]
NODE_ENV = "development"
_.path = ["./node_modules/.bin"]
```

## Config Location Priority

Mise searches upward from the current directory. Configs closer to the repo take precedence:

```
~/.config/mise/config.toml         ← global defaults
mise.local.toml                    ← personal/local overrides (git-ignored)
mise.toml                          ← THE DEFAULT, commit this
mise/config.toml
.mise/config.toml
.config/mise.toml
.config/mise/config.toml
.config/mise/conf.d/*.toml
```

## Rules

1. **`mise.toml`** at repo root is the canonical config file
2. **`mise.local.toml`** is reserved for local overrides (in `.gitignore`)
3. **`min_version`** SHOULD be set to require a minimum mise binary version
4. **`[tools]`** SHOULD list at least one language runtime (node, python, go, etc.)
5. Use **loose versions** (e.g. `node = "20"`) for team flexibility; pin exact versions only for CI reproducibility
6. `mise use` is the recommended way to install tools AND update `mise.toml` in one step
7. `mise.toml` MUST be tracked by git

## What Mise Manages

Mise manages **language runtimes and dev tools** (compilers, linters, formatters, databases). It does NOT manage itself — use `mise self-update` or your system package manager to update mise itself.

### Examples of tools mise handles:

| Tool | mise Key |
|------|----------|
| Node.js | `node = "20"` |
| Python | `python = "3.12"` |
| Go | `go = "1.22"` |
| Rust | `rust = "stable"` |
| Java | `java = "17"` |
| Terraform | `terraform = "1"` |
| ShellCheck | `shellcheck = "latest"` |
| Trivy | `trivy = "latest"` |
| git-cliff | `git-cliff = "latest"` |
| Lefthook | `lefthook = "latest"` |
| sops | `sops = "latest"` |
| age | `age = "latest"` |

## Edge Cases

### Legacy `.tool-versions` files

`.tool-versions` is the asdf format. Mise reads it for backward compatibility but recommends `mise.toml` for new projects. To migrate:

```bash
mise install           # reads .tool-versions too
mise current --toml > mise.toml  # snapshot to new format
```

### Lockfile for reproducibility

Enable per-project lockfile to pin exact tool versions:

```bash
mise settings set experimental=true
# Then: mise.lock will be generated
```

### Monorepos with different tool sets per directory

Place `mise.toml` in subdirectories to override parent settings for specific tasks.

## Reference

- [mise documentation](https://mise.jdx.dev)
- [mise GitHub](https://github.com/jdx/mise)
- [Configuration docs](https://mise.jdx.dev/configuration.html)
