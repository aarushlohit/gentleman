# Contributing to Gentleman

Thank you for your interest in contributing to **Gentleman**! We are building a privacy-first utility to prevent embarrassing accidental calls and safeguard digital dignity. By contributing, you help make Android apps safer and more intentional.

---

## Table of Contents
1. [Code of Conduct](#code-of-conduct)
2. [How Can I Contribute?](#how-can-i-contribute)
3. [Development Environment Setup](#development-environment-setup)
4. [Accessibility Service Guidelines](#accessibility-service-guidelines)
5. [Git and Commit Style Conventions](#git-and-commit-style-conventions)
6. [Pull Request Process](#pull-request-process)

---

## Code of Conduct

This project and everyone participating in it is governed by the [Gentleman Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior to the maintainers.

## How Can I Contribute?

### Reporting Bugs
* Check the existing issues first to ensure it hasn't already been reported.
* Open a new issue with a clear title and description, steps to reproduce, device model, Android version, and logs if possible (e.g. `adb logcat -d | grep Gentleman`).

### Suggesting Enhancements
* Open a feature request issue describing the enhancement, its benefits, and potential design.

### Submitting Code Changes
* Look for issues labeled `good first issue` or `help wanted` to get started.
* Create a fork, commit your changes on a feature branch, and submit a Pull Request (PR) targeting the `main` branch.

---

## Development Environment Setup

Gentleman is built using Flutter (Frontend) and Kotlin (Android Accessibility Service backend).

### Prerequisites
* **Flutter SDK**: `3.0.0` or higher.
* **Android Studio / SDK**: Android SDK 34 (Upside Down Cake) or higher.
* **Kotlin**: `1.9.0` or higher.
* **ADB (Android Debug Bridge)**: Installed and added to system path.

### Build Instructions
1. Clone the repository:
   ```bash
   git clone https://github.com/aarushlohit/gentleman.git
   cd gentleman
   ```
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application in debug mode:
   ```bash
   flutter run
   ```

---

## Accessibility Service Guidelines

The core backend of Gentleman runs inside an **Android Accessibility Service** (`AccessibilityMonitorService.kt`) to scan active layouts. When writing or modifying accessibility logic, adhere to these guidelines:

### 1. Avoid Memory Leaks and Node Recycling Issues
* Android recycles `AccessibilityNodeInfo` objects aggressively. **Never store references** to `AccessibilityNodeInfo` in asynchronous callbacks or delay handlers.
* Always capture coordinates (e.g., `Rect`) or type metadata, and resolve fresh nodes from `rootInActiveWindow` dynamically when actions need to be performed.

### 2. Strict UI Filtering
* Ensure blockers are *only* added when the active screen is a chat window. Use helpers like `hasMessageInput` to confirm conversation status.
* Limit button scanning coordinate boundaries strictly to header dimensions (`y` between `60px` and `520px` depending on display scaling) to avoid accidental triggers on scrolled message history lists or list items.

### 3. Debugging Layouts
* Dump active screen trees to identify target button content-descriptions or layout structures:
  ```bash
  adb shell uiautomator dump /sdcard/window_dump.xml
  adb pull /sdcard/window_dump.xml .
  ```

---

## Git and Commit Style Conventions

We enforce semantic commit messages to keep our history readable:

* **Format**: `type(scope): description`
* **Common Types**:
  * `feat`: A new user-facing feature.
  * `fix`: A bug fix.
  * `docs`: Documentation changes only.
  * `style`: Code formatting changes (whitespaces, semicolons).
  * `refactor`: Structural code changes that do not alter behavior.
  * `test`: Adding or updating tests.
  * `chore`: Build steps, dependency upgrades, release tasks.
* **Example**:
  ```text
  feat(android): add support for instagram conversation call buttons
  fix(service): resolve overlay memory leak by releasing window layouts on close
  ```

---

## Pull Request Process

1. Create a descriptive branch name: `feature/your-feature-name` or `bugfix/your-fix-name`.
2. Format and analyze your code before committing:
   ```bash
   flutter format .
   flutter analyze
   ```
3. Submit your PR with a detailed description explaining what was changed, why, and how it was tested.
4. Ensure your PR builds successfully on continuous integration tests before requesting review.
