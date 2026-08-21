import '../../../core/errors/app_error.dart';
import '../../../core/network/pagination.dart';
import '../../../core/utils/result.dart';
import '../../../shared/models/event.dart';
import '../../sample/sample_content.dart';
import '../domain/event_repository.dart';

/// Development-only repository. See `features/sample/sample_content.dart`.
///
/// Selected only when `CIRQLES_USE_SAMPLE_CONTENT=true`, which [AppConfig]
/// forces off in production. Cards fed from here are labelled “Sample”.
class SampleEventRepository implements EventRepository {
  const SampleEventRepository();

  @override
  Future<Result<Paginated<Event>>> upcomingEvents({
    PageRequest page = const PageRequest(),
  }) async {
    // A short delay so loading states are exercised during development.
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return Success<Paginated<Event>>(
      Paginated<Event>(items: SampleContent.events()),
    );
  }

  @override
  Future<Result<Event>> eventBySlug(String slug) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    for (final event in SampleContent.events()) {
      if (event.slug == slug) return Success<Event>(event);
    }
    return const Failure<Event>(
      NotFoundError(debugMessage: 'no sample event with that slug'),
    );
  }
}
