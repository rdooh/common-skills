# Project Structure Standards

This document is the canonical reference for how projects in this ecosystem are structured. It defines:
- What artifact families exist
- Where they live
- What format they use
- How they relate to each other
- How skills use them
- How Strux monitors them

Every skill in `common-skills` that touches documentation, architecture, or task tracking references this file. When a convention changes, update it here — the skills inherit the change.

---

## The Skill–Strux Division of Labour

**Common-skills** tells agents *how to produce correct artifacts* — it is prescriptive and proactive.

**Strux** monitors artifacts *after the fact* and reports violations — it is descriptive and reactive.

They are complementary, not overlapping. As Strux matures, skills will delegate their audit steps to it (e.g. `/doc-sync` running `strux diagnose` rather than doing its own diffing). Until then, skills perform lightweight manual checks.

---

## Standard Project Docs Layout

Every project is expected to have this structure under its root:

```
docs/
  features/         # Gherkin .feature files — one per feature area
  decisions/        # MADR-formatted ADR files
  architecture/
    architecture.dsl          # Structurizr DSL — single source of truth
    diagrams/                 # Generated Mermaid views (do not edit manually)
      container.mermaid
      container-target.mermaid
      system-context.mermaid
      system-context-target.mermaid
  contracts/        # JSON Schema contract files
  statecharts/      # JSON statechart files
  standards/        # Project-specific standards and linting reports
tickets/            # TIX markdown tickets (if using TIX medium)
  tix-manifest.json
```

If a project uses a different ticket medium (Jira, local plan), the `tickets/` directory may be absent. See the Task Tracking section.

---

## Artifact Families

There are three groups of artifacts. Each group answers a different question.

### Group 1 — Requirements + Features
*What does the system do, from the user's perspective?*

| Artifact | Location | Format | Strux sensor |
|---|---|---|---|
| Ticket | `tickets/TIX-NNN-slug.md` | Markdown with YAML frontmatter | `strux-tix` |
| Feature file | `docs/features/feature-name.feature` | Gherkin + lifecycle tags | `gherkin-rules` |

### Group 2 — Architecture + Decisions
*How is the system built, and why were those choices made?*

| Artifact | Location | Format | Strux sensor |
|---|---|---|---|
| Architecture model | `docs/architecture/architecture.dsl` | Structurizr DSL | `diagram-rules` |
| Architectural Decision Record | `docs/decisions/ADR-NNN-slug.md` | MADR | `adr-rules` |

### Group 3 — Contracts + Statecharts
*What are the boundaries and rules between components?*

| Artifact | Location | Format | Strux sensor |
|---|---|---|---|
| Contract | `docs/contracts/CON-NNN-slug.contract.json` | JSON Schema | `contract-rules` |
| Statechart | `docs/statecharts/STATE-NNN-slug.statechart.json` | JSON (XState-compatible) | `statechart-rules` |

---

## Feature Files

### Format
Gherkin syntax. One `Feature:` per file. Filename matches the feature slug.

```gherkin
@proposed
Feature: [Feature Title]
  As a [role]
  I want to [action]
  So that [outcome]

  Scenario: [Happy path scenario name]
    Given [precondition]
    When [action taken]
    Then [expected outcome]

  Scenario Outline: [Parameterized scenario name]
    Given [precondition with "<parameter>"]
    When [action with "<parameter>"]
    Then [expected result should be "<expected>"]

    Examples:
      | parameter | expected |
      | value_1   | result_1 |
```

### Lifecycle tags
Feature files carry a lifecycle tag at the top of the file:

| Tag | Meaning |
|---|---|
| `@proposed` | Draft — under discussion, not yet approved for implementation |
| `@accepted` | Approved — implementation may proceed |
| `@in-progress` | Currently being implemented |
| `@done` | Implemented and verified |
| `@deprecated` | No longer active |

**Rule:** A feature file must be `@accepted` before implementation begins. It must not move to `@done` until `/verify` returns CONFIRMED. Nothing ships `@proposed`.

### Quality rules (enforced by Strux `gherkin-rules`)
- One `Feature:` per file
- No duplicate scenario names within a file
- No duplicate feature names across the project
- `Scenario Outline:` must have an `Examples:` table
- `Background:` must not be empty; not used for single-scenario files
- No duplicate tags on a single scenario or feature block
- Terminology (nouns, verbs) must be consistent across all feature files

