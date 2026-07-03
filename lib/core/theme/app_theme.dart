import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io' as io;
import 'app_colors.dart';

/// App-wide Material 3 themes.
abstract final class AppTheme {
  static ThemeData light([ColorScheme? dynamicScheme]) {
    final scheme = dynamicScheme ??
        const ColorScheme.light(
          primary: AppColors.lightPrimary,
          onPrimary: AppColors.lightOnPrimary,
          primaryContainer: AppColors.lightPrimaryContainer,
          onPrimaryContainer: AppColors.lightOnPrimaryContainer,
          secondary: AppColors.lightSecondary,
          onSecondary: AppColors.lightOnSecondary,
          secondaryContainer: AppColors.lightSecondaryContainer,
          onSecondaryContainer: AppColors.lightOnSecondaryContainer,
          tertiary: AppColors.lightTertiary,
          surface: AppColors.lightSurface,
          surfaceContainerHighest: AppColors.lightSurfaceVariant,
          onSurface: AppColors.lightOnSurface,
          onSurfaceVariant: AppColors.lightOnSurfaceVariant,
          outline: AppColors.lightOutline,
          outlineVariant: AppColors.lightOutlineVariant,
          error: AppColors.lightError,
          onError: AppColors.lightOnError,
        );

    final baseLight = ThemeData.light(useMaterial3: true);
    final isTest = io.Platform.environment.containsKey('FLUTTER_TEST');
    final textTheme = isTest
        ? baseLight.textTheme
        : GoogleFonts.dmSansTextTheme(baseLight.textTheme).copyWith(
            displayLarge: GoogleFonts.cormorantGaramond(
              textStyle: baseLight.textTheme.displayLarge,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.8,
            ),
            displayMedium: GoogleFonts.cormorantGaramond(
              textStyle: baseLight.textTheme.displayMedium,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.2,
            ),
            headlineLarge: GoogleFonts.cormorantGaramond(
              textStyle: baseLight.textTheme.headlineLarge,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.8,
            ),
            headlineMedium: GoogleFonts.dmSans(
              textStyle: baseLight.textTheme.headlineMedium,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.8,
            ),
            titleLarge: GoogleFonts.dmSans(
              textStyle: baseLight.textTheme.titleLarge,
              fontWeight: FontWeight.w700,
            ),
          );
    return baseLight.copyWith(
      colorScheme: scheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.8), width: 1),
        ),
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.88),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: scheme.surfaceContainerHighest.withValues(alpha: 0.9),
        indicatorColor: AppColors.lightPrimary.withValues(alpha: 0.14),
        height: 78,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? scheme.primary : scheme.onSurfaceVariant,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected) ? scheme.primary : scheme.onSurfaceVariant,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.lightPrimary,
        foregroundColor: AppColors.lightOnPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.82),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: AppColors.lightPrimary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 0.5,
        space: 0,
      ),
    );
  }

  static ThemeData dark([ColorScheme? dynamicScheme]) {
    final scheme = dynamicScheme ??
        const ColorScheme.dark(
          primary: AppColors.darkPrimary,
          onPrimary: AppColors.darkOnPrimary,
          primaryContainer: AppColors.darkPrimaryContainer,
          onPrimaryContainer: AppColors.darkOnPrimaryContainer,
          secondary: AppColors.darkSecondary,
          onSecondary: AppColors.darkOnSecondary,
          secondaryContainer: AppColors.darkSecondaryContainer,
          onSecondaryContainer: AppColors.darkOnSecondaryContainer,
          tertiary: AppColors.darkTertiary,
          surface: AppColors.darkSurface,
          surfaceContainerHighest: AppColors.darkSurfaceVariant,
          onSurface: AppColors.darkOnSurface,
          onSurfaceVariant: AppColors.darkOnSurfaceVariant,
          outline: AppColors.darkOutline,
          outlineVariant: AppColors.darkOutlineVariant,
          error: AppColors.darkError,
          onError: AppColors.darkOnError,
        );

    final baseDark = ThemeData.dark(useMaterial3: true);
    final isTest = io.Platform.environment.containsKey('FLUTTER_TEST');
    final textTheme = isTest
        ? baseDark.textTheme
        : GoogleFonts.dmSansTextTheme(baseDark.textTheme).copyWith(
            displayLarge: GoogleFonts.cormorantGaramond(
              textStyle: baseDark.textTheme.displayLarge,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.8,
            ),
            displayMedium: GoogleFonts.cormorantGaramond(
              textStyle: baseDark.textTheme.displayMedium,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.2,
            ),
            headlineLarge: GoogleFonts.cormorantGaramond(
              textStyle: baseDark.textTheme.headlineLarge,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.8,
            ),
            headlineMedium: GoogleFonts.dmSans(
              textStyle: baseDark.textTheme.headlineMedium,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.8,
            ),
            titleLarge: GoogleFonts.dmSans(
              textStyle: baseDark.textTheme.titleLarge,
              fontWeight: FontWeight.w700,
            ),
          );
    return baseDark.copyWith(
      colorScheme: scheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.8), width: 1),
        ),
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.88),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: scheme.surfaceContainerHighest.withValues(alpha: 0.92),
        indicatorColor: AppColors.darkPrimary.withValues(alpha: 0.16),
        height: 78,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? scheme.primary : scheme.onSurfaceVariant,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected) ? scheme.primary : scheme.onSurfaceVariant,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: AppColors.darkOnPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: AppColors.darkPrimary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 0.5,
        space: 0,
      ),
    );
  }
}
