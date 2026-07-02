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
          const SizedBox(height: 32),
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
                  onTap: () {},
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
