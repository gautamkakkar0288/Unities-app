import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/cirqles_colors.dart';
import '../../../app/theme/sizing.dart';
import '../../../app/theme/spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/app_notification.dart';
import '../../../shared/models/enums.dart';
import '../../../shared/widgets/async_section.dart';
import '../../../shared/widgets/cirqles_app_bar.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/surface_card.dart';
import '../data/notification_providers.dart';

/// Alerts: reminders, membership decisions and community activity.
///
/// Read state comes from `notifications.read_at`. There is no endpoint to mark
/// anything read yet, so the screen does not offer a button that would lie —
/// tapping a notification navigates, nothing more.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inbox = ref.watch(notificationInboxProvider);

    return Scaffold(
      appBar: const CirqlesAppBar(eyebrow: 'Your campus', title: 'Alerts'),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () async => ref.refresh(notificationInboxProvider.future),
          child: ListView(
            padding: const EdgeInsets.only(
              left: Spacing.pageGutter,
              right: Spacing.pageGutter,
              top: Spacing.sm,
              bottom: Spacing.bottomActionInset,
            ),
            children: <Widget>[
              AsyncSection(
                value: inbox,
                onRetry: () => ref.invalidate(notificationInboxProvider),
                builder: (page) {
                  if (page.items.isEmpty) {
                    return const EmptyState(
                      icon: Icons.notifications_none_rounded,
                      title: 'You are all caught up',
                      message: 'Event reminders and community updates land '
                          'here.',
                    );
                  }
                  return Column(
                    children: <Widget>[
                      for (final notification in page.items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: Spacing.sm),
                          child: _NotificationRow(notification: notification),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = CirqlesColors.of(context);

    return SurfaceCard(
      onTap: () => _openTarget(context),
      semanticLabel: '${notification.isUnread ? 'Unread. ' : ''}'
          '${notification.title}. ${notification.body}',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: Sizing.avatarSm,
            width: Sizing.avatarSm,
            decoration: BoxDecoration(
              color: colors.brand.subtle,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _iconFor(notification.kind),
              size: Sizing.iconSm,
              color: colors.brand.base,
            ),
          ),
          const SizedBox(width: Spacing.smPlus),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  notification.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    // Unread is weight plus a dot, never colour alone.
                    fontWeight: notification.isUnread
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
                if (notification.body.isNotEmpty) ...<Widget>[
                  const SizedBox(height: Spacing.xxs),
                  Text(notification.body, style: theme.textTheme.bodySmall),
                ],
                const SizedBox(height: Spacing.xs),
                Text(
                  Formatters.relativeShort(notification.createdAt),
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ),
          if (notification.isUnread)
            Padding(
              padding: const EdgeInsets.only(left: Spacing.sm, top: Spacing.xs),
              child: Container(
                height: 8,
                width: 8,
                decoration: BoxDecoration(
                  color: colors.brand.base,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Deep-links from a notification target. Only kinds the app has a screen
  /// for are navigable; the rest do nothing rather than dead-ending.
  void _openTarget(BuildContext context) {
    final targetId = notification.targetId;
    if (targetId == null) return;
    switch (notification.targetKind) {
      case TargetKind.event:
        context.push(Routes.eventPath(targetId));
      case TargetKind.community:
        context.push(Routes.communityPath(targetId));
      case TargetKind.post:
      case TargetKind.comment:
      case TargetKind.activity:
      case TargetKind.user:
      case null:
        break;
    }
  }

  IconData _iconFor(NotificationKind kind) {
    return switch (kind) {
      NotificationKind.eventReminder => Icons.event_outlined,
      NotificationKind.communityPost => Icons.forum_outlined,
      NotificationKind.mention => Icons.alternate_email_rounded,
      NotificationKind.membership => Icons.how_to_reg_outlined,
      NotificationKind.moderation => Icons.shield_outlined,
      NotificationKind.activity => Icons.bolt_outlined,
    };
  }
}
