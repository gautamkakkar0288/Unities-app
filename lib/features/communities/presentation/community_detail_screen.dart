import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/community.dart';
import '../../../shared/widgets/async_section.dart';
import '../../../shared/widgets/cirqles_button.dart';
import '../../../shared/widgets/status_chip.dart';
import '../data/community_providers.dart';

/// Community detail, reached by tap or by deep link (`/communities/:slug`).
///
/// Joining is a server action with approval rules and membership counters, so
/// the action is shown in the state the policy implies and disabled, rather
/// than optimistically flipping a local flag.
class CommunityDetailScreen extends ConsumerWidget {
  const CommunityDetailScreen({required this.slug, super.key});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final community = ref.watch(communityBySlugProvider(slug));

    return Scaffold(
      appBar: AppBar(title: const Text('Community')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Spacing.pageGutter),
          child: AsyncSection(
            value: community,
            onRetry: () => ref.invalidate(communityBySlugProvider(slug)),
            builder: (data) => _CommunityDetail(community: data),
          ),
        ),
      ),
    );
  }
}

class _CommunityDetail extends StatelessWidget {
  const _CommunityDetail({required this.community});

  final Community community;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(community.name, style: theme.textTheme.headlineLarge),
        if (community.tagline.isNotEmpty) ...<Widget>[
          const SizedBox(height: Spacing.sm),
          Text(
            community.tagline,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: Spacing.md),
        Wrap(
          spacing: Spacing.sm,
          runSpacing: Spacing.sm,
          children: <Widget>[
            StatusChip(
              label: Formatters.memberCount(community.memberCount),
              icon: Icons.people_outline_rounded,
            ),
            StatusChip(label: community.kind.label, tone: StatusTone.support),
            StatusChip(label: community.scope.label),
            if (community.isVerified)
              const StatusChip(
                label: 'Verified',
                tone: StatusTone.success,
                icon: Icons.verified_rounded,
              ),
          ],
        ),
        if (community.about != null) ...<Widget>[
          const SizedBox(height: Spacing.lg),
          Text('About', style: theme.textTheme.titleMedium),
          const SizedBox(height: Spacing.sm),
          Text(community.about!, style: theme.textTheme.bodyMedium),
        ],
        if (community.guidelines.isNotEmpty) ...<Widget>[
          const SizedBox(height: Spacing.lg),
          Text('Guidelines', style: theme.textTheme.titleMedium),
          const SizedBox(height: Spacing.sm),
          for (final guideline in community.guidelines)
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.xs),
              child: Text(
                '• $guideline',
                style: theme.textTheme.bodyMedium,
              ),
            ),
        ],
        const SizedBox(height: Spacing.xl),
        PrimaryButton(
          label: community.viewerHasJoined ? 'You are a member' : 'Join',
          onPressed: null,
        ),
        const SizedBox(height: Spacing.sm),
        Text(
          'Joining happens on the web for now. Membership approval and member '
          'counts are handled by server actions with no mobile endpoint yet.',
          style: theme.textTheme.labelSmall,
        ),
      ],
    );
  }
}
