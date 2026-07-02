import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App text styles built on Google Sans with warm, readable defaults.
abstract final class AppTextStyles {
  static TextStyle _base(BuildContext context) => GoogleFonts.googleSans(
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle displayLarge(BuildContext context) =>
      _base(context).copyWith(fontSize: 57, fontWeight: FontWeight.w400, letterSpacing: -0.25);

  static TextStyle displayMedium(BuildContext context) =>
      _base(context).copyWith(fontSize: 45, fontWeight: FontWeight.w400);

  static TextStyle displaySmall(BuildContext context) =>
      _base(context).copyWith(fontSize: 36, fontWeight: FontWeight.w400);

  static TextStyle headlineLarge(BuildContext context) =>
      _base(context).copyWith(fontSize: 32, fontWeight: FontWeight.w600);

  static TextStyle headlineMedium(BuildContext context) =>
      _base(context).copyWith(fontSize: 28, fontWeight: FontWeight.w600);

  static TextStyle headlineSmall(BuildContext context) =>
      _base(context).copyWith(fontSize: 24, fontWeight: FontWeight.w600);

  static TextStyle titleLarge(BuildContext context) =>
      _base(context).copyWith(fontSize: 22, fontWeight: FontWeight.w500);

  static TextStyle titleMedium(BuildContext context) =>
      _base(context).copyWith(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.15);

  static TextStyle titleSmall(BuildContext context) =>
      _base(context).copyWith(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1);

  static TextStyle bodyLarge(BuildContext context) =>
      _base(context).copyWith(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5);

  static TextStyle bodyMedium(BuildContext context) =>
      _base(context).copyWith(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25);

  static TextStyle bodySmall(BuildContext context) =>
      _base(context).copyWith(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4);

  static TextStyle labelLarge(BuildContext context) =>
      _base(context).copyWith(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1);

  static TextStyle labelMedium(BuildContext context) =>
      _base(context).copyWith(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5);

  static TextStyle labelSmall(BuildContext context) =>
      _base(context).copyWith(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5);
}
