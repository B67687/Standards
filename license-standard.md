# License Standard

## Default License: MIT

All public repos should use the **MIT License** unless there's a specific reason to choose otherwise.

MIT is:

- Permissive — anyone can use, copy, modify, merge, publish, distribute
- Compatible with most ecosystems (npm, PyPI, Crates.io, NuGet, Maven)
- The standard for open-source projects without corporate requirements
- What your existing licensed repos already use

## License File

The license text goes in the repo root as `LICENSE` (no extension, no `.txt`).

```text
MIT License

Copyright (c) [year] B67687

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

[full MIT text...]
```

**Year rule:** Use the year the repo was first created. If the repo was created in 2025 and the license is added in 2026, use `2025`. If the repo spans multiple years, use the range `2025-2026`.

## Repos Missing Licenses

| Repo              | Status                               | Action                            |
| ----------------- | ------------------------------------ | --------------------------------- |
| Agentic-Workflows | Has MIT ✅                           | —                                 |
| Bus-Hop           | Has MIT ✅                           | —                                 |
| Ithmb-Codec       | README says MIT but no LICENSE file  | Add LICENSE                       |
| Agent-Harness     | Missing                              | Add LICENSE                       |
| Traffic-Dashboard | README has MIT badge but no LICENSE  | Add LICENSE                       |
| 2002-Combat       | README has MIT badge but no LICENSE  | Private — optional                |
| CS-Notes          | README says "provided for reference" | Add "All Rights Reserved" or omit |

## README Badge

If the repo has a badge header, include the license badge:

```markdown
<img src="docs/badges/license.svg" alt="MIT">
```

## When Not to Use MIT

- **Forks** — keep the upstream license
- **Learning notes / reference material** — "All Rights Reserved" or no license (CS-Notes pattern)
- **Private repos** — no license needed
