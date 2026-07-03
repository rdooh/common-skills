---
description: Run tests for a VS Code extension and produce a structured result. Required gate before vscode-ext-load packages or installs.
---

# /vscode-ext-test

## Core Principle

This skill applies the `/verify` principle to test execution. Running tests is not the outcome — passing tests with a visible artifact is. A "tests passed" claim with no output is not evidence.

---

## When this runs

**Automatically** — called by `/vscode-ext-load` before packaging. Do not skip it.

**Explicitly** — call `/vscode-ext-test` any time to run tests and see results without triggering a build or install.

---

## Test architecture

Each extension has two test layers:

### 1. Unit tests (`src/test/unit/`)
Pure logic only — no VS Code API, no file system, no network. Fast. Run with Jest directly.

### 2. Integration / smoke tests (`src/test/integration/`)
Uses `@vscode/test-electron` to spin up a real VS Code Extension Host. Minimum: one smoke test confirming the extension activates without throwing. Additional tests for command registration, panel creation, service connectivity (e.g. Indexatron, Forge) where relevant.

---

## Step 1 — Check test setup exists

Look for:
- `package.json` with `"test"` script
- `src/test/` directory
- `jest.config.js` or `jest.config.ts`

If test setup is missing, **do not skip ahead**. Run `/vscode-ext-test --scaffold` to create it (see Scaffold Protocol below), then return to Step 2.

---

## Step 2 — Run unit tests

```bash
npm run test:unit
```

This runs Jest over `src/test/unit/` and writes results to `test-results/unit.json`.

Capture the full output. Do not summarize.

---

## Step 3 — Run integration tests

```bash
npm run test:integration
```

This launches `@vscode/test-electron`, runs the integration suite, and writes results to `test-results/integration.json`.

Capture the full output. Do not summarize.

---

## Step 4 — Deliver verdict

Parse the JSON result files and issue a verdict:

**PASSED** — all tests in both suites passed. State the counts: `X unit tests passed, Y integration tests passed`. Include the JSON result paths as artifacts.

**FAILED** — one or more tests failed. List each failing test by name with its error message. Do not proceed to packaging. Surface the failures and wait for direction.

**PARTIAL** — one suite passed, the other failed or did not run. Treat as FAILED for gating purposes. Report which suite failed and why.

---

## Blocking rule

`/vscode-ext-load` must not proceed to `npm run package` unless this skill returns **PASSED**. If tests are not yet scaffolded, scaffold them first — an extension with no tests does not get a free pass, it gets tests written before the next install.

---

## Test results visibility

Results are written to `test-results/unit.json` and `test-results/integration.json` in each extension's directory. These files use Jest's `--json` reporter format and are the source of truth for:

- The VS Code Test Explorer (via `vscode.TestController` integration — future)
- Any custom test panel webview in an extension (future)
- CI pipelines (future)

The `test-results/` directory is gitignored — these are runtime artifacts, not source.

---

## Scaffold Protocol (`--scaffold`)

When an extension has no test setup, create the following structure:

### Files to create

**`jest.config.js`**
```js
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  testMatch: ['**/test/unit/**/*.test.ts'],
  reporters: ['default', ['jest-json-reporter', { outputFile: 'test-results/unit.json' }]],
};
```

**`src/test/unit/.gitkeep`** — placeholder so the directory exists

**`src/test/unit/extension.test.ts`** — minimal unit test:
```ts
describe('extension', () => {
  it('placeholder — replace with real unit tests', () => {
    expect(true).toBe(true);
  });
});
```

**`.vscode-test.js`** — test-cli config (at extension root):
```js
const { defineConfig } = require('@vscode/test-cli');
const os = require('os');
const path = require('path');

module.exports = defineConfig({
  files: 'out/test/integration/suite/**/*.test.js',
  mocha: { ui: 'tdd', timeout: 10000 },
  // Short user-data path avoids Unix socket 103-char limit on deep project paths
  launchArgs: ['--user-data-dir', path.join(os.tmpdir(), 'vsc-test-EXTENSION_NAME')],
});
```
Replace `EXTENSION_NAME` with a short unique slug.

**`src/test/integration/suite/index.ts`** — Mocha suite loader:
```ts
import * as path from 'path';
import * as fs from 'fs';
import Mocha from 'mocha';

function findTestFiles(dir: string): string[] {
  const results: string[] = [];
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) results.push(...findTestFiles(full));
    else if (entry.name.endsWith('.test.js')) results.push(full);
  }
  return results;
}

export function run(): Promise<void> {
  const mocha = new Mocha({ ui: 'tdd', color: true });
  for (const f of findTestFiles(path.resolve(__dirname, '.'))) mocha.addFile(f);
  return new Promise((resolve, reject) => {
    mocha.run(failures => failures > 0 ? reject(new Error(`${failures} test(s) failed`)) : resolve());
  });
}
```

**`src/test/integration/suite/activation.test.ts`** — smoke test:
```ts
import * as assert from 'assert';
import * as vscode from 'vscode';

suite('Activation smoke test', () => {
  test('extension activates without throwing', async () => {
    // Extension ID format: publisher.name from package.json
    const ext = vscode.extensions.all.find(e => e.id.includes('EXTENSION_NAME'));
    assert.ok(ext, 'Extension not found — check publisher.name in package.json');
    await ext.activate();
    assert.ok(ext.isActive, 'Extension did not activate');
  });
});
```
Replace `EXTENSION_NAME` with the extension's `name` from `package.json`.

### `package.json` additions

Add to `devDependencies`:
```json
"@types/mocha": "^10.0.0",
"@types/jest": "^29.0.0",
"@vscode/test-cli": "^0.0.15",
"@vscode/test-electron": "^3.0.0",
"jest": "^29.0.0",
"mocha": "^10.0.0",
"ts-jest": "^29.0.0"
```

Add to `scripts`:
```json
"test:unit": "jest",
"compile:tests": "tsc -p ./src/test/integration/tsconfig.json",
"test:integration": "npm run compile:tests && vscode-test",
"test": "npm run test:unit && npm run test:integration"
```

Add to `.gitignore` (or create it):
```
test-results/
```

After scaffolding, run `npm install`, then return to Step 2.

---

## Extensions with back-end services

For extensions that connect to a running service (e.g. Indexatron, Forge), add integration tests that:

1. Check whether the service is running before attempting connection tests
2. Skip gracefully (not fail) if the service is not available: `test.skip` or a conditional
3. When the service IS available, assert that the client connects and returns a valid response

This prevents CI failures when services aren't running while still providing real connectivity tests when they are.
