import 'enums.dart';
import 'json.dart';
import 'wire_enum.dart';

/// An in-app notification (`notifications` table).
///
/// Named `AppNotification` to avoid colliding with Flutter's `Notification`.
/// Read state is a nullable timestamp on the row, not a boolean, so [isUnread]
/// derives from it rather than duplicating a flag.
///
/// [targetKind] and [targetId] are what a tap resolves into a deep link.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.userId,
    required this.kind,
    required this.title,
    required this.body,
    this.targetKind,
    this.targetId,
    this.readAt,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, Object?> json) {
    return AppNotification(
      id: Json.requireString(json, 'id'),
      userId: Json.optionalString(json, 'userId') ??
          Json.optionalString(json, 'user_id') ??
          '',
      kind: enumFromWire(NotificationKind.values, json['kind']) ??
          NotificationKind.activity,
      title: Json.requireString(json, 'title'),
      body: Json.optionalString(json, 'body') ?? '',
      targetKind: enumFromWire(TargetKind.values, json['targetKind']) ??
          enumFromWire(TargetKind.values, json['target_kind']),
      targetId: Json.optionalString(json, 'targetId') ??
          Json.optionalString(json, 'target_id'),
      readAt: Json.optionalDateTime(json, 'readAt') ??
          Json.optionalDateTime(json, 'read_at'),
      createdAt: Json.optionalDateTime(json, 'createdAt') ??
          Json.optionalDateTime(json, 'created_at') ??
          DateTime.now().toUtc(),
    );
  }

  final String id;
  final String userId;
  final NotificationKind kind;
  final String title;
  final String body;
  final TargetKind? targetKind;
  final String? targetId;
  final DateTime? readAt;
  final DateTime createdAt;

  bool get isUnread => readAt == null;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'userId': userId,
        'kind': kind.wire,
        'title': title,
        'body': body,
        'targetKind': targetKind?.wire,
        'targetId': targetId,
        'readAt': Json.encodeDateTime(readAt),
        'createdAt': Json.encodeDateTime(createdAt),
      };
}
