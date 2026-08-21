import 'package:flutter/material.dart';

import 'oklch.dart';

/// Elevation (docs/DESIGN/09-Elevation-System.md).
///
/// Soft and restrained: higher elevation means higher interruption, not more
/// decoration. Shadows are shadow-colour translations of the web tokens.
class Elevations {
  const Elevations._();

  static final Color _shadow = oklch(0.2, 0.02, 260);

  /// Resting content surface.
  static List<BoxShadow> get card => <BoxShadow>[
        BoxShadow(
          color: _shadow.withValues(alpha: 0.04),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
        BoxShadow(
          color: _shadow.withValues(alpha: 0.06),
          blurRadius: 3,
          offset: const Offset(0, 1),
        ),
      ];

  /// Floating panel: bottom navigation, sticky headers.
  static List<BoxShadow> get panel => <BoxShadow>[
        BoxShadow(
          color: _shadow.withValues(alpha: 0.08),
          blurRadius: 12,
          spreadRadius: -2,
          offset: const Offset(0, 4),
        ),
      ];

  /// Dialogs and modal sheets.
  static List<BoxShadow> get dialog => <BoxShadow>[
        BoxShadow(
          color: _shadow.withValues(alpha: 0.16),
          blurRadius: 40,
          spreadRadius: -8,
          offset: const Offset(0, 16),
        ),
      ];
}
