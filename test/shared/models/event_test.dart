import 'package:cirqles/shared/models/enums.dart';
import 'package:cirqles/shared/models/event.dart';
import 'package:flutter_test/flutter_test.dart';

/// These tests protect the two places mobile clients usually break: decoding a
/// payload whose keys or enum values are not exactly what was expected, and
/// re-deriving business meaning (capacity, fees) that the schema already
/// defines.
void main() {
  Map<String, Object?> baseJson() => <String, Object?>{
        'id': 'evt_1',
        'slug': 'portfolio-review-night',
        'title': 'Portfolio Review Night',
        'kind': 'WORKSHOP',
        'mode': 'IN_PERSON',
        'status': 'PUBLISHED',
        'startsAt': '2026-03-01T13:00:00.000Z',
        'endsAt': '2026-03-01T15:00:00.000Z',
        'registeredCount': 46,
        'communityId': 'com_1',
        'interestId': 'int_1',
        'capacity': 50,
        'venue': 'Studio 3',
      };

  group('Event.fromJson', () {
    test('decodes wire enum values from the Cirqles schema', () {
      final event = Event.fromJson(baseJson());

      expect(event.kind, EventKind.workshop);
      expect(event.mode, EventMode.inPerson);
      expect(event.status, EventStatus.published);
      expect(event.startsAt.isUtc, isTrue);
    });

    test('accepts snake_case keys, as a SQL-shaped payload would send', () {
      final json = baseJson()
        ..remove('registeredCount')
        ..remove('communityId')
        ..remove('interestId')
        ..['registered_count'] = 12
        ..['community_id'] = 'com_2'
        ..['interest_id'] = 'int_2'
        ..['fee_in_paise'] = 15000;

      final event = Event.fromJson(json);

      expect(event.registeredCount, 12);
      expect(event.communityId, 'com_2');
      expect(event.interestId, 'int_2');
      expect(event.feeInPaise, 15000);
    });

    test('falls back to a safe default for an unknown enum value', () {
      // A new event kind added to the backend must not crash an older build.
      final event = Event.fromJson(baseJson()..['kind'] = 'HACKATHON');

      expect(event.kind, EventKind.meetup);
    });

    test('survives a round trip through toJson', () {
      final original = Event.fromJson(baseJson());
      final restored = Event.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.slug, original.slug);
      expect(restored.kind, original.kind);
      expect(restored.mode, original.mode);
      expect(restored.startsAt, original.startsAt);
      expect(restored.endsAt, original.endsAt);
      expect(restored.capacity, original.capacity);
      expect(restored.registeredCount, original.registeredCount);
    });
  });

  group('capacity and fee semantics', () {
    test('null capacity means unlimited, never zero seats', () {
      final event = Event.fromJson(baseJson()..remove('capacity'));

      expect(event.hasUnlimitedCapacity, isTrue);
      expect(event.remainingSeats, isNull);
      expect(event.isFull, isFalse);
      expect(event.isNearlyFull, isFalse);
    });

    test('null fee means free', () {
      final event = Event.fromJson(baseJson());

      expect(event.isFree, isTrue);
    });

    test('a paid event is not free', () {
      final event = Event.fromJson(baseJson()..['feeInPaise'] = 15000);

      expect(event.isFree, isFalse);
    });

    test('remaining seats never goes negative when a counter overshoots', () {
      final event = Event.fromJson(
        baseJson()
          ..['capacity'] = 40
          ..['registeredCount'] = 44,
      );

      expect(event.remainingSeats, 0);
      expect(event.isFull, isTrue);
      // “Almost full” must not fire once it is actually full.
      expect(event.isNearlyFull, isFalse);
    });

    test('nearly full at the presentation threshold', () {
      final event = Event.fromJson(
        baseJson()
          ..['capacity'] = 50
          ..['registeredCount'] = 40,
      );

      expect(event.isNearlyFull, isTrue);
      expect(event.remainingSeats, 10);
    });
  });

  test('a cancelled_at timestamp cancels the event even if status lags', () {
    final event = Event.fromJson(
      baseJson()..['cancelled_at'] = '2026-02-20T10:00:00.000Z',
    );

    expect(event.isCancelled, isTrue);
  });
}
