import '../../../core/errors/app_error.dart';
import '../../../core/network/api_paths.dart';
import '../../../core/network/pagination.dart';
import '../../../core/utils/result.dart';
import '../../../shared/models/app_notification.dart';
import '../domain/notification_repository.dart';

/// Awaiting a notifications endpoint.
///
/// Push is a separate gap: there is no device-token registration on the server,
/// so no push SDK is wired into the app. Adding one now would only prove it can
/// be added.
class PendingNotificationRepository implements NotificationRepository {
  const PendingNotificationRepository();

  @override
  Future<Result<Paginated<AppNotification>>> inbox({
    PageRequest page = const PageRequest(),
  }) async =>
      const Failure<Paginated<AppNotification>>(
        MissingBackendCapabilityError(
          capability: MissingCapabilities.notificationsList,
          detail: MissingCapabilities.notificationsDetail,
        ),
      );
}
