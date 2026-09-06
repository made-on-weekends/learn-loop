# Current System Audit — Learn Loop

> **Audit Date:** 2026-09-04  
> **Repository:** `made-on-weekends/learn-loop`  
> **Framework:** Flutter (Material 3) | Dart `^3.12.2`  
> **Target Platform:** Mobile (Android/iOS) and Web (Offline printable PDF generator)

---

## 1. Executive Summary

This document presents a comprehensive audit of the existing **Learn Loop** codebase. Learn Loop is an offline, client-side Flutter application designed for parents, preschool teachers, and homeschool educators to customize and export print-ready A4 educational worksheets.

---

## 2. Existing Screens

The application currently features 6 screen widgets under `lib/screens/`:

1. **`HomeScreen` (`lib/screens/home_screen.dart`)**
   - Main entry point featuring a grid of 5 activity cards and a collapsible hamburger navigation drawer (`Drawer`).
   - Hosts global maintainer donation callouts (`_launchDonation`) with project UTM parameters.
   - Houses the global `KidProfileCard` inside the navigation drawer.

2. **`HandwritingScreen` (`lib/screens/handwriting_screen.dart`)**
   - Editor for handwriting and tracing activities.
   - Allows configuration of text source (uppercase, lowercase, numbers, custom text), practice mode (tracing vs. copy), direction (row vs. column), grade guidelines preset, line style overrides, row height overrides, and dotted font toggle.

3. **`CountingScreen` (`lib/screens/counting_screen.dart`)**
   - Editor for object counting and matching worksheets.
   - Supports two activity types (`countAndWrite`, `drawToMatch`), number range selection (min/max), questions per page, and shape choices (`circle`, `square`, `triangle`, `star`, `heart`, `tree`, `apple`, `random`).

4. **`MathScreen` (`lib/screens/math_screen.dart`)**
   - Editor for basic arithmetic worksheets.
   - Supports addition, subtraction, and mixed operations in horizontal or vertical problem formats, 1 or 2 column grid layouts, customizable question count, number range, and toggleable scratch workspaces.

5. **`PrewritingScreen` (`lib/screens/prewriting_screen.dart`)**
   - Editor for fine-motor tracing line worksheets.
   - Features line patterns (`straight`, `wave`, `zigzag`, `castle`), stroke width, line count, line spacing, and dotted vs. solid stroke styling.

6. **`ShapesScreen` (`lib/screens/shapes_screen.dart`)**
   - Editor for shape tracing and learning worksheets.
   - Features multi-select shape picker (`circle`, `square`, `triangle`, `rectangle`, `star`, `heart`), tracing arrows toggle, shape name labels toggle, and stroke style (dotted vs. solid).

---

## 3. Existing Worksheet Types & Capabilities

| Worksheet Module | Underlying Activity Types | Customization Options | Rendering Mechanism |
| :--- | :--- | :--- | :--- |
| **Handwriting Practice** | Tracing, Independent Copying | Text source (upper/lower/numbers/custom), Zaner-Bloser grade levels (KG, Gr 1-3+), line styles (2-line, 3-line, separated), row height (9-20mm), dotted/solid font, direction. | `PdfService.generateHandwriting` (Canvas text metrics, custom OTF font glyph drawing) |
| **Numbers & Counting** | Count & Write, Draw to Match | Number range (1-10 default), shape selection (8 shape designs), items per page (1-12), auto-scaling grid. | `PdfService.generateCounting` (Canvas shape path drawing, box grid layout) |
| **Addition & Subtraction** | Addition, Subtraction, Mixed | Range (1-20), format (horizontal/vertical), 1/2 columns, question count (1-20), scratch drawing box grid. | `PdfService.generateMath` (Text + vector rectangle workspaces) |
| **Pre-Writing Lines** | Line Tracing | 4 patterns (straight, wave, zigzag, castle), line count (1-10), stroke width, line spacing, dotted toggle. | `PdfService.generatePrewriting` (Vector path commands: `moveTo`, `lineTo`, `curveTo`) |
| **Shapes Tracing** | Tracing & Shape Learning | Multi-select 6 core shapes, arrow guide indicators, dotted/solid strokes, shape label text. | `PdfService.generateShapes` (Vector geometric paths + directional arrows) |

---

## 4. Architectural Analysis

