---
description: Implementation contract — enter the coding phase with an approved plan and leave it only after /verify confirms.
---

# /implement

## Core Principle

Implementation without a plan is exploration. Exploration is valuable — but it is not implementation. This skill is a one-page contract: you have a plan, it has been approved, and your job is to execute it faithfully. Deviations are not forbidden — they are flagged before continuing, not after. Nothing is "done" here. Done is `/verify`'s word.

---

## When this runs

After `/plan` has produced a plan and the user has approved it. Before `/test` and `/verify`.

---

## Step 1 — Confirm plan exists and is approved

Verify that a `/plan` output is present in context and that the user has explicitly approved it. If no plan exists, redirect to `/plan` and stop. If a plan exists but approval is ambiguous, ask before writing a single line of code.

State the plan reference: which ticket, which feature file, how many items in the plan.

---

## Step 2 — Mark ticket in-progress

Call `/task start` with the active ticket ID. This is not optional — invisible work is untracked work.

---

## Step 3 — Set feature lifecycle

Update the feature file's lifecycle tag from `@accepted` to `@in-progress`. This signals that implementation has begun and prevents another agent from concurrently starting the same work.

---

## Step 4 — Implement the plan

Follow the approved plan exactly, item by item. For each item:

- Name the file being changed
- Make the change
- Confirm the item is done before moving to the next

**When a deviation is necessary** — a file not in the plan needs to change, the approach needs to adjust, or a scenario maps to something different than anticipated — stop before making the change. State:

```
DEVIATION: <what was planned> → <what is actually needed>
REASON: <why the plan item does not match reality>
PROCEEDING: yes (minor, no architectural impact) | no (needs approval)
```

Minor deviations (different line numbers, additional helper function in the same file) may proceed. Deviations that add files, change interfaces, or affect other feature areas require a pause for review.

---

## Step 5 — Cross-file impact check

Before declaring implementation complete, verify:

- No file outside the approved plan was unintentionally modified
- No exported interface or type was changed without a corresponding plan item
- No new dependency was introduced that wasn't present before

If any unplanned change is discovered, surface it now — do not omit it from the record.

---

## Step 6 — Hand off to verification

Do not declare the implementation complete. Do not use the words "done", "complete", "finished", or "working". When the plan items are executed, state:

```
IMPLEMENTATION: all plan items executed

UNPLANNED CHANGES: none | <list>
DEVIATIONS: none | <list>

Next step: run /test then /verify
```

Then run `/verify` (or `/test` first if a test skill applies — e.g. `/vscode-ext-test` for VS Code extensions).

---

## Blocking rule

**You may not begin writing code without an approved plan.** You may not declare implementation complete without a CONFIRMED verdict from `/verify`. You may not skip the cross-file impact check — an undisclosed change is a hidden risk. Any deviation from the approved plan must be surfaced before the deviated change is made, not discovered during review afterward.
