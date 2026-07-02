import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Animated protection status indicator dot (glowing interactive red dot).
class ProtectionDot extends StatelessWidget {
  final bool isActive;
  final double size;

  const ProtectionDot({super.key, required this.isActive, this.size = 12});

  void _showSarcasticStatus(BuildContext context) {
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
                color: Colors.red,
                boxShadow: [
                  BoxShadow(color: Colors.redAccent, blurRadius: 6, spreadRadius: 1),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Text('Dignity Status: Active'),
          ],
        ),
        content: const Text(
          'Yes, the dot is red. No, nothing is wrong.\n\n'
          'We chose red because it triggers your overthinking brain to check on the app. '
          'Your beloved one is 100% safe from the demon of accidental touch.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('I will stop overthinking'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSarcasticStatus(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? Colors.red : Colors.grey,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.6),
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
                  fontWeight: FontWeight.w600,
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
