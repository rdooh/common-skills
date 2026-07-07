# Skill Chain Design — Status and Next Steps

## Current chain (what exists)

```
/feature-doc  →  [GAP: orient + plan]  →  [implement]  →  /verify
```

`/feature-doc` (~/.claude/commands/feature-doc.md) — pre-implementation gate.
Enforces feature file + ADR exist, runs 4-check audit (terminology, state assumptions,
behavioral contradiction, scope creep), blocks on failure. Strong. Keep as-is.

`/verify` (~/.claude/commands/verify.md) — post-implementation evidence gate.
Evidence-typed catalog, blocks "done" declarations without artifacts. Strong. Keep as-is.

## The gap — two skills to build

### /orient
**Purpose:** Project-aware context loader. Replaces manual file-reading at session start.
**How it works:** Given the current task area (e.g. "interpret-pipeline viewer", "evoyaNGS components"),
loads the relevant ADRs, feature files, inventory data, and port registry into context.
Smarter than Agent OS /inject-standards because it's artifact-aware, not generic.
**Input:** Task description or ticket ID
**Output:** Structured context summary — which ADRs loaded, which feature files loaded,
which standards apply, any gaps or stale docs flagged
**Reference:** Agent OS /inject-standards is the generic equivalent to learn from

### /plan
**Purpose:** Implementation planning skill. Produces a structured plan against feature file
acceptance criteria. This is the plan-mode pattern the user wants as the default before
any implementation begins.
**How it works:**
1. Reads the relevant .feature file(s) — maps each scenario to a deliverable
2. Reads relevant ADRs — surfaces architectural constraints
3. Identifies risks, unknowns, cross-file impacts
4. Produces a numbered plan with file-level specificity
5. Surfaces for user approval before any code is written
**Input:** Ticket ID or task description + loaded context (ideally after /orient)
**Output:** Numbered plan with: files to create/modify, scenarios being addressed,
risks flagged, explicit "awaiting approval" gate
**Reference:** Claude Code native plan mode is the execution vehicle; this skill
shapes the plan quality before plan mode runs

## Complete target chain

```
/feature-doc  →  /orient  →  /plan  →  [approve]  →  [implement]  →  /verify
(pre-flight)   (load ctx)  (plan)    (human gate)  (auto-execute)  (evidence)
```

User preference: plan → approve → execute to completion without interruption,
except when Forge workflows are explicitly requested.

## Relationship to Agent OS

Agent OS v3 ships: discover-standards, inject-standards, shape-spec, plan-product, index-standards.
It intentionally retired implement-tasks (Claude Code plan mode does it better — see v3 changelog).
/discover-standards is useful as a one-time extraction tool to pull codebase conventions into
structured files. After that, /orient replaces /inject-standards with project-specific awareness.
Once /orient exists, Agent OS is no longer needed in the daily workflow.

## Suggested next agent prompt

"Build two global Claude skills at ~/.claude/commands/:
1. orient.md — project-aware context loader (see SKILL-CHAIN-DESIGN.md for spec)
2. plan.md — implementation planning skill with feature file mapping (see SKILL-CHAIN-DESIGN.md)
Read ~/.claude/commands/feature-doc.md and verify.md first to match the writing style and
depth of the existing skills. These should slot into the chain described in SKILL-CHAIN-DESIGN.md."
