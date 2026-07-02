// Widget smoke test for Gentleman.
//
// Hive is initialised in a fresh temp directory so each run is isolated.
// Platform-channel-backed providers are overridden with lightweight stubs
// so no MethodChannel calls or pending timers leak into the test harness.

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gentleman/main.dart';
import 'package:gentleman/core/constants/app_constants.dart';
import 'package:gentleman/core/models/protected_app.dart';
import 'package:gentleman/core/models/protection_event.dart';
import 'package:gentleman/core/services/permission_service.dart';
import 'package:gentleman/core/services/platform_channel_service.dart';
import 'package:gentleman/core/services/hive_service.dart';
import 'package:gentleman/core/services/settings_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Minimal PathProvider stub that uses a real temp directory so Hive resolves.
class _FakePathProvider extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  final String _dir;
  _FakePathProvider(this._dir);

  @override
  Future<String?> getApplicationDocumentsPath() async => _dir;
  @override
  Future<String?> getTemporaryPath() async => _dir;
  @override
  Future<String?> getApplicationSupportPath() async => _dir;
  @override
  Future<String?> getApplicationCachePath() async => _dir;
}

void main() {
  late Directory tempDir;

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    tempDir = await Directory.systemTemp.createTemp('gentleman_test_');
    PathProviderPlatform.instance = _FakePathProvider(tempDir.path);

    await Hive.initFlutter(tempDir.path);
    Hive.registerAdapter(AppProtectionStatusAdapter());
    Hive.registerAdapter(ProtectedAppAdapter());
    Hive.registerAdapter(InteractionTypeAdapter());
    Hive.registerAdapter(ProtectionResultAdapter());
    Hive.registerAdapter(ProtectionEventAdapter());
    await Hive.openBox<dynamic>(AppConstants.settingsBox);
    await Hive.openBox<ProtectionEvent>(AppConstants.statisticsBox);
    await Hive.openBox<ProtectedApp>(AppConstants.rulesBox);
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  testWidgets('App renders smoke test', (WidgetTester tester) async {
    // Override permission and settings providers so they don't fire
    // platform channel calls or schedule timers.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Provide a stub PlatformChannelService that never calls MethodChannel.
          platformChannelServiceProvider.overrideWith(
            (ref) => PlatformChannelService(),
          ),
          // Provide a PermissionState that is already resolved (no async load).
          permissionProvider.overrideWith(
            (ref) => PermissionNotifier(
              ref.read(platformChannelServiceProvider),
              ref.read(hiveServiceProvider),
            ),
          ),
          // Provide default AppSettings without triggering platform calls.
          appSettingsProvider.overrideWith(
            (ref) => AppSettingsNotifier(
              ref.read(hiveServiceProvider),
              ref.read(platformChannelServiceProvider),
            ),
          ),
        ],
        child: const GentlemanApp(),
      ),
    );

    // Pump and settle to let all initial routing transitions and animations finish.
    await tester.pumpAndSettle();
    expect(find.textContaining('Gentleman'), findsWidgets);
  });
}
