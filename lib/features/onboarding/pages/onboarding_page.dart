import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/services/settings_provider.dart';
import '../../../core/widgets/app_logo.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _belovedController = TextEditingController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    _userController.dispose();
    _belovedController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage == 1) {
      if (_userController.text.trim().isEmpty || _belovedController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter both names. We promise we won\'t send them to the cloud!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }
    _pageController.nextPage(
      duration: 350.ms,
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _complete() async {
    final user = _userController.text.trim();
    final beloved = _belovedController.text.trim();
    await ref.read(appSettingsProvider.notifier).completeOnboarding(user, beloved);
    if (mounted) {
      context.go(RoutePaths.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  cs.surface,
                  cs.primary.withValues(alpha: 0.05),
                  cs.primary.withValues(alpha: 0.1),
                ],
              ),
            ),
          ),
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (idx) => setState(() => _currentPage = idx),
            children: [
              // Page 1: Welcome
              _buildPage(
                content: [
                  const AppLogo(size: 110, showGlow: true)
                      .animate()
                      .scale(duration: 600.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: 32),
                  Text(
                    'Welcome to\nGentleman',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                  const SizedBox(height: 16),
                  Text(
                    'Accidental video calls. They happen to the best of us. Usually in the middle of the night. Usually to your boss, ex, or someone you haven\'t talked to in 5 years.\n\nLet\'s fix that.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                          height: 1.6,
                        ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                  const SizedBox(height: 48),
                  FilledButton(
                    onPressed: _nextPage,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Protect My Dignity'),
                  ).animate().fadeIn(delay: 600.ms),
                ],
              ),
              // Page 2: Inputs
              _buildPage(
                content: [
                  Icon(LucideIcons.userCheck, size: 64, color: cs.primary)
                      .animate()
                      .scale(duration: 400.ms),
                  const SizedBox(height: 24),
                  Text(
                    'Who are we securing?',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Help us personalize the shielding experience.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _userController,
                    decoration: const InputDecoration(
                      labelText: 'Your Name',
                      prefixIcon: Icon(LucideIcons.user),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _belovedController,
                    decoration: const InputDecoration(
                      labelText: 'Your Beloved One\'s Name',
                      prefixIcon: Icon(LucideIcons.heart),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Icon(LucideIcons.shieldAlert, size: 16, color: cs.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Safe: We don\'t store your data anywhere. No telemetry, no servers, no tracking. Everything is fully local-only.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontStyle: FontStyle.italic,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  FilledButton(
                    onPressed: _nextPage,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Save & Continue'),
                  ),
                ],
              ),
              // Page 3: Success
              _buildPage(
                content: [
                  const Icon(LucideIcons.shieldCheck, size: 90, color: Colors.green)
                      .animate()
                      .scale(duration: 500.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 32),
                  Text(
                    'Shield Activated!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.green,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              height: 1.6,
                            ),
                        children: [
                          const TextSpan(text: 'Successfully saved '),
                          TextSpan(
                            text: _belovedController.text,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
                          ),
                          const TextSpan(text: ' from the demon of accidental touch!\n\n'),
                          TextSpan(
                            text: 'Now, ${_userController.text}, whenever you accidentally tap a call button in WhatsApp or Instagram, Gentleman will intercept it and wait for your deliberate hold.',
                            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  FilledButton(
                    onPressed: _complete,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Start Protecting'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPage({required List<Widget> content}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height - 128,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: content,
        ),
      ),
    );
  }
}
