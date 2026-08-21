import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router/routes.dart';
import '../../../app/theme/spacing.dart';
import '../../../shared/widgets/async_section.dart';
import '../../../shared/widgets/cirqles_app_bar.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/event_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../events/data/event_providers.dart';
import '../../sample/sample_content.dart';

/// Home: what is happening next, for this student.
///
/// Calm rather than noisy — no infinite scroll of strangers, no engagement
/// metrics. Events come first because that is the thing a student acts on
/// today, and each one names the community hosting it.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider);
    final config = ref.watch(appConfigProvider);
    final events = ref.watch(upcomingEventsProvider);
    final name = session.user?.displayName;

    return Scaffold(
      appBar: CirqlesAppBar(
        eyebrow: _greeting(),
        title: name == null ? 'Cirqles' : _firstName(name),
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () async => ref.refresh(upcomingEventsProvider.future),
          child: ListView(
            padding: const EdgeInsets.only(
              left: Spacing.pageGutter,
              right: Spacing.pageGutter,
              top: Spacing.sm,
              bottom: Spacing.bottomActionInset,
            ),
            children: <Widget>[
              const SectionHeader(
                title: 'Happening soon',
                subtitle: 'Events from the circles you are part of',
              ),
              AsyncSection(
                value: events,
                onRetry: () => ref.invalidate(upcomingEventsProvider),
                builder: (page) {
                  if (page.items.isEmpty) {
                    return const EmptyState(
                      icon: Icons.event_available_outlined,
                      title: 'Nothing on yet',
                      message: 'When your communities publish events, they '
                          'show up here first.',
                    );
                  }
                  return Column(
                    children: <Widget>[
                      for (final event in page.items)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: Spacing.smPlus,
                          ),
                          child: EventCard(
                            event: event,
                            isSample: config.useSampleContent,
                            communityName: config.useSampleContent
                                ? SampleContent.communityNameFor(
                                    event.communityId,
                                  )
                                : null,
                            onTap: () => context.push(
                              Routes.eventPath(event.slug),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _firstName(String displayName) => displayName.split(' ').first;
}
