import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';

/// Animated protection status indicator dot.
class ProtectionDot extends StatelessWidget {
  final bool isActive;
  final double size;

  const ProtectionDot({super.key, required this.isActive, this.size = 12});

  void _showStatus(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.success,
                boxShadow: [
                  BoxShadow(color: AppColors.success, blurRadius: 6, spreadRadius: 1),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Text('Shield Status'),
          ],
        ),
        content: const Text(
          'The indicator is intentionally prominent so you can verify protection instantly. '
          'A glow means Gentleman is actively guarding supported call actions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showStatus(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? AppColors.success : AppColors.lightSecondary,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.success.withValues(alpha: 0.6),
                    blurRadius: 12,
                    spreadRadius: 3,
                  ),
                ]
              : null,
        ),
      )
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .scale(
            begin: const Offset(0.9, 0.9),
            end: const Offset(1.15, 1.15),
            duration: 800.ms,
            curve: Curves.easeInOut,
          ),
    );
  }
}

/// Section header used across screens.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          if (actionText != null)
            TextButton(
              onPressed: onAction,
              child: Text(actionText!),
            ),
        ],
      ),
    );
  }
}
