import 'enums.dart';
import 'json.dart';
import 'wire_enum.dart';

/// A university or city (`places` table).
///
/// The backend calls this a *place*, not a *university*, because cities are the
/// same entity with a different [kind]. The app keeps that vocabulary so the
/// two codebases stay talkable.
///
/// [emailDomain] is the university verification rule: sign-up matches the
/// address domain against it. It is enforced on the server; the app only uses
/// it to explain the rule to the student.
class Place {
  const Place({
    required this.id,
    required this.kind,
    required this.name,
    required this.slug,
    required this.status,
    this.parentPlaceId,
    this.emailDomain,
    this.createdAt,
  });

  factory Place.fromJson(Map<String, Object?> json) {
    return Place(
      id: Json.requireString(json, 'id'),
      kind: enumFromWire(PlaceKind.values, json['kind']) ?? PlaceKind.university,
      name: Json.requireString(json, 'name'),
      slug: Json.requireString(json, 'slug'),
      status:
          enumFromWire(PlaceStatus.values, json['status']) ?? PlaceStatus.active,
      parentPlaceId: Json.optionalString(json, 'parentPlaceId') ??
          Json.optionalString(json, 'parent_place_id'),
      emailDomain: Json.optionalString(json, 'emailDomain') ??
          Json.optionalString(json, 'email_domain'),
      createdAt: Json.optionalDateTime(json, 'createdAt') ??
          Json.optionalDateTime(json, 'created_at'),
    );
  }

  final String id;
  final PlaceKind kind;
  final String name;
  final String slug;
  final PlaceStatus status;

  /// A university's city, when set.
  final String? parentPlaceId;
  final String? emailDomain;
  final DateTime? createdAt;

  bool get isUniversity => kind == PlaceKind.university;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'kind': kind.wire,
        'name': name,
        'slug': slug,
        'status': status.wire,
        'parentPlaceId': parentPlaceId,
        'emailDomain': emailDomain,
        'createdAt': Json.encodeDateTime(createdAt),
      };
}
