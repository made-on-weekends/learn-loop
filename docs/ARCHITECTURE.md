# ARCHITECTURE.md

> Technical structure. How the pieces fit together. Not how to use the project (see AGENTS.md).

## High-level diagram

```
  ┌────────────────────────────────────────────────────────┐
  │                       Flutter UI                       │
  │  (HomeScreen -> Editor Screens -> Settings / Preview)  │
  └───────────────────────────┬────────────────────────────┘
                              │
                              ▼ Rebuilds on state change
  ┌────────────────────────────────────────────────────────┐
  │                 WorksheetEditorLayout                  │
  │         (Combines controls and PdfPreview)            │
  └───────────────────────────┬────────────────────────────┘
                              │
                              ▼ Calls pdfBuilder callback
  ┌────────────────────────────────────────────────────────┐
  │                       PdfService                       │
  │    (Generates A4 pages using raw canvas drawing)       │
  └────────────────────────────────────────────────────────┘
```

## Layers

### Client Layer (Flutter UI)

- **Main Entry (`main.dart`)**: Configures application branding, Material 3 seed color theme, and default dark/light styles.
- **Home Dashboard (`screens/home_screen.dart`)**: Entry grid navigating users to individual worksheet type editors.
- **Editor Screens (`screens/`)**: Maintain local configuration states and feed values to control panels.
- **Shared Editor Shell (`widgets/worksheet_editor_layout.dart`)**: Implements dual split-pane responsive view (side-by-side controls and interactive PDF on desktop, swipeable tabs on mobile).

### PDF Generation Layer (`services/pdf_service.dart`)

- **Canvas Drawer**: Draws lines, grids, shapes, and text onto the low-level `pdf` document canvas using coordinates converted to points (e.g., standard margins, row heights, shape coordinates).
- **Asset Loader**: Loads local font assets (`PrintClearly.otf`, `PrintDashed.otf`, `PrintBold.otf`) with standard Helvetica fallbacks in case of loading errors.

## Request lifecycle

```
1. User interacts with settings control (e.g., toggles a guideline, adjusts font size).
2. Flutter widget triggers state update (`setState`).
3. The parent editor widget rebuilds, triggering a rebuild of the `PdfPreview` widget.
4. `PdfPreview` invokes the `pdfBuilder` callback.
5. The callback invokes `PdfService.generateHandwriting` (or other generator service method) with the latest configs.
6. `PdfService` draws elements on A4 document and returns compiled PDF `Uint8List` bytes.
7. `PdfPreview` renders the PDF pages on screen.
```

## Patterns we use

- **Single Source of Truth**: Document settings are modeled as immutable configuration classes (`lib/models/`) and updated in a single state controller (within the editor screen).
- **Stateless PDF Generation**: `PdfService` is fully functional and stateless; it takes configurations and returns raw PDF byte vectors with no side effects.
- **Responsive Layouts**: Screens adapt automatically to width constraints (split columns for desktops/tablets, tabs for phones).

## Patterns we avoid

- **Direct State Mutation**: Never modify config objects in place; always instantiate a new copy using `copyWith` to avoid state desync.
- **Inline Canvas Math**: Avoid writing raw point calculations directly in the widgets; keep all drawing geometry and conversion math isolated inside `PdfService`.

## Deployment

The app is built as a standard client-side Flutter application.
- **Web**: Deployed to web hosting engines (e.g., Vercel, Firebase Hosting).
- **Android**: Packaged as an APK/AAB (`flutter build apk`). For publishing to Google Play Store, see the [Play Store Launch Guide](docs/PLAYSTORE_LAUNCH.md).
- **iOS**: Packaged via Xcode.
