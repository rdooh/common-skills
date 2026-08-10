# The Unified Developer Standards Basket (NeoNGS Blueprint)

> **Status:** Strategic Reference / Promotion Blueprint  
> **Target Ecosystem:** NeoNGS Software & Ecosystem Submodules  
> **Author:** Rob Dooh & Antigravity Agent  
> **Date:** 2026-07-29  

---

## Executive Summary

To prevent tool-specific fragmentation and vendor lock-in, all software repositories across the **NeoNGS Software** ecosystem adopt a **Unified Basket of Tool-Agnostic Open Developer Standards**.

Rather than tools (such as Nexus, QSOS, or AI Agents) inventing custom configuration rules, **tools act as lightweight adapters** that consume and visualize the standard basket. This ensures zero data loss, zero workflow breakage, and 100% portability whether working via IDEs, CLI tools, CI/CD pipelines, or autonomous agent runners.

---

## The 5 Pillars of the Standards Basket

```
                     ┌─────────────────────────────────────────────────────────┐
                     │          THE UNIFIED STANDARDS BASKET                   │
                     └────────────────────────────┬────────────────────────────┘
                                                  │
 ┌───────────────────────┬────────────────────────┼──────────────────────────┬───────────────────────┐
 ▼                       ▼                        ▼                          ▼                       ▼
Pillar 1: Identity      Pillar 2: Work Items     Pillar 3: Decisions        Pillar 4: Architecture   Pillar 5: Evidence
catalog-info.yaml       work/tix-manifest.json   docs/decisions/ADR-*.md    docs/architecture/       ctrf-report.json & releases/
(Backstage Spec)        (GitHub Issue Schema)    (MADR Standard)            (Structurizr C4 DSL)     (CTRF Test Report Spec)
```

---

### Pillar 1: Identity & Component Boundaries (`catalog-info.yaml`)
* **Open Standard**: Spotify Backstage Component Specification (`kind: Component`, `apiVersion: backstage.io/v1alpha1`).
* **Location**: `<repository-root>/catalog-info.yaml` (or `<subproject>/catalog-info.yaml`).
* **Canonical Role**: Serves as the single explicit boundary marker for subprojects in monorepos. Declares component identity, owner, lifecycle maturity (`experimental`, `production`), and the subproject ticket prefix (`qsos.io/ticket-prefix`).

### Pillar 2: Work Items & Task Manifests (`work/`)
* **Open Standard**: GitHub Issue Vocabulary + CommonMark Markdown + JSON Schema Draft 2020-12.
* **Location**: `work/tix-manifest.json` and `work/<PREFIX>-NNN-slug/<PREFIX>-NNN-slug.md`.
* **Canonical Enums**:
  * `status`: `"todo"` | `"ready"` | `"in-progress"` | `"done"`
  * `priority`: `"high"` | `"medium"` | `"low"`
  * `type`: `"feat"` | `"fix"` | `"chore"` | `"spike"` | `"refactor"`
* **Canonical File Naming**: `work/<PREFIX>-NNN-slug/<PREFIX>-NNN-slug.md` (uniquely named matching the parent folder slug to prevent editor tab title collisions).
* **Tool Alignment**: Nexus renders `work/tix-manifest.json` in the IDE Kanban board; QSOS agents execute tasks against it; git tracks history.

### Pillar 3: Architectural Decisions (`docs/decisions/`)
* **Open Standard**: MADR (Markdown Architectural Decision Records).
* **Location**: `docs/decisions/ADR-NNN-slug.md`.
* **Naming**: Sequential 3-digit zero-padded numbers (`ADR-001-title.md`), gapless.
* **Canonical Role**: Documents problem context, considered options, trade-offs, and architectural consequences.

### Pillar 4: System Architecture & Visual Models (`docs/architecture/`)
* **Open Standard**: Structurizr / C4 Model DSL + Mermaid export.
* **Location**: `docs/architecture/architecture.dsl`.
* **Canonical Role**: Single source of truth for software systems, containers, components, and code-level relationships. Every element carries `Current` or `Target` status linked to an ADR.

### Pillar 5: Evidence, Test Reports & Release Attestations (`docs/releases/` & `evidence/`)
* **Open Standard**: **CTRF (Common Test Report Format, `ctrf-report.json`)** + Markdown Release Attestation Schema.
* **Location**: `work/<PREFIX>-NNN-slug/evidence/ctrf-report.json` and `docs/releases/v{version}.md`.
* **Canonical Role**: CTRF provides a universal, tool-agnostic JSON schema for test execution reports across unit, integration, BDD (Playwright/Gherkin), and E2E test suites. AI agents (`/qsos-verify`, `/qsos-validate`) and IDE test explorers ingest CTRF reports as verified empirical proof.

---

## Tool-to-Standard Binding Matrix

| Tool / Agent | Role | How It Binds to the Standards Basket |
| :--- | :--- | :--- |
| **Nexus VS Code Extension** | Interactive IDE Kanban & Dashboard | Reads `work/tix-manifest.json` & `catalog-info.yaml`; updates both `.json` manifest and `.md` frontmatter simultaneously. |
| **QSOS Compliance Checkers** | Automated Linter & Audit Engine | Validates repository artifacts against the 5 pillars; reports violations without modifying code. |
| **QSOS Agent Workflow** | Autonomous Agent Orchestration | Traverses `catalog-info.yaml` for prefix scope; updates ticket status (`in-progress` / `done`) during feature runs; writes CTRF test evidence. |
| **Backstage / Internal Portals** | Enterprise Developer Portal | Ingests `catalog-info.yaml` and links to ADRs, features, and CTRF release attestations natively. |

---

## Promotion Blueprint to NeoNGS Enterprise Workspace

When graduating a tool or repo from Personal Projects to `NeoNGS Software`:

1. Ensure the repo root contains a valid `catalog-info.yaml` declaring `metadata.name` and `qsos.io/ticket-prefix`.
2. Ensure `work/tix-manifest.json` conforms to `tix-manifest.schema.json`.
3. Verify zero legacy file names (no generic `ticket.md` files) and zero legacy `in_progress` aliases.
4. Export or reference this blueprint in your enterprise engineering handbook.
