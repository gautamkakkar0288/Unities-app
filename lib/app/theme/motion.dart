import 'package:flutter/animation.dart';

/// Motion (docs/DESIGN/08-Motion-System.md): 150ms–300ms, purposeful, never
/// blocking. Widgets read these instead of inventing durations.
class Motion {
  const Motion._();

  /// Micro-interactions: press, ripple, chip toggle.
  static const Duration fast = Duration(milliseconds: 150);

  /// State changes: expanding a section, swapping a skeleton for content.
  static const Duration base = Duration(milliseconds: 200);

  /// Screen transitions.
  static const Duration slow = Duration(milliseconds: 300);

  static const Curve standard = Cubic(0.2, 0, 0, 1);
  static const Curve entrance = Cubic(0, 0, 0.2, 1);
  static const Curve exit = Cubic(0.4, 0, 1, 1);
}
