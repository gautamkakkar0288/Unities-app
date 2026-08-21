import 'wire_enum.dart';

/// Platform roles (`user_role` in the Cirqles schema).
///
/// Ordered from least to most privileged so `index` comparisons express
/// “at least this role”. Authorisation itself stays on the server; the app uses
/// roles only to decide what to show.
enum UserRole implements WireEnum {
  student('STUDENT', 'Student'),
  organizer('ORGANIZER', 'Organiser'),
  communityModerator('COMMUNITY_MODERATOR', 'Community moderator'),
  universityAdmin('UNIVERSITY_ADMIN', 'University admin'),
  platformAdmin('PLATFORM_ADMIN', 'Platform admin');

  const UserRole(this.wire, this.label);

  @override
  final String wire;
  final String label;

  bool isAtLeast(UserRole other) => index >= other.index;

  /// Can create events and manage a community's calendar.
  bool get canOrganise => isAtLeast(UserRole.organizer);

  /// Has access to moderation surfaces (not built in this phase).
  bool get canModerate => isAtLeast(UserRole.communityModerator);
}

/// A place is either a university or a city (`place_kind`). Cirqles is
/// multi-university from the schema up; the app must never assume one campus.
enum PlaceKind implements WireEnum {
  university('UNIVERSITY', 'University'),
  city('CITY', 'City');

  const PlaceKind(this.wire, this.label);

  @override
  final String wire;
  final String label;
}

enum PlaceStatus implements WireEnum {
  active('ACTIVE', 'Active'),
  pending('PENDING', 'Pending'),
  suspended('SUSPENDED', 'Suspended');

  const PlaceStatus(this.wire, this.label);

  @override
  final String wire;
  final String label;
}

enum CommunityKind implements WireEnum {
  official('OFFICIAL', 'Official'),
  interest('INTEREST', 'Interest'),
  student('STUDENT', 'Student-led');

  const CommunityKind(this.wire, this.label);

  @override
  final String wire;
  final String label;
}

enum CommunityScope implements WireEnum {
  university('UNIVERSITY', 'University'),
  city('CITY', 'City'),
  interest('INTEREST', 'Interest'),
  global('GLOBAL', 'Global');

  const CommunityScope(this.wire, this.label);

  @override
  final String wire;
  final String label;
}

/// How a student gets in (`join_policy`). Drives which primary action a
/// community card offers: Join, Request to join, or Invite only.
enum JoinPolicy implements WireEnum {
  open('OPEN', 'Open to join'),
  approval('APPROVAL', 'Approval required'),
  invite('INVITE', 'Invite only');

  const JoinPolicy(this.wire, this.label);

  @override
  final String wire;
  final String label;
}

/// Membership lifecycle (`membership_state`).
enum MembershipState implements WireEnum {
  invited('INVITED', 'Invited'),
  pending('PENDING', 'Pending approval'),
  member('MEMBER', 'Member'),
  moderator('MODERATOR', 'Moderator'),
  owner('OWNER', 'Owner');

  const MembershipState(this.wire, this.label);

  @override
  final String wire;
  final String label;

  /// Whether this state grants access to member-only surfaces.
  bool get isJoined =>
      this == MembershipState.member ||
      this == MembershipState.moderator ||
      this == MembershipState.owner;
}

enum EventKind implements WireEnum {
  workshop('WORKSHOP', 'Workshop'),
  talk('TALK', 'Talk'),
  tournament('TOURNAMENT', 'Tournament'),
  performance('PERFORMANCE', 'Performance'),
  trip('TRIP', 'Trip'),
  meetup('MEETUP', 'Meetup'),
  drive('DRIVE', 'Drive');

  const EventKind(this.wire, this.label);

  @override
  final String wire;
  final String label;
}

enum EventMode implements WireEnum {
  inPerson('IN_PERSON', 'In person'),
  online('ONLINE', 'Online'),
  hybrid('HYBRID', 'Hybrid');

  const EventMode(this.wire, this.label);

  @override
  final String wire;
  final String label;
}

enum EventStatus implements WireEnum {
  draft('DRAFT', 'Draft'),
  published('PUBLISHED', 'Published'),
  cancelled('CANCELLED', 'Cancelled');

  const EventStatus(this.wire, this.label);

  @override
  final String wire;
  final String label;
}

/// Registration lifecycle (`registration_state`). Waitlisting is a first-class
/// state in the schema, so the app treats it as a normal outcome of
/// registering, not an error.
enum RegistrationState implements WireEnum {
  registered('REGISTERED', 'Registered'),
  waitlisted('WAITLISTED', 'Waitlisted'),
  cancelled('CANCELLED', 'Cancelled');

  const RegistrationState(this.wire, this.label);

  @override
  final String wire;
  final String label;
}

enum NotificationKind implements WireEnum {
  eventReminder('EVENT_REMINDER', 'Event reminder'),
  communityPost('COMMUNITY_POST', 'Community post'),
  mention('MENTION', 'Mention'),
  membership('MEMBERSHIP', 'Membership'),
  moderation('MODERATION', 'Moderation'),
  activity('ACTIVITY', 'Activity');

  const NotificationKind(this.wire, this.label);

  @override
  final String wire;
  final String label;
}

/// What a notification or audit entry points at (`audit_target_kind`). Used to
/// resolve a notification tap into a deep link.
enum TargetKind implements WireEnum {
  post('POST'),
  comment('COMMENT'),
  event('EVENT'),
  community('COMMUNITY'),
  activity('ACTIVITY'),
  user('USER');

  const TargetKind(this.wire);

  @override
  final String wire;
}

/// Verification lifecycle for communities and organisers
/// (`verification_state`).
enum VerificationState implements WireEnum {
  unverified('UNVERIFIED', 'Unverified'),
  pending('PENDING', 'Verification pending'),
  verified('VERIFIED', 'Verified');

  const VerificationState(this.wire, this.label);

  @override
  final String wire;
  final String label;

  bool get isVerified => this == VerificationState.verified;
}

enum ReviewStatus implements WireEnum {
  pending('PENDING', 'Pending'),
  approved('APPROVED', 'Approved'),
  rejected('REJECTED', 'Rejected'),
  merged('MERGED', 'Merged');

  const ReviewStatus(this.wire, this.label);

  @override
  final String wire;
  final String label;
}
