/// Icon, avatar and touch-target sizes.
///
/// [minTouchTarget] is 48dp rather than 44dp: Material's accessibility floor is
/// the stricter of the two guidelines the design system points at, and a
/// student tapping a Save button on a bus should not have to aim.
class Sizing {
  const Sizing._();

  static const double minTouchTarget = 48;

  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double iconLg = 24;

  static const double avatarSm = 28;
  static const double avatarMd = 40;
  static const double avatarLg = 64;

  static const double bottomNavHeight = 64;

  /// Event and community card media ratio, consistent per card type.
  static const double cardMediaAspectRatio = 16 / 9;

  /// Below this width, secondary metadata rows collapse.
  static const double compactPhoneWidth = 360;
}
