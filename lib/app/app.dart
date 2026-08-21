import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/theme/app_theme.dart';
import 'providers.dart';
import 'router/app_router.dart';
import 'theme/spacing.dart';

/// Root widget.
class CirqlesApp extends ConsumerWidget {
  const CirqlesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);

    return MaterialApp.router(
      title: 'Cirqles',
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(routerProvider),
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      // Light is the primary experience per DESIGN_SYSTEM.md. The dark theme is
      // built and tested, but there is no user-facing switch yet, so the app
      // does not follow the system setting and surprise students with a theme
      // the design system has not signed off for every surface.
      themeMode: ThemeMode.light,
      builder: (context, child) {
        // Respect the student's font size, within limits the layouts can take.
        var content = MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.6,
          child: child ?? const SizedBox.shrink(),
        );
        if (config.showEnvironmentBanner) {
          content = _EnvironmentBanner(
            label: config.environment.name,
            child: content,
          );
        }
        return content;
      },
    );
  }
}

/// Non-production builds are labelled, so a bug report says which backend it
/// came from.
class _EnvironmentBanner extends StatelessWidget {
  const _EnvironmentBanner({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Banner(
      message: label.toUpperCase(),
      location: BannerLocation.topStart,
      color: Theme.of(context).colorScheme.secondary,
      child: child,
    );
  }
}

/// Shown instead of the app when `--dart-define` configuration is unusable.
///
/// Failing loudly at startup beats a thousand confusing request errors later.
class ConfigurationErrorApp extends StatelessWidget {
  const ConfigurationErrorApp({required this.problems, super.key});

  final List<String> problems;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Icon(Icons.settings_suggest_rounded, size: 40),
                const SizedBox(height: Spacing.md),
                Text(
                  'Cirqles is not configured',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: Spacing.sm),
                Text(
                  'Check the --dart-define values documented in README '
                  '§ Configuration.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: Spacing.md),
                for (final problem in problems)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Spacing.sm),
                    child: Text(
                      '• $problem',
                      style: Theme.of(context).textTheme.bodySmall,
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
