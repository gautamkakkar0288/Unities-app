import 'package:flutter/material.dart';

import 'color_tokens.dart';
import 'semantic_color.dart';

/// Meaning tokens, carried on the [ThemeData] so no widget has to import the
/// palette. Read with `CirqlesColors.of(context)`.
///
/// [ColorScheme] owns neutral chrome (surfaces, outlines, primary action).
/// This extension owns *status*: verified, pending, cancelled, featured,
/// nearly-full. DESIGN_SYSTEM.md §3 forbids status colour being the only
/// signal, so every widget that uses these also carries an icon or a label.
@immutable
class CirqlesColors extends ThemeExtension<CirqlesColors> {
  const CirqlesColors({
    required this.brand,
    required this.support,
    required this.featured,
    required this.success,
    required this.warning,
    required this.info,
    required this.danger,
    required this.skeletonBase,
    required this.skeletonHighlight,
  });

  factory CirqlesColors.light() => CirqlesColors(
        brand: ColorTokens.primary,
        support: ColorTokens.support,
        featured: ColorTokens.featured,
        success: ColorTokens.success,
        warning: ColorTokens.warning,
        info: ColorTokens.info,
        danger: ColorTokens.danger,
        skeletonBase: ColorTokens.muted,
        skeletonHighlight: ColorTokens.card,
      );

  factory CirqlesColors.dark() => CirqlesColors(
        brand: ColorTokens.darkPrimary,
        support: ColorTokens.darkSupport,
        featured: ColorTokens.darkFeatured,
        success: ColorTokens.darkSuccess,
        warning: ColorTokens.darkWarning,
        info: ColorTokens.darkInfo,
        danger: ColorTokens.darkDanger,
        skeletonBase: ColorTokens.darkMuted,
        skeletonHighlight: ColorTokens.darkCard,
      );

  final SemanticColor brand;
  final SemanticColor support;
  final SemanticColor featured;
  final SemanticColor success;
  final SemanticColor warning;
  final SemanticColor info;
  final SemanticColor danger;
  final Color skeletonBase;
  final Color skeletonHighlight;

  static CirqlesColors of(BuildContext context) {
    final colors = Theme.of(context).extension<CirqlesColors>();
    assert(colors != null, 'CirqlesColors missing: use AppTheme.light()/dark()');
    return colors ?? CirqlesColors.light();
  }

  @override
  CirqlesColors copyWith({
    SemanticColor? brand,
    SemanticColor? support,
    SemanticColor? featured,
    SemanticColor? success,
    SemanticColor? warning,
    SemanticColor? info,
    SemanticColor? danger,
    Color? skeletonBase,
    Color? skeletonHighlight,
  }) {
    return CirqlesColors(
      brand: brand ?? this.brand,
      support: support ?? this.support,
      featured: featured ?? this.featured,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      danger: danger ?? this.danger,
      skeletonBase: skeletonBase ?? this.skeletonBase,
      skeletonHighlight: skeletonHighlight ?? this.skeletonHighlight,
    );
  }

  @override
  CirqlesColors lerp(covariant CirqlesColors? other, double t) {
    if (other == null) return this;
    return CirqlesColors(
      brand: SemanticColor.lerp(brand, other.brand, t),
      support: SemanticColor.lerp(support, other.support, t),
      featured: SemanticColor.lerp(featured, other.featured, t),
      success: SemanticColor.lerp(success, other.success, t),
      warning: SemanticColor.lerp(warning, other.warning, t),
      info: SemanticColor.lerp(info, other.info, t),
      danger: SemanticColor.lerp(danger, other.danger, t),
      skeletonBase: Color.lerp(skeletonBase, other.skeletonBase, t)!,
      skeletonHighlight:
          Color.lerp(skeletonHighlight, other.skeletonHighlight, t)!,
    );
  }
}
