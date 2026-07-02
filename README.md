# Gentleman

Protecting your dignity, one tap at a time.

Gentleman prevents accidental voice and video calls in WhatsApp and Instagram by using an Android Accessibility Service to detect call UI and requiring a deliberate hold before a call proceeds.

Status: Work in progress — native Android services and overlay integration are being implemented.

Features
-- Detect call buttons in supported apps (WhatsApp, Instagram)
-- Hold-to-confirm protection with configurable hold duration
-- Local-only storage using Hive (no network)
-- Privacy-first: no user data leaves the device

Build & run
Requirements: Flutter 3.0+, Android SDK, Kotlin

```bash
flutter pub get
flutter run -d emulator-5554
```

Contributing
See `CONTRIBUTING.md` for contribution guidelines, code style, and commit message format.

License
MIT — see `LICENSE`.
