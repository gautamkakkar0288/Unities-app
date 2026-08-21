import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/providers.dart';
import '../../../app/theme/spacing.dart';
import '../../../core/network/api_paths.dart';
import '../../../shared/widgets/cirqles_button.dart';
import '../../../shared/widgets/surface_card.dart';

/// Registration hand-off.
///
/// This screen does not pretend to sign anyone up. Cirqles registers students
/// through the `registerUser` **server action**, which has no HTTP contract, so
/// there is nothing for a mobile client to call. Rather than build a form that
/// cannot submit, the app explains the rule it would have to enforce anyway
/// (a university email address) and opens the web sign-up page.
///
/// The typed seam exists in `AuthRepository.signUp`, which fails with
/// `MissingBackendCapabilityError` until an endpoint lands.
class SignUpScreen extends ConsumerWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final signUpUrl = ref.watch(authRepositoryProvider).webSignUpUrl;

    return Scaffold(
      appBar: AppBar(title: const Text('Create an account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Spacing.pageGutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Join with your campus email',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                'Cirqles verifies students by university email domain. Use the '
                'address your campus gave you — personal addresses are not '
                'accepted.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Spacing.lg),
              PrimaryButton(
                label: 'Continue on the web',
                icon: Icons.open_in_new_rounded,
                onPressed: () => _openSignUp(context, signUpUrl),
              ),
              const SizedBox(height: Spacing.md),
              SecondaryButton(
                label: 'Back to sign in',
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(height: Spacing.lg),
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const Icon(Icons.info_outline_rounded, size: 20),
                        const SizedBox(width: Spacing.sm),
                        Expanded(
                          child: Text(
                            'Why not in the app yet?',
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.sm),
                    Text(
                      MissingCapabilities.signUpDetail,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: Spacing.sm),
                    Text(
                      'Blocked capability: '
                      '${MissingCapabilities.signUp}',
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openSignUp(BuildContext context, Uri url) async {
    final launched = await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open $url')),
      );
    }
  }
}
