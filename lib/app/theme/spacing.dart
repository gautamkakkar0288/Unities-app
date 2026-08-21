/// Spacing scale (docs/DESIGN/04-Spacing-&-Layout.md).
///
/// Named by step, not by pixel, so a screen reads `Spacing.lg` and a token
/// change is one edit here. A literal `EdgeInsets.all(13)` in a widget is a
/// review comment.
class Spacing {
  const Spacing._();

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double smPlus = 12;
  static const double md = 16;
  static const double mdPlus = 20;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 40;
  static const double xxxl = 48;

  /// Horizontal page gutter on phones.
  static const double pageGutter = md;

  /// Breathing room above a bottom navigation bar or sticky action.
  static const double bottomActionInset = xxxl + md;
}
