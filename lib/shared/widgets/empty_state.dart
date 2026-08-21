import 'package:flutter/material.dart';

import '../../app/theme/cirqles_colors.dart';
import '../../app/theme/sizing.dart';
import '../../app/theme/spacing.dart';
import 'cirqles_button.dart';

/// Empty states explain and offer a way forward.
///
/// Three flavours matter and they are not interchangeable: nothing exists yet,
/// nothing matched a filter, or the app cannot show this yet because the
/// backend does not expose it. The last one is [EmptyState.notAvailableYet],
/// which names the capability rather than implying the student has no events.
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.footnote,
    super.key,
  });

  /// For a capability the backend does not expose over HTTP yet.
  factory EmptyState.notAvailableYet({
    required String title,
    required String message,
    required String capability,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return EmptyState(
      icon: Icons.construction_rounded,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
      footnote: 'Waiting on backend capability: $capability',
    );
  }

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Small print. Used to state honestly what the app is waiting on.
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = CirqlesColors.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.mdPlus,
        vertical: Spacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: colors.brand.subtle,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: Sizing.iconLg,
              color: colors.brand.base,
            ),
          ),
          const SizedBox(height: Spacing.md),
          Text(
            title,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onAction != null) ...<Widget>[
            const SizedBox(height: Spacing.md),
            PrimaryButton(
              label: actionLabel!,
              onPressed: onAction,
              isFullWidth: false,
            ),
          ],
          if (footnote != null) ...<Widget>[
            const SizedBox(height: Spacing.md),
            Text(
              footnote!,
              style: theme.textTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
