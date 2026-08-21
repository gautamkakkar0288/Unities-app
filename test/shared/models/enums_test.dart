import 'package:cirqles/shared/models/enums.dart';
import 'package:cirqles/shared/models/wire_enum.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('enumFromWire', () {
    test('maps the exact wire values used by the Cirqles schema', () {
      expect(
        enumFromWire(UserRole.values, 'COMMUNITY_MODERATOR'),
        UserRole.communityModerator,
      );
      expect(
        enumFromWire(MembershipState.values, 'OWNER'),
        MembershipState.owner,
      );
      expect(
        enumFromWire(NotificationKind.values, 'EVENT_REMINDER'),
        NotificationKind.eventReminder,
      );
    });

    test('returns null for unknown or missing values', () {
      expect(enumFromWire(EventMode.values, 'TELEPATHY'), isNull);
      expect(enumFromWire(EventMode.values, null), isNull);
      expect(enumFromWire(EventMode.values, 42), isNull);
    });
  });

  group('role privileges', () {
    test('are ordered least to most privileged', () {
      expect(UserRole.student.canOrganise, isFalse);
      expect(UserRole.organizer.canOrganise, isTrue);
      expect(UserRole.organizer.canModerate, isFalse);
      expect(UserRole.platformAdmin.canModerate, isTrue);
      expect(UserRole.universityAdmin.isAtLeast(UserRole.organizer), isTrue);
    });
  });

  test('membership states that grant member-only access', () {
    expect(MembershipState.invited.isJoined, isFalse);
    expect(MembershipState.pending.isJoined, isFalse);
    expect(MembershipState.member.isJoined, isTrue);
    expect(MembershipState.moderator.isJoined, isTrue);
    expect(MembershipState.owner.isJoined, isTrue);
  });

  test('every enum value has a non-empty wire value', () {
    final all = <WireEnum>[
      ...UserRole.values,
      ...PlaceKind.values,
      ...PlaceStatus.values,
      ...CommunityKind.values,
      ...CommunityScope.values,
      ...JoinPolicy.values,
      ...MembershipState.values,
      ...EventKind.values,
      ...EventMode.values,
      ...EventStatus.values,
      ...RegistrationState.values,
      ...NotificationKind.values,
      ...TargetKind.values,
      ...VerificationState.values,
      ...ReviewStatus.values,
    ];

    for (final value in all) {
      expect(value.wire, isNotEmpty);
      expect(value.wire, value.wire.toUpperCase());
    }
  });
}
