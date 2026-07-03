# Gentleman App — Handoff Document

This document outlines the current state of the Gentleman App, the newly implemented architecture, and documents the major technical hurdles (struggles) overcome during this session. It serves as a guide for future development.

## 🚀 Current State
- **Flutter UI**: The Flutter dashboard, settings, statistics, protected apps, and permissions surfaces have been fully redesigned into a warmer, more premium visual system with atmospheric backgrounds, glassmorphism-style panels, stronger typography, and a more intentional navigation shell.
- **Confirmation Shield Overlay**: A horizontal progress bar overlay with haptic feedback successfully intercepts outgoing VoIP calls (WhatsApp, Instagram).
- **Absolute Instant-Abort Flow**: The system currently operates on an "Instant Abort & Bypass" architecture. Tapping a call button instantly aborts the action to prevent any VoIP handshake, ensuring the recipient's phone never rings accidentally. The user must hold the overlay to 100% to unlock a 8-second bypass window, then tap the call button a second time to proceed.

---

## 🧗 Key Struggles & Technical Challenges

### 1. Android Accessibility Service Quirks & Silent Failures
**The Struggle**: During rapid development and deployment (`flutter run`), the app would often suddenly stop working. The accessibility service would seemingly ignore all clicks.
**The Cause**: Android automatically disables accessibility services as a security measure whenever an app is force-stopped or re-installed.
**The Solution**: We had to constantly monitor and force-enable the service via ADB after every build:
`adb shell settings put secure enabled_accessibility_services org.kde.kdeconnect_tp/...:com.gentleman.app/com.gentleman.app.AccessibilityMonitorService && adb shell settings put secure accessibility_enabled 1`

### 2. The Illusion of `GLOBAL_ACTION_BACK`
**The Struggle**: We initially tried to block calls by simply triggering the Android 'Back' button (`GLOBAL_ACTION_BACK`) when a call button was tapped.
**The Cause**: For VoIP apps like WhatsApp and Instagram, pressing 'Back' does not terminate an outgoing call; it merely minimizes the call screen into picture-in-picture or background mode while continuing to dial the recipient.
**The Solution**: We had to implement an aggressive decline polling loop. When a call is intercepted, the service scans the active window every 80 milliseconds for up to 1.2 seconds, searching for buttons with descriptions matching `decline`, `end_call`, `hangup`, or `cancel`, and programmatically clicks them to forcefully terminate the connection.

### 3. The "Black Box" of Third-Party View Hierarchies
**The Struggle**: Finding the correct UI node to click for hanging up was difficult because third-party app layouts change frequently and differ across Android versions.
**The Solution**: We built a custom layout dumper (`dumpNodeHierarchy()`) within `AccessibilityMonitorService.kt` to recursively print the entire view tree of the active screen to Logcat. This allowed us to reverse-engineer the structure of the WhatsApp call screen and target the correct decline button safely.

### 4. WindowManager Leaks and Duplicate Overlays
**The Struggle**: Occasionally, tapping a call button would crash the app with a `WindowManager$BadTokenException` or visual glitches where multiple overlays stacked on top of each other.
**The Cause**: Android accessibility events can fire multiple `TYPE_VIEW_CLICKED` events for a single physical tap (e.g., the text node and its parent container both report a click). This spawned multiple `OverlayService` intents simultaneously.
**The Solution**: We implemented strict state guarding in `OverlayService.kt`. We now check `if (overlayView != null) return` before inflating and attaching the view to the WindowManager.

### 5. Race Conditions in Abort vs. Confirm Flows
**The Struggle**: Trying to allow the call to ring in the background *while* showing the confirmation overlay proved mathematically unsafe. If the user held the overlay to 100%, but the call screen took a moment too long to load, the delayed abort loop would trigger and hang up the call anyway. Conversely, if we waited too long to abort on an accidental tap, the recipient's phone would ring for half a second.
**The Solution**: We pivoted to the **Instant-Abort & Second Tap architecture**. The first tap is always killed instantly (zero chance of ringing). The user unlocks the shield by holding to 100%, and then taps again to actually place the call. This is the only 100% fail-safe method for true accidental call prevention.

---

## 🔜 Next Steps / Future Enhancements
- Monitor the effectiveness of the second-tap bypass architecture with real users.
- Extend the same premium visual language to onboarding, splash, and about screens so the product feels consistent end-to-end.
- Consider exploring `OverlayService` animations (e.g., a fade-out transition when dismissing) so the native interception layer matches the polish of the Flutter shell.
- Explore drawing transparent touch-interception overlays directly over the WhatsApp toolbar as an alternative to instant-aborting.
