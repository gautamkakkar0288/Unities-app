import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/event.dart';
import '../../../shared/widgets/async_section.dart';
import '../../../shared/widgets/cirqles_button.dart';
import '../../../shared/widgets/skeleton.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../../shared/widgets/surface_card.dart';
import '../data/event_providers.dart';

/// Event detail, reached by tap or by deep link (`/events/:slug`).
///
/// Registration is not wired: it is a server action that manages capacity,
/// waitlist promotion and counters. The button is present and honest about why
/// it is disabled, so the flow is designed but not faked.
class EventDetailScreen extends ConsumerWidget {
  const EventDetailScreen({required this.slug, super.key});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final event = ref.watch(eventBySlugProvider(slug));

    return Scaffold(
      appBar: AppBar(title: const Text('Event')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Spacing.pageGutter),
          child: AsyncSection(
            value: event,
            onRetry: () => ref.invalidate(eventBySlugProvider(slug)),
            loading: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Skeleton(height: 28),
                SizedBox(height: Spacing.md),
                Skeleton(height: 14, width: 200),
                SizedBox(height: Spacing.lg),
                CardSkeleton(),
              ],
            ),
            builder: (data) => _EventDetail(event: data),
          ),
        ),
      ),
    );
  }
}

class _EventDetail extends StatelessWidget {
  const _EventDetail({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Wrap(
          spacing: Spacing.sm,
          runSpacing: Spacing.sm,
          children: <Widget>[
            StatusChip(label: event.kind.label, tone: StatusTone.brand),
            StatusChip(label: event.mode.label),
            if (event.isCancelled)
              const StatusChip(
                label: 'Cancelled',
                tone: StatusTone.danger,
                icon: Icons.event_busy_rounded,
              ),
          ],
        ),
        const SizedBox(height: Spacing.md),
        Text(event.title, style: theme.textTheme.headlineLarge),
        const SizedBox(height: Spacing.sm),
        Text(
          '${Formatters.eventWhen(event.startsAt)} · '
          '${Formatters.eventDuration(event.startsAt, event.endsAt)}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (event.venue != null) ...<Widget>[
          const SizedBox(height: Spacing.xs),
          Text(event.venue!, style: theme.textTheme.bodyMedium),
        ],
        const SizedBox(height: Spacing.lg),
        SurfaceCard(
          child: Row(
            children: <Widget>[
              Expanded(
                child: _Stat(
                  label: 'Going',
                  value: '${event.registeredCount}',
                ),
              ),
              Expanded(
                child: _Stat(
                  label: 'Seats left',
                  value: event.hasUnlimitedCapacity
                      ? 'Unlimited'
                      : '${event.remainingSeats}',
                ),
              ),
              Expanded(
                child: _Stat(
                  label: 'Entry',
                  value: Formatters.fee(event.feeInPaise),
                ),
              ),
            ],
          ),
        ),
        if (event.description != null) ...<Widget>[
          const SizedBox(height: Spacing.lg),
          Text('About', style: theme.textTheme.titleMedium),
          const SizedBox(height: Spacing.sm),
          Text(event.description!, style: theme.textTheme.bodyMedium),
        ],
        if (event.agenda.isNotEmpty) ...<Widget>[
          const SizedBox(height: Spacing.lg),
          Text('Agenda', style: theme.textTheme.titleMedium),
          const SizedBox(height: Spacing.sm),
          for (final item in event.agenda)
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: 64,
                    child: Text(item.at, style: theme.textTheme.labelSmall),
                  ),
                  Expanded(
                    child: Text(
                      item.title,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
        ],
        const SizedBox(height: Spacing.xl),
        const PrimaryButton(label: 'Register', onPressed: null),
        const SizedBox(height: Spacing.sm),
        Text(
          'Registration happens on the web for now. It is a server action that '
          'manages capacity and the waitlist, and has no mobile endpoint yet.',
          style: theme.textTheme.labelSmall,
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(value, style: theme.textTheme.titleLarge),
        const SizedBox(height: Spacing.xxs),
        Text(label, style: theme.textTheme.labelSmall),
      ],
    );
  }
}
