import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/network/pagination.dart';
import '../../../shared/models/event.dart';
import '../domain/event_repository.dart';
import 'pending_event_repository.dart';
import 'sample_event_repository.dart';

/// Which implementation the app runs against is a configuration decision made
/// in exactly one place.
final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return ref.watch(appConfigProvider).useSampleContent
      ? const SampleEventRepository()
      : const PendingEventRepository();
});

/// Screens watch this. The `Result` failure is rethrown so Riverpod's
/// `AsyncValue` carries the typed [AppError] into the shared error view.
final upcomingEventsProvider = FutureProvider<Paginated<Event>>((ref) async {
  final result = await ref.watch(eventRepositoryProvider).upcomingEvents();
  return result.fold(
    onSuccess: (page) => page,
    onFailure: (error) => throw error,
  );
});

final eventBySlugProvider = FutureProvider.family<Event, String>(
  (ref, slug) async {
    final result = await ref.watch(eventRepositoryProvider).eventBySlug(slug);
    return result.fold(
      onSuccess: (event) => event,
      onFailure: (error) => throw error,
    );
  },
);
