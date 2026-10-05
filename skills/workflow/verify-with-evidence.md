# Verify With Evidence

You are being invoked because evidence-based verification is required. This applies to any task involving debugging, fixing, or confirming that something is working. It is not optional.

## Trigger phrases

Any of the following means this skill is in effect:

- "verify with evidence"
- "show me evidence"
- "prove it works"
- "don't just tell me it's fixed"
- "check it yourself"
- "I'll believe it when I see it"
- "you're not checking"
- "how do you know?"

---

## The Core Rule

**Saying a thing works is not evidence that it works.**

The following are NOT evidence:

- "I changed the code so it should work now"
- "The command ran without errors"
- "I can see the fix looks correct"
- "The logic is sound"
- "It compiled / type-checked"
- "I started the server"
- "I ran the install script"

Evidence is an **observable artifact** — output you can see, a response you can read, a status you can query — that directly confirms the symptom is present or absent.

---

## Banned Phrases

These are **prohibited** in any verdict or evidence statement:

- "should work"
- "likely fixed"
- "appears to be working"
- "probably"
- "seems to"
- "I believe"
- "logically"
- "this should"

If you cannot confirm without hedging, issue **UNCONFIRMED**.

---

## The Three-Step Protocol

### Step 1 — Reproduce the symptom before touching anything

Find a way to observe the problem from the outside, the same way the user experiences it. This is your baseline. Run the tool. Capture the output. Show it.

Examples:
- Server won't start → run it, capture the actual error output
- Port not responding → `curl -s http://localhost:PORT/health` and show the response or connection error
- Test failing → run the test, show the actual failure output
- Command not found → run the command, show what actually happens
- UI not rendering → open the URL, check the browser response or take a screenshot
- Daemon not running → `launchctl list | grep <service-name>` or `ps aux | grep <process>`
- Database not connecting → attempt a connection and show the error, not just the config
- Dependency missing → run the command that uses it and show what fails, not just the config file

If you cannot reproduce the symptom, say so explicitly. Do not guess at a fix for a problem you cannot see. Ask the user what they observe and work backwards to find an observable test.

### Step 2 — Fix

Make your change.

### Step 3 — Run the same observation again

The exact same check you ran in Step 1. The symptom must be observably gone — not "probably gone because I changed the right thing."

If the symptom is still present, you are not done. Do not report success. Return to Step 1 with the new information.

---

## Evidence Type Catalog

Select the appropriate evidence type. If the context doesn't clearly match any entry, reason through what observable, artifact-producing evidence could exist for this type of change — then proceed with that and flag it as `[NEW PATTERN]`.

**UI / Visual behavior**
- Tool: Playwright, browser automation, or screenshot tool
- Artifact: Before-and-after screenshots, or a screenshot showing the expected state
- Minimum: One screenshot showing the problem is absent in the corrected state

**API / HTTP behavior**
- Tool: `curl`, `httpie`, a test harness, or Playwright network interception
- Artifact: Actual response body and status code (not inferred, not mocked)
- Minimum: The response payload showing the correct behavior

**Unit / integration test**
- Tool: The project's declared test runner
- Artifact: The parsed test result output or JSON file
- Floor: Must show `passed` status for all relevant test cases. Any skipped or failed tests must result in UNCONFIRMED.

**Log / console output**
- Tool: Run the relevant code path and capture stdout/stderr
- Artifact: The actual log lines produced
- Minimum: Log output demonstrating the correct behavior — not just absence of an error

**Performance / benchmark**
- Tool: The project's benchmark tool, Lighthouse, or equivalent
- Artifact: Numeric measurements before and after
- Minimum: Two numbers with units from the same measurement method

**Data / state change**
- Tool: Database query, file diff, or state inspection
- Artifact: The actual data showing the expected state
- Minimum: Query output or file contents demonstrating the correct state exists

**Build / compilation**
- Use only when the claim is specifically that something now builds or compiles
- Tool: The project's build tool
- Artifact: Build stdout showing success, including bundle size, warnings resolved, etc.
- Minimum: Full build output, not just exit code

**CLI / script behavior**
- Tool: Run the command and capture output
- Artifact: The actual stdout/stderr
- Minimum: Output demonstrating the correct behavior, not just exit 0

**Process / service running**
- Tool: `ps aux | grep <name>`, `launchctl list | grep <name>`, `lsof -i :PORT`, or `curl localhost:PORT`
- Artifact: The actual process list entry or HTTP response
- Minimum: A running process entry or a valid HTTP response — not just "I started it"

**Contract / schema validation**
- Tool: JSON Schema validator (ajv, jsonschema, etc.) run against actual output
- Artifact: Validator output showing the payload against the schema
- Minimum: Named schema, actual payload, and validator result

---

## Verdict System

Issue one of three verdicts:

**CONFIRMED** — The artifact unambiguously demonstrates the claimed outcome. You may use the words "fixed", "done", "resolved", "working", or "complete" only with this verdict.

**UNCONFIRMED** — The artifact shows the problem is still present, or you gathered no independently-observable evidence. Describe specifically what was found. Do not re-attempt the fix silently — surface this and wait for direction. Include this statement:
> "No independently-observable evidence gathered"

**INCONCLUSIVE** — The artifact exists but does not clearly confirm or deny. Explain why it is ambiguous. Include the artifact anyway. Ask what additional evidence would resolve it.

**Blocking language rule:** The words "fixed", "done", "resolved", "working", and "complete" are **prohibited** unless the verdict is CONFIRMED.

**Direct link rule:** Every evidence claim must include a direct `file://` path or `http://` URL. A claim without a link is not evidence.
- Bad: "Tests passed"
- Good: "Tests passed — file:///path/to/test-results/unit.json"

---

## Common Failure Modes to Avoid

**"The server is running"** — Did you curl it? `curl -s -o /dev/null -w "%{http_code}" http://localhost:PORT` must return a real status code, not a connection refused error.

**"The tests pass"** — Did you run them and show the output? "Should pass" and "passes" are different things.

**"The fix is in"** — Was the service restarted? Does the running process reflect the new code? A code change that hasn't been reloaded has not taken effect.

**"The dependency is installed"** — In which environment? Run the actual command that uses it and confirm it resolves.

**"The port is open"** — Run `lsof -i :PORT` or `curl localhost:PORT` and show the response.

**"I deployed it"** — Check the version endpoint, process start time, or startup log of the new build. Assumption is not observation.

**"The config is correct"** — The running process may still be using the old config. Confirm it has reloaded since the change.

---

## When You Cannot Observe the Symptom

1. Say so explicitly — do not pretend you verified when you did not
2. Describe exactly what the user should run or check
3. Give the expected output if working, and the failure output if not
4. Issue INCONCLUSIVE — do not declare the task complete

Example:
> "I cannot directly verify this from here. To confirm it's working, run: `curl http://localhost:3000/health` — you should see `{"status":"ok"}`. If you see connection refused, the service did not start. Verdict: INCONCLUSIVE."

---

## The Standard

If the user has to open a browser, run a command, or check a log to find out whether your fix worked — you did not finish the job. Verification is part of the fix, not the user's responsibility.

**When you say something works, you have seen it work.**
