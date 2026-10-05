# Mandate — Session Directive

A mandate is a hard constraint on what you are doing right now. It is not a memory — it is an active directive.

## Why this exists

Context compaction loses detail. A mandate must survive compaction fully intact so that a fresh context window can pick up exactly where the last one left off, with no drift and no re-explanation from the user. The mandate file is the single source of truth for "what am I doing and what are the rules."

## Two layers: the how-to and the what-and-why

- **Baseline (the how-to):** `mandate-baseline` (installed next to this skill; source `skills/workflow/mandate-baseline.md`). How every agent reports, refers to work, handles git, documents, tools, approvals and compaction. It is maintained in one place so that all sessions behave the same way. **A mandate never copies it.**
- **Session mandate (the what and why):** goal, scope, current state, out of scope, and the choices made at setup. Short. Only this changes per session.

If a rule is wanted in every session, it belongs in the baseline, not in a mandate. If a baseline line does not suit one session, the mandate overrides it by name under "Choices and overrides".

## Session isolation

**CRITICAL:** Mandates are session-scoped. Multiple Claude sessions can run concurrently in the same project. Each session MUST use its own mandate file to avoid clobbering another session's directive.

- **File naming:** `session_mandate_{short-id}.md` where `{short-id}` is the first 8 characters of `$CLAUDE_CODE_SESSION_ID`
- **Discovery:** after compaction, `MEMORY.md` contains a line pointing to this session's mandate file — the short ID in the filename lets the session find its own file
- **Cleanup:** `/mandate clear` deletes only this session's file. Stale files from dead sessions are harmless — they are never read by a session that doesn't own them

To resolve your session ID, run: `echo $CLAUDE_CODE_SESSION_ID | cut -c1-8`

## Compaction survival mechanism

1. The mandate lives in project memory (`session_mandate_{short-id}.md`) and is indexed in `MEMORY.md`
2. After compaction, MEMORY.md is loaded automatically — the one-liner points to the file
3. **Any Claude instance that sees a mandate entry in MEMORY.md matching its session ID MUST read that file and the baseline before taking any action** and acknowledge both in 2 to 3 sentences
4. If a mandate entry in MEMORY.md does NOT match this session's ID, ignore it — it belongs to another session
5. The mandate file must be **self-contained for the what and why** — it should make full sense to a reader with zero conversation history, given the baseline

## Usage

The user invokes `/mandate` with an optional argument: `$ARGUMENTS`

**First:** resolve the session short ID by reading `$CLAUDE_CODE_SESSION_ID` and taking the first 8 characters. Read the baseline.

**Parse the argument to determine the action:**

### `/mandate set <text>`, `/mandate <text>` or `/mandate revise`

Write (or revise) the mandate at `~/.claude/projects/{project-key}/memory/session_mandate_{short-id}.md`.

#### Step 1: setup questions (on first set and on every revise)

Ask these together in one message, each with its recommended default marked. The owner can answer "defaults". Skip any the user's text already answers. On revise, show the current choice and ask whether it still holds.

1. **Voice.** A) `af_heart`, speed 1.1, spoken prefix named after the project, e.g. "Interpret Report" (recommended). B) A different voice and prefix. C) Voice off.
2. **Role.** A) Engineer and architect: builds, verifies, commits (recommended). B) Planner: docs, tickets and decisions only, no code. C) Investigator: read-only, reports findings.
3. **Tracking.** A) CatalystOS is the system of record. B) In-repo tickets. C) Jira (also apply the Jira rules in the baseline).
4. **Scope guard (always required).** The goal, the repo or directories in play, and what is out of scope. Never guess these. If the user declines to give the goal, write "TBD: not yet set" and ask again when work needs direction.

Everything else in the baseline applies without a question. If the user names a different choice for a baseline default (for example "ask before pushing", "fuller written reports", "spawn freely up to N agents", "also run the CatalystOS check after compaction"), record it under "Choices and overrides".

#### Step 2: write the file

**Template:**

```markdown
---
name: session-mandate-{short-id}
description: Active session mandate ({short-id}) — {project} — read immediately after compaction before taking any action
metadata:
  type: project
---

**Mandate set {date} (session {short-id}).** Baseline: mandate-baseline v{n}. After compaction, reread this file and the baseline before acting.

## Objective
{One or two sentences: what are we doing and why. Enough context that a reader with no
conversation history understands the situation.}

## Scope
{Exactly which files, directories, packages or systems are in play. Absolute paths.
Flag anything in scope that needs extra caution (shared libraries, production data).}

## Choices and overrides
- Voice: {voice_id}, speed {n}, prefix "{prefix}"
- Role: {engineer-architect | planner | investigator}
- Tracking: {CatalystOS | in-repo | Jira}
- Overrides of baseline lines: {none, or the line and the new rule}

## Session rules
{Numbered list of constraints specific to THIS session only. Not the baseline.
Include lessons learned earlier in the session that must not be repeated.}

## Current state
{Branch, what was recently merged or changed, known broken or in-progress items.
Prevents a post-compaction Claude from redoing completed work.}

## Out of scope
{What NOT to touch. Explicit. If another agent owns something, say so.}
```

A thin Objective or Scope is a failed mandate, but a stated "TBD" is honest; a guessed value is not.

Also update MEMORY.md — replace any existing mandate line **for this session** (match by short-id) or append:
`- [Active mandate ({short-id})](session_mandate_{short-id}.md) — {one-line summary}`

Do NOT remove mandate lines belonging to other sessions.

Confirm with one line: `Mandate set ({short-id}): {summary}`

### `/mandate` (no arguments, or `get`)
Read and echo the current mandate from `session_mandate_{short-id}.md`, followed by the baseline version it is on. If none exists, say "No active mandate for this session."

Also list any other mandate files present (from other sessions) with a note that they are not yours.

### `/mandate clear`
Delete `session_mandate_{short-id}.md` and remove this session's mandate line from MEMORY.md. Do NOT touch other sessions' mandate files or lines. Confirm: `Mandate cleared ({short-id}).`

### `/mandate clear-all`
Delete ALL `session_mandate_*.md` files and the legacy `session_mandate.md` if present. Remove all mandate lines from MEMORY.md. Use when the user wants a clean slate across all sessions. Confirm: `All mandates cleared.`

## Behaviour rules

- A mandate is **loud** — when it exists, treat it as the primary constraint on your actions. It is not passive context.
- **After compaction:** find and read `session_mandate_{short-id}.md` for YOUR session ID and the baseline immediately, reflect them back in 2 to 3 sentences, speak a gist, then continue. Do not ask the user to re-explain. Ignore mandate files that don't match your session.
- A mandate does not replace task-level instructions — it frames them. "Focus on UI changes" doesn't mean ignore a build error, it means don't go chasing deploy fixes unprompted.
- Only the user sets, changes, or clears mandates. Never self-modify. Changes to the baseline are the user's call and are made in the source file, not in a session mandate.
- **Never write to another session's mandate file.** If you detect a collision (file changed by another session), re-read your own file — if it was overwritten, rewrite it from your context and warn the user.
- **Existing mandates** written before the baseline existed keep working. On their next revise, move their standing rules into "Choices and overrides" or drop them if the baseline now covers them.
