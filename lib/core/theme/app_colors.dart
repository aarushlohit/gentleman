import 'package:flutter/material.dart';

/// Gentleman app color palette — warm yellow/black with softened accents.
abstract final class AppColors {
  // ─── Light Theme ───
  static const Color lightPrimary = Color(0xFFE8B830);
  static const Color lightOnPrimary = Color(0xFF1A1A1A);
  static const Color lightPrimaryContainer = Color(0xFFFDE8A0);
  static const Color lightOnPrimaryContainer = Color(0xFF2C2200);

  static const Color lightSecondary = Color(0xFF6B5C3E);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightSecondaryContainer = Color(0xFFF4E4C8);
  static const Color lightOnSecondaryContainer = Color(0xFF261A00);

  static const Color lightTertiary = Color(0xFF7C6A4F);
  static const Color lightSurface = Color(0xFFFFFBF5);
  static const Color lightSurfaceVariant = Color(0xFFF5F0E8);
  static const Color lightOnSurface = Color(0xFF1C1B17);
  static const Color lightOnSurfaceVariant = Color(0xFF4A4740);
  static const Color lightBackground = Color(0xFFFFFBF5);
  static const Color lightOnBackground = Color(0xFF1C1B17);
  static const Color lightOutline = Color(0xFFD5CFC5);
  static const Color lightOutlineVariant = Color(0xFFE8E2D8);
  static const Color lightError = Color(0xFFBA1A1A);
  static const Color lightOnError = Color(0xFFFFFFFF);

  // ─── Dark Theme ───
  static const Color darkPrimary = Color(0xFFF5C93C);
  static const Color darkOnPrimary = Color(0xFF3D3000);
  static const Color darkPrimaryContainer = Color(0xFF574600);
  static const Color darkOnPrimaryContainer = Color(0xFFFFDE8C);

  static const Color darkSecondary = Color(0xFFD8C8A0);
  static const Color darkOnSecondary = Color(0xFF3C3000);
  static const Color darkSecondaryContainer = Color(0xFF54461E);
  static const Color darkOnSecondaryContainer = Color(0xFFF4E4C8);

  static const Color darkTertiary = Color(0xFFBBA888);
  static const Color darkSurface = Color(0xFF131313);
  static const Color darkSurfaceVariant = Color(0xFF1E1E1E);
  static const Color darkOnSurface = Color(0xFFE8E2D8);
  static const Color darkOnSurfaceVariant = Color(0xFFCCC6BC);
  static const Color darkBackground = Color(0xFF0E0E0E);
  static const Color darkOnBackground = Color(0xFFE8E2D8);
  static const Color darkOutline = Color(0xFF58544D);
  static const Color darkOutlineVariant = Color(0xFF3A3730);
  static const Color darkError = Color(0xFFFFB4AB);
  static const Color darkOnError = Color(0xFF690005);

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
