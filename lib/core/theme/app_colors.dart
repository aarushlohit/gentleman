import 'package:flutter/material.dart';

/// Gentleman app color palette — warm yellow/black with softened accents.
abstract final class AppColors {
  // ─── Light Theme (Apple iOS inspired) ───
  static const Color lightPrimary = Color(0xFFBF9B30); // Apple gold
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightPrimaryContainer = Color(0xFFF2F2F7); // iOS gray 6
  static const Color lightOnPrimaryContainer = Color(0xFF1C1C1E);

  static const Color lightSecondary = Color(0xFF8E8E93); // iOS gray
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightSecondaryContainer = Color(0xFFE5E5EA); // iOS gray 5
  static const Color lightOnSecondaryContainer = Color(0xFF000000);

  static const Color lightTertiary = Color(0xFF3A3A3C);
  static const Color lightSurface = Color(0xFFF2F2F7); // iOS grouped background
  static const Color lightSurfaceVariant = Color(0xFFFFFFFF); // White list item background
  static const Color lightOnSurface = Color(0xFF000000); // iOS default text
  static const Color lightOnSurfaceVariant = Color(0xFF3C3C43); // iOS secondary text
  static const Color lightBackground = Color(0xFFF2F2F7);
  static const Color lightOnBackground = Color(0xFF000000);
  static const Color lightOutline = Color(0xFFC7C7CC); // iOS separator
  static const Color lightOutlineVariant = Color(0xFFD1D1D6);
  static const Color lightError = Color(0xFFFF3B30); // iOS system red
  static const Color lightOnError = Color(0xFFFFFFFF);

  // ─── Dark Theme (Apple iOS inspired) ───
  static const Color darkPrimary = Color(0xFFFFCC00); // iOS yellow/gold
  static const Color darkOnPrimary = Color(0xFF000000);
  static const Color darkPrimaryContainer = Color(0xFF1C1C1E); // iOS cell background
  static const Color darkOnPrimaryContainer = Color(0xFFFFFFFF);

  static const Color darkSecondary = Color(0xFF8E8E93); // iOS gray
  static const Color darkOnSecondary = Color(0xFFFFFFFF);
  static const Color darkSecondaryContainer = Color(0xFF2C2C2E);
  static const Color darkOnSecondaryContainer = Color(0xFFFFFFFF);

  static const Color darkTertiary = Color(0xFFAEAEB2);
  static const Color darkSurface = Color(0xFF000000); // iOS pure black
  static const Color darkSurfaceVariant = Color(0xFF1C1C1E); // iOS cell background
  static const Color darkOnSurface = Color(0xFFFFFFFF); // iOS white text
  static const Color darkOnSurfaceVariant = Color(0xFFE5E5EA); // iOS secondary text
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkOnBackground = Color(0xFFFFFFFF);
  static const Color darkOutline = Color(0xFF38383A); // iOS dark separator
  static const Color darkOutlineVariant = Color(0xFF2C2C2E);
  static const Color darkError = Color(0xFFFF453A); // iOS dark system red
  static const Color darkOnError = Color(0xFFFFFFFF);

  // ─── Semantic ───
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color danger = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // ─── App-Specific ───
  static const Color whatsapp = Color(0xFF25D366);
  static const Color instagram = Color(0xFFE4405F);
  static const Color protectionActive = Color(0xFF4CAF50);
  static const Color protectionInactive = Color(0xFF9E9E9E);
}
