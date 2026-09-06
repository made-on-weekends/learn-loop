# Worksheet QA & Print Quality Checklist

> **Date:** 2026-09-04  
> **Purpose:** Quality Assurance validation standard for all generated printable PDF worksheets and app UI interactions.

---

## 1. Printable PDF Output QA

- [ ] **Generator Correctness:** Mathematical calculations, arithmetic answers, counting quantities, and sequence logic are 100% accurate.
- [ ] **Developmental Appropriateness:** Font sizes, stroke thicknesses, and line spacings match the target age/grade parameters.
- [ ] **Spelling & Text Instructions:** All instructions, titles, labels, and custom text inputs are free from typos and grammatically correct.
- [ ] **Page Bounds & Margin Safety:** No text, shapes, grid lines, or stroke paths are clipped or overflow off the printable page area across all margin settings (Narrow 10mm to Wide 25.4mm).
- [ ] **Font Rendering:** Custom OTF fonts (`PrintClearly`, `PrintDashed`, `PrintBold`) render crisp, aligned glyphs without character overlap or baseline misalignment.
- [ ] **High Contrast & Ink Efficiency:** Worksheet elements use clean black/dark-grey outlines suitable for monochrome home printing without excessive dark fills.
- [ ] **Randomization & Reproducibility:** Worksheets generated with identical seeds produce identical layout and question sets. Re-generating produces unique, non-duplicate question sets.
- [ ] **Paper Formats:** Page rendering displays accurately on standard A4 paper format (with US Letter compatibility).

---

## 2. Flutter UI & Responsive Layout QA

- [ ] **Split View (Desktop > 800px):** Editor control panel on the left and interactive `PdfPreview` on the right render side-by-side cleanly without horizontal overflow.
- [ ] **Tabbed View (Mobile <= 800px):** Swipeable tabs ("Customize" and "Preview & Print") function smoothly.
- [ ] **Theme Support:** App UI displays cleanly in both Light and Dark mode without low-contrast text. Printable PDF canvas preview remains clean high-contrast black-on-white.
- [ ] **Global Kid Profile:** Changing age/grade in the drawer updates default line styles and row heights across screens.
- [ ] **Static Analysis & Tests:** `flutter analyze` reports 0 issues, and `flutter test` executes cleanly.
