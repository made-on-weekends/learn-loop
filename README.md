# 🥷 Learn Loop

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Framework: Flutter](https://img.shields.io/badge/Framework-Flutter%203.x-blue.svg)](https://flutter.dev)
[![Language: Dart](https://img.shields.io/badge/Language-Dart-success.svg)](https://dart.dev)

Learn Loop is a mobile and web application built with Flutter that allows parents, preschool teachers, and home-school educators to dynamically customize, preview, and print high-resolution educational worksheets for toddlers and young learners (ages 2–9).

The application operates completely offline, runs entirely on the client, and generates high-resolution 300 DPI vector PDFs directly on the device.

---

## ✨ Features

1. **Global Header Config**: Add a custom sheet title, student name line, and date line.
2. **Authentic Zaner-Bloser Handwriting Practice**: Grade-level guidelines (Kindergarten to Grade 3) with authentic visual anchor colors (Solid Red Headline, Dotted Blue Midline, Thick Black Baseline) and 0.75-inch left margin red line guide.
3. **Numbers & Counting**: "Count and Write" exercises and "Draw to Match" shape grids with customizable target counts.
4. **Addition & Subtraction**: Basic arithmetic configuration in adjustable ranges, horizontal/vertical displays, and optional drawing scratch spaces.
5. **Pre-Writing Lines**: Dotted lines tracing straight, wave, zigzag, and castle patterns for fine-motor control practice.
6. **Shapes Tracing**: Tracing circles, squares, triangles, rectangles, stars, and hearts with directional indicator arrows and name copy guides.

---

## 📏 Zaner-Bloser Grade-Level Specifications

Learn Loop implements exact fractional-inch measurements for authentic handwriting paper across grade levels:

| Grade Level | Total Line Height (Baseline to Headline) | Midline Position (From Baseline) | Descender Buffer / Skip Space |
| :--- | :--- | :--- | :--- |
| **Kindergarten (Ages 4–6)** | 1.00 inch | 0.50 inch (50%) | 0.50 inch |
| **Grade 1 (Ages 6–7)** | 0.625 inch (5/8") | 0.3125 inch (50%) | 0.3125 inch |
| **Grade 2 (Ages 7–8)** | 0.50 inch (1/2") | 0.25 inch (50%) | 0.25 inch |
| **Grade 3 (Ages 8–9)** | 0.375 inch (3/8") | 0.1875 inch (50%) | 0.1875 inch |

### 🎨 Line Style and Color Specifications

Authentic Zaner-Bloser paper uses distinct visual anchors to guide young writers:

- **Headline (Top)**: Solid Red line. Marks the upper boundary for uppercase letters and ascenders.
- **Midline (Center)**: Dashed/Dotted Blue line. Marks the half-way boundary for lowercase letter bodies.
- **Baseline (Bottom)**: Thick, solid Black line. The "ground" where all letters sit.
- **Descender / Skip Space**: The blank area under the baseline. It has no printed bottom boundary, using the next line's red headline as its floor.
- **Left Red Margin Guide**: A solid vertical red line at 0.75 inches (19.05 mm) to teach students where to start writing sentences.

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
- **`lib/services/pdf_service.dart`**: Stateless service drawing vector paths onto low-level PDF canvases for clean 300 DPI A4 printing.

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
- ☕ **Support the maintainer** via [donation](https://asifiqbal.rocks/donation?utm_source=learn_loop&utm_medium=github_readme&utm_campaign=readme&ref=learn-loop-readme) to fund further open-source initiatives.

---

## 📄 License

This project is licensed under the [MIT License](https://choosealicense.com/licenses/mit).
