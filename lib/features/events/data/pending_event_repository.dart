import '../../../core/errors/app_error.dart';
import '../../../core/network/api_paths.dart';
import '../../../core/network/pagination.dart';
import '../../../core/utils/result.dart';
import '../../../shared/models/event.dart';
import '../domain/event_repository.dart';

/// The real implementation, minus the endpoint.
///
/// Cirqles queries events in `lib/services` and renders them from server
/// components; there is no JSON route a mobile client can call. Rather than
/// invent `/api/events` and ship a client that 404s, every method returns a
/// [MissingBackendCapabilityError] that names the gap. The UI turns that into a
/// “not in the app yet” state, and the gap stays visible in code review,
/// ARCHITECTURE.md and the app itself.
///
/// When the endpoint lands, this class is where the request goes — the
/// interface, the models, the paging and the screens do not change.
class PendingEventRepository implements EventRepository {
  const PendingEventRepository();

  static const AppError _missing = MissingBackendCapabilityError(
    capability: MissingCapabilities.eventsList,
    detail: MissingCapabilities.eventsDetail,
  );

  @override
  Future<Result<Paginated<Event>>> upcomingEvents({
    PageRequest page = const PageRequest(),
  }) async =>
      const Failure<Paginated<Event>>(_missing);

  @override
  Future<Result<Event>> eventBySlug(String slug) async =>
      const Failure<Event>(_missing);
}
