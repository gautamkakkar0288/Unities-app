import '../../../core/network/pagination.dart';
import '../../../core/utils/result.dart';
import '../../../shared/models/app_notification.dart';

/// Notification reads.
///
/// Marking as read is intentionally not here yet: it is a write with no
/// endpoint, and a button that silently does nothing is worse than no button.
abstract interface class NotificationRepository {
  Future<Result<Paginated<AppNotification>>> inbox({PageRequest page});
}
