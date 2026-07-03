---
description: Build, install, and verify a VS Code extension — automatically, without asking the user to do it.
---

# /vscode-ext-load

## When this runs

**Automatically** — any time you finish work on a VS Code extension, run this protocol before declaring done. Do not hand the user a list of instructions. Do not say "you can now install it by...". Do it.

**Explicitly** — the user can call `/vscode-ext-load` at any time to (re)build and reload the current extension.

This skill applies the `/verify` core principle: the extension being installed and active in VS Code is the outcome. Writing the code is not the outcome.

---

## Step 1 — Locate the extension root

Identify the extension directory. It is the folder containing `package.json` with a `"publisher"` or `"engines.vscode"` field. If you are mid-task, you already know this path. If not, look for it from the current working directory upward.

---

## Step 2 — Install dependencies (if needed)

Check whether `node_modules` exists and is current relative to `package.json`. If not:

```bash
npm install
```

---

## Step 3 — Build and install

Check `package.json` scripts for the fastest path, in this order of preference:

**Preferred — use the `install-ext` script if present:**
```bash
npm run install-ext
```
This compiles, packages, and installs in one step. Most extensions in this workspace have it.

**Fallback — if no `install-ext` script:**
```bash
npm run compile
npx @vscode/vsce package --allow-missing-repository
code --install-extension "$(ls -t *.vsix | head -1)"
```

**If the extension has a webview build step** (look for `build:webview` or a `scripts/build-webview.js`), ensure it runs as part of compile. `npm run compile` should handle this if `package.json` is correct — if it doesn't, run the webview build explicitly before packaging.

---

## Step 4 — Verify installation

Run:
```bash
code --list-extensions
```

Confirm the extension's ID (from `package.json` `"publisher"."name"`) appears in the output.

**CONFIRMED** — extension ID is present in the list. State this explicitly.

**UNCONFIRMED** — extension ID is absent. Do not ask the user to investigate. Check:
1. Did the `.vsix` file get created? (`ls -t *.vsix | head -1`)
2. Did `code --install-extension` exit 0?
3. Is the extension ID in `package.json` what you expected?

Fix what's wrong and retry before surfacing to the user.

---

## Step 5 — Reload prompt

VS Code requires a window reload to activate a newly installed or updated extension. After confirming installation, tell the user:

> "Extension installed. Reload your VS Code window to activate it (`Cmd+Shift+P` → `Developer: Reload Window`)."

This is the **only** instruction you hand to the user — because it requires a human to interact with a running VS Code window and cannot be automated from the terminal.

---

## Blocking rule

You may not say the extension is "ready", "installed", "working", or "done" unless Step 4 returned CONFIRMED. If you cannot reach CONFIRMED, report exactly what failed and what you tried.

---

## Notes on this extension ecosystem

- Build tool: TypeScript compiler (`tsc`) for extension code; some extensions also have a webview build step
- Package tool: `@vscode/vsce` via `npx`
- Install command: `code --install-extension <file>.vsix`
- Extensions with `install-ext` script: `forge-workflows`, `indexatron-monitor` (use this as the model when adding the script to others)
- No testing framework is currently in place — when tests are added, running them belongs between Step 2 and Step 3
