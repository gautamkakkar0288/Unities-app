import 'package:flutter/material.dart';

import '../../app/theme/elevation.dart';
import '../../app/theme/radii.dart';
import '../../app/theme/spacing.dart';

/// The one card in the app.
///
/// Every card-shaped surface routes through here so radius, border, shadow and
/// press feedback stay identical across events, communities and profiles. New
/// card types compose this rather than re-deriving the treatment.
class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(Spacing.md),
    this.semanticLabel,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: Radii.card,
          border: Border.all(color: scheme.outlineVariant),
          boxShadow: Elevations.card,
        ),
        child: Material(
          type: MaterialType.transparency,
          borderRadius: Radii.card,
          child: InkWell(
            onTap: onTap,
            borderRadius: Radii.card,
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}
