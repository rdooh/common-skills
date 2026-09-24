# Capture Processing — CatalystOS Daily Review

Process unprocessed captures from CatalystOS (Chora) following GTD principles: full read, search before creating, traceability on every closure.

## Usage

```
/capture-processing [batch_size]
```

- `batch_size`: Number of captures to process (default: 5, max: 10)

## Processing Protocol

### 1. Fetch Unprocessed Captures (Oldest First)

Use `mcp__catalyst-os__search_raw_captures` with `unprocessed_only=true` and `limit=batch_size`. Sort by `captured_at` ascending (FIFO).

### 2. For Each Capture

**a) Read Full Body**
- Never truncate or preview
- Read the complete capture body

**b) Search for Related Tasks**
- Use `mcp__catalyst-os__search_tasks` with relevant keywords from the capture
- Include both open and done tasks in search
- Identify connections, duplicates, or prior work

**c) Analyze**
- What does this capture contain?
- What is its relevance/significance?
- What connections exist to tasks or other work?

**d) Determine Disposition**
- Mark processed (most common - retrospective docs, completed work reports)
- Create task(s) (actionable items not yet tracked)
- Create reference task (someday/maybe, future ideas)
- Park for later (unclear, needs more context)

### 3. Present Batch Report

Use this exact format for each capture in the batch:

```
---

**Capture ID:** cap-YYYYMMDD-NNN
**Capture Title:** [First line or H1 from body]
**Analysis:** [1-2 sentences: what it contains, why it matters]
**Related tasks:**
- ✅ tsk-YYYYMMDD-NNN (description) [if done]
- 🔄 tsk-YYYYMMDD-NNN (description) [if in progress]
- ⏸️ tsk-YYYYMMDD-NNN (description) [if open/waiting]
- None [if no related tasks found]

**Tasks to create:**
- [Task title and brief scope]
- None [if no tasks needed]

**Tags proposed:** #tag1 #tag2

**Proposed action:** ✅ [Mark processed | Create tasks | Park] (brief rationale)

---
```

### 4. Wait for User Approval

Present the batch report and wait for explicit approval before executing any actions.

### 5. Execute Actions

For each approved capture:

**If marking processed:**
```
mcp__catalyst-os__update_capture({
  id: "cap-YYYYMMDD-NNN",
  processed: true,
  note: "[Brief summary of what this capture documented]. [Reference to related tasks if any]. [Tags proposed: #tag1 #tag2]"
})
```

**If creating tasks:**
- Create task(s) via `mcp__catalyst-os__create_task`
- Then mark capture processed with note referencing the new task IDs

**If parking:**
- Do not mark processed
- Add note explaining why parked

## Critical Rules (Do Not Violate)

1. **Full read of every capture body** — no preview, no truncation, no "80 chars is enough"
2. **Traceability on every closure** — processing notes must include evidence: task IDs created/referenced, capture IDs of duplicates, or concrete explanation with proof
3. **Search before creating** — always search existing tasks before creating new ones
4. **No batch shortcuts** — even if 10 captures look similar, each must be individually read and assessed
5. **User approval for substantive dispositions** — present proposed actions and wait for sign-off
6. **Honest confidence reporting** — never claim high confidence without full reads

## References

- GTD principles: `.agents/skills/personal-os/references/capture.md`
- Processing decision tree: `.agents/skills/personal-os/references/clarify.md`
- Memory: `feedback_capture_means_written.md`, `feedback_traceability_on_closure.md`
- Original requirement: tsk-20260915-055

## Status Icons

- ✅ Done
- 🔄 In progress / active
- ⏸️ Open / waiting / blocked
- ❌ Cancelled

## Notes

**Skill location:** This skill is currently in `.claude/commands/` as project-local. CatalystOS-specific skills don't yet have a canonical home in the repo structure (see cap-20260924-003). May be relocated to `common-skills/catalyst/` or similar when infrastructure is clarified.
