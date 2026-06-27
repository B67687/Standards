# Code Documentation Standard

## Domains

docs,backend

## Purpose

Code documentation exists for three audiences: new developers onboarding, AI agents consuming code for generation or maintenance, and API consumers integrating with your library or service. Good docs reduce tribal knowledge, speed up debugging, and make automated tooling (LSPs, doc generators, code search) effective. Bad docs or missing docs waste time; excessive docs rot. This standard defines the balance.

## Principles

- **Document intent, not mechanics.** The code already says *what* it does. Comments should say *why* it does it, or *why not* the obvious alternative.
- **Keep docs near code.** Inline docstrings and file-level comments survive refactors better than external wikis. Link to external docs for background, don't duplicate them.
- **Document public APIs always.** Every exported function, class, type, and module needs a doc comment. Internal helpers may skip if the name and types are self-explanatory.
- **Self-explanatory code needs no comment.** If the code is clear from reading it, adding a comment is noise. Reserve comments for non-obvious constraints, edge cases, and reasoning.

## Docstring Requirements per Language

### TypeScript / JavaScript

Use **JSDoc** (`/** ... */`) for all public APIs. Required tags on exported functions:

- `@param` — describe each parameter, even if the type is obvious (explain units, nullability, side effects)
- `@returns` — describe the return value, including error states
- `@throws` — document when and why errors are thrown

```typescript
/** Fetches route data for a given stop ID.
 * @param stopId - GTFS-compatible stop identifier (e.g. "1234")
 * @param includeTiming - If true, includes real-time arrival estimates
 * @returns Route data or null if the stop has no active routes
 * @throws {FetchError} On network failure after 3 retries
 */
export async function getRoutesForStop(stopId: string, includeTiming: boolean): Promise<RouteData[] | null>
```

Internal functions may omit `@param` and `@returns` if the signature is unambiguous.

### Python

Use **Google-style docstrings**. Start with a one-line summary, then optional extended description, then sections:

```python
def fetch_arrivals(stop_id: str, limit: int = 10) -> list[Arrival]:
    """Fetch upcoming arrival times for a stop.

    Queries the real-time API and caches results for 30 seconds.
    Returns empty list for unknown stops (no error raised).

    Args:
        stop_id: GTFS stop identifier.
        limit: Maximum number of arrivals to return (1-50).

    Returns:
        List of Arrival objects, newest first. Empty if stop_id
        is unknown or no arrivals are scheduled.

    Raises:
        ConnectionError: After 3 failed attempts to reach the API.
    """
```

### Rust

Use **rustdoc** (`///` lines or `//!` for crate/module level). Include at least one usage example in a code block:

```rust
/// Parses a GTFS-rt feed from raw bytes.
///
/// Returns parsed entities or a descriptive error. Supports
/// both v1 and v2 format automatically.
///
/// # Examples
///
/// ```rust
/// let feed = parse_feed(&bytes).unwrap();
/// println!("{} entities", feed.entity.len());
/// ```
pub fn parse_feed(data: &[u8]) -> Result<Feed, ParseError>
```

Module-level doc (`//!`) must describe the module's purpose, key types, and any cross-module relationships.

### Go

Use **`// FunctionName` comments** (no colons or decoration). Every exported symbol must have a comment. Unexported symbols may skip if the name is self-documenting.

```go
// GetRoutesForStop fetches all active routes serving the given stop.
// Returns nil if the stop is unknown or has no active service.
// Errors indicate network or parsing failures.
func GetRoutesForStop(stopID string) ([]Route, error)
```

The Go toolchain treats the first sentence of a doc comment as a summary. Start with the symbol name in the first sentence.

### Shell

Use **function-level comments only** — a `#` block before each function describing purpose, args, and side effects. Inline comments within a function are reserved for non-obvious logic.

```bash
# fetch_arrivals: Query real-time API for a stop and print JSON.
# Args: $1 - stop ID, $2 - API base URL
# Prints: JSON array of arrivals to stdout
# Exits: 1 on network failure, 2 on invalid stop ID
fetch_arrivals() {
```

## What MUST Be Documented

- **Public API functions and classes** — every exported symbol in libraries and every function consumed across packages/modules.
- **Complex algorithms or non-obvious logic** — anything with bit manipulation, recursion, probabilistic data structures, concurrency primitives, or math beyond arithmetic.
- **Security-relevant code** — authentication, authorization, input sanitization, encryption, secret handling. Document invariants and threat model assumptions.
- **Configuration and constants** — environment variables, feature flags, magic numbers, enum variants. Explain valid values, defaults, and side effects.

## What MUST NOT Be Documented

- **Self-explanatory code** — `i++`, `value += tax`, `if (user == null) return`. Adding a comment here is noise that rots when the code changes.
- **Internal implementation that changes frequently** — private helpers under active development, algorithm choices still being explored, temporary workarounds with a TODO tracking issue. Document the TODO, not the workaround details.

## Inline Comments

Use inline comments (`//` or `#`) to explain *why*, never *what*. Good inline comments capture:

- Why a seemingly wrong approach was chosen (e.g. "defer here avoids a deadlock because...")
- Why a particular value was chosen (e.g. "30-second timeout matches the upstream SLA")
- A constraint that would otherwise be invisible (e.g. "this field is null for v1 requests only")

Bad inline comments restate the code:

```
// DON'T: i++ increments i by 1
i++;

// DO: iterate backwards so removals don't shift indices
for (let i = items.length - 1; i >= 0; i--)
```

## Doc Generation Tools

Per-language tooling for generating API reference docs from docstrings:

| Language | Tool | Command / Config |
|----------|------|------------------|
| TypeScript | [TypeDoc](https://typedoc.org/) | `typedoc --out docs/api` |
| Python | [Sphinx](https://www.sphinx-doc.org/) with `autodoc` | `sphinx-apidoc -o docs/api src/` |
| Rust | built-in **rustdoc** | `cargo doc --no-deps` |
| Go | built-in **go doc** / **pkgsite** | `go doc ./...` |

These tools are optional per-project but should be configured in CI when a project has public API consumers outside its owning team.

## Enforcement

- **Review gate.** Every PR with new public API surface must include docstrings. Reviewers flag undocumented exports as blocking.
- **CI checks (where tooling exists).** TypeScript projects may run `typedoc` with `--validation` to fail on missing `@param`/`@returns`. Rust projects fail on `cargo doc` warnings. Go's `golint` and `staticcheck` flag missing exported symbol comments. Python projects may use `darglint` or `interrogate` for docstring coverage thresholds.
- **Audit script.** This standard's check (`scripts/checks/code-documentation.sh`) scans for docstring indicators in source files and flags gaps. Run `./scripts/audit.sh --standard code-documentation` to validate.
