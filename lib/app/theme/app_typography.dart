import 'package:flutter/material.dart';

/// Typographic roles from DESIGN_SYSTEM.md §2, mapped onto Material's
/// [TextTheme] slots so stock widgets inherit them.
///
/// The web scale is fluid (`clamp()`); on phones it always resolves to the
/// small end of each clamp, so those are the values used here. Sizes are in
/// logical pixels and scale with the platform text-size setting because no
/// widget locks `textScaler`.
class AppTypography {
  const AppTypography._();

  static const List<String> _fallback = <String>[
    'Inter',
    'SF Pro Text',
    'Roboto',
  ];

  static TextTheme textTheme(Color foreground, Color muted) {
    TextStyle style({
      required double size,
      required double height,
      FontWeight weight = FontWeight.w400,
      double letterSpacing = 0,
      Color? color,
    }) {
      return TextStyle(
        fontSize: size,
        height: height,
        fontWeight: weight,
        letterSpacing: letterSpacing,
        color: color ?? foreground,
        fontFamilyFallback: _fallback,
      );
    }

    return TextTheme(
      // Display — marketing and launch moments only.
      displayLarge: style(
        size: 40,
        height: 1.05,
        weight: FontWeight.w700,
        letterSpacing: -1.2,
      ),
      // Heading
      headlineLarge: style(
        size: 30,
        height: 1.15,
        weight: FontWeight.w600,
        letterSpacing: -0.6,
      ),
      headlineMedium: style(
        size: 24,
        height: 1.2,
        weight: FontWeight.w600,
        letterSpacing: -0.36,
      ),
      titleLarge: style(
        size: 20,
        height: 1.3,
        weight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      // Subheading — card groups.
      titleMedium: style(size: 17, height: 1.4, weight: FontWeight.w600),
      // Body
      bodyLarge: style(size: 17, height: 1.65),
      bodyMedium: style(size: 15, height: 1.6),
      bodySmall: style(size: 14, height: 1.55, color: muted),
      // Caption — metadata and timestamps.
      labelSmall: style(size: 13, height: 1.45, color: muted),
      // Label — buttons, tabs, badges, inputs.
      labelLarge: style(size: 14, height: 1.2, weight: FontWeight.w500),
      labelMedium: style(size: 14, height: 1.2, weight: FontWeight.w500),
    );
  }
}
