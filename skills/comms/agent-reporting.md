---
description: Agent reporting and reflection — spoken updates, questions in the audio, reflect back instead of confirming, short chat checklists, and a practicality test. For any agent working with an owner who runs several agents and is often not looking at the screen.
---

# /agent-reporting

**Status:** trial, from 2026-10-02 (reflect-back check-in: working, no damage so far). Written from one long working session; refine it as it is used.

## Core principle

The owner runs several agents in parallel and is often not looking at your screen. Audio is how they know you are alive, what you did and what you need. Silence is a failure. So is a report they cannot act on. Carry the effort yourself: do the first pass, make a recommendation, and ask for a judgement only where only they can give it.

## 1. Voice updates

- Keep your own voice and your own spoken prefix (for example "Orbit Planner Report"), so the owner can tell parallel agents apart. Load the voice tool with ToolSearch before first use.
- Speak when you start a piece of work; at each meaningful finding, change, ticket update, commit or deploy; when blocked and what unblocks you; when you finish and whether it worked; when you need a decision; after context compaction, once you have reread your mandate.
- About 60 to 120 words. Say what happened, what changed, what is next. Plain words. No code, file paths or long lists.
- No vanity statistics (counts of files, tickets or tests that do not drive a decision).
- Do not report routine self-checks (your own screenshots, lint runs) unless they found something the owner must act on.
- Never say "nothing needs you" unless it is true. If something unreviewed is waiting for them, say so.
- Add a "voice gist checkpoint" item to every todo list you keep.

## 2. Questions go in the audio

- Put the question at the end of the spoken update, one at a time. The owner often does not read the chat.
- Make it answerable by voice: give your recommendation and the one reason, then ask yes, no or tweak. Offer at least two real options, never one option and its negation.
- Never ask an open question that makes the owner build a mental model. Do the first pass yourself.
- If you need to know the answer to a factual question that someone else can answer, say who, and ask them.

## 3. The chat supports the audio

- A headline, then a checklist with sublists, ticked as items finish, so progress is visible at a glance.
- Put detail behind labelled points: B1, B2 for benefits, R1, R2 for risks, A1, A2 for assumptions. The owner can then say "yes, but R2 is wrong".
- Three levels of resolution for a decision: a spoken gist of about 100 words; short numbered written points; and, where it helps, a small structured map of the options for anyone who wants the full reasoning.
- Do not restate the audio at length.

## 4. Reflect back; do not ask them to confirm

After a brain-dump, reflect your understanding back briefly, then stop. Do not ask "is that right?".

| Their reply | Signal | What you do |
| --- | --- | --- |
| Explicitly confirms a point | Strong | Treat as settled |
| Says nothing about a point | Weak | Treat as true enough and proceed, and say that you did |
| Disputes or corrects a point | Negative | Revise and reflect again |

Caveats:
- Restating in words is weak evidence of shared understanding. For a high-stakes point, test with a concrete case or a prediction, and ask for one reason the point might be wrong.
- The owner's connection is sometimes slow. A short silence is not agreement while a question is open. Keep working on anything that does not depend on the answer; when a late answer arrives, apply it, say what it changed, and recheck what you assumed meanwhile.
- Silence can mean "agree" or "did not read that part". Say which points you took as weak agreement.

## 5. Make it practical

For any process, trigger, interval or reminder you propose, name who or what does it, when, and what makes them. If nothing makes it happen, it will not happen, however logical it is. Prefer things that a tool derives from data and shows where the owner already looks over anything that relies on someone remembering.

## 6. Keep the record honest

- Update ticket status when work starts and when it ends, not afterwards. The owner may be watching a board.
- Do not leave fixes for others when the fix is within your reach. Amend it, with the ticket key in the commit.
- Re-read the next ticket number immediately before filing a ticket if other agents file concurrently, and check for duplicates afterwards.
- Say plainly when something is unverified or was read from documents only, and when a tool failed. Do not work around a broken tool silently.

## 7. Your mandate

Add a short section to your own mandate file covering these points. Edit only your own mandate file. Tell the owner exactly what you are adding and do it only after they agree. Do not edit other agents' files or any shared memory index. Reread your mandate after any compaction.

## A good update and a bad one

- Good: "Orbit Builder Report. Finished the guarded-write change. It refuses a save when the file has changed underneath, and it passes its tests. I deployed version 0.4.41. Next is the approval card. One question: should a refused save show a difference, or just the message?"
- Bad: "Done. Updated 7 files, 142 lines, 14 tests passed. Let me know if anything else is needed."
