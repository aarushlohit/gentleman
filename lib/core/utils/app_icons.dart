import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Maps package names to Material icons.
abstract final class AppIcons {
  static IconData iconForPackage(String packageName) {
    switch (packageName) {
      case 'com.whatsapp':
        return LucideIcons.messageCircle;
      case 'com.instagram.android':
        return LucideIcons.camera;
      default:
        return LucideIcons.smartphone;
    }
  }

  static Color colorForPackage(String packageName) {
    switch (packageName) {
      case 'com.whatsapp':
        return const Color(0xFF25D366);
      case 'com.instagram.android':
        return const Color(0xFFE4405F);
      default:
        return Colors.grey;
    }
  }
}
