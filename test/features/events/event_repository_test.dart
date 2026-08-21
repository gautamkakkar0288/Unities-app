import 'package:cirqles/core/errors/app_error.dart';
import 'package:cirqles/features/events/data/pending_event_repository.dart';
import 'package:cirqles/features/events/data/sample_event_repository.dart';
import 'package:cirqles/features/events/domain/event_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PendingEventRepository', () {
    const EventRepository repository = PendingEventRepository();

    test('reports the missing capability instead of pretending to work',
        () async {
      final result = await repository.upcomingEvents();

      expect(result.isSuccess, isFalse);
      final error = result.errorOrNull;
      expect(error, isA<MissingBackendCapabilityError>());
      expect(
        (error! as MissingBackendCapabilityError).capability,
        isNotEmpty,
      );
    });

    test('detail reads for deep links fail the same way', () async {
      final result = await repository.eventBySlug('portfolio-review-night');

      expect(result.errorOrNull, isA<MissingBackendCapabilityError>());
    });
  });

  group('SampleEventRepository', () {
    const EventRepository repository = SampleEventRepository();

    test('returns a first page of labelled sample events', () async {
      final result = await repository.upcomingEvents();

      final page = result.valueOrNull;
      expect(page, isNotNull);
      expect(page!.items, isNotEmpty);
      // Sample events must be upcoming, or the UI states make no sense.
      for (final event in page.items) {
        expect(event.startsAt.isAfter(DateTime.now().toUtc()), isTrue);
      }
    });

    test('resolves a known slug and fails cleanly on an unknown one', () async {
      final found = await repository.eventBySlug('portfolio-review-night');
      expect(found.valueOrNull?.slug, 'portfolio-review-night');

      final missing = await repository.eventBySlug('no-such-event');
      expect(missing.errorOrNull, isA<NotFoundError>());
    });
  });
}
