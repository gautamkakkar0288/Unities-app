import 'enums.dart';
import 'json.dart';
import 'wire_enum.dart';

/// A community (`communities` table).
///
/// [memberCount] is a denormalised counter on the row, so the app displays it
/// and never computes it. [verification] is what earns the verified mark in the
/// UI — always alongside a label or icon, never colour alone.
class Community {
  const Community({
    required this.id,
    required this.slug,
    required this.name,
    required this.tagline,
    required this.kind,
    required this.scope,
    required this.joinPolicy,
    required this.verification,
    required this.memberCount,
    required this.interestId,
    this.about,
    this.guidelines = const <String>[],
    this.placeId,
    this.createdById,
    this.createdAt,
    this.archivedAt,
    this.viewerMembership,
  });

  factory Community.fromJson(Map<String, Object?> json) {
    return Community(
      id: Json.requireString(json, 'id'),
      slug: Json.requireString(json, 'slug'),
      name: Json.requireString(json, 'name'),
      tagline: Json.optionalString(json, 'tagline') ?? '',
      kind: enumFromWire(CommunityKind.values, json['kind']) ??
          CommunityKind.student,
      scope: enumFromWire(CommunityScope.values, json['scope']) ??
          CommunityScope.university,
      joinPolicy: enumFromWire(JoinPolicy.values, json['joinPolicy']) ??
          enumFromWire(JoinPolicy.values, json['join_policy']) ??
          JoinPolicy.open,
      verification:
          enumFromWire(VerificationState.values, json['verification']) ??
              VerificationState.unverified,
      memberCount: Json.optionalInt(json, 'memberCount') ??
          Json.optionalInt(json, 'member_count') ??
          0,
      interestId: Json.optionalString(json, 'interestId') ??
          Json.optionalString(json, 'interest_id') ??
          '',
      about: Json.optionalString(json, 'about'),
      guidelines: Json.stringList(json, 'guidelines'),
      placeId: Json.optionalString(json, 'placeId') ??
          Json.optionalString(json, 'place_id'),
      createdById: Json.optionalString(json, 'createdById') ??
          Json.optionalString(json, 'created_by_id'),
      createdAt: Json.optionalDateTime(json, 'createdAt') ??
          Json.optionalDateTime(json, 'created_at'),
      archivedAt: Json.optionalDateTime(json, 'archivedAt') ??
          Json.optionalDateTime(json, 'archived_at'),
      viewerMembership:
          enumFromWire(MembershipState.values, json['viewerMembership']),
    );
  }

  final String id;
  final String slug;
  final String name;
  final String tagline;
  final CommunityKind kind;
  final CommunityScope scope;
  final JoinPolicy joinPolicy;
  final VerificationState verification;
  final int memberCount;
  final String interestId;
  final String? about;
  final List<String> guidelines;

  /// University or city this community belongs to; null for global/interest
  /// scope.
  final String? placeId;
  final String? createdById;
  final DateTime? createdAt;
  final DateTime? archivedAt;

  /// The current student's membership state, when the response includes it.
  /// Decides whether the card offers Join, Requested, or Open.
  final MembershipState? viewerMembership;

  bool get isArchived => archivedAt != null;
  bool get isVerified => verification.isVerified;
  bool get viewerHasJoined => viewerMembership?.isJoined ?? false;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'slug': slug,
        'name': name,
        'tagline': tagline,
        'kind': kind.wire,
        'scope': scope.wire,
        'joinPolicy': joinPolicy.wire,
        'verification': verification.wire,
        'memberCount': memberCount,
        'interestId': interestId,
        'about': about,
        'guidelines': guidelines,
        'placeId': placeId,
        'createdById': createdById,
        'createdAt': Json.encodeDateTime(createdAt),
        'archivedAt': Json.encodeDateTime(archivedAt),
        'viewerMembership': viewerMembership?.wire,
      };
}
