import 'enums.dart';
import 'json.dart';
import 'wire_enum.dart';

/// One line of an event agenda (`agenda` jsonb column).
class AgendaItem {
  const AgendaItem({required this.at, required this.title});

  factory AgendaItem.fromJson(Map<String, Object?> json) => AgendaItem(
        at: Json.requireString(json, 'at'),
        title: Json.requireString(json, 'title'),
      );

  /// A label such as `18:30`, stored as text by the backend rather than a
  /// timestamp, so it is kept as text here too.
  final String at;
  final String title;

  Map<String, Object?> toJson() =>
      <String, Object?>{'at': at, 'title': title};
}

/// An event (`events` table).
///
/// Capacity and fee semantics come from the schema and are not re-invented
/// here: a null [capacity] means unlimited, and a null [feeInPaise] means free.
/// Fees are stored in paise (integer) because the platform is India-first.
class Event {
  const Event({
    required this.id,
    required this.slug,
    required this.title,
    required this.kind,
    required this.mode,
    required this.status,
    required this.startsAt,
    required this.endsAt,
    required this.registeredCount,
    required this.communityId,
    required this.interestId,
    this.description,
    this.venue,
    this.agenda = const <AgendaItem>[],
    this.registrationClosesAt,
    this.capacity,
    this.feeInPaise,
    this.createdById,
    this.createdAt,
    this.cancelledAt,
    this.viewerRegistrationState,
  });

  factory Event.fromJson(Map<String, Object?> json) {
    return Event(
      id: Json.requireString(json, 'id'),
      slug: Json.requireString(json, 'slug'),
      title: Json.requireString(json, 'title'),
      kind: enumFromWire(EventKind.values, json['kind']) ?? EventKind.meetup,
      mode: enumFromWire(EventMode.values, json['mode']) ?? EventMode.inPerson,
      status: enumFromWire(EventStatus.values, json['status']) ??
          EventStatus.published,
      startsAt: Json.requireDateTime(json, 'startsAt'),
      endsAt: Json.optionalDateTime(json, 'endsAt') ??
          Json.requireDateTime(json, 'startsAt'),
      registeredCount: Json.optionalInt(json, 'registeredCount') ??
          Json.optionalInt(json, 'registered_count') ??
          0,
      communityId: Json.optionalString(json, 'communityId') ??
          Json.optionalString(json, 'community_id') ??
          '',
      interestId: Json.optionalString(json, 'interestId') ??
          Json.optionalString(json, 'interest_id') ??
          '',
      description: Json.optionalString(json, 'description'),
      venue: Json.optionalString(json, 'venue'),
      agenda: Json.listOf(json['agenda'], AgendaItem.fromJson),
      registrationClosesAt:
          Json.optionalDateTime(json, 'registrationClosesAt') ??
              Json.optionalDateTime(json, 'registration_closes_at'),
      capacity: Json.optionalInt(json, 'capacity'),
      feeInPaise: Json.optionalInt(json, 'feeInPaise') ??
          Json.optionalInt(json, 'fee_in_paise'),
      createdById: Json.optionalString(json, 'createdById') ??
          Json.optionalString(json, 'created_by_id'),
      createdAt: Json.optionalDateTime(json, 'createdAt') ??
          Json.optionalDateTime(json, 'created_at'),
      cancelledAt: Json.optionalDateTime(json, 'cancelledAt') ??
          Json.optionalDateTime(json, 'cancelled_at'),
      viewerRegistrationState: enumFromWire(
        RegistrationState.values,
        json['viewerRegistrationState'],
      ),
    );
  }

  final String id;
  final String slug;
  final String title;
  final EventKind kind;
  final EventMode mode;
  final EventStatus status;
  final DateTime startsAt;
  final DateTime endsAt;

  /// Denormalised counter maintained by the backend.
  final int registeredCount;
  final String communityId;
  final String interestId;
  final String? description;
  final String? venue;
  final List<AgendaItem> agenda;
  final DateTime? registrationClosesAt;

  /// Null means unlimited.
  final int? capacity;

  /// Null means free. There is no payment integration in the backend yet, so a
  /// paid event can be displayed but not paid for in the app.
  final int? feeInPaise;
  final String? createdById;
  final DateTime? createdAt;
  final DateTime? cancelledAt;

  /// The current student's registration state, when the response includes it.
  final RegistrationState? viewerRegistrationState;

  bool get isCancelled =>
      status == EventStatus.cancelled || cancelledAt != null;
  bool get isFree => feeInPaise == null || feeInPaise == 0;
  bool get hasUnlimitedCapacity => capacity == null;

  int? get remainingSeats {
    final total = capacity;
    if (total == null) return null;
    final remaining = total - registeredCount;
    return remaining < 0 ? 0 : remaining;
  }

  bool get isFull => remainingSeats == 0;

  /// Drives the “Almost full” treatment. 80% is a presentation threshold, not a
  /// backend rule, and lives here so every surface agrees on it.
  bool get isNearlyFull {
    final total = capacity;
    if (total == null || total == 0) return false;
    return registeredCount / total >= 0.8 && !isFull;
  }

  bool get registrationClosed {
    final closes = registrationClosesAt;
    if (closes == null) return false;
    return DateTime.now().toUtc().isAfter(closes);
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'slug': slug,
        'title': title,
        'kind': kind.wire,
        'mode': mode.wire,
        'status': status.wire,
        'startsAt': Json.encodeDateTime(startsAt),
        'endsAt': Json.encodeDateTime(endsAt),
        'registeredCount': registeredCount,
        'communityId': communityId,
        'interestId': interestId,
        'description': description,
        'venue': venue,
        'agenda': agenda.map((item) => item.toJson()).toList(),
        'registrationClosesAt': Json.encodeDateTime(registrationClosesAt),
        'capacity': capacity,
        'feeInPaise': feeInPaise,
        'createdById': createdById,
        'createdAt': Json.encodeDateTime(createdAt),
        'cancelledAt': Json.encodeDateTime(cancelledAt),
        'viewerRegistrationState': viewerRegistrationState?.wire,
      };
}
