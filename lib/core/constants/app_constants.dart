/// App-wide constants.
abstract final class AppConstants {
  static const String appName = 'Gentleman';
  static const String appTagline = 'Protecting your dignity, one tap at a time.';
  static const String appDescription = 'Gentleman prevents accidental voice and video calls in WhatsApp and Instagram. '
      'It uses Accessibility Service to detect call buttons when they appear and requires you to hold them '
      'before the call goes through.';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  static const String copyright = '© 2025 Gentleman. All rights reserved.';

  static const String githubUrl = 'https://github.com/aarush/gentleman';
  static const String licenseUrl = 'https://github.com/aarush/gentleman/blob/main/LICENSE';
  static const String privacyPolicyUrl = '';

  // ─── Supported Apps ───
  static const String whatsappPackage = 'com.whatsapp';
  static const String whatsappName = 'WhatsApp';
  static const String instagramPackage = 'com.instagram.android';
  static const String instagramName = 'Instagram';

  // ─── Default Settings ───
  static const int defaultHoldDurationMs = 1000;
  static const bool defaultVibrationEnabled = true;
  static const bool defaultAnimationEnabled = true;
  static const bool defaultDarkMode = false;
  static const bool defaultDynamicColors = false;

  // ─── Hive Boxes ───
  static const String settingsBox = 'settings';
  static const String statisticsBox = 'statistics';
  static const String rulesBox = 'rules';

  // ─── Platform Channel ───
  static const String channelName = 'com.gentleman/protection';
  static const String methodGetForegroundApp = 'getForegroundApp';
  static const String methodIsAccessibilityEnabled = 'isAccessibilityEnabled';
  static const String methodIsOverlayEnabled = 'isOverlayEnabled';
  static const String methodOpenAccessibilitySettings = 'openAccessibilitySettings';
  static const String methodOpenOverlaySettings = 'openOverlaySettings';
  static const String methodOpenBatterySettings = 'openBatterySettings';
  static const String methodIsServiceRunning = 'isServiceRunning';
  static const String methodOnProtectionEvent = 'onProtectionEvent';
  static const String methodOnProtectionDecision = 'onProtectionDecision';
  static const String methodIsBatteryOptimizationDisabled = 'isBatteryOptimizationDisabled';
  static const String methodSetHoldDurationMs = 'setHoldDurationMs';

  // ─── Hold Duration Options ───
  static const List<int> holdDurationOptions = [500, 1000, 1500, 2000];
}
