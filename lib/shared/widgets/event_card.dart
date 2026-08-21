import 'package:flutter/material.dart';

import '../../app/theme/sizing.dart';
import '../../app/theme/spacing.dart';
import '../../core/utils/formatters.dart';
import '../models/enums.dart';
import '../models/event.dart';
import 'status_chip.dart';
import 'surface_card.dart';

/// An event, as it appears in every list in the app.
///
/// Answers the four questions a student actually has — what, when, where, can
/// I still get in — in that order. Status is derived from the model
/// (cancelled, full, nearly full, already registered) rather than passed in,
/// so two screens cannot disagree about the same event.
class EventCard extends StatelessWidget {
  const EventCard({
    required this.event,
    this.communityName,
    this.onTap,
    this.isSample = false,
    super.key,
  });

  final Event event;

  /// Whose event this is. Community-first: the host is not a footnote.
  final String? communityName;
  final VoidCallback? onTap;

  /// Marks placeholder content shown when no endpoint exists yet.
  final bool isSample;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chips = _statusChips();

    return SurfaceCard(
      onTap: onTap,
      semanticLabel: '${event.title}, ${Formatters.eventWhen(event.startsAt)}'
          '${communityName == null ? '' : ', hosted by $communityName'}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  Formatters.eventWhen(event.startsAt),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              if (isSample) const StatusChip(label: 'Sample'),
            ],
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            event.title,
            style: theme.textTheme.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: Spacing.sm),
          _MetaRow(event: event, communityName: communityName),
          if (chips.isNotEmpty) ...<Widget>[
            const SizedBox(height: Spacing.smPlus),
            Wrap(
              spacing: Spacing.sm,
              runSpacing: Spacing.sm,
              children: chips,
            ),
          ],
        ],
      ),
    );
  }

  /// Status is expressed with text plus icon, never colour alone.
  List<Widget> _statusChips() {
    if (event.isCancelled) {
      return const <Widget>[
        StatusChip(
          label: 'Cancelled',
          tone: StatusTone.danger,
          icon: Icons.event_busy_rounded,
        ),
      ];
    }

    final chips = <Widget>[];

    switch (event.viewerRegistrationState) {
      case RegistrationState.registered:
        chips.add(
          const StatusChip(
            label: 'You are going',
            tone: StatusTone.success,
            icon: Icons.check_circle_outline_rounded,
          ),
        );
      case RegistrationState.waitlisted:
        chips.add(
          const StatusChip(
            label: 'Waitlisted',
            tone: StatusTone.info,
            icon: Icons.hourglass_bottom_rounded,
          ),
        );
      case RegistrationState.cancelled:
      case null:
        break;
    }

    if (event.isFull) {
      chips.add(
        const StatusChip(
          label: 'Full',
          tone: StatusTone.warning,
          icon: Icons.groups_rounded,
        ),
      );
    } else if (event.isNearlyFull) {
      chips.add(
        StatusChip(
          label: '${event.remainingSeats} seats left',
          tone: StatusTone.featured,
          icon: Icons.trending_up_rounded,
        ),
      );
    }

    if (!event.isFree) {
      chips.add(
        StatusChip(
          label: Formatters.fee(event.feeInPaise),
          icon: Icons.confirmation_number_outlined,
        ),
      );
    }

    return chips;
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.event, this.communityName});

  final Event event;
  final String? communityName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final where = switch (event.mode) {
      EventMode.online => 'Online',
      EventMode.hybrid => 'Hybrid · ${event.venue ?? 'Venue TBA'}',
      EventMode.inPerson => event.venue ?? 'Venue TBA',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (communityName != null)
          _MetaLine(
            icon: Icons.groups_2_outlined,
            text: communityName!,
            style: theme.textTheme.bodySmall,
          ),
        _MetaLine(
          icon: event.mode == EventMode.online
              ? Icons.videocam_outlined
              : Icons.place_outlined,
          text: where,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.icon, required this.text, this.style});

  final IconData icon;
  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.xxs),
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            size: Sizing.iconSm,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: Spacing.xs),
          Expanded(
            child: Text(text, style: style, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
