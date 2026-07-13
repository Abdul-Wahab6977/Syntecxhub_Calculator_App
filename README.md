<div align="center">

# 🧮 Calculator App

### A production-ready, neo-minimalist calculator built with Flutter

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Provider](https://img.shields.io/badge/State%20Management-Provider-FF9F0A)](https://pub.dev/packages/provider)
[![License](https://img.shields.io/badge/License-MIT-2E2F38)](#license)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-007AFF)](#)

*Built as part of the SyntecxHub Android Development Internship — Project 1*

</div>

---

## 📱 Overview

A sleek, dark-themed calculator inspired by the Apple and Google calculator apps, engineered with a **strict separation of concerns** between business logic and UI. Every calculation runs through a dedicated, fully-testable controller — the widgets only render state and forward user intent.

|                    | Details                                              |
|--------------------|-------------------------------------------------------|
| **Framework**      | Flutter (Material 3)                                  |
| **Language**       | Dart                                                   |
| **State Management** | Provider (`ChangeNotifier`)                          |
| **Architecture**   | Clean layered architecture (Controller → UI)           |
| **Design Language**| Neo-minimalist, dark mode, high-contrast               |

---

## ✨ Features

### Core Functionality
- ➕ ➖ ✖️ ➗ Basic arithmetic operations with **AC / C / Backspace**
- 🎯 **High-precision math engine** — mitigates floating-point artifacts (e.g. `0.1 + 0.2` correctly displays `0.3`)
- ⚠️ Graceful **divide-by-zero handling** with a locked keypad until cleared
- 🔒 Strict input validation — no consecutive operators, single decimal point per number, capped input length
- 🔁 **%** and **+/-** (sign toggle) support

### Design & UX
- 🌑 Deep obsidian dark theme (`#121212`) with premium amber & tech-blue accents
- 📊 Two-stage display — muted expression history above, bold auto-scaling result below
- 💧 Ripple/ink touch feedback on every key
- 📐 Fully responsive — adaptive **portrait (4×5 grid)** and **landscape (split display/keypad)** layouts
- 👆 Touch targets sized for comfortable, accurate input on any screen

---

## 🏗️ Architecture

The project follows a clean, layered structure so logic and presentation never mix:

```
lib/
├── main.dart                          # App entry point + theme configuration
├── controllers/
│   └── calculator_controller.dart     # ChangeNotifier — all state & math logic
├── screens/
│   └── calculator_screen.dart         # Responsive UI, display, layout logic
└── widgets/
    └── calc_button.dart               # Reusable, styled calculator key
```

**Why this matters:**
- `calculator_controller.dart` has **zero Flutter widget imports** — it can be unit tested in complete isolation.
- UI widgets never compute anything; they only call controller methods (`onDigitPressed`, `onOperatorPressed`, `onEqualsPressed`, etc.) and rebuild from `context.watch<CalculatorController>()`.
- Adding a new operator, button, or screen doesn't require touching unrelated layers.

---

## 🎨 Design System

| Element              | Color                          | Hex        |
|----------------------|----------------------------------|------------|
| Background            | Deep Obsidian / Charcoal        | `#121212`  |
| Number Buttons         | Dark Slate Gray                 | `#2E2F38`  |
| Operator Buttons (+ − × ÷) | Premium Amber                | `#FF9F0A`  |
| Equals Button          | Tech Blue                       | `#007AFF`  |
| Action Buttons (AC, ⌫, %) | Light Gray / Silver          | `#D1D1D6`  |
| Error State            | Signal Red                      | `#FF453A`  |

---

## 🚀 Getting Started

### Prerequisites
Make sure you have the following installed:
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.x or later)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/) with the Flutter/Dart extensions
- An Android emulator, iOS simulator, or physical device

Verify your setup:
```bash
flutter doctor
```

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Abdul-Wahab6977/Syntecxhub_Calculator_App.git
   cd Syntecxhub_Calculator_App
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Project Structure Check
Make sure your folder layout matches exactly before running:
```
lib/
├── main.dart
├── controllers/calculator_controller.dart
├── screens/calculator_screen.dart
└── widgets/calc_button.dart
```

---

## 🧠 Math Engine Highlights

```dart
// Prevents classic floating-point artifacts before any value
// is displayed or reused in a subsequent calculation.
double _roundForPrecision(double value) {
  const precision = 10;
  final factor = _pow10(precision);
  return (value * factor).round() / factor;
}
```

- Division by zero returns `null` from the internal `_calculate()` method, which the controller interprets as a signal to lock the UI and surface a clear, human-readable error — instead of crashing or silently showing `Infinity`/`NaN`.
- Input is validated at the point of entry, not after the fact — consecutive operators simply replace the pending operator instead of stacking symbols.

---

## 📦 Dependencies

| Package    | Purpose                          |
|------------|------------------------------------|
| `provider` | Lightweight, idiomatic state management |
| `cupertino_icons` | Default iOS-style iconography |

---

## 🗺️ Roadmap / Possible Extensions

- [ ] Scientific mode (sin, cos, log, √, x²)
- [ ] Calculation history log with persistence
- [ ] Light theme toggle
- [ ] Haptic feedback on key press
- [ ] Unit tests for `CalculatorController`

---

## 🤝 Contributing

This project was built as part of the **SyntecxHub Internship Program**. Suggestions and improvements are welcome — feel free to fork, open an issue, or submit a pull request.

---

## 📄 License

This project is available under the MIT License. Feel free to use it for learning purposes.

---

<div align="center">

### 🏢 SyntecxHub — *Create | Think | Solve*

</div>
