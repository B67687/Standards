# CS Team Project Architecture Standard

## Domains

backend


## Context

School team projects in computer science share a common problem: every group reinvents architectural decisions from scratch, wasting 2-3 weeks debating folder structure instead of writing code. This standard eliminates that waste.

**Origin:** Derived from analyzing 47 real SC2002 Turn-Based Combat Arena repos across GitHub. 7 distinct architectural archetypes emerged. This standard codifies the decision process so any CS team project picks the right architecture in under 5 minutes.

## Decision Matrix

When your team gets an assignment PDF, answer these 3 questions:

| Question | If answer is... | Use Architecture |
|---|---|---|
| **Has persistent data?** (files, DB, CRUD operations) | Yes | **Three-Tier** (UI → Logic → Data) |
| | No | Keep going ↓ |
| **Has a GUI?** (Swing, JavaFX, web frontend) | Yes | **MVC** (Controller/Model/View) |
| | No (console only) | Keep going ↓ |
| **Is it client-server / API / network protocol?** | Yes | **Hexagonal** (Ports/Adapters) |
| | No | **Layered** (fallback — safest for OOP console apps) |

**Result you get:** One architecture, zero debate, ready in 30 seconds.

## Architecture Templates

### Layered (console OOP apps)

Best for: pure Java/C#/Python console assignments with game logic or simulations.

```
project/
├── api/           # Interfaces defining contracts between layers
├── model/         # Pure data + domain logic (no I/O dependency)
├── engine/        # Core business logic (game loop, rules engine)
├── ui/            # I/O layer (console, swap for GUI later)
└── Main.java      # Entry point — wires layers together
```

**Rule:** Dependencies point INWARD. `api ← model ← engine ← ui`. Nothing in `model` imports from `ui`.

### Three-Tier (database CRUD)

Best for: campus systems, library managers, booking systems, any persistent CRUD.

```
project/
├── presentation/  # UI layer (CLI menus, forms)
├── business/      # Business logic + validation
├── data/          # Database/file access (DAO pattern)
└── model/         # Shared domain objects (no dependencies)
```

**Rule:** Presentation → Business → Data. Model is shared everywhere but depends on nothing.

### MVC (GUI apps)

Best for: Swing, JavaFX, React, or any graphical interface.

```
project/
├── controller/    # Handles input events, updates model
├── model/         # Application state + domain logic
├── view/          # Renders UI (FXML, Swing forms, templates)
└── service/       # Optional — complex business logic extracted from controller
```

**Rule:** View → Controller → Model. View never reaches directly into Model.

### Hexagonal / Ports-Adapters (REST APIs, services)

Best for: backend services, API servers, anything with HTTP or gRPC.

```
project/
├── domain/        # Core business logic (pure, no frameworks)
├── application/   # Use cases / service interfaces (ports)
├── adapter/       # Implementations (inbound: controllers, outbound: DB, HTTP)
│   ├── inbound/   # REST controllers, CLI handlers
│   └── outbound/  # Repository implementations, external APIs
└── config/        # Dependency injection wiring
```

**Rule:** Domain knows nothing. Adapters implement ports. Config wires it all together.

## Team Role Mapping

Once architecture is chosen, assign layers to team members:

| Team Member | Owns | Deliverable |
|---|---|---|
| #1 (strongest) | Core logic / Engine / Domain | Interfaces, business rules, UML class diagram |
| #2 | UI / View / Presentation | All user-facing code |
| #3 | Data / Model / Persistence | Data classes, file/DB operations |
| #4 | Integration + Testing | Wiring layers, smoke tests, README |
| #5 (if exists) | Documentation + UML | Sequence diagrams, design report, project README |

Each member has clear boundaries. No merge conflicts, no "who writes this class" arguments.

## Why This Works for CS Assignments

CS projects differ from real engineering:

| Factor | CS Assignment | Real Engineering |
|--------|--------------|-----------------|
| Team size | 3-5 | 6-50+ |
| Timeline | 4-8 weeks | 6+ months |
| Requirements | Known upfront | Emergent, changing |
| Evaluation | Principles + UML + patterns | Production metrics |
| Value of debate | Negative (wastes time) | Necessary (alignment) |

The best architecture for a CS assignment is the one that:
1. Gives every member a clear lane (no stepping on each other)
2. Makes UML diagrams trivial (layers map directly to packages)
3. Lets the marker see your design intent from the folder structure alone
4. Requires the least deliberation — pick and ship

## About the Origin Data

This standard was formed by analyzing **47 public SC2002 Turn-Based Combat Arena** team project repos on GitHub. Architecture archetypes found:

| Archetype | Prevalence | Best For |
|-----------|-----------|----------|
| Package-by-layer | ~37% | Quick & dirty — not recommended |
| BCE (Boundary-Control-Entity) | ~25% | When SC2002 specifically mandates it |
| Action+Engine | ~21% | Turn-based games with many action types |
| Layered | ~4% | Console OOP — **this repo's approach** |
| MVC | ~2% | GUI apps |
| Trigger/Event | ~6% | Complex state machines |
| Entity-based | ~2% | Simple data-only projects |

## Success Criteria

A CS team project using this standard is successful when:
- Architecture was chosen in 1 meeting (under 30 min)
- Every team member can explain which layer they own and why
- Folder structure alone communicates design intent
- UML class diagram is a 1:1 map of the package structure
- No file exceeds 250 lines (single responsibility enforced by layer boundaries)
