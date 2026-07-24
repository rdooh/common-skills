# Project Structure Standards

This document is the canonical reference for how projects in this ecosystem are structured. It defines:
- What artifact families exist and where they live
- The document-space quadrant model
- Artifact formats, lifecycle tags, and cross-artifact relationships
- How skills use them
- How Strux monitors them

Every skill in `common-skills` that touches documentation, architecture, or task tracking references this file. When a convention changes, update it here — the skills inherit the change.

---

## The Document-Space Quadrant Model

All project artifacts fall on two axes:

**Axis 1: Durable vs. Point-in-time**
- *Durable* — describes what the system is, was decided, or formally attests to. Read long after it was written.
- *Point-in-time* — relevant during active work. Value decays after the work closes.

**Axis 2: Specification vs. Evidence**
- *Specification* — claims about what should be true (features, decisions, architecture)
- *Evidence* — proof that something was true at a specific moment (test results, screenshots, release attestations)

| | Durable | Point-in-time |
|---|---|---|
| **Specification** | `docs/` | *(empty — git history serves this role)* |
| **Evidence** | `docs/releases/` | `work/<ticket-folder>/` |

**The fourth quadrant is intentionally empty.** Point-in-time specification is answered by `git log`, not a folder. Store the current truth; use version control as the time machine.

This model is defined in Strux ADR-023 and is the authority for all QSOS-governed projects.

---

## The Skill–Strux Division of Labour

**Common-skills (QSOS)** tells agents *how to produce correct artifacts* — prescriptive and proactive.

**Strux** monitors artifacts *after the fact* and reports violations — descriptive and reactive.

They are complementary. As compliance tooling matures, skills delegate their audit steps to it (e.g. `/qsos-doc-sync` delegating to installed tooling). Until then, `/qsos-audit` covers the most important checks manually.

---

## Subprojects

A **subproject** is any directory within a repo that has its own `catalog-info.yaml`. The presence of that file is the single signal that QSOS uses to treat the directory as a self-contained unit with its own documentation and ticket space.

### Layout

A subproject mirrors the root layout, scoped to its own directory:

```
<subproject>/
  catalog-info.yaml          — component identity and QSOS annotations
  docs/
    features/                — Gherkin feature files for this component only
    decisions/               — ADRs for this component only
  work/
    <PREFIX>-NNN-slug/       — tickets scoped to this component
      ticket.md
      evidence/
  testing/
    manifest.json            — test runner declaration for this component
```

### catalog-info.yaml annotation

Every subproject's `catalog-info.yaml` must declare a `qsos.io/ticket-prefix` annotation. The prefix is ≤5 characters, uppercase, and unique across all subprojects in the repo.

```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: my-component
  annotations:
    qsos.io/ticket-prefix: "MYCO"
spec:
  type: tool
  lifecycle: experimental
  owner: rob
```

When QSOS skills (brainstorm, orient, plan, etc.) run inside a subproject directory, they:
1. Detect `catalog-info.yaml` in the current or nearest ancestor directory (stopping at the repo root)
2. Read `qsos.io/ticket-prefix` from annotations
3. Write feature files to `<subproject>/docs/features/`
4. Write tickets to `<subproject>/work/<PREFIX>-NNN-slug/`
5. Resolve `features:` and `adrs:` paths in ticket frontmatter relative to the subproject root

If no `catalog-info.yaml` is found, QSOS falls back to the repo root `docs/` and `work/`.

### Ticket numbering

Ticket numbers (`NNN`) are globally unique across the entire repo regardless of prefix. Do not reindex when moving tickets into a subproject — the git history references the original numbers. Numbers only reset when starting a genuinely new repo.

### Catalog lifecycle invariant

`spec.lifecycle` in `catalog-info.yaml` reflects the component's overall maturity. QSOS enforces:

| catalog lifecycle | permitted feature tag states |
|---|---|
| `experimental` | any (`@proposed` through `@done`) |
| `production` | only `@done` or `@deprecated` — no `@proposed` or `@in-progress` |

A component must not be promoted to `lifecycle: production` while any of its feature files carry `@proposed` or `@in-progress`. `/qsos-doc-sync` checks this invariant at close time and flags a violation if it would be breached.

---

## Standard Project Layout

