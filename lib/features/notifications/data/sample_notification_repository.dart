import '../../../core/network/pagination.dart';
import '../../../core/utils/result.dart';
import '../../../shared/models/app_notification.dart';
import '../../sample/sample_content.dart';
import '../domain/notification_repository.dart';

/// Development-only repository. See `features/sample/sample_content.dart`.
class SampleNotificationRepository implements NotificationRepository {
  const SampleNotificationRepository();

  @override
  Future<Result<Paginated<AppNotification>>> inbox({
    PageRequest page = const PageRequest(),
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return Success<Paginated<AppNotification>>(
      Paginated<AppNotification>(items: SampleContent.notifications()),
    );
  }
}
