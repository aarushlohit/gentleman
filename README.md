<p align="center">
  <img src="assets/gentleman.png" width="300" alt="Gentleman Logo" />
</p>

# Why I Built Gentleman

This project exists because of one accidental tap.

Yes, it happened to me.

I accidentally started a video call with someone I absolutely did **not** intend to call. I hung up immediately and apologized.

The funny part?

I'm an overthinker.

So instead of moving on, my brain immediately started asking:

> *"What do they think of me now?"*
> *"Do they think I called on purpose?"*
> *"Was that awkward?"*

After a few minutes of unnecessary overthinking, I had a different thought:

**Why doesn't Android protect us from accidental taps in the first place?**

That single moment became the idea behind **Gentleman**.

So, to the person who accidentally received that call—

**I'm genuinely sorry.**

Your unexpected notification became an open-source project that might save thousands of people from experiencing the same awkward moment.

Sometimes the best projects don't start with a million-dollar idea.

Sometimes they start with one unfortunate tap.

---

**Gentleman**

*Protecting your dignity, one tap at a time.*

---

## What is Gentleman?

Gentleman prevents accidental voice and video calls in WhatsApp and Instagram by using an Android Accessibility Service to detect call UI and requiring a deliberate hold before a call proceeds.

### Features
* **Call Detection:** Detects call buttons in supported apps (WhatsApp, Instagram).
* **Hold-to-Confirm:** Configurable hold duration to ensure intent before calling.
* **Privacy-First:** Local-only storage using Hive. No network, no tracking, no user data leaves the device.

## Build & Run
Requirements: Flutter 3.0+, Android SDK, Kotlin

```bash
flutter pub get
flutter run -d emulator-5554
```

## Contributing
See `CONTRIBUTING.md` for contribution guidelines, code style, and commit message format.

## License
MIT — see `LICENSE`.
