# Language Standard — American English

## Domains

docs


## Rule

All documentation, commit messages, code comments, and user-facing text **must use American English** spelling and conventions.

## Common American ↔ British Mappings

| American | British | Examples |
|----------|---------|----------|
| `-or` | `-our` | color/colour, behavior/behaviour, favor/favour, honor/honour |
| `-er` | `-re` | center/centre, meter/metre, liter/litre, theater/theatre |
| `-ize` | `-ise` | standardize/standardise, organize/organise, recognize/recognise |
| `-og` | `-ogue` | dialog/dialogue, catalog/catalogue, analog/analogue |
| `-se` | `-ce` | license/licence (noun), defense/defence, pretense/pretence |
| `-ed` | `-t` | learned/learnt, spelled/spelt, burned/burnt, dreamed/dreamt |
| `-ller` | `-ller` (same) | traveler/traveller, labeled/labelled, canceled/cancelled |
| `-ck` | `-que` | check/cheque, mask/masque |
| `program` | `programme` | — |
| `practice` | `practise` (verb) | — |
| `toward` | `towards` | — |
| `among` | `amongst` | — |
| `while` | `whilst` | — |

## Enforcement

- `scripts/checks/language.sh` greps markdown and text files for common British spellings
- **[Vale.sh](https://vale.sh/)** (v3.15+, prose linter) recommended for deeper style checks — use `write-good` ruleset configured via `.vale.ini`
- New content should follow American English; existing content is grandfathered (no retroactive conversion)
- The check is advisory for existing files, blocking for new files in CI

## Rationale

- American English is the de facto standard in software (Go stdlib, Linux kernel, Python PEP 8, Kubernetes, Docker, Git docs, npm/rust/cargo ecosystems)
- This repo and all affiliated repos already use American English throughout
- A single consistent dialect eliminates style debates in code review

## Related Standards

- [README Standard](README-standard.md) — user-facing documentation format
- [Commit Conventions Standard](commit-conventions-standard.md) — commit message language