### 4.1 Navigation & Routing Architecture
- **Current Model:** Imperative screen navigation using standard `Navigator.push(context, MaterialPageRoute(...))`.
- **Limitation:** Hardcoded list of 5 generator items inside `HomeScreen`. No centralized route registry, metadata model, or categorization.

### 4.2 State Management Architecture
- **Local Screen State:** Each screen is a `StatefulWidget` managing local mutable configuration model instances (`HandwritingConfig`, `CountingConfig`, `MathConfig`, `PrewritingConfig`, `ShapesConfig`, `GlobalConfig`).
- **Global State:** `SettingsService` provides a `ValueNotifier<KidProfile>` for global learner profile (age and grade).

### 4.3 Persistence & Storage
- **Current Persistence:** `shared_preferences` persists global `KidProfile` JSON under `'learn_loop_kid_profile'`.
- **Gap:** No storage for recently generated worksheets, saved configurations, or favorite activities.

### 4.4 Reusable UI Components
- **`WorksheetEditorLayout` (`lib/widgets/worksheet_editor_layout.dart`)**: Core shell providing a responsive dual-pane split layout for desktop (>800px) and a swipeable tabbed layout ("Customize" / "Preview & Print") for mobile.
- **`KidProfileCard` (`lib/widgets/kid_profile_card.dart`)**: Global age/grade selector card.
- **`LineStyleSelector` (`lib/widgets/line_style_selector.dart`)**: Visual line style preset picker.
- **`PageMarginDropdown` (`lib/widgets/page_margin_dropdown.dart`)**: Page margin preset selector (Narrow 10mm, Moderate 15mm, Normal 19mm, Wide 25.4mm).

### 4.5 PDF & Print Services (`lib/services/pdf_service.dart`)
- **Technology Stack:** `pdf` package (`pw.Document`, `pw.PageFormat.a4`), `printing` package (`PdfPreview`).
- **Stateless Functional Design:** `PdfService` exposes 5 static async methods taking configuration models and returning compiled `Uint8List` PDF bytes.
- **Font System:** Custom OTF fonts loaded via `rootBundle`:
  - `PrintClearly.otf` (Solid manuscript handwriting)
  - `PrintDashed.otf` (Dotted tracing manuscript handwriting)
  - `PrintBold.otf` (Bold manuscript handwriting)
  - Fallbacks to `Helvetica` / `Helvetica-Bold` on font load failure.
- **Drawing System:** Low-level `PdfGraphics` vector path instructions (`moveTo`, `lineTo`, `curveTo`, `strokePath`, `cubicTo`). Standard unit conversion (`mmToPt = 72.0 / 25.4`).

---

## 5. Domain Models Audit

```
lib/models/
├── global_config.dart          # Page header, title, name/date lines, margins, red margin line
├── handwriting_config.dart     # Handwriting source, grade guidelines, row height, line styles
├── handwriting_line_style.dart # Line style definitions (2-line, 3-line, separated)
├── kid_profile.dart            # Age (2-8) and KidGrade enum (playgroup -> grade3Plus)
├── counting_config.dart        # Activity type, min/max number, shape design, questions per page
├── math_config.dart            # Operation (add/sub/mixed), format (vert/horiz), grid cols, scratch space
├── prewriting_config.dart      # Line patterns (straight, wave, zigzag, castle), stroke width, count
└── shapes_config.dart          # Selected shapes list, tracing guide arrows, labels, dotted mode
```

---

## 6. Test Suite Audit

The project contains 5 test suites under `test/`:
- `font_alignment_test.dart`: Validates font metrics and Zaner-Bloser baseline alignments.
- `handwriting_defaults_test.dart`: Verifies `HandwritingDefaultsResolver` age/grade resolution hierarchy.
- `pdf_service_test.dart`: Integration tests executing all 5 PDF generator functions (`generateHandwriting`, `generateCounting`, `generateMath`, `generatePrewriting`, `generateShapes`) to ensure valid non-empty byte outputs without crashes.
- `ui_refinements_test.dart`: Widget tests verifying margin dropdowns, line style selectors, and controls.
- `widget_test.dart`: Baseline app launch test.

---

## 7. Open Source & Support Links

All maintainer support callouts and donation links use standard UTM parameter formatting:
- Base URL: `https://asifiqbal.rocks/donation?utm_source=learn_loop&utm_medium=github_readme&utm_campaign=readme&ref=learn-loop-readme`
