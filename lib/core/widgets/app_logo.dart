import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Gentleman shield-check logo mark used as the app branding icon.
class AppLogo extends StatelessWidget {
  final double size;
  final bool showGlow;

  const AppLogo({super.key, this.size = 48, this.showGlow = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary,
            cs.primary.withValues(alpha: 0.7),
          ],
        ),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: cs.primary.withValues(alpha: 0.35),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.28),
        child: Image.asset(
          'assets/gentleman.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              LucideIcons.shieldCheck,
              size: size * 0.52,
              color: cs.onPrimary,
            );
          },
        ),
      ),
    );
  }
}

/// Animated version for splash / onboarding.
class AnimatedAppLogo extends StatelessWidget {
  final double size;

  const AnimatedAppLogo({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return AppLogo(size: size, showGlow: true)
        .animate()
        .fadeIn(duration: 600.ms, delay: 200.ms)
        .scale(begin: const Offset(0.8, 0.8), duration: 500.ms, curve: Curves.easeOutBack);
  }
}
