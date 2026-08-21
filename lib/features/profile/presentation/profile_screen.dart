import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/providers.dart';
import '../../../app/theme/spacing.dart';
import '../../../core/network/api_paths.dart';
import '../../../shared/widgets/cirqles_app_bar.dart';
import '../../../shared/widgets/dialogs.dart';
import '../../../shared/widgets/profile_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/surface_card.dart';
import '../../auth/presentation/auth_controller.dart';

/// Profile: who the app thinks you are, and what it cannot tell you yet.
///
/// Everything shown here comes from the Auth.js session payload — id, name,
/// email, image, role. University affiliation, interests, communities and
/// badges are on the `users` and `memberships` tables with no endpoint, so
/// they are listed as pending rather than filled with plausible fiction.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authControllerProvider).user;
    final config = ref.watch(appConfigProvider);

    if (user == null) {
      // The router prevents this; the screen still does not assume it.
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: const CirqlesAppBar(eyebrow: 'You on Cirqles', title: 'Profile'),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.only(
            left: Spacing.pageGutter,
            right: Spacing.pageGutter,
            top: Spacing.sm,
            bottom: Spacing.bottomActionInset,
          ),
          children: <Widget>[
            ProfileCard(user: user),
            const SizedBox(height: Spacing.lg),
            const SectionHeader(title: 'Your campus identity'),
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Cirqles verifies students by university email domain. '
                    'Your verification state and campus are stored on the '
                    'server and are not exposed to the app yet '
                    '(${MissingCapabilities.profile}).',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: Spacing.sm),
                  TextButton(
                    onPressed: () => _open(
                      context,
                      ref.read(authRepositoryProvider).webVerifyEmailUrl,
                    ),
                    child: const Text('Manage verification on the web'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.lg),
            const SectionHeader(title: 'App'),
            SurfaceCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.dns_outlined),
                    title: const Text('Backend'),
                    subtitle: Text(
                      '${config.environment.name} · ${config.apiBaseUrl}',
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout_rounded),
                    title: const Text('Sign out'),
                    onTap: () => _confirmSignOut(context, ref),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Sign out of Cirqles?',
      message: 'You will need your university email and password to sign back '
          'in.',
      confirmLabel: 'Sign out',
      isDestructive: true,
    );
    if (!confirmed) return;
    await ref.read(authControllerProvider.notifier).signOut();
  }

  Future<void> _open(BuildContext context, Uri url) async {
    final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open $url')),
      );
    }
  }
}
