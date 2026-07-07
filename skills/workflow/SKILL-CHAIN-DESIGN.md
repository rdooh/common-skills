# Skill Chain Design

This document captures the design decisions and current state of the common-skills workflow chain.
For artifact formats, file locations, and cross-artifact relationships, see
`common-skills/standards/project-structure.md` — that is the canonical reference.

---

## The chain

```
/brainstorm → /feature-doc → /architecture → /orient → /plan → [approve]
    → /implement → /test → /deploy → /verify → /doc-sync
```

`/task` is not a stage — it is a cross-cutting adapter called by every skill that reads or writes task state.
`/bug` is an entry point for bug triage that feeds back into `/feature-doc`.

---

## Skill inventory

### Exists — strong

**`/verify`** — Post-implementation evidence gate. Evidence-typed catalog (UI, API, unit test, log, perf, data, build, CLI). Blocks "done" declarations without artifacts. Blocking verdicts: CONFIRMED / UNCONFIRMED / INCONCLUSIVE.

**`/feature-doc`** — Pre-implementation docs gate. Enforces feature file + ADR exist, runs 4-check audit (terminology, state assumptions, behavioral contradiction, scope creep), blocks on CONFLICT. Three modes: new / change / bug.

### Exists — VS Code specific (generalise later)

**`/vscode-ext-test`** — Runs Jest unit tests + `@vscode/test-cli` integration smoke test. Gates packaging. Scaffold protocol for extensions without tests.

**`/vscode-ext-load`** — Build → test gate → package → install → verify. Gates on `/vscode-ext-test` passing. Handles `npm run install-ext` pattern.

### To build

**`/brainstorm`** — Top of chain. Interactive scoping (learns from Agent OS `/shape-spec`). Produces: draft ticket (TIX), draft feature file (`@proposed`). Must be aware of existing feature files and ADRs — not a blank-slate tool. Output feeds `/feature-doc`.

**`/architecture`** — Owns `docs/architecture/architecture.dsl`. Updates Current/Target tagged elements when a feature changes the structural model. Creates or updates ADR when an architectural decision is made. Knows the duality rule: every `Target` element needs an `Accepted` ADR, every `Current` element must be verifiable in code.

**`/orient`** — Project-aware context loader. Given a task description or ticket ID, loads the relevant ticket, feature files, ADRs, and DSL section into context. Produces a structured summary: what was loaded, what standards apply, any gaps or stale docs flagged. Smarter than Agent OS `/inject-standards` because it is artifact-aware. Runs before `/plan`.

**`/plan`** — Implementation planning. Reads the relevant `.feature` file(s) and maps each scenario to a deliverable. Reads relevant ADRs for architectural constraints. Checks ticket readiness (feature linked, ADR assessed, no blockers). Produces a numbered plan with file-level specificity. Gates on human approval before any code is written.

**`/implement`** — Lightweight contract for the coding phase. Enters plan mode, follows the plan, but sets explicit expectations: double-check cross-file impacts, flag anything that contradicts the plan, mark ticket `in-progress` via `/task`, do not declare done without running `/verify`. Not a how-to — a one-page contract.

**`/task`** — Cross-cutting adapter for task tracking. Resolves the tracking medium in play (Jira → TIX files → local plan → ask), confirms with the user, then exposes a consistent interface: find / read / start / update / close. All other skills call this rather than touching ticket systems directly. Degrades gracefully when a medium lacks certain capabilities.

**`/doc-sync`** — Post-implementation reconciliation. Re-reads the feature file against what was built, checks DSL `Target` elements that should now be `Current`, closes the ticket with an evidence pointer. Delegates to `strux diagnose` when Strux is available. Produces a sync report: what was updated, what drift was found, what remains open.

**`/bug`** — Bug triage entry point. Currently buried inside `/feature-doc` bug mode — deserves its own skill once the chain is complete. Flow: reproduce → diagnose → determine gap vs. conflict → update feature file → create or link ticket → feed into `/plan`.

---

## Key design decisions

### Ticket tracking is a cross-cutting concern, not a stage
`/task` is an adapter, not a workflow step. Every skill that touches task state calls it. Medium is resolved once per session and confirmed with the user. See `project-structure.md` for medium preference order and capability matrix.

### Architecture and decisions are a separate group from features
Three artifact groups: Requirements+Features / Architecture+Decisions / Contracts+Statecharts. `/feature-doc` owns group 1. `/architecture` owns group 2. Group 3 is not yet served by a dedicated skill — ADRs reference contracts and statecharts but no skill currently drafts them.

### Structurizr DSL is the architecture source of truth
Not Mermaid. DSL is semantic-first; Mermaid diagrams are generated outputs. Current/Target duality is expressed via tags in a single file, not two separate files. See `project-structure.md` and Strux ADR-007, ADR-014.

### Feature files carry a lifecycle tag
`@proposed` → `@accepted` → `@in-progress` → `@done`. Nothing ships `@proposed`. `/feature-doc` sets `@accepted`. `/implement` sets `@in-progress` via `/task`. `/doc-sync` sets `@done` after `/verify` confirms.

### Skills prescribe; Strux monitors
Skills tell the agent what to produce. Strux audits the artifacts after the fact. As Strux matures, skills delegate their audit steps to it rather than doing manual checks. The handoff point is `/doc-sync`, which is the natural place to run `strux diagnose`.

### Agent OS relationship
Agent OS `/shape-spec` is the prior art for `/brainstorm`. Key difference: `/shape-spec` produces a spec folder in `agent-os/specs/`; `/brainstorm` produces a ticket and a feature file in the standard locations. Once `/orient` exists, Agent OS `/inject-standards` is no longer needed in the daily workflow — `/orient` is project-artifact-aware where `/inject-standards` is generic.

---

## Suggested build order

1. `/task` — everything else calls it
2. `/brainstorm` — top of chain, produces first artifacts
3. `/orient` — loads context; needed before `/plan` is useful
4. `/plan` — gates implementation
5. `/architecture` — parallel domain to `/feature-doc`
6. `/implement` — lightweight coding phase contract
7. `/doc-sync` — closes the loop
8. `/bug` — extract from `/feature-doc` once chain is complete
