# Secrets Management Standard

## Purpose

Keep secrets out of git history. Encrypt `.env` files at rest, store the encrypted version in git, and decrypt only at runtime. This prevents credential leaks while keeping secrets deployable.

## Tools

| Tool | Role |
|------|------|
| **[sops](https://getsops.io)** | Encrypts/decrypts structured files (YAML, JSON, env) — encrypts values only, leaves keys visible |
| **[age](https://age-encryption.org)** | Simple, modern file encryption — sops uses it as a key backend |

## File Naming

| File | In Git? | Purpose |
|------|---------|---------|
| `.env` | ❌ `.gitignore` | Local dev secrets, never committed |
| `.env.encrypted` | ✅ Yes | Encrypted version of .env via sops |
| `.sops.yaml` | ✅ Yes | sops configuration (encryption rules, recipients) |
| `secrets.enc.yaml` | ✅ Yes | Encrypted YAML/JSON secrets |
| `age-key.txt` | ❌ Never | Age private key — NEVER commit, keep offline |
| `.env.*.local` | ❌ `.gitignore` | Per-environment local overrides |

## Workflow

### 1. Generate an age keypair

```bash
age-keygen -o ~/.config/sops/age/keys.txt
# Output:
# Public key: age1yt3tfqlfrwdwx0z0ynwplcr6qxcxfaqycuprpmy89nr83ltx74tqdpszlw
```

The key file is your **root credential** — protect it like a password. Store it in `~/.config/sops/age/keys.txt` (sops discovers this automatically).

### 2. Create `.sops.yaml` at repo root

```yaml
# .sops.yaml
creation_rules:
  - age: >-
      age1yt3tfqlfrwdwx0z0ynwplcr6qxcxfaqycuprpmy89nr83ltx74tqdpszlw
```

For multiple environments:

```yaml
creation_rules:
  - path_regex: \.dev\.enc\.yaml$
    age: 'age1devkey...'
  - path_regex: \.prod\.enc\.yaml$
    age: 'age1prodkey...'
  - path_regex: \.env\.encrypted$
    age: 'age1defaultkey...'
```

### 3. Encrypt your .env

```bash
# After editing .env, encrypt it for git
sops encrypt .env > .env.encrypted
```

### 4. Decrypt at runtime (local)

sops discovers the age key automatically from the first available:

1. `SOPS_AGE_KEY` env var (raw key string) — best for CI
2. `SOPS_AGE_KEY_FILE` env var (path to key file)
3. `~/.config/sops/age/keys.txt`

```bash
sops decrypt .env.encrypted > .env
```

### 5. Decrypt in CI

Set the age private key as a CI secret, then:

```yaml
# GitHub Actions
- name: Decrypt secrets
  env:
    SOPS_AGE_KEY: ${{ secrets.SOPS_AGE_KEY }}
  run: |
    sops decrypt --output-type dotenv .env.encrypted > .env
```

## Gitignore Rules

Add these patterns to `.gitignore`:

```gitignore
# Secrets — never tracked
.env
.env.*
.env.*.local
age-key.txt
*.age
```

## .gitattributes for Cleartext Diffs

To see meaningful diffs on encrypted files (decrypted diff):

```gitignore
*.encrypted diff=sopsdiffer
```

```bash
git config diff.sopsdiffer.textconv "sops decrypt"
```

## `scripts/tools/setup-env-enc.sh`

A setup script is available at `scripts/tools/setup-env-enc.sh` that:

1. Generates an age keypair (if none exists)
2. Creates `.sops.yaml` with the public key
3. Adds `.env` to `.gitignore` (if not already present)
4. Creates `.gitattributes` for cleartext diffs
5. Provides instructions for CI setup

## Edge Cases

### Rotating Keys

1. Add the new public key to `.sops.yaml`
2. Run `sops updatekeys -y .env.encrypted` to re-encrypt for the new key
3. Run `sops rotate -i .env.encrypted` to generate a new data key
4. Remove the old key from `.sops.yaml`

### Multiple Recipients

Add multiple age keys so any recipient can decrypt:

```yaml
creation_rules:
  - age: >-
      age1key1...,
      age1key2...,
      age1key3...
```

### Editing Encrypted Files

```bash
# Opens decrypted content, re-encrypts on save
sops edit .env.encrypted
```

### Converting Existing Secrets

If secrets were ever committed to git, assume they're compromised. Rotate all credentials and regenerate keys.

## Reference

- [sops documentation](https://getsops.io/docs/)
- [age documentation](https://age-encryption.org)
- [sops GitHub](https://github.com/getsops/sops)