```
docs/                              — durable specification + durable evidence
  features/                        — Gherkin feature files
  decisions/                       — MADR ADRs
  architecture/
    architecture.dsl               — Structurizr DSL (single source of truth)
    diagrams/                      — Generated Mermaid views (never edit manually)
  contracts/                       — JSON Schema contract files
  statecharts/                     — XState-compatible statechart files
  releases/                        — formal release attestations
  standards/                       — project-specific standards and linting reports

work/                              — point-in-time work (transient)
  tix-manifest.json                — compiled ticket registry (auto-generated)
  TIX-NNN-slug/                    — one folder per ticket
    ticket.md                      — always present; frontmatter + description
    screenshots/                   — optional: UI evidence
    evidence/                      — optional: verify runs, test output
    logs/                          — optional: debug output (typically git-ignored)

.audit-baseline.json               — optional: acknowledged pre-existing violations (see below)
logs/                              — tool status files and diagnostic reports (git-ignored)
```

Each top-level directory carries a `README.md` that self-identifies its quadrant role.

---

## Artifact Families

### Group 1 — Requirements + Features
*What does the system do, from the user's perspective?*

| Artifact | Location | Format | Strux sensor |
|---|---|---|---|
| Ticket | `work/TIX-NNN-slug/ticket.md` | Markdown with YAML frontmatter | `strux-tix` |
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
| Statechart | `docs/statecharts/STATE-NNN-slug.statechart.json` | XState JSON | `statechart-rules` |

### Group 4 — Release Evidence
*What was formally attested at a specific version?*

| Artifact | Location | Format |
|---|---|---|
| Release attestation | `docs/releases/v{version}.md` | Markdown — version, date, evidence pointers |

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

| Tag | Set by | Meaning |
|---|---|---|
| `@proposed` | `/brainstorm` | Draft — under discussion, not yet approved |
| `@accepted` | `/feature-doc` | Approved — implementation may proceed |
| `@in-progress` | `/implement` | Currently being implemented |
| `@done` | `/doc-sync` | Implemented and verified |
| `@deprecated` | `/doc-sync` | No longer active |

**Rule:** A feature file must be `@accepted` before implementation begins. It must not move to `@done` until `/verify` returns CONFIRMED. Nothing ships `@proposed`.

### Quality rules (enforced by Strux `gherkin-rules`)
- One `Feature:` per file
- No duplicate scenario names within a file
- No duplicate feature names across the project
- `Scenario Outline:` must have an `Examples:` table
- `Background:` must not be empty; not used for single-scenario files
- No duplicate tags on a single scenario or feature block
- Terminology must be consistent across all feature files

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

[What was decided. Reference DSL element names where relevant.]

## Considered Options

- **Option A: [Name]** — [description, pros/cons]
- **Option B: [Name]** — [description, pros/cons]

## Consequences

- [What becomes easier]
- [What becomes harder]
- [Known trade-offs]
```

### When to write an ADR
*If this decision were reversed in six months, would it require migrating data, refactoring multiple files, or changing how other features work?* If yes — write an ADR.

---

## Architecture Model (Structurizr DSL)

### Location
`docs/architecture/architecture.dsl` — single file, single source of truth.

### Current / Target duality
Every element is tagged `Current` or `Target`:
- **`Current`** — exists in the codebase now
- **`Target`** — planned; corresponds to an accepted ADR but not yet implemented

**Rule:** Every `Target` element must have a corresponding `Accepted` ADR. Every `Current` element must match an implemented component verifiable in the codebase.

### Generated views
`docs/architecture/diagrams/` — Mermaid files generated from the DSL. Never edit manually.

---

## Tickets

### Ticket prefix

In a subproject with a `qsos.io/ticket-prefix` annotation, tickets use that prefix instead of `TIX-`:

```
work/ADDON-017-bdd-lifecycle-toolbar/
  ticket.md
```

At the repo root (no `catalog-info.yaml`), tickets use `TIX-`. Numbers are globally unique across both spaces — never reuse a number, never reindex.

### Ticket as folder
Each ticket is a directory under `work/`:

```
work/TIX-NNN-slug/
  ticket.md          — always present
  screenshots/       — optional
  evidence/          — optional
  logs/              — optional (typically git-ignored)
