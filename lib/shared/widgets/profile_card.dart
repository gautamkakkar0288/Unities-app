import 'package:flutter/material.dart';

import '../../app/theme/sizing.dart';
import '../../app/theme/spacing.dart';
import '../models/cirqles_user.dart';
import 'status_chip.dart';
import 'surface_card.dart';
import 'user_avatar.dart';

/// Identity header for the profile tab.
///
/// Shows only what the session actually contains — name, email, role — plus
/// university affiliation *when* it is known. It is not known today: the
/// Auth.js session payload does not include `universityId`, and there is no
/// profile endpoint. Rather than print a plausible campus name, the caller
/// passes null and the row is omitted.
class ProfileCard extends StatelessWidget {
  const ProfileCard({
    required this.user,
    this.universityName,
    this.isVerifiedStudent,
    super.key,
  });

  final SessionUser user;
  final String? universityName;

  /// Null means “unknown”, which is different from “unverified” and is
  /// rendered differently.
  final bool? isVerifiedStudent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SurfaceCard(
      padding: const EdgeInsets.all(Spacing.mdPlus),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              UserAvatar(
                initials: user.initials,
                imageUrl: user.imageUrl,
                size: Sizing.avatarLg,
                semanticLabel: user.displayName,
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      user.displayName,
                      style: theme.textTheme.headlineMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (user.email != null) ...<Widget>[
                      const SizedBox(height: Spacing.xxs),
                      Text(
                        user.email!,
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Wrap(
            spacing: Spacing.sm,
            runSpacing: Spacing.sm,
            children: <Widget>[
              StatusChip(
                label: user.role.label,
                tone: StatusTone.brand,
                icon: Icons.badge_outlined,
              ),
              if (universityName != null)
                StatusChip(
                  label: universityName!,
                  tone: StatusTone.support,
                  icon: Icons.school_outlined,
                ),
              if (isVerifiedStudent == true)
                const StatusChip(
                  label: 'Verified student',
                  tone: StatusTone.success,
                  icon: Icons.verified_user_outlined,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
