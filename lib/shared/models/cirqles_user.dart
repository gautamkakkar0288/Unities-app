import 'enums.dart';
import 'json.dart';
import 'wire_enum.dart';

/// The signed-in user as the **Auth.js session** exposes it.
///
/// This is deliberately narrow. `auth.ts` in the Unities repository adds only
/// `id` and `role` to the default session payload, so those five fields plus
/// the expiry are all the app can honestly claim to know after sign-in.
/// University affiliation, interests, communities and badges live on the
/// `users` row and have no endpoint yet — see [CirqlesUser] and
/// `MissingCapabilities.profile`.
class SessionUser {
  const SessionUser({
    required this.id,
    required this.role,
    this.name,
    this.email,
    this.imageUrl,
  });

  factory SessionUser.fromJson(Map<String, Object?> json) {
    return SessionUser(
      id: Json.requireString(json, 'id'),
      // Absent role would be a backend contract change; default to the least
      // privileged rather than guessing upward.
      role: enumFromWire(UserRole.values, json['role']) ?? UserRole.student,
      name: Json.optionalString(json, 'name'),
      email: Json.optionalString(json, 'email'),
      imageUrl: Json.optionalString(json, 'image'),
    );
  }

  final String id;
  final UserRole role;
  final String? name;
  final String? email;
  final String? imageUrl;

  /// For avatars when there is no image. Falls back to the email local part,
  /// then to a neutral glyph — never to a random colour or emoji.
  String get initials {
    final source = (name ?? email ?? '').trim();
    if (source.isEmpty) return '•';
    final parts = source.split(RegExp(r'[\s.@_-]+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '•';
    if (parts.length == 1) return parts.first.characters1();
    return '${parts.first.characters1()}${parts.elementAt(1).characters1()}';
  }

  String get displayName => name ?? email?.split('@').first ?? 'Student';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'role': role.wire,
        'name': name,
        'email': email,
        'image': imageUrl,
      };
}

extension on String {
  String characters1() => substring(0, 1).toUpperCase();
}

/// The full `users` row.
///
/// Modelled from `lib/db/schema/users.ts`: id, name, email, emailVerified,
/// image, role, universityId, createdAt. `passwordHash` exists in the schema
/// and is intentionally absent here — it must never leave the server.
///
/// Nothing populates this yet. It is defined now because the moment a profile
/// endpoint exists, this is the shape it returns, and screens can be written
/// against it without inventing fields.
class CirqlesUser {
  const CirqlesUser({
    required this.id,
    required this.email,
    required this.role,
    this.name,
    this.emailVerifiedAt,
    this.imageUrl,
    this.universityId,
    this.createdAt,
  });

  factory CirqlesUser.fromJson(Map<String, Object?> json) {
    return CirqlesUser(
      id: Json.requireString(json, 'id'),
      email: Json.requireString(json, 'email'),
      role: enumFromWire(UserRole.values, json['role']) ?? UserRole.student,
      name: Json.optionalString(json, 'name'),
      emailVerifiedAt: Json.optionalDateTime(json, 'emailVerified') ??
          Json.optionalDateTime(json, 'email_verified'),
      imageUrl: Json.optionalString(json, 'image'),
      universityId: Json.optionalString(json, 'universityId') ??
          Json.optionalString(json, 'university_id'),
      createdAt: Json.optionalDateTime(json, 'createdAt') ??
          Json.optionalDateTime(json, 'created_at'),
    );
  }

  final String id;
  final String email;
  final UserRole role;
  final String? name;

  /// Null until the student redeems the verification link. This *is* university
  /// verification in the current backend: sign-up only accepts an address whose
  /// domain matches a university, and the email proves they hold it.
  final DateTime? emailVerifiedAt;
  final String? imageUrl;

  /// FK to `places.id` where kind is UNIVERSITY.
  final String? universityId;
  final DateTime? createdAt;

  bool get isEmailVerified => emailVerifiedAt != null;
  bool get hasUniversity => universityId != null;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'email': email,
        'role': role.wire,
        'name': name,
        'emailVerified': Json.encodeDateTime(emailVerifiedAt),
        'image': imageUrl,
        'universityId': universityId,
        'createdAt': Json.encodeDateTime(createdAt),
      };
}
