---
version: alpha
name: Learn Loop Design System
description: Visual system, tokens, UI guides, and ink-efficient print palettes for Learn Loop.
colors:
  primary: "#6366F1"
  secondary: "#8B5CF6"
  success: "#10B981"
  warning: "#F59E0B"
  danger: "#B91C1C"
  bg: "#FFFFFF"
  fg: "#1F2937"
  muted: "#9CA3AF"
typography:
  body:
    fontFamily: "Inter, Helvetica, sans-serif"
    fontSize: "14px"
    fontWeight: 400
    lineHeight: 1.5
  heading:
    fontFamily: "Outfit, Inter, sans-serif"
    fontSize: "20px"
    fontWeight: 900
    lineHeight: 1.2
rounded:
  sm: "8px"
  md: "12px"
  lg: "24px"
spacing:
  1: 4
  2: 8
  3: 12
  4: 16
  6: 24
  8: 32
components:
  button-primary:
    backgroundColor: "#4F46E5" # Darker Indigo for WCAG AA compliance (5.4:1 contrast)
    textColor: "{colors.bg}"
    rounded: "{rounded.md}"
  button-primary-hover:
    backgroundColor: "#3730A3"
  card-generator:
    backgroundColor: "#6D28D9" # Darker Purple for WCAG AA compliance (4.9:1 contrast)
    textColor: "{colors.bg}"
    rounded: "{rounded.lg}"
  badge-success:
    backgroundColor: "{colors.success}"
    textColor: "{colors.fg}" # Dark text on light green for contrast
  badge-warning:
    backgroundColor: "{colors.warning}"
    textColor: "{colors.fg}" # Dark text on amber for contrast
  badge-danger:
    backgroundColor: "{colors.danger}"
    textColor: "{colors.bg}"
  text-muted:
    textColor: "{colors.muted}"
  text-main:
    textColor: "{colors.fg}"
---

# DESIGN.md

