# AGENTS.md

> Briefing packet for AI coding agents (Claude Code, Antigravity, Codex, Cursor, Gemini CLI, etc.).
> Humans should read README.md instead.

## Rules of engagement

These rules are the agent's first read every session. Keep this list short — 5–10 rules, each one absolute.

1. **Do** follow Flutter / Dart conventions documented in this file and the relevant `docs/` files.
2. **Do** check `docs/DECISIONS.md` before contradicting any documented pattern.
3. **Do** ask before expanding scope beyond `docs/PRODUCT.md`.
4. **Don't** edit files in the do-not-touch zones below.
5. **Don't** introduce any external Dart/Flutter package without a `docs/DECISIONS.md` entry.
6. **Do** ensure all generated worksheet types render properly in both wide-screen split layout and mobile tabbed layout.
7. **Do** run `flutter analyze` and `flutter test` before declaring code complete.

## Stack

- Language(s): Dart
- Framework(s): Flutter (Material 3)
- Backend: None (offline client-only app generating PDFs)
- Database: None (in-memory config states)
- Hosting / runtime: Mobile (Android/iOS) and Web
- Package/dependency manager: `flutter pub`
- Language version: Dart SDK `^3.12.2` (as per `pubspec.yaml`)

## Commands

```bash
# Get dependencies
flutter pub get

# Dev / run
flutter run

# Lint / format check
flutter analyze
flutter format .

# Test
flutter test
```

## Conventions

- **File naming**: Lowercase with underscores (snake_case) for files/directories as per Dart guidelines.
- **Component structure**: Screen files live in `lib/screens/`, configuration models in `lib/models/`, shared layouts/widgets in `lib/widgets/`, and PDF generator builders in `lib/services/pdf_service.dart`.
- **State Management**: Simple configurations use in-memory `StatefulWidget` states passed down to the `WorksheetEditorLayout` and `PdfPreview`.
- **PDF Generation**: Standardized coordinates in points (`mmToPt` is 72.0 / 25.4). Canvas-drawn paths (like shapes, tracing lines, arrow guides) are drawn using vector paths to keep file size small and printable resolutions high.

## Do-not-touch zones

- `.dart_tool/`, `.idea/`, `build/`
- Platform native directories: `android/`, `ios/`, `linux/`, `macos/`, `web/`, `windows/` (unless explicitly requested for platform configuration changes)
- Font files in `assets/fonts/`
- Lock file: `pubspec.lock` (always update via `flutter pub get`/`upgrade`)

## Where to look

- Architecture overview: `docs/ARCHITECTURE.md`
- Settled decisions: `docs/DECISIONS.md` (read before contradicting any pattern)
- Product scope: `docs/PRODUCT.md`
- Test strategy: `docs/TESTING.md`
