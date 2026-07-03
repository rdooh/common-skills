# Common Skills

A single source of truth for reusable agent skills/commands, installable across any AI harness.

## Why this exists

Skills (prompts that tell an agent how to do a specific job) tend to get written once, copied into a harness-specific folder, and then drift — or disappear when a project is cleaned up. This repo solves that by maintaining one canonical copy of every skill and using an install script to deploy them wherever each harness expects to find them.

## Structure

```
common-skills/
  skills/           # canonical skill files — edit these, never the installed copies
    research/       # fact-finding, web research, source synthesis
    coding/         # code review, refactoring, debugging workflows
    comms/          # writing, summarizing, communicating findings
    workflow/       # orchestration, planning, task management
  adapters/         # per-harness path mappings (metadata only, not skill content)
    gstack/
    agent-os/
    claude-code/
  registry.yml      # index of all skills and their install targets
  install.sh        # run once to symlink skills into all registered harness paths
```

## How to add a skill

1. Create a `.md` file in the appropriate `skills/` subdirectory.
2. Add an entry to `registry.yml` listing where it should be installed.
3. Run `./install.sh` — it will create symlinks for all new entries.

## How to install

```bash
# Clone (or pull latest) then run the install script
./install.sh
```

The script is idempotent — running it multiple times is safe. It uses symlinks by default, so edits to files in `skills/` are immediately live in all harnesses without re-running install.

## Design decisions

### One repo, many harnesses

Different harnesses (Claude Code, Agent OS, GStack, future tools) expect skill files in different locations. Rather than maintaining separate copies, `registry.yml` maps each skill to its install targets. Adding a new harness means adding one line per skill — not duplicating files.

### Symlinks over copies

The install script creates symlinks rather than copying files. This means you edit in one place and all harnesses see the change immediately. The tradeoff is that symlinks can break if the repo moves — if that's a problem for a specific target, the registry supports a `mode: copy` override per entry.

### Markdown as the universal format

All skills are plain markdown. Every harness in this ecosystem either reads markdown natively or can be adapted to do so with a thin front-matter shim. This keeps skills readable, diffable, and harness-agnostic.

### Skills are not project-specific

Skills describe *how to do a type of work*, not *what to do in a specific project*. Project-specific context belongs in `CLAUDE.md`, ADRs, or project specs — not here. When a skill needs project context it should prompt the agent to look it up, not hard-code it.

## Harness-specific notes

| Harness | Install path | Format |
|---|---|---|
| Claude Code (global) | `~/.claude/commands/` | `.md` with optional YAML front-matter |
| Claude Code (project) | `.claude/commands/` | same |
| Agent OS | `agent-os/standards/global/` | `.md` |
| GStack | `.claude/commands/` | `.md` with `description:` front-matter |
