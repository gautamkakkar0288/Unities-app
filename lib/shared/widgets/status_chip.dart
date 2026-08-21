import 'package:flutter/material.dart';

import '../../app/theme/cirqles_colors.dart';
import '../../app/theme/radii.dart';
import '../../app/theme/semantic_color.dart';
import '../../app/theme/sizing.dart';
import '../../app/theme/spacing.dart';

/// Which meaning a chip carries. Kept as a small enum so screens name the
/// *status*, not a colour.
enum StatusTone { neutral, brand, support, featured, success, warning, info, danger }

/// Compact status indicator: Verified, Waitlisted, Almost full, Cancelled.
///
/// Always renders text, and optionally an icon. Colour is never the only
/// signal, which is both an accessibility requirement and the reason this is a
/// component rather than a coloured `Container` per screen.
class StatusChip extends StatelessWidget {
  const StatusChip({
    required this.label,
    this.tone = StatusTone.neutral,
    this.icon,
    super.key,
  });

  final String label;
  final StatusTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = CirqlesColors.of(context);
    final semantic = _resolve(colors, theme.colorScheme);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: semantic.subtle,
        borderRadius: Radii.chip,
        border: Border.all(color: semantic.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: Sizing.iconSm, color: semantic.foreground),
            const SizedBox(width: Spacing.xs),
          ],
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: semantic.foreground,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  SemanticColor _resolve(CirqlesColors colors, ColorScheme scheme) {
    return switch (tone) {
      StatusTone.neutral => SemanticColor(
          base: scheme.onSurfaceVariant,
          foreground: scheme.onSurfaceVariant,
          subtle: scheme.surfaceContainer,
          border: scheme.outlineVariant,
        ),
      StatusTone.brand => colors.brand,
      StatusTone.support => colors.support,
      StatusTone.featured => colors.featured,
      StatusTone.success => colors.success,
      StatusTone.warning => colors.warning,
      StatusTone.info => colors.info,
      StatusTone.danger => colors.danger,
    };
  }
}

/// Count badge for the notifications tab.
class CountBadge extends StatelessWidget {
  const CountBadge({required this.count, super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    final colors = CirqlesColors.of(context);
    final label = count > 99 ? '99+' : '$count';

    return Semantics(
      label: '$count unread',
      child: Container(
        constraints: const BoxConstraints(minWidth: 18),
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.xs,
          vertical: 1,
        ),
        decoration: BoxDecoration(
          color: colors.danger.base,
          borderRadius: Radii.chip,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colors.danger.foreground,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
        ),
      ),
    );
  }
}
