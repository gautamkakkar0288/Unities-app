import 'package:flutter/material.dart';

import '../../app/theme/radii.dart';
import '../../app/theme/sizing.dart';
import '../../app/theme/spacing.dart';
import '../../core/utils/formatters.dart';
import '../models/community.dart';
import '../models/enums.dart';
import 'status_chip.dart';
import 'surface_card.dart';

/// A community in a list.
///
/// The join affordance is derived from [Community.joinPolicy] and the viewer's
/// membership state, because offering “Join” on an invite-only community is a
/// promise the backend will refuse.
class CommunityCard extends StatelessWidget {
  const CommunityCard({
    required this.community,
    this.onTap,
    this.onJoin,
    this.isSample = false,
    super.key,
  });

  final Community community;
  final VoidCallback? onTap;
  final VoidCallback? onJoin;
  final bool isSample;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SurfaceCard(
      onTap: onTap,
      semanticLabel: '${community.name}, '
          '${Formatters.memberCount(community.memberCount)}'
          '${community.isVerified ? ', verified' : ''}',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _CommunityMonogram(community: community),
          const SizedBox(width: Spacing.smPlus),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        community.name,
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (community.isVerified) ...<Widget>[
                      const SizedBox(width: Spacing.xs),
                      // Icon plus tooltip: the mark is not colour-only.
                      Tooltip(
                        message: 'Verified community',
                        child: Icon(
                          Icons.verified_rounded,
                          size: Sizing.iconSm,
                          color: theme.colorScheme.primary,
                          semanticLabel: 'Verified community',
                        ),
                      ),
                    ],
                  ],
                ),
                if (community.tagline.isNotEmpty) ...<Widget>[
                  const SizedBox(height: Spacing.xxs),
                  Text(
                    community.tagline,
                    style: theme.textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: Spacing.sm),
                Wrap(
                  spacing: Spacing.sm,
                  runSpacing: Spacing.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    StatusChip(
                      label: Formatters.memberCount(community.memberCount),
                      icon: Icons.people_outline_rounded,
                    ),
                    StatusChip(
                      label: community.kind.label,
                      tone: StatusTone.support,
                    ),
                    if (isSample)
                      const StatusChip(label: 'Sample'),
                  ],
                ),
              ],
            ),
          ),
          if (onJoin != null && !community.viewerHasJoined) ...<Widget>[
            const SizedBox(width: Spacing.sm),
            TextButton(
              onPressed: onJoin,
              child: Text(_joinLabel(community)),
            ),
          ],
        ],
      ),
    );
  }

  String _joinLabel(Community community) {
    if (community.viewerMembership == MembershipState.pending) {
      return 'Requested';
    }
    return switch (community.joinPolicy) {
      JoinPolicy.open => 'Join',
      JoinPolicy.approval => 'Request',
      JoinPolicy.invite => 'Invite only',
    };
  }
}

/// Communities have no image column in the schema, so identity comes from an
/// initial on a tinted tile rather than a placeholder photo.
class _CommunityMonogram extends StatelessWidget {
  const _CommunityMonogram({required this.community});

  final Community community;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: Sizing.avatarMd,
      width: Sizing.avatarMd,
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: Radii.control,
      ),
      child: Center(
        child: Text(
          community.name.isEmpty
              ? '•'
              : community.name.substring(0, 1).toUpperCase(),
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.secondary,
          ),
        ),
      ),
    );
  }
}
