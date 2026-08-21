import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/empty_state.dart';
import 'routes.dart';

/// Shown for an unmatched route, including a deep link from an older or newer
/// version of the web app.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({required this.location, super.key});

  final String location;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Not found')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: EmptyState(
              icon: Icons.explore_off_rounded,
              title: 'We could not open that link',
              message: 'This part of Cirqles may not exist in the app yet.',
              actionLabel: 'Go to Home',
              onAction: () => context.go(Routes.home),
              footnote: location,
            ),
          ),
        ),
      ),
    );
  }
}
