# 🥷 Learn Loop

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Framework: Flutter](https://img.shields.io/badge/Framework-Flutter%203.x-blue.svg)](https://flutter.dev)
[![Language: Dart](https://img.shields.io/badge/Language-Dart-success.svg)](https://dart.dev)

Learn Loop is a mobile and web application built with Flutter that allows parents, preschool teachers, and home-school educators to dynamically customize, preview, and print A4-sized educational worksheets for toddlers (ages 2–6).

The application operates completely offline, runs entirely on the client, and generates ink-efficient worksheets directly on the device using low-level vector paths for high-quality, scalable printing.

---

## ✨ Features

1. **Global Header Config**: Add a custom sheet title, student name line, and date line.
2. **Handwriting Practice**: Solid or dotted tracing letters, numbers, and custom words with customizable/toggleable guidelines (top, midline, baseline, bottom line).
3. **Numbers & Counting**: "Count and Write" exercises and "Draw to Match" shape grids with customizable target counts.
4. **Addition & Subtraction**: Basic arithmetic configuration in adjustable ranges, horizontal/vertical displays, and optional drawing scratch spaces.
5. **Pre-Writing Lines**: Dotted lines tracing straight, wave, zigzag, and castle patterns for fine-motor control practice.
6. **Shapes Tracing**: Tracing circles, squares, triangles, rectangles, stars, and hearts with directional indicator arrows and name copy guides.

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart SDK `^3.12.2` or later)
- Android Studio / Xcode (for mobile development/deployment)

### Installation & Run

1. Clone this repository and fetch the dependencies:
   ```bash
   flutter pub get
   ```

2. Run the application on your connected emulator, browser, or physical device:
   ```bash
   flutter run
   ```

3. Run automated tests (unit and widget tests):
   ```bash
   flutter test
   ```

4. Format and analyze code:
   ```bash
   flutter format .
   flutter analyze
   ```

---

## 📂 Project Architecture

The codebase follows clean Flutter conventions:
- **`lib/main.dart`**: Application branding initialization using a Material 3 Indigo seed color theme.
- **`lib/screens/`**: Dashboard and editor screens (e.g., `HomeScreen`, `HandwritingScreen`, etc.).
- **`lib/models/`**: Immutable configuration states for worksheets.
- **`lib/widgets/`**: Reusable components, including `WorksheetEditorLayout` which manages responsive split-screen (desktop) and tabbed (mobile) viewports.
- **`lib/services/pdf_service.dart`**: Stateless service drawing vector paths onto low-level PDF canvases for clean A4 printing.

---

## 🎨 Design System

Learn Loop utilizes a strict design system for both UI interactions and print documents:
- **UI System**: Clean Indigo theme seed with vibrant gradient markers on the home dashboard. Fully supports native Dark Mode.
- **PDF Print Palette**: Monochrome/greyscale ink-efficient design (no heavy fills or solid margins) using specific grey levels (`grey300` to `grey700`) to conserve printer ink.
- **Typography**: Uses `Outfit` (headings) and `Inter` (body) for UI, and specialised fonts (`PrintClearly.otf`, `PrintDashed.otf`, `PrintBold.otf`) for educational tracing.

For more details, see the [Design System Documentation](docs/DESIGN.md).

---

## 📱 Mobile & Physical Device Testing

Since the application adapts dynamically to wide desktop viewports (split-pane controls/preview) and mobile viewports (tabbed settings/preview), testing on physical devices is critical.

For step-by-step setup guides:
- See the [Android Device Testing Guide](docs/ANDROID_DEVICE_TESTING.md).
- See the [Play Store Launch Guide](docs/PLAYSTORE_LAUNCH.md).

---

## 📄 Documentation Index

- [PRODUCT.md](docs/PRODUCT.md) — Product requirements, scope boundary, and roadmap.
- [ARCHITECTURE.md](docs/ARCHITECTURE.md) — Software layers, lifecycle, and patterns.
- [DESIGN.md](docs/DESIGN.md) — Design token YAML configuration and print guidelines.
- [TESTING.md](docs/TESTING.md) — Automated testing scripts and device deployment.
- [DECISIONS.md](docs/DECISIONS.md) — History of accepted architectural decisions.
- [AGENTS.md](AGENTS.md) — Coding conventions and briefing instructions for AI assistants.

---

## 🐛 Issues & Troubleshooting

Encountered an issue or have a feature suggestion?
- View our [Quick Guide to Reporting Issues](REPORTING.md) before submitting an issue.
- Read [AGENTS.md](AGENTS.md) for quick command reminders and agent coding guidelines.

## 🤝 Contributing

We are always looking for improvements and additions! Please read the [Contribution Guide](CONTRIBUTING.md) to understand our branching strategy, conventions, and pull request checklist.

## ⭐ Support Us

If **Learn Loop** makes generating toddler educational worksheets seamless and saves you time:
- ⭐ **Star this repository** to help others discover the project.
- 📣 **Spread the word** on X/Twitter or your blog.
- ☕ **Support the maintainer** via [donation](https://asifiqbal.rocks/donation) to fund further open-source initiatives.

---

## 📄 License

This project is licensed under the [MIT License](https://choosealicense.com/licenses/mit).
