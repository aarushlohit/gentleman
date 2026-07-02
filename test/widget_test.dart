// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gentleman/main.dart';
import 'package:gentleman/core/constants/app_constants.dart';
import 'package:gentleman/core/models/protected_app.dart';
import 'package:gentleman/core/models/protection_event.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    // Initialize Hive as the app expects boxes to be available synchronously.
    await Hive.initFlutter();
    Hive.registerAdapter(AppProtectionStatusAdapter());
    Hive.registerAdapter(ProtectedAppAdapter());
    Hive.registerAdapter(InteractionTypeAdapter());
    Hive.registerAdapter(ProtectionResultAdapter());
    Hive.registerAdapter(ProtectionEventAdapter());
    await Hive.openBox<dynamic>(AppConstants.settingsBox);
    await Hive.openBox<ProtectionEvent>(AppConstants.statisticsBox);
    await Hive.openBox<ProtectedApp>(AppConstants.rulesBox);

    await tester.pumpWidget(const ProviderScope(child: GentlemanApp()));
    expect(find.text('Gentleman'), findsWidgets);
  });
}
