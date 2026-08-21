import 'dart:ui' show Color;

/// A meaning token, not a colour.
///
/// The web design system ships every semantic colour as a quartet
/// (`--color-success`, `--color-success-foreground`, `--color-success-subtle`,
/// `--color-success-border`). Keeping them together is what stops a widget
/// pairing a subtle background with a base foreground and failing contrast.
class SemanticColor {
  const SemanticColor({
    required this.base,
    required this.foreground,
    required this.subtle,
    required this.border,
  });

  /// The saturated colour: icons, fills, active indicators.
  final Color base;

  /// Text/icon colour to use *on top of* [subtle].
  final Color foreground;

  /// Tinted surface for chips, callouts and badges.
  final Color subtle;

  /// Border for a [subtle] surface.
  final Color border;

  static SemanticColor lerp(SemanticColor a, SemanticColor b, double t) {
    return SemanticColor(
      base: Color.lerp(a.base, b.base, t)!,
      foreground: Color.lerp(a.foreground, b.foreground, t)!,
      subtle: Color.lerp(a.subtle, b.subtle, t)!,
      border: Color.lerp(a.border, b.border, t)!,
    );
  }
}
