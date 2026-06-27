# Architecture Documentation Standard

## Domains

docs, backend, infra

## Purpose

Architecture documentation answers one question: "How does this system work?" It gives new developers, maintainers, and AI agents a shared mental model of the system without having to read every file or talk to a person. Without it, knowledge dies when people leave, tribal lore takes root, and onboarding becomes a bottleneck.

## Required Artifacts

Every repo (where applicable) SHOULD include the following. Adapt scope to match the system's complexity.

### System Context Diagram (C4 Level 1)

What does this system interact with? Show external actors, other systems, and the boundary of your system. This is the big-picture view so readers understand where your system fits.

### Component Diagram (C4 Level 2)

What are the major modules or components, and how do they connect? Show internal structure, key dependencies between components, and entry points. This is the diagram most readers will reference daily.

### Data Flow

How does data move through the system? Include:
- Key data models or schemas
- Read/write paths (Create, Read, Update, Delete operations)
- Event flows or message passing (if applicable)
- Data lifecycle (where is it created, transformed, stored, archived)

### Deployment Architecture

How is the system deployed? Include (as applicable):
- Infrastructure topology (servers, containers, serverless)
- Network boundaries and security groups
- CI/CD pipeline stages
- Environment breakdown (dev, staging, prod)
- Scaling strategy

## Format

Architecture docs SHOULD use diagrams. Mermaid is the preferred format because it embeds directly in Markdown, renders on GitHub, and stays in version control. PlantUML and SVG are acceptable alternatives when Mermaid lacks the needed shape or layout.

Every diagram MUST have an accompanying text explanation. Diagrams alone are not enough.

## Where This Lives

The preferred location is `docs/ARCHITECTURE.md` at the repo root. For smaller projects, an `## Architecture` section in the README is acceptable. Consistency matters -- pick one pattern per organization.

## Relationship to ADRs

Architecture Decision Records (ADRs) capture individual decisions and their rationale. `ARCHITECTURE.md` describes the current state of the system, not how it got there.

- **ADRs answer**: "Why did we choose X over Y?"
- **ARCHITECTURE.md answers**: "What does the system look like now?"

Link to relevant ADRs from architecture diagrams or component descriptions so readers can trace from "what" to "why."

## Required For

Architecture docs are REQUIRED for: libraries, applications, services, and tools that other people depend on.

Architecture docs are OPTIONAL for: documentation-only repos, project templates, and scratch projects.

## Minimum Content

Every architecture doc MUST include at minimum:

1. **One diagram** showing the major components and their relationships
2. **Text explanation** of each component's role (a few sentences per component)
3. **Technology stack summary** listing programming languages, frameworks, databases, and major libraries

## Maintenance

Architecture docs MUST be updated when the architecture changes. The update happens as part of the same pull request that introduces the change, not as a follow-up. If a PR ships without updating the architecture doc, it is incomplete.

## C4 Model

The C4 model (Context, Container, Component, Code) is the recommended reference for diagram levels. This standard requires Level 1 (System Context) and Level 2 (Component/Container). Level 3 (Component internals) and Level 4 (Code) are optional -- include them when the complexity of a specific module warrants it.

Do not follow C4 dogmatically. Adapt its levels to what your team actually needs. A two-page diagram is better than an empty UML standard.
