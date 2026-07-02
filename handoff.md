# Gentleman — Handoff Document

**Last updated:** 2026-07-02  
**Status:** ✅ Feature-complete

---

## What the app does

Gentleman is a privacy-first Android app that prevents accidental voice and
video calls in WhatsApp and Instagram. When a user taps a call button inside a
monitored app, Gentleman intercepts the event via the Android Accessibility
Service and shows a full-screen "Hold to Confirm" overlay. The call only proceeds
if the user holds the overlay for the configured duration (default 1 000 ms).
All data stays on-device — no network, no accounts, no tracking.

---

## Architecture

| Layer | Technology |
|-------|-----------|
| UI | Flutter (Dart), Riverpod, GoRouter, Material 3 |
| Persistence | Hive (local NoSQL) — `settings`, `statistics`, `rules` boxes |
| State | `StateNotifier` providers for settings, statistics, permissions, protected apps |
| Native bridge | Single `MethodChannel` (`com.gentleman/protection`) |
| Android monitoring | `AccessibilityMonitorService` (Kotlin) |
| Android overlay | `OverlayService` (Kotlin foreground service) |

---

## Screens

| Screen | Route | Navigation |
|--------|-------|-----------|
| Dashboard | `/` | Tab 0 (bottom nav) |
| Statistics | `/statistics` | Tab 1 |
| Protected Apps | `/protected-apps` | Tab 2 |
| Permissions | `/permissions` | Tab 3 |
| Settings | `/settings` | Pushed (no bottom nav) |
| About | `/about` | Pushed (no bottom nav) |

---

## Completed features (as of this handoff)

- [x] Bottom `NavigationBar` with `StatefulShellRoute` (tabs persist state)
- [x] Dashboard Enable All / Disable All button wired to `ProtectedAppsNotifier`
- [x] Statistics page — full scrollable event history, coloured result badges, time-ago labels
- [x] Permissions page — live battery optimisation status via `PowerManager`
- [x] Settings — real CSV export via `share_plus`
- [x] About — Open Source Notices opens `showLicensePage()`
- [x] `OverlayService` — `startForeground()` with silent notification (Android 8+)
- [x] `OverlayService` — uses user-configured hold duration (not hardcoded 1 000 ms)
- [x] `MainActivity` — `BroadcastReceiver` refs stored and unregistered in `onDestroy`
- [x] Hold duration propagated Flutter → Android via `setHoldDurationMs` MethodChannel
- [x] Widget smoke test — stable with Hive temp dir, path_provider stub, provider overrides
- [x] `flutter analyze` exits 0 — no warnings or infos

---

## Known limitations / future work

- **More monitored apps:** Only WhatsApp and Instagram are supported. Additional
  apps can be added by registering package names in `HiveService.seedDefaultRules`
  and updating the accessibility service heuristics in `AccessibilityMonitorService`.
- **Per-app statistics:** The stats page shows aggregate counts per app. A
  per-day bar chart or sparkline would improve clarity.
- **In-app icon fetching:** App icons are currently rendered from a static lookup
  table. A real icon from the device's PackageManager would require a platform
  channel call.
- **Notification tap action:** The OverlayService foreground notification is
  silent and has no tap action. Adding a PendingIntent to launch MainActivity
  would improve UX.
- **Release signing:** `signingConfig = signingConfigs.getByName("debug")` in
  `build.gradle.kts` should be replaced with a real release key before publishing.
- **Upgrade dependencies:** 49 packages have newer versions constrained by the
  current dependency graph. Run `flutter pub upgrade --major-versions` when ready.

---

## Running the project

```bash
# Install dependencies
flutter pub get

# Run analyzer (should exit 0)
flutter analyze

# Run tests (should exit 0)
flutter test

# Run on a connected Android device
flutter run
```

Accessibility service and overlay permission must be granted manually on first
launch. The Permissions screen provides direct links to the system settings.

---

## Git history (feature commits)

```
feat(about): wire Open Source Notices tile to showLicensePage
feat(settings): implement real CSV export via share_plus
feat(android): propagate hold duration setting to OverlayService
fix(android): unregister BroadcastReceivers in onDestroy to prevent leak
fix(android): add required foreground notification to OverlayService
feat(permissions): surface real battery optimisation status
feat(statistics): add full event history list with result badges
feat(nav): add bottom NavigationBar with StatefulShellRoute
fix(dashboard): wire Enable All / Disable All button to provider
fix(analyzer): resolve sort_child_properties_last warnings in settings page
fix(test): stabilise widget smoke test
```