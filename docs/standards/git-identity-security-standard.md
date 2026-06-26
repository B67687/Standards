# Git Identity Security Standard

## Domains

security,universal


## Motivation

AI agents can hallucinate git identities (names, emails), causing signed commits to fail, attribution to break, and security policies to be bypassed. This standard locks down git's identity and signing configuration so only authorized identities can create commits.

## Requirements

### 1. Global Identity Lock (`user.useConfigOnly`)

`user.useConfigOnly = true` must be set globally. This prevents git from auto-creating a local identity override from the system's username/hostname when `user.name` or `user.email` is missing locally. Without this flag, any `git commit` in a repo without local identity creates a junk entry.

```ini
[user]
    useConfigOnly = true
```

### 2. Global Identity

The global `user.name` and `user.email` must be set to the primary maintainer identity.

```ini
[user]
    name = Primary Name
    email = primary@example.com
```

### 3. SSH Commit Signing

Commits must be signed with an SSH key. This provides non-repudiation — the signature proves the commit was created by someone holding the expected private key, regardless of the `user.name`/`user.email` fields.

```ini
[gpg]
    format = ssh
[user]
    signingkey = ~/.ssh/id_ed25519
[gpg "ssh"]
    program = ssh-keygen
    allowedSignersFile = ~/.config/git/allowed_signers
[commit]
    gpgsign = true
```

### 4. Config-Driven Committer Enforcement (Optional, Per-Repo)

For repos that need restricted committer identity, set `hooks.allowed-committer-name` and/or `hooks.allowed-committer-email` as regex patterns. The pre-commit hook enforces these.

```bash
# Only B67687 can commit
git config hooks.allowed-committer-name "B67687"
git config hooks.allowed-committer-email ".*@users\.noreply\.github\.com"

# Multiple allowed (regex alternation)
git config hooks.allowed-committer-name "B67687|DeepSeek-V4-Flash \(AI\)"
```

If neither config is set, no identity enforcement applies — the pre-commit hook passes through.

## Audit Checks

The audit verifies:

1. **Global `user.useConfigOnly` is true** — prevents accidental local identity overrides
2. **Global `user.name` is set** — primary identity is configured
3. **Global `user.email` is set** — primary email is configured
4. **SSH signing key exists** — `user.signingkey` points to an existing file
5. **`gpg.format = ssh`** — signing uses SSH keys
6. **`commit.gpgsign = true`** — automatic signing enabled globally
7. **`allowedSignersFile` exists** — SSH key verification is configured

## See Also

- [Auto-Commit GitOps Standard](auto-commit-gitops-standard.md) — AI attribution via committer field
- [Commit Conventions Standard](commit-conventions-standard.md) — message format and signing
- `scripts/hooks/pre-commit` — config-driven identity gate
