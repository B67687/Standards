# Meta-Standard: Minimal Surface Principle

## Rule

Every file in the repository must contain **exactly as much as required, no more and no less**.

Anything extra is a liability:
- Extra **entries** in `.gitignore` leak local directory structure
- Extra **comments** in config files document implementation details that should remain local
- Extra **documentation** of internal processes creates a maintenance burden
- Extra **whitelist entries** reveal file names that should never be mentioned
- Extra **lines** in README caused by copy-paste errors are still extra — verify every edit

## Application

| File | What to Strip |
|------|--------------|
| `.gitignore` | Only entries that counteract whitelist patterns. No documentation of local-only files. No section headers. No redundant `!` patterns. |
| `README.md` | Only information the end user needs. No build instructions for internal tooling. No CI configuration details. No duplicate content. |
| `CHANGELOG.md` | Only changes users can see. No infrastructure changes, CI updates, or internal refactoring. |
| Config files | Only settings that differ from defaults. No explanatory comments. |
| CI configs | Never push CI configs to GitHub if CI runs locally. |

## READMEs

README is the most public-facing file. It must not reference:
- Local-only scripts or tools
- Local directory structure (empty directories should not exist at all)
- Local CI infrastructure
- Internal processes that only matter to the maintainer

**Do not duplicate content.** Every line must be intentional. A duplicate line from a copy-paste error is still extra surface.

## Cleanup All Evidence of Cleanup

There is no such thing as a cleanup commit. A file that should not exist must never appear in any commit — not even in a commit that "removes" it.

A commit that exists solely to remove something is evidence that the thing once existed. The only fix is to squash it away into legitimate work. Renaming the commit message is not enough — the commit itself must not exist separately.

## No Preemptive Directories

Do not create directories before they have content. An empty `docs/adr/` or `docs/screenshots/` directory leaks workflow information. Create directories only when you have a file to put in them. This follows YAGNI: you ain't gonna need it until you need it.

## Commit Signing

All commits must be signed with a valid SSH or GPG key. When re-signing a batch of commits:
- **Preserve dates:** `GIT_COMMITTER_DATE="$(git log -1 --format=%aD)"` must be set during amend to keep author date = committer date
- **Do not change anything else:** signing should only add the signature header, not modify content, messages, or timestamps
- **Test one commit first** before signing the full history

## Batch Force-Pushes

If multiple history rewrites are needed (message cleanup, content removal, re-signing), batch them into a single filter-repo pass. Each force-push is disruptive:
- Invalidates existing clones
- Breaks open PRs
- Resets commit statuses

Plan all changes before the first rewrite, then execute them in one pass.

## When to Add

Add content only when:
1. A tool REQUIRES it to function (e.g., `.gitignore` patterns)
2. A user NEEDS it to use the project (e.g., README install instructions)
3. A standard MANDATES it (e.g., LICENSE file)

Remove content when:
1. It documents local-only infrastructure
2. It's redundant with a broader pattern
3. It reveals more than necessary about your setup
4. It's a duplicate (even by accident)

## Operational Rule: YAGNI

The Minimal Surface Principle is achieved operationally by following **YAGNI (You Ain't Gonna Need It)**:

- Add a config entry only when a tool or workflow actually requires it
- Add a `.gitignore` entry only when a file actually appears
- Add a README section only when a user actually needs the information
- Create a directory only when you have a file to put in it
- Remove an entry when the requirement is removed

## Sources

The Minimal Surface Principle is the convergence of seven established industry principles:

| Principle | Source | Relationship |
|-----------|--------|-------------|
| **Rule of Silence** | Unix (McIlroy) | A file should be silent except for what distinguishes it from defaults |
| **Occam's Razor** | William of Ockham | Entities (lines, entries) must not be multiplied beyond necessity |
| **YAGNI** | XP / Ron Jeffries | Add entries only when actually needed, never preemptively |
| **Least Privilege** | Saltzer & Schroeder | Expose only the information necessary for the file's purpose |
| **DRY** | Hunt & Thomas | Every piece of knowledge has one authoritative representation |
| **SSOT** | Information science | Master each fact in exactly one place |
| **Chesterton's Fence** | G. K. Chesterton | Before removing an entry, understand why it was added |
