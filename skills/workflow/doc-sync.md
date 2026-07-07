---
description: Post-implementation reconciliation — close the loop between what was planned, what was built, and what the docs say.
---

# /doc-sync

## Core Principle

Docs that are written before implementation and never updated after it are fiction. This skill is the reconciliation pass: it re-reads what was specified, compares it to what was built, resolves the gap, and closes the record. A feature is not done when the code compiles — it is done when the spec, the architecture model, the ticket, and the implementation all agree.

---

## When this runs

After `/verify` has returned CONFIRMED. This skill does not run if verification is outstanding — closing docs on unverified work is premature.

---

## Step 1 — Confirm verification is complete

Check that `/verify` has returned CONFIRMED in this session for the active ticket. If `/verify` has not run or returned UNCONFIRMED or INCONCLUSIVE, stop. State: "Doc sync cannot run until /verify returns CONFIRMED."

---

## Step 2 — Check feature lifecycle

Load the feature file(s) linked to the active ticket. The lifecycle tag should be `@in-progress`. If it is:

- `@proposed` — implementation should not have started; note as a process gap
- `@accepted` — `/implement` should have set this to `@in-progress`; note and correct
- `@in-progress` — correct; continue
- `@done` — this skill has already run; confirm this is not a duplicate run

---

## Step 3 — Check behavioral drift

For each scenario in the feature file, re-read the `Given / When / Then` steps and compare to the implemented behavior.

Ask: does the code do what the scenario says it does? Test cases passing is not the same question — tests may not cover all scenarios, and scenarios may have been written before edge cases were discovered.

For each scenario, note:
- **Match** — behavior matches specification
- **Drift** — implemented behavior differs from what the scenario specifies

If drift is found, determine what is authoritative:
- The spec was correct, the implementation drifted → fix the code or flag for the next ticket
- The implementation revealed a better behavior → update the scenario to reflect reality, note the change

Do not silently accept drift. Both outcomes require a record.

---

## Step 4 — Check DSL duality

Load `docs/architecture/architecture.dsl`. For each `Target` element that was part of the work delivered in this ticket:

- Has it been implemented? If yes, change the tag from `"Target"` to `"Current"`
- Is it partially implemented? Leave as `"Target"` and note what remains

If `architecture_updated` was `true` in the ticket frontmatter, confirm the DSL was actually updated during implementation. If it was not, do it now.

---

## Step 5 — Check ADR completeness

Review the implementation decisions made. Apply the 6-month reversal test: was any choice made during implementation that would have warranted an ADR, but none was written?

Common triggers:
- A library was chosen for a non-trivial reason
- A pattern was applied that will govern future similar work
- A component boundary was established that other code now depends on

If a decision slipped through undocumented, write the ADR now (status `Accepted`, retrospective). It is better to write it late than never.

---

## Step 6 — Run Strux if available

Execute `strux diagnose` and include its output in the report. Strux will audit:
- Gherkin rules on the updated feature file
- ADR linting rules
- DSL element consistency
- Cross-artifact graph completeness

If Strux is not available, note this and proceed with the manual checks above as the fallback.

---

## Step 7 — Update lifecycle and close ticket

1. Set feature file lifecycle tag to `@done`
2. Call `/task close <id> <evidence pointer>` — the evidence pointer is the artifact reference from `/verify` (test result path, screenshot, log excerpt, etc.)

---

## Step 8 — Produce sync report

```
DOC SYNC REPORT

FEATURE: <path> → @done
TICKET: <id> → closed [evidence: <pointer>]

DSL CHANGES:
  - <element name> [Target → Current | no change needed]
  [or: none]

ADR GAPS FILLED:
  - <ADR-NNN: title — created retrospectively>
  [or: none]

BEHAVIORAL DRIFT:
  - Scenario "<name>": <match | drift — <description and resolution>>
  [or: none]

STRUX: <output summary | not available>

SYNC VERDICT: CLEAN | DRIFT FOUND — <details>
```

---

## Blocking rule

**You may not mark the ticket `done` or the feature `@done` unless `/verify` has returned CONFIRMED.** Do not skip the behavioral drift check — a test suite passing is not the same as every specified scenario being implemented as written. An undocumented architectural decision discovered during this step must be recorded as an ADR before the sync report is marked CLEAN.
