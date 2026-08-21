import 'enums.dart';
import 'json.dart';
import 'wire_enum.dart';

/// A student's relationship to a community (`memberships` table).
class Membership {
  const Membership({
    required this.id,
    required this.communityId,
    required this.userId,
    required this.state,
    this.requestedAt,
    this.joinedAt,
    this.invitedById,
    this.decidedById,
    this.decidedAt,
    this.createdAt,
  });

  factory Membership.fromJson(Map<String, Object?> json) {
    return Membership(
      id: Json.requireString(json, 'id'),
      communityId: Json.optionalString(json, 'communityId') ??
          Json.requireString(json, 'community_id'),
      userId: Json.optionalString(json, 'userId') ??
          Json.requireString(json, 'user_id'),
      state: enumFromWire(MembershipState.values, json['state']) ??
          MembershipState.member,
      requestedAt: Json.optionalDateTime(json, 'requestedAt') ??
          Json.optionalDateTime(json, 'requested_at'),
      joinedAt: Json.optionalDateTime(json, 'joinedAt') ??
          Json.optionalDateTime(json, 'joined_at'),
      invitedById: Json.optionalString(json, 'invitedById') ??
          Json.optionalString(json, 'invited_by_id'),
      decidedById: Json.optionalString(json, 'decidedById') ??
          Json.optionalString(json, 'decided_by_id'),
      decidedAt: Json.optionalDateTime(json, 'decidedAt') ??
          Json.optionalDateTime(json, 'decided_at'),
      createdAt: Json.optionalDateTime(json, 'createdAt') ??
          Json.optionalDateTime(json, 'created_at'),
    );
  }

  final String id;
  final String communityId;
  final String userId;
  final MembershipState state;
  final DateTime? requestedAt;
  final DateTime? joinedAt;
  final String? invitedById;
  final String? decidedById;
  final DateTime? decidedAt;
  final DateTime? createdAt;

  bool get isJoined => state.isJoined;
  bool get isAwaitingDecision => state == MembershipState.pending;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'communityId': communityId,
        'userId': userId,
        'state': state.wire,
        'requestedAt': Json.encodeDateTime(requestedAt),
        'joinedAt': Json.encodeDateTime(joinedAt),
        'invitedById': invitedById,
        'decidedById': decidedById,
        'decidedAt': Json.encodeDateTime(decidedAt),
        'createdAt': Json.encodeDateTime(createdAt),
      };
}
