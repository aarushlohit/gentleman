import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/services/hive_service.dart';
import 'core/theme/app_theme.dart';
import 'core/services/settings_provider.dart';
import 'core/services/protection_event_service.dart';
import 'dart:io' as io;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
  ));

  final container = ProviderContainer();

  await container.read(hiveInitProvider.future);

  // Initialize protection event service so native events are observed and persisted.
  // Avoid initializing during `flutter test` to prevent platform channel streams
  // from interfering with the test harness.
  try {
    final isInTest = io.Platform.environment['FLUTTER_TEST'] == 'true' ||
        io.Platform.environment['FLUTTER_TEST'] == '1';
    if (!isInTest) {
      container.read(protectionEventServiceProvider);
    }
  } catch (_) {
    // In environments where `Platform` isn't available or access fails,
    // skip initializing the protection service to keep tests stable.
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const GentlemanApp(),
    ),
  );
}

class GentlemanApp extends ConsumerWidget {
  const GentlemanApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Gentleman',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
    );
  }
}