### Audit checks (performed by `/feature-doc` until Strux takes over)
1. **Terminology** — same nouns/verbs as existing files for the same concepts
2. **State assumptions** — every `Given` clause is satisfiable by another scenario's `Then`
3. **Behavioral contradiction** — no `Then` contradicts a `Then` in another file for the same trigger
4. **Scope creep** — behavior that belongs to a different feature area (note only, not a blocker)

---

## Architectural Decision Records (ADRs)

### Naming convention
`ADR-NNN-short-slug.md` — three-digit zero-padded number, sequential, no gaps.

### Format (MADR)
```markdown
# ADR-NNN: [Title]

## Status

[Proposed | Accepted | Superseded | Rejected]

**Date:** YYYY-MM-DD
**Decision makers:** [Names]

## Context

[The situation that forces a decision. Constraints. Problem being addressed.
Mention any C4 DSL element names that are affected.]

## Decision

[What was decided. Reference DSL element names where relevant — this is
what Strux's ADR sensor cross-checks against the architecture model.]

## Considered Options

- **Option A: [Name]** — [description, pros/cons]
- **Option B: [Name]** — [description, pros/cons]

## Consequences

- [What becomes easier]
- [What becomes harder]
- [Known trade-offs]
```

### When to write an ADR
Apply this test: *If this decision were reversed in six months, would it require migrating data, refactoring multiple files, or changing how other features work?* If yes — write an ADR. If no — skip it.

**Warrants an ADR:** choosing a persistence strategy, selecting a communication protocol between services, deciding how state is managed, adding or removing a container in the C4 model.

**Does not warrant an ADR:** adding a button, adding a command, changing a label, adding a new scenario to an existing feature.

### Linting rules (enforced by Strux `adr-rules`)
- Filename must match `^ADR-(\d{3})-(.+)\.md$`
- Numbers must be monotonic — no gaps, no duplicates
- Required fields: Status, Date, Decision makers
- Valid statuses: `Proposed`, `Accepted`, `Superseded`, `Rejected`
- Required sections: Context, Decision, Consequences
- No empty sections
- Superseded ADRs must link to the replacing ADR

---

## Architecture Model (Structurizr DSL)

### Location
`docs/architecture/architecture.dsl` — single file, single source of truth.

### Format
Structurizr DSL. Semantic-first: declares systems, containers, components, and relationships. Visual layout is generated from this, not embedded in it.

### Current / Target duality
Every element is tagged `Current` or `Target`:

- **`Current`** — exists in the codebase now
- **`Target`** — planned; corresponds to an accepted ADR but not yet implemented

```
workspace {
  model {
    system = softwareSystem "Name" "Description" {
      containerA = container "Name" "Description" "Technology" "Current"
      containerB = container "Name" "Description" "Technology" "Target"

      containerA -> containerB "Relationship" "Protocol" "Current"
    }
  }
}
```

**Rule:** Every `Target` element must have a corresponding `Accepted` ADR. Every `Current` element must match an implemented component verifiable in the codebase. This is what Strux's `diagram-rules` sensor audits.

### Generated views
`docs/architecture/diagrams/` contains Mermaid files generated from the DSL. These are compiled outputs — do not edit them manually. They are regenerated by `strux generate-diagrams` (Current view) or `strux generate-diagrams --target` (Current + Target view).

### When to update
Update `architecture.dsl` when:
- A new container or component is added or removed
- A relationship between containers changes
- A previously `Target` element is implemented (change tag to `Current`)
- A new ADR is accepted that affects the structural model

The `/architecture` skill owns this update process.

---

## Tickets

### Medium preference order
Skills resolve the task tracking medium in this order, then ask for lightweight confirmation before proceeding:

1. **Jira** — if MCP is configured and a project key is resolvable from context
2. **TIX files** — if `tickets/` directory exists with `tix-manifest.json`
3. **Local plan** — if a `plan.md` or `PLAN.md` with checkboxes exists in the working directory
4. **None** — ask the user to declare

On resolution, the skill states: *"I'll use [medium] for task tracking — proceed?"* and continues unless redirected.

