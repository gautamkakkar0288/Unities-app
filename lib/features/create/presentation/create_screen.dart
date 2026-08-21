import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/spacing.dart';
import '../../../shared/models/enums.dart';
import '../../../shared/widgets/cirqles_app_bar.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../../shared/widgets/surface_card.dart';
import '../../auth/presentation/auth_controller.dart';

/// Create: the organiser entry point.
///
/// Everything here is role-gated *and* blocked on the backend. Creating an
/// event or a community is a server action with capacity, approval and audit
/// rules attached; a mobile write path needs to be designed with those rules,
/// not guessed. The screen shows what will live here and who will be able to
/// use it, and says plainly that it is not wired up.
class CreateScreen extends ConsumerWidget {
  const CreateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final role = ref.watch(authControllerProvider).user?.role;
    final createEnabled = ref.watch(appConfigProvider).createEnabled;
    final canOrganise = role?.canOrganise ?? false;

    return Scaffold(
      appBar: const CirqlesAppBar(eyebrow: 'Bring people together', title: 'Create'),
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
            if (!canOrganise)
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'Hosting is for organisers',
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        StatusChip(
                          label: (role ?? UserRole.student).label,
                          icon: Icons.badge_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.sm),
                    Text(
                      'Your community owners can give you organiser access. '
                      'Roles are managed on the server.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: Spacing.md),
            _CreateOption(
              icon: Icons.event_outlined,
              title: 'Host an event',
              description: 'Workshops, talks, tournaments, meetups and drives.',
              enabled: createEnabled && canOrganise,
            ),
            const SizedBox(height: Spacing.smPlus),
            _CreateOption(
              icon: Icons.groups_2_outlined,
              title: 'Propose a community',
              description:
                  'Student-led circles go through a review before launch.',
              enabled: createEnabled && canOrganise,
            ),
            const SizedBox(height: Spacing.lg),
            Text(
              'Creating events and communities happens on the web for now. '
              'These flows are server actions with approval and capacity rules '
              'that have no mobile endpoint yet.',
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateOption extends StatelessWidget {
  const _CreateOption({
    required this.icon,
    required this.title,
    required this.description,
    required this.enabled,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Opacity(
      // Dimmed *and* labelled: opacity alone is not a status signal.
      opacity: enabled ? 1 : 0.75,
      child: SurfaceCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: Spacing.smPlus),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: Spacing.xxs),
                  Text(description, style: theme.textTheme.bodySmall),
                  const SizedBox(height: Spacing.sm),
                  const StatusChip(
                    label: 'Not in the app yet',
                    icon: Icons.schedule_rounded,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
