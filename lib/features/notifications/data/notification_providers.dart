import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/network/pagination.dart';
import '../../../shared/models/app_notification.dart';
import '../domain/notification_repository.dart';
import 'pending_notification_repository.dart';
import 'sample_notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return ref.watch(appConfigProvider).useSampleContent
      ? const SampleNotificationRepository()
      : const PendingNotificationRepository();
});

final notificationInboxProvider =
    FutureProvider<Paginated<AppNotification>>((ref) async {
  final result = await ref.watch(notificationRepositoryProvider).inbox();
  return result.fold(
    onSuccess: (page) => page,
    onFailure: (error) => throw error,
  );
});

/// Badge count for the bottom navigation.
///
/// Zero while loading or unavailable: a badge is a claim about the student's
/// inbox, and guessing one is worse than showing none.
final unreadNotificationCountProvider = Provider<int>((ref) {
  final inbox = ref.watch(notificationInboxProvider).valueOrNull;
  if (inbox == null) return 0;
  return inbox.items.where((notification) => notification.isUnread).length;
});
