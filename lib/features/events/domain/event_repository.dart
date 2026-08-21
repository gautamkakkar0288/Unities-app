import '../../../core/network/pagination.dart';
import '../../../core/utils/result.dart';
import '../../../shared/models/event.dart';

/// Event reads the mobile MVP needs.
///
/// Defined from the product requirement, not from an endpoint that exists:
/// there is no events JSON API yet, so this interface is the specification the
/// backend work can be written against.
abstract interface class EventRepository {
  /// Published, upcoming events relevant to the signed-in student.
  Future<Result<Paginated<Event>>> upcomingEvents({PageRequest page});

  /// One event by slug — the deep-link entry point.
  Future<Result<Event>> eventBySlug(String slug);
}
