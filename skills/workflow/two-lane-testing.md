---
description: Two-lane testing for fast, safe iteration — a scoped fast lane (about 30 s) that gates each small step, and a full-suite audit lane that runs in a throwaway worktree in the background and never blocks. Use when a project's full test run is slow enough that waiting on it would stall work.
---

# /two-lane-testing

**Status:** trial, from 2026-10-07. Built and proven on one project (Interpret V1 front-end rework); refine it as it is used elsewhere.

## Core principle

Gatekeeping and auditing are different jobs. A **gate** must be fast enough to run after every small change, so it is scoped to what changed and aims at the most likely catches. An **audit** is comprehensive and slow, so it must never be waited for: it runs against a committed snapshot in the background, and its result is read at natural pauses. A late audit failure has a short list of suspects: the commits since the last green one.

Never sit on a sleep timer waiting for a long run. Start it in the background, carry on, and read the result when it is announced or at the next pause.

## The two lanes

| Lane | Gates the next step? | Budget | Runs |
| --- | --- | --- | --- |
| Fast | Yes, after every small change | target 30 s, hard ceiling 60 s | only what the change touches; fails at the first red |
| Audit | No | as long as it needs | everything, on a committed snapshot, in a throwaway worktree with its own ports and database |

## Fast lane: how to build it

1. **Find what changed**: uncommitted files; if the tree is clean, the files of the last commit. Do not use the last commit when something is uncommitted.
2. **Map changes to checks** in a small config file (path pattern to checks). Typical: type check, related unit tests only, lint of touched files only, build, records check, shell/python syntax. Anything with no fast check is *named* in the output ("covered by the audit"), never silently skipped.
3. **Browser tests: a handful, tagged** (for example `@fast`) — the most telling one to three per screen — mapped to the screens a change touches. Skip global warm-ups when the stack is already running.
4. **Call tools directly, not through `npx`.** Local binaries run in 1 to 2 s; `npx` startup cost 15 s per call on the project this was built on. Measure before accepting a slow step.
5. **Print the verdict against the budget** ("within target", "over target", "OVER THE CEILING") and exit non-zero over the ceiling.
6. **Prove it**: a deliberate type error and a deliberate behaviour break must each fail it quickly.
7. A flake in the fast lane is a bug in the test, not noise. Reproduce under load (run several copies in parallel) and fix the race.

## Audit lane: how to build it

1. **Audit committed state only.** Record every repo's commit (some projects keep tests in a second repo).
2. **Throwaway worktree per audit**, removed afterwards. Share heavy read-only things by symlink (dependency folders, seed data).
3. **Isolation**: separate ports, database name, run directory and seed copy from the dev stack and from the fast lane, so the audit can run beside real work. Run it at lower priority (`nice`) and with fewer workers.
4. **One at a time, coalescing.** A lock file with the process id; a request while one runs sets a "pending" flag, and after the run the next audit takes the newest commit, not each queued one.
5. **Record per commit**: a result file with the commits audited, the checks, and on failure *"last green commit X; look at `git log X..Y`"*. Keep a `LATEST` pointer and a `status` command that shows last audit, last green, and commits since.
6. **Start it so you are told when it ends**: run the worker as a background task (the harness announces completion); a detached `start` also works for agents without that.
7. Do not run the audit on uncommitted work; commit first (small, frequent commits make the suspect list short).

## Working rhythm

1. Small change → fast lane (seconds) → fix or continue.
2. Commit → start an audit of the commit → carry on with the next step.
3. At natural pauses (end of a step, before reporting) read `audit status`. If red, bisect the range since the last green commit, fix, commit.
4. Report the audit state honestly: "audited up to X, green" or "Y commits since the last audit".

## Per-project config (keep it in the project, not here)

- the path-to-checks map and the `@fast` tags
- the full command, and the isolated ports, database and run directory for the audit
- where results are stored and which commands start and read them

## What not to do

- Do not make the fast lane comprehensive to feel safer; that turns it back into a gate that is waited on.
- Do not wait on the audit, and do not poll it with sleeps.
- Do not skip the audit because the fast lane is green; the audit catches what the map did not.
- Do not leave the audit's ports or database shared with the dev stack.
