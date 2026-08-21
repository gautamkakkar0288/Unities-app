import 'package:flutter/material.dart';

import '../../../app/theme/cirqles_colors.dart';
import '../../../app/theme/radii.dart';
import '../../../app/theme/spacing.dart';

/// Shown while the session is being restored.
///
/// Deliberately quiet and short-lived: it exists so the app never flashes the
/// sign-in screen at a student who is already signed in. It states what it is
/// doing rather than showing a bare spinner.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = CirqlesColors.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 72,
                  width: 72,
                  decoration: BoxDecoration(
                    color: colors.brand.subtle,
                    borderRadius: Radii.card,
                    border: Border.all(color: colors.brand.border),
                  ),
                  child: Center(
                    child: Text(
                      'C',
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: colors.brand.base,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.lg),
                Text('Cirqles', style: theme.textTheme.headlineLarge),
                const SizedBox(height: Spacing.sm),
                Text(
                  'Your campus, in circles',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: Spacing.xl),
                const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(height: Spacing.md),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    'Checking your session…',
                    style: theme.textTheme.labelSmall,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
