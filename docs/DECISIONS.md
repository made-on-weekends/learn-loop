# DECISIONS.md

> Settled architectural decisions. **Append-only.** Never edit or delete past entries (one exception: `Status` field of a superseded entry).
> If a decision is reversed, append a new entry with `Supersedes: #NNNN`.

## How to use this file

- Read before contradicting any documented pattern.
- New decisions are added with the next sequential number.
- Each entry has: number, title, date, status, context, decision, consequences, optional `Supersedes`.

## Status values

- `Proposed` — under discussion
- `Accepted` — current
- `Superseded by #NNNN` — replaced by a later decision (only the Status field can be edited on a superseded entry)
- `Deprecated` — no longer applies but no replacement

---

## 0001 — Project initialized

**Date:** 2026-06-23
**Status:** Accepted
**Context:** Project scaffolded and alignment documents initialized using the `project-ninja` skill.
**Decision:** Establish `AGENTS.md` and `docs/` as the canonical source of truth for AI agent context. The cross-references are owned per `references/cross-references.md` in the project-ninja skill.
**Consequences:** All AI coding agents read `AGENTS.md` first. Major technical and architectural choices must be documented in `docs/DECISIONS.md`.

## 0002 — Design System initialized

**Date:** 2026-06-27
**Status:** Accepted
**Context:** A design token structure is required to ensure alignment between UI styles, component definitions, and PDF generation options.
**Decision:** Initialize `docs/DESIGN.md` using the Google Labs design.md specification. Define the standard token sets for colors, typography, rounded dimensions, and component structures. Standardize on indigo seed theme for UI and greyscale bounds for ink-efficient printing.
**Consequences:** Any UI theme adjustments or PDF styling rules must be updated in `docs/DESIGN.md` to maintain consistency and avoid drift. Changes must be linted via `npx @google/design.md lint docs/DESIGN.md`.
