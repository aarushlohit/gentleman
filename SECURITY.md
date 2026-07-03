# Security Policy

We take the security and privacy of **Gentleman** users very seriously. Since the application handles layout inspections on-device via an Accessibility Service, maintaining complete isolation of user data is our highest priority.

---

## Supported Versions

Only the latest release version on the `main` branch is actively supported with security updates.

| Version | Supported |
| ------- | --------- |
| >= 1.0  | Yes       |
| < 1.0   | No        |

---

## Reporting a Vulnerability

If you discover a potential security vulnerability within Gentleman, please **do not open a public issue**. Instead, follow these steps:

1. Submit a detailed report privately to the maintainer via email at `141929019+aarushlohit@users.noreply.github.com`.
2. Include a clear description of the vulnerability, a proof of concept (PoC), and the potential impact of the issue.
3. We will acknowledge receipt of your report within 48 hours and work with you to coordinate a patch and release cycle.

We ask that you practice responsible disclosure and give us reasonable time to resolve the issue before releasing details publicly.

---

## Security Principles of Gentleman

1. **Zero Telemetry**: We collect no analytics, logs, or crash reporting data off-device.
2. **Local Storage Only**: All user configuration (such as custom hold timers and app lock states) is encrypted and stored locally using standard secure Hive boxes.
3. **No Network Access**: The core background service has **no internet permission** requested in the Android Manifest, preventing any potential data leaks.