### Capability matrix
| Operation | Jira | TIX files | Local plan |
|---|---|---|---|
| find eligible work | ✓ | ✓ | ✓ |
| read for direction | ✓ | ✓ | ✓ (limited) |
| create | ✓ | ✓ | ✓ (add checkbox) |
| start (mark in-progress) | ✓ | ✓ | ✓ |
| update (attach artifact/note) | ✓ | ✓ | — |
| link to ADR/feature | ✓ | ✓ | — |
| close with evidence pointer | ✓ | ✓ | ✓ (check off) |
| sprint / priority / watchers | ✓ | — | — |

Skills degrade gracefully when a capability is unavailable — they note it and continue with what's possible.

### TIX file format
```markdown
---
id: TIX-NNN
title: [Ticket Title]
status: [todo | ready | in-progress | done]
priority: [low | medium | high]
type: [feat | fix | chore]
impact_scope:
  - [packages/component-name]
features:
  - [docs/features/relevant-feature.feature]
adrs:
  - [docs/decisions/ADR-NNN-relevant-decision.md]
architecture_updated: [true | false]
depends_on:
  - [TIX-NNN]
---

[Description of work. Bullet points for sub-tasks.]
```

### Ticket readiness gates (enforced by Strux `strux-tix`)
A ticket is `ready` (eligible for implementation) when:
- Feature file is linked and `@accepted`
- ADR impact has been assessed (`architecture_updated` field populated)
- No open blocking dependencies

The `/plan` skill checks readiness before producing an implementation plan.

---

## Contracts

### Naming convention
`CON-NNN-slug.contract.json` — sequential, referenced in ADRs and DSL relationship annotations.

### Format
JSON Schema (draft-07). Defines the data shape of a boundary between two components.

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "id": "CON-NNN",
  "title": "[Title] Contract Schema",
  "type": "object",
  "properties": {
    "propertyName": {
      "type": "string",
      "description": "Description"
    }
  },
  "required": ["propertyName"]
}
```

### When to write a contract
When an ADR defines a communication boundary between two containers or components and the shape of that communication matters for correctness. Referenced in DSL relationship annotations: `containerA -> containerB "..." "..." "contract:CON-NNN"`.

---

## Statecharts

### Naming convention
`STATE-NNN-slug.statechart.json` — sequential.

### Format
JSON, XState-compatible. Models the lifecycle of a process or entity.

```json
{
  "id": "STATE-NNN",
  "name": "[Title] Statechart",
  "initial": "idle",
  "states": {
    "idle": { "on": { "START": "running" } },
    "running": {
      "on": {
        "SUCCESS": "done",
        "FAIL": "failed"
      }
    },
    "done": { "type": "final" },
    "failed": { "type": "final" }
  }
}
```

---

## Cross-artifact relationships

The relationships between artifact families are what Strux's graph resolver (`strux-synthesizer`) compiles into a relational model for auditing:

```
Ticket  ──links to──►  Feature file  ──@accepted before──►  Implementation
   │                       │
   └──links to──►  ADR  ──references──►  DSL element
                    │
                    └──governs──►  Contract / Statechart
```

When the `/doc-sync` skill runs post-implementation, it verifies this graph is internally consistent: tickets closed, feature files `@done`, DSL `Target` elements promoted to `Current`, no orphaned ADRs.

---

## Skill chain reference

The full chain, with artifact touchpoints:

| Stage | Skill | Reads | Writes / Updates |
|---|---|---|---|
| Brainstorm | `/brainstorm` | Existing features, ADRs | Draft ticket, draft feature (`@proposed`) |
| Feature spec | `/feature-doc` | Feature files, ADRs | Feature file (`@accepted`), ADR if needed |
| Architecture | `/architecture` | `architecture.dsl`, ADRs | `architecture.dsl` (Current/Target), ADR |
| Context load | `/orient` | Ticket, features, ADRs, DSL | Nothing — loads into context |
| Planning | `/plan` | Ticket (readiness), features, ADRs | Nothing — produces plan for approval |
| Implementation | `/implement` | Plan, feature file | Ticket → `in-progress` |
| Testing | `/test` | — | Test results artifact |
| Deploy | `/deploy` | — | Install artifact |
| Verification | `/verify` | — | Evidence artifact |
| Doc sync | `/doc-sync` | All of the above | Feature → `@done`, DSL Target → Current, ticket → `done` |
| Bug triage | `/bug` | Feature files, ticket | Gap scenario or conflict note in feature file |

`/task` is not a stage — it is a cross-cutting adapter called by every skill that needs to read or write task state.