> Self-contained design-system source of truth. Conforms to the [design.md spec](https://github.com/google-labs-code/design.md/blob/main/docs/spec.md): YAML frontmatter holds machine-readable tokens; the body holds human rationale. This doc owns the values; `BRAND.md` owns identity.

## Overview

The Learn Loop design system is clean, modern, and high-contrast, designed to make educational worksheet generation intuitive. It pairs a premium, vibrant UI interface with clean, ink-efficient print designs. 

The application UI utilizes a rich color system of harmonious gradients to delineate different worksheet generators on the dashboard. The PDF worksheets themselves are drawn using low-level canvas vectors in precise coordinates using an ink-efficient monochrome and grey scale palette.

## Colors

### UI Theme Colors
These colors are used throughout the Flutter application interface to establish theme aesthetics, input states, and screen navigation.

| Token       | Hex / value | Usage                                                   |
|-------------|-------------|---------------------------------------------------------|
| `primary`   | `#6366F1`   | Main application theme seed, active slider tracks/thumbs|
| `secondary` | `#8B5CF6`   | Purple color used in primary dashboard gradient pairs    |
| `success`   | `#10B981`   | Green/emerald used for math worksheet screen themes      |
| `warning`   | `#F59E0B`   | Amber used for numbers and counting screen themes       |
| `danger`    | `#EF4444`   | Red used in warning states and counting gradients       |
| `bg`        | `#FFFFFF`   | App background canvas (light mode)                      |
| `fg`        | `#1F2937`   | Body text and primary UI copy                           |
| `muted`     | `#9CA3AF`   | Light grey placeholder text and inactive slider states  |

### Dashboard Gradient Pairs
The HomeScreen uses visual gradients to make each worksheet editor card distinct:
*   **Handwriting Practice**: Indigo (`#6366F1`) to Purple (`#8B5CF6`)
*   **Numbers & Counting**: Amber (`#F59E0B`) to Red (`#EF4444`)
*   **Addition & Subtraction**: Emerald (`#10B981`) to Green (`#059669`)
*   **Pre-Writing Lines**: Pink (`#EC4899`) to Rose (`#F43F5E`)
*   **Shapes Tracing**: Blue (`#3B82F6`) to Cyan (`#06B6D4`)

### PDF Print Colors (Ink-Efficient Palette)
To save cartridge ink and ensure maximum contrast on physical paper, PDFs ignore UI gradients and use standard black, white, and specific grey levels:

| Color Code | Hex Equivalent | Usage                                                              |
|------------|----------------|--------------------------------------------------------------------|
| `white`    | `#FFFFFF`      | Base paper/canvas background, shape fills                          |
| `black`    | `#000000`      | Text, primary outline shapes, stroke guides                        |
| `grey700`  | `#374151`      | Handwriting solid baseline guide                                    |
| `grey600`  | `#4B5563`      | Secondary instructions (e.g., "Draw X shapes below")               |
| `grey500`  | `#6B7280`      | Handwriting solid top and bottom guideline bounds                 |
| `grey400`  | `#9CA3AF`      | Handwriting dashed midline guide, counting question outer border   |
| `grey300`  | `#D1D5DB`      | Handwriting vertical grid dividers, page headers separator         |

## Typography

### App UI Typography
The interface uses standard sans-serif system fonts with a primary fallback chain to `Inter` and `Outfit` to ensure cross-platform consistency.

*   **Font families**: `Outfit` (Headings), `Inter` (Body/Labels)
*   **Font weights in use**: `900` (Bold Headers), `700` (Section Titles), `400` (Body text)
*   **Type scale**:

| Token       | Size | Line height | Usage                                                    |
|-------------|------|-------------|----------------------------------------------------------|
| `text-xs`   | 11px | 1.3         | Microcopy, caption details below sliders                 |
| `text-sm`   | 13px | 1.4         | Settings control labels, checkbox text                   |
| `text-base` | 14px | 1.5         | Standard body copy and inputs                            |
| `text-lg`   | 16px | 1.4         | Control panel section headers                            |
| `heading-2` | 20px | 1.2         | Screen titles, generator card headers                    |
| `heading-1` | 28px | 1.1         | Dashboard title "Learn Loop"                             |

### PDF Worksheet Typography
Printed sheets require specialised fonts for handwriting and tracing exercises.

*   `PrintClearly.otf`: A regular solid-line handwriting font.
*   `PrintDashed.otf`: A dashed handwriting font for tracing lines.
*   `PrintBold.otf`: A thick handwriting font for strong outline characters.
*   *Helvetica / Helvetica-Bold* act as native PDF fallbacks if assets fail to load.
*   **Sizes**: Font sizing is configurable in the UI and ranges from `24.0 pt` to `56.0 pt` to accommodate different developmental age ranges.

## Layout

*   **Dashboard Grid**: Flexible cross-axis layout. Columns auto-adapt to device constraints using a `SliverGrid` with `maxCrossAxisExtent: 400.0`.
*   **Editor Screen Shell**: Implemented in `WorksheetEditorLayout`.
    *   **Wide Screens (Desktop/Tablet)**: Side-by-side split layout (settings on the left, PDF preview on the right).
    *   **Mobile Screens (Phones)**: Swipeable Tabbed layout (Tab 1: settings pane, Tab 2: full-page interactive preview).
*   **Worksheet Print Dimensions**: Standard A4 format (`595.27` x `841.89` points). Page margins are user-customizable from `5.0 mm` (`14.17 pt`) to `30.0 mm` (`85.0 pt`).

## Elevation & Depth

*   **Dashboard Cards**: Elevate using a soft low-contrast shadow token: `boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: Offset(0, 4))]`.
*   **App Bar**: Scrolled under elevation value `1` with elevation `0` when at top page position.

## Shapes

Standard rounded corners used for layout containers and controls:
*   `rounded.sm` (`8px`): Minor UI elements and tooltips.
*   `rounded.md` (`12px`): Input decorator outlines, segmented buttons, dropdowns, and editor text fields.
*   `rounded.lg` (`24px`): Generator dashboard action cards.

## Components

### Buttons
*   **Primary Button**: Accent color background (`primary`), white text, rounded corners (`md`), height 48px.
*   **Segmented Action Buttons**: Filled container shape with rounded border (`md`) to switch parameters.

### Form Inputs
*   **TextFields & Dropdowns**: Filled container style (`grey.shade50`), rounded border (`md`). Default borders are light grey (`grey.shade300`); focused borders change to primary seed (`#6366F1`) with a line thickness of `2.0`.
*   **Sliders**: Color-coded slider using primary (`#6366F1`) for thumb/active track, and light grey (`grey.shade300`) for inactive track bounds.

### Previews
*   **PDF Interactive Frame**: Responsive container overlaying dark canvas (`grey.shade900`) representing paper margins, centering preview sheets.

## Do's and Don'ts

**Do:**
*   Always use predefined token colors (Indigo seed/grey shades) for general controls; do not introduce custom hex codes.
*   Keep worksheet text within A4 margins by dynamically wrapping lines or adjusting column counts in the generator code.
*   Use vector canvas paths instead of bitmap assets when drawing pre-writing guides and shapes to ensure infinite print resolution.
*   Provide a light grey outline container around individual math and counting questions to help young children focus.

**Don't:**
*   Don't use saturated primary colors (like pure red, green, or blue) for the app controls; rely on the color scheme seed.
*   Don't print background fills or solid color borders on the A4 PDF to prevent draining parent/teacher printer cartridges.
*   Don't use thin dashed midline guides on screens; make sure dashed guides are sufficiently thick to be visible when rendered on high-resolution print jobs.
*   Don't hardcode physical coordinates; convert all positions from millimeters to points using `mmToPt` to respect user margin settings.

## Dark mode

Learn Loop supports native theme-swapping matching the host device settings:
*   **ThemeMode**: `ThemeMode.system`
*   **Dark Style**: Brightness settings swap from light to dark brightness using the Indigo colorSchemeSeed to automatically generate matching Material 3 dark variants.

## Motion

*   **Page Transitions**: Standard Material route transitions on push/pop.
*   **Dashboard Interactions**: InkWell splash effects on dashboard card tapping.

## Density

*   Control panel settings use dense form styling (`isDense: true`, compact content padding) to ensure configurations fit on mobile screen viewports.

## Accessibility minimums

*   **Contrast**: Text color to background contrast maintains a 4.5:1 ratio in both light and dark modes.
*   **Target Size**: Interactive list items, switches, and sliders maintain a minimum tap target height of 48dp.
*   **Keyboard Navigation**: Tab stops are configured across forms to allow standard keyboard configuration entry.
