---
description: Prerequisite mapping session — given an objective, build a condition tree that exposes what must be true, where the risk lives, and what must be understood before any action is chosen.
---

# /prerequisite-map

## Core Principle

Plans answer "what will we do." This skill answers "what must be true."

Those are different questions. A plan sequences activity. A prerequisite map models the logical conditions for an outcome to exist. The map comes first — it shapes every subsequent choice about sequencing, resource, and risk.

The tool is a condition tree: the objective is the root, conditions that must hold for it to be satisfied are its children, and so on recursively. Where a condition is unknown or uncertain, that is load-bearing information. Where multiple condition sets could satisfy a parent, that is optionality worth naming.

Action lives at the leaves — and only after the tree is built.

---

## When to use this

- At the start of a project, initiative, or significant decision — before architecture, before planning, before committing to any approach
- When a plan feels stuck or has stalled — the map may reveal that the wrong conditions are being worked
- When early choices have created downstream constraints — to make visible what got closed off and why
- When a goal is stated but the path is unclear or contested

---

## The anti-pattern this counters

Building what you know because it produces visible motion. Known problems are solved problems — executing them produces no learning. Hard problems — the ones with unknown solutions that constrain everything else — are load-bearing. Their solutions determine the solution space for everything downstream.

The symptom: progress from 0 to 60 feels fast, then stalls at 85. Early architectural or strategic choices, made casually because the work felt safe, have closed doors you needed. This happens because sequencing was driven by confidence, not criticality.

The map forces criticality to the surface before any commitment is made.

---

## Step 1 — Establish the objective

Ask the user to state the objective in one or two sentences. Push for precision:

- What is the outcome, not the activity?
- How will you know it has been achieved?
- Is this a final outcome (done when reached) or a steady state (ongoing, with a definition of nominal)?

If the objective is vague, reflect it back and ask one clarifying question. Do not proceed with a fuzzy root — everything downstream inherits the ambiguity.

Record the objective as the root node.

---

## Step 2 — First decomposition

Ask: **"What must be true for this objective to be achieved?"**

Generate the first level of conditions together. For each condition:

- State it as a **condition**, not a task. ("The data pipeline can process 10k records/min" not "Build the data pipeline.")
- Assess: **Known** (we understand how to make this true) or **Unknown** (this is an open question)
- Assess: **Constraining** — does satisfying this condition limit the options available for satisfying other conditions?
- Assess: **AND or OR** — must all sibling conditions be true (AND), or will any one suffice (OR)?

Flag conditions that are both Unknown and Constraining — these are the highest-priority items in the tree. They represent risk that is also load-bearing.

---

## Step 3 — Recurse on unknowns

For each Unknown condition, ask: **"What must be true for this to be achievable?"**

Continue recursively until you reach either:
- A **leaf**: a condition that can be verified or falsified with a concrete experiment or investigation
- A **known condition**: something already understood well enough to act on with confidence

Do not recurse on Known conditions unless prompted. The goal is to expose the unknown territory, not to decompose the entire tree exhaustively.

---

## Step 4 — Surface the structure

Once the tree has sufficient depth, step back and characterize it:

**Where is the risk concentrated?**
Which unknown conditions, if unsatisfiable, would invalidate the objective or force a major restructure of the path?

**Where is the optionality?**
Which OR branches represent genuine strategic choices — different paths to the same condition? Name them explicitly as options, not as redundancy.

**What is the critical path?**
Which chain of conditions, from root to leaf, must be resolved first — because those conditions constrain the most others?

**What must not be decided yet?**
Which conditions appear safe to resolve now but are actually downstream of unknowns? Flag these as premature decisions — making them now may close doors that should stay open.

---

## Step 5 — Produce the map

Output the condition tree in a format the user can work with. Default format:

```
OBJECTIVE: [root statement]

├── [Condition A] — AND — Known / Constraining
│   ├── [Condition A1] — AND — Unknown / Constraining ⚠️
│   │   └── [Leaf: experiment to run or question to answer]
│   └── [Condition A2] — AND — Known
│
├── [Condition B] — OR — Unknown
│   ├── [Option B1] — path via X
│   └── [Option B2] — path via Y
│
└── [Condition C] — AND — Known
```

Legend:
- ⚠️ = Unknown + Constraining — highest priority to resolve
- OR branches = strategic optionality
- Leaves = investigable actions (not plan steps — investigation steps)

---

## Step 6 — Prioritize the next move

Given the map, ask: **"What is the smallest experiment or investigation that would most reduce the uncertainty in this tree?"**

This is not a plan. It is one next move — the one that unlocks the most downstream clarity. Prefer moves that:
- Resolve Unknown + Constraining conditions
- Preserve optionality (avoid committing to an OR branch before understanding the trade-offs)
- Produce a finding, not just an artifact

---

## Tone and facilitation notes

- Hold the objective steady. When the conversation drifts toward activity or solution, bring it back to conditions.
- Distinguish between "we haven't done this yet" (a task) and "we don't know if this is possible" (a real unknown). Only the latter is a genuine condition to recurse on.
- Be willing to challenge the objective itself. If decomposition reveals that the stated objective cannot be made true regardless of conditions satisfied, say so early.
- The map is a thinking tool, not a deliverable. Prefer a rough map that provokes useful questions over a polished one that produces false confidence.
