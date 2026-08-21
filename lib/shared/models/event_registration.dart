import 'enums.dart';
import 'json.dart';
import 'wire_enum.dart';

/// A student's registration for an event (`event_registrations` table).
///
/// [promotedAt] is set when the backend moves a waitlisted student into a freed
/// seat, which is why the app must treat waitlisting as a live state rather
/// than a dead end.
class EventRegistration {
  const EventRegistration({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.state,
    this.createdAt,
    this.promotedAt,
    this.cancelledAt,
  });

  factory EventRegistration.fromJson(Map<String, Object?> json) {
    return EventRegistration(
      id: Json.requireString(json, 'id'),
      eventId: Json.optionalString(json, 'eventId') ??
          Json.requireString(json, 'event_id'),
      userId: Json.optionalString(json, 'userId') ??
          Json.requireString(json, 'user_id'),
      state: enumFromWire(RegistrationState.values, json['state']) ??
          RegistrationState.registered,
      createdAt: Json.optionalDateTime(json, 'createdAt') ??
          Json.optionalDateTime(json, 'created_at'),
      promotedAt: Json.optionalDateTime(json, 'promotedAt') ??
          Json.optionalDateTime(json, 'promoted_at'),
      cancelledAt: Json.optionalDateTime(json, 'cancelledAt') ??
          Json.optionalDateTime(json, 'cancelled_at'),
    );
  }

  final String id;
  final String eventId;
  final String userId;
  final RegistrationState state;
  final DateTime? createdAt;
  final DateTime? promotedAt;
  final DateTime? cancelledAt;

  bool get isActive => state != RegistrationState.cancelled;
  bool get wasPromotedFromWaitlist => promotedAt != null;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'eventId': eventId,
        'userId': userId,
        'state': state.wire,
        'createdAt': Json.encodeDateTime(createdAt),
        'promotedAt': Json.encodeDateTime(promotedAt),
        'cancelledAt': Json.encodeDateTime(cancelledAt),
      };
}
