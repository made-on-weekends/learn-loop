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

## 0003 — Authentic Zaner-Bloser Grade Specifications & url_launcher Dependency

**Date:** 2026-08-29
**Status:** Accepted
**Context:** Need standardized grade-level fractional-inch measurements (Kindergarten: 1.00", Grade 1: 0.625", Grade 2: 0.50", Grade 3: 0.375") with authentic Zaner-Bloser multi-color guidelines (Red Headline, Dotted Blue Midline, Thick Black Baseline, Blank Descender Space), 0.75" left margin red line guide, and external URL launcher capability for maintainer support links.
**Decision:** Implement `GradeLevel` and `GuidelineColorScheme` presets in `HandwritingConfig` and `PdfService`. Introduce `url_launcher` package to open maintainer donation links (`asifiqbal.rocks/donation`) with project UTM parameters.
**Consequences:** `url_launcher: ^6.3.0` added to `pubspec.yaml`. Handwriting practice PDFs support exact grade level guidelines and authentic visual anchor colors. Maintainer support actions added across app UIs and documentation.

## 0004 — Global Kid Profile Settings & Handwriting Line Style Defaults

**Date:** 2026-08-29
**Status:** Accepted
**Context:** The app requires a centralized Kid Profile system (Age and Grade) to derive default handwriting practice settings (line style and row height) across activities while supporting per-worksheet overrides.
**Decision:** Implement `KidGrade` enum, `KidProfile` model, `HandwritingLineStyle` enum with `HandwritingStyleDefinition`, and `HandwritingDefaultsResolver`. Persist global kid settings using `shared_preferences` (`SettingsService`).
**Consequences:** Defaults for line style and row height are automatically calculated from Kid Profile with precedence: Worksheet Override → Grade → Age → Fallback. Visual selectors and reset actions are added to the UI.

## 0005 — Hamburger Drawer Navigation & Handwriting UI/UX Refinements

**Date:** 2026-08-29
**Status:** Accepted
**Context:** Centralize learner profile and support access into a hamburger drawer menu to declutter individual generator screens, expand line style visual previews for improved readability, standardize row heights and page margins into preset dropdowns, and simplify line color scheme selection.
**Decision:** 
1. Relocate global `KidProfileCard` and support actions into a hamburger `Drawer` navigation in `HomeScreen`.
2. Expand `LineStyleSelector` to provide spacious visual canvas previews on click.
3. Replace continuous row height slider with standard age/grade presets dropdown in `HandwritingScreen`.
4. Replace line color scheme dropdown with a 2-option segmented toggle (Color vs Black & White).
5. Remove left margin checkbox option from `HandwritingScreen` and make dotted font option visible only in tracing mode.
6. Replace margin sliders across all 5 worksheet modules with a standardized `PageMarginDropdown` preset selector (Narrow 10mm, Moderate 15mm, Normal 19mm, Wide 25.4mm).
**Consequences:** Streamlined, clean UI across all activity editors with consistent margin presets and clear guideline visualizations.

