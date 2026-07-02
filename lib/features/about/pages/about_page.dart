import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_logo.dart';

class AboutPage extends ConsumerWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                const AppLogo(size: 80),
                const SizedBox(height: 16),
                Text('Gentleman', style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    )),
                const SizedBox(height: 4),
                Text(
                  'Version ${AppConstants.appVersion}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(AppConstants.appDescription, textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.5,
                )),
          const SizedBox(height: 28),
          
          // About the Author Card
          Card(
            clipBehavior: Clip.antiAlias,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: cs.primary.withValues(alpha: 0.15), width: 1.5),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cs.primary.withValues(alpha: 0.08),
                    cs.primary.withValues(alpha: 0.01),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(LucideIcons.terminal, color: cs.primary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'About the Author',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          Text(
                            'Lohit A.K.A @aarushlohit',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Hi, I\'m Lohit A.K.A (Aarushlohit). Author | lyricist | Coder | hacker not really but cybersec researcher !!! | spotify artist | @aarushlohit github and aarushlohit_01 instagram\n\n'
                    'I\'m a developer who enjoys building practical software that solves real problems.\n\n'
                    'I\'m also an overthinker.\n\n'
                    'One accidental video call turned into several minutes of wondering what the other person thought of me. Instead of accepting it as "just one of those things," I decided to build a solution.\n\n'
                    'That\'s how Gentleman was born.\n\n'
                    'I believe the best software often comes from small everyday frustrations. If a tiny moment of embarrassment can inspire a tool that helps thousands of people, then it was probably worth it.\n\n'
                    'If you\'d like to contribute, report bugs, or suggest new ideas, you\'re always welcome.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                          fontSize: 13,
                        ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton.filledTonal(
                        onPressed: () => _launchUrl(context, 'https://github.com/aarushlohit'),
                        icon: const Icon(LucideIcons.github),
                        tooltip: 'GitHub',
                      ),
                      IconButton.filledTonal(
                        onPressed: () => _launchUrl(context, 'https://instagram.com/aarushlohit_01'),
                        icon: const Icon(LucideIcons.instagram),
                        tooltip: 'Instagram',
                      ),
                      IconButton.filledTonal(
                        onPressed: () => _launchUrl(context, 'https://open.spotify.com/'), //spotify artist generic link
                        icon: const Icon(LucideIcons.music),
                        tooltip: 'Spotify',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                _AboutTile(
                  icon: LucideIcons.github,
                  label: 'Source Code',
                  onTap: () => _launchUrl(context, AppConstants.githubUrl),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _AboutTile(
                  icon: LucideIcons.shield,
                  label: 'Privacy Policy',
                  onTap: () => _launchUrl(context, AppConstants.privacyPolicyUrl),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _AboutTile(
                  icon: LucideIcons.fileText,
                  label: 'License',
                  subtitle: 'MIT',
                  onTap: () => _launchUrl(context, AppConstants.licenseUrl),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _AboutTile(
                  icon: LucideIcons.users,
                  label: 'Open Source Notices',
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: 'Gentleman',
                    applicationVersion: AppConstants.appVersion,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 24),
          Center(
            child: Text(
              AppConstants.copyright,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Made with ❤️ for your privacy',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _AboutTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  const _AboutTile({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: const Icon(LucideIcons.chevronRight, size: 18),
      onTap: onTap,
    );
  }
}
