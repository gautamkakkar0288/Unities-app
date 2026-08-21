import '../../shared/models/app_notification.dart';
import '../../shared/models/community.dart';
import '../../shared/models/enums.dart';
import '../../shared/models/event.dart';

/// Development-only placeholder content.
///
/// This exists for exactly one reason: several screens have no endpoint to call
/// yet, and reviewing layout, typography and status treatments against three
/// empty states is impossible. It is gated behind `CIRQLES_USE_SAMPLE_CONTENT`,
/// force-disabled in production builds by [AppConfig], and every card rendered
/// from it is visibly labelled “Sample” in the UI.
///
/// It is not a mock server, it does not imitate endpoint shapes, and no
/// production code path can reach it.
class SampleContent {
  const SampleContent._();

  static DateTime _inHours(int hours) =>
      DateTime.now().toUtc().add(Duration(hours: hours));

  static List<Community> communities() => <Community>[
        Community(
          id: 'sample-community-1',
          slug: 'design-collective',
          name: 'Design Collective',
          tagline: 'Critique nights, portfolio reviews and studio visits.',
          kind: CommunityKind.student,
          scope: CommunityScope.university,
          joinPolicy: JoinPolicy.open,
          verification: VerificationState.verified,
          memberCount: 412,
          interestId: 'sample-interest-design',
          viewerMembership: MembershipState.member,
        ),
        Community(
          id: 'sample-community-2',
          slug: 'quiz-society',
          name: 'Quiz Society',
          tagline: 'Weekly quizzes and inter-college tournaments.',
          kind: CommunityKind.official,
          scope: CommunityScope.university,
          joinPolicy: JoinPolicy.approval,
          verification: VerificationState.verified,
          memberCount: 1280,
          interestId: 'sample-interest-quiz',
        ),
        Community(
          id: 'sample-community-3',
          slug: 'campus-runners',
          name: 'Campus Runners',
          tagline: 'Sunrise runs, half-marathon training, zero judgement.',
          kind: CommunityKind.interest,
          scope: CommunityScope.city,
          joinPolicy: JoinPolicy.open,
          verification: VerificationState.unverified,
          memberCount: 96,
          interestId: 'sample-interest-fitness',
        ),
      ];

  static List<Event> events() => <Event>[
        Event(
          id: 'sample-event-1',
          slug: 'portfolio-review-night',
          title: 'Portfolio Review Night',
          kind: EventKind.workshop,
          mode: EventMode.inPerson,
          status: EventStatus.published,
          startsAt: _inHours(20),
          endsAt: _inHours(22),
          registeredCount: 46,
          capacity: 50,
          communityId: 'sample-community-1',
          interestId: 'sample-interest-design',
          venue: 'Studio 3, Design Block',
          description:
              'Bring three pieces. Seniors and two visiting designers review '
              'in small groups.',
        ),
        Event(
          id: 'sample-event-2',
          slug: 'inter-college-quiz-finals',
          title: 'Inter-college Quiz Finals',
          kind: EventKind.tournament,
          mode: EventMode.hybrid,
          status: EventStatus.published,
          startsAt: _inHours(52),
          endsAt: _inHours(56),
          registeredCount: 210,
          communityId: 'sample-community-2',
          interestId: 'sample-interest-quiz',
          venue: 'Central Auditorium',
          feeInPaise: 15000,
          viewerRegistrationState: RegistrationState.registered,
        ),
        Event(
          id: 'sample-event-3',
          slug: 'sunrise-long-run',
          title: 'Sunrise Long Run',
          kind: EventKind.meetup,
          mode: EventMode.inPerson,
          status: EventStatus.published,
          startsAt: _inHours(30),
          endsAt: _inHours(32),
          registeredCount: 18,
          capacity: 40,
          communityId: 'sample-community-3',
          interestId: 'sample-interest-fitness',
          venue: 'North Gate',
        ),
      ];

  static List<AppNotification> notifications() => <AppNotification>[
        AppNotification(
          id: 'sample-notification-1',
          userId: 'sample-user',
          kind: NotificationKind.eventReminder,
          title: 'Portfolio Review Night starts tomorrow',
          body: 'Studio 3, Design Block · 6:30 pm',
          targetKind: TargetKind.event,
          targetId: 'sample-event-1',
          createdAt: _inHours(-2),
        ),
        AppNotification(
          id: 'sample-notification-2',
          userId: 'sample-user',
          kind: NotificationKind.membership,
          title: 'Quiz Society approved your request',
          body: 'You can now post and register for member-only events.',
          targetKind: TargetKind.community,
          targetId: 'sample-community-2',
          createdAt: _inHours(-26),
        ),
        AppNotification(
          id: 'sample-notification-3',
          userId: 'sample-user',
          kind: NotificationKind.communityPost,
          title: 'New post in Campus Runners',
          body: 'Route change for Sunday: meeting at North Gate instead.',
          targetKind: TargetKind.community,
          targetId: 'sample-community-3',
          readAt: DateTime.now().toUtc(),
          createdAt: _inHours(-50),
        ),
      ];

  static String communityNameFor(String communityId) {
    for (final community in communities()) {
      if (community.id == communityId) return community.name;
    }
    return 'Cirqles community';
  }
}
