import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router/routes.dart';
import '../../../app/theme/spacing.dart';
import '../../../core/network/api_paths.dart';
import '../../../shared/widgets/async_section.dart';
import '../../../shared/widgets/cirqles_app_bar.dart';
import '../../../shared/widgets/cirqles_text_field.dart';
import '../../../shared/widgets/community_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/section_header.dart';
import '../../communities/data/community_providers.dart';

/// Explore: communities first, then search.
///
/// Communities live here rather than in their own tab, matching the web
/// information architecture (`lib/navigation/config.ts`), so both clients teach
/// students the same mental model. Search is visible but disabled until a query
/// endpoint exists — an input that silently returns nothing is worse than one
/// that says why.
class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final TextEditingController _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(appConfigProvider);
    final communities = ref.watch(discoverCommunitiesProvider);

    return Scaffold(
      appBar: const CirqlesAppBar(
        eyebrow: 'Discover',
        title: 'Explore',
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.only(
            left: Spacing.pageGutter,
            right: Spacing.pageGutter,
            top: Spacing.sm,
            bottom: Spacing.bottomActionInset,
          ),
          children: <Widget>[
            SearchField(
              controller: _query,
              hintText: 'Search communities and events',
              enabled: config.searchEnabled,
            ),
            if (!config.searchEnabled) ...<Widget>[
              const SizedBox(height: Spacing.sm),
              Text(
                'Search is not available in the app yet '
                '(${MissingCapabilities.search}).',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
            const SizedBox(height: Spacing.lg),
            const SectionHeader(
              title: 'Communities',
              subtitle: 'Official societies, student groups and interests',
            ),
            AsyncSection(
              value: communities,
              onRetry: () => ref.invalidate(discoverCommunitiesProvider),
              builder: (page) {
                if (page.items.isEmpty) {
                  return const EmptyState(
                    icon: Icons.groups_2_outlined,
                    title: 'No communities yet',
                    message: 'Communities from your campus will appear here.',
                  );
                }
                return Column(
                  children: <Widget>[
                    for (final community in page.items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: Spacing.smPlus),
                        child: CommunityCard(
                          community: community,
                          isSample: config.useSampleContent,
                          onTap: () => context.push(
                            Routes.communityPath(community.slug),
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
    );
  }
}