```

The `ticket.md` file is the minimum viable ticket. Subfolders accumulate as the work generates artifacts.

### Medium preference order
Skills resolve the task tracking medium in this order:

1. **Jira** — if MCP is configured and a project key is resolvable
2. **TIX files** — if `work/` directory exists with `tix-manifest.json`
3. **Local plan** — if a `plan.md` with checkboxes exists
4. **None** — ask the user to declare

On resolution: *"I'll use [medium] for task tracking — proceed?"* Continue unless redirected.

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

### TIX ticket.md format
```markdown
---
id: TIX-NNN
title: [Ticket Title]
status: [todo | ready | in-progress | done]
priority: [low | medium | high]
type: [feat | fix | chore | refactor]
impact_scope:
  - [packages/component-name]
features:
  - [docs/features/relevant-feature.feature]
adrs:
  - [docs/decisions/ADR-NNN-relevant-decision.md]
architecture_updated: [true | false]
depends_on:
  - [TIX-NNN]
jira: [PROJ-123]           # optional
---

[Description of work. Bullet points for sub-tasks.]
```

### Ticket readiness gates
A ticket is `ready` (eligible for implementation) when:
- Feature file is linked and `@accepted`
- ADR impact has been assessed (`architecture_updated` field populated)
- No open blocking dependencies

The `/plan` skill checks readiness before producing an implementation plan.

---

## Release Evidence

Formal attestations live in `docs/releases/`. Each file covers one released version:

```markdown
---
version: 1.2.0
date: YYYY-MM-DD
verified_by: /verify
---

## Evidence

- Test results: work/TIX-NNN-slug/evidence/unit.json
- Screenshot: work/TIX-NNN-slug/screenshots/post-deploy.png
```

---

## Contracts

### Naming convention
`CON-NNN-slug.contract.json` — sequential, referenced in ADRs and DSL relationship annotations.

### Format
JSON Schema (draft-07). Defines data shape at a component boundary.

---

## Statecharts

### Naming convention
`STATE-NNN-slug.statechart.json` — sequential.

### Format
JSON, XState-compatible. Models the lifecycle of a process or entity.

---

## Audit Baseline

`.audit-baseline.json` is an optional file at the project root. It exists only when a project adopts QSOS standards against an existing codebase that already has violations.

**What it does:** Records pre-existing violations at adoption time so the compliance tooling suppresses them rather than failing the build on day one. New violations — in new files or introduced into edited files — always fail immediately. Baseline entries are removed progressively as the team fixes the legacy issues.

**What agents should know:**
- If the file exists, do not treat it as a problem or flag it as unknown
- Do not create it unless explicitly asked — it is a human decision to acknowledge legacy violations
- Do not add entries to it during normal workflow — it is not a way to suppress legitimate new failures

The file is committed to version control so all contributors share the same suppression set.

---

## Cross-artifact relationships

```
Ticket  ──links to──►  Feature file  ──@accepted before──►  Implementation
   │                       │
   └──links to──►  ADR  ──references──►  DSL element
                    │
                    └──governs──►  Contract / Statechart
```

When `/doc-sync` runs post-implementation, it verifies this graph is internally consistent: tickets closed, feature files `@done`, DSL `Target` elements promoted to `Current`, no orphaned ADRs.

---

## Skill chain reference

| Stage | Skill | Reads | Writes / Updates |
|---|---|---|---|
| Brainstorm | `/brainstorm` | Existing features, ADRs | Draft ticket (`work/`), draft feature (`@proposed`) |
| Feature spec | `/feature-doc` | Feature files, ADRs | Feature file (`@accepted`), ADR if needed |
| Architecture | `/architecture` | `architecture.dsl`, ADRs | `architecture.dsl`, ADR |
| Context load | `/orient` | Ticket, features, ADRs, DSL | Nothing — loads into context |
| Planning | `/plan` | Ticket (readiness), features, ADRs | Nothing — produces plan for approval |
| Implementation | `/implement` | Plan, feature file | Ticket → `in-progress` |
| Verification | `/verify` | — | Evidence artifact (`work/TIX-NNN/evidence/`) |
| Doc sync | `/doc-sync` | All of the above | Feature → `@done`, DSL Target → Current, ticket → `done`; checks catalog lifecycle invariant if `catalog-info.yaml` present |
| Bug triage | `/bug` | Feature files, ticket | Gap scenario or conflict note in feature file |

`/task` is not a stage — it is a cross-cutting adapter called by every skill that needs to read or write task state.
