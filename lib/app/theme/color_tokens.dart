import 'package:flutter/material.dart';

import 'oklch.dart';
import 'semantic_color.dart';

/// Cirqles colour tokens.
///
/// Values are transcribed 1:1 from `app/globals.css` in the Unities repository
/// and converted from OKLCH by [oklch]. Light mode is the primary experience;
/// dark mode is a designed system rather than an inversion, exactly as
/// DESIGN_SYSTEM.md §4 requires.
///
/// Widgets must never reach for a raw colour. They read either the
/// [ColorScheme] (chrome) or [CirqlesColors] (meaning).
class ColorTokens {
  const ColorTokens._();

  // --- Light -------------------------------------------------------------

  /// Warm off-white, never stark.
  static final Color background = oklch(0.992, 0.003, 95);
  static final Color foreground = oklch(0.17, 0.012, 260);
  static final Color card = oklch(1, 0, 0);
  static final Color cardForeground = oklch(0.17, 0.012, 260);
  static final Color muted = oklch(0.966, 0.004, 260);
  static final Color mutedForeground = oklch(0.53, 0.014, 260);
  static final Color secondaryForeground = oklch(0.24, 0.012, 260);
  static final Color border = oklch(0.916, 0.005, 260);

  /// Wonder Blue.
  static final SemanticColor primary = SemanticColor(
    base: oklch(0.55, 0.185, 258),
    foreground: oklch(0.99, 0.005, 258),
    subtle: oklch(0.965, 0.022, 258),
    border: oklch(0.88, 0.06, 258),
  );

  /// Soft Indigo — tags, sub-navigation, charts.
  static final SemanticColor support = SemanticColor(
    base: oklch(0.55, 0.16, 288),
    foreground: oklch(0.99, 0.005, 288),
    subtle: oklch(0.965, 0.022, 288),
    border: oklch(0.88, 0.055, 288),
  );

  /// Warm Orange — trending, featured, limited-time. Use sparingly.
  static final SemanticColor featured = SemanticColor(
    base: oklch(0.7, 0.16, 55),
    foreground: oklch(0.26, 0.06, 55),
    subtle: oklch(0.965, 0.035, 65),
    border: oklch(0.87, 0.075, 60),
  );

  static final SemanticColor success = SemanticColor(
    base: oklch(0.6, 0.13, 155),
    foreground: oklch(0.38, 0.09, 155),
    subtle: oklch(0.96, 0.032, 155),
    border: oklch(0.86, 0.07, 155),
  );

  static final SemanticColor warning = SemanticColor(
    base: oklch(0.75, 0.14, 78),
    foreground: oklch(0.44, 0.09, 70),
    subtle: oklch(0.965, 0.04, 85),
    border: oklch(0.87, 0.08, 80),
  );

  static final SemanticColor info = SemanticColor(
    base: oklch(0.64, 0.12, 235),
    foreground: oklch(0.41, 0.09, 240),
    subtle: oklch(0.96, 0.03, 235),
    border: oklch(0.86, 0.06, 235),
  );

  static final SemanticColor danger = SemanticColor(
    base: oklch(0.58, 0.205, 26),
    foreground: oklch(0.99, 0.005, 26),
    subtle: oklch(0.965, 0.028, 26),
    border: oklch(0.87, 0.07, 26),
  );

  // --- Dark --------------------------------------------------------------

  static final Color darkBackground = oklch(0.17, 0.008, 260);
  static final Color darkForeground = oklch(0.965, 0.003, 260);
  static final Color darkCard = oklch(0.212, 0.009, 260);
  static final Color darkMuted = oklch(0.27, 0.01, 260);
  static final Color darkMutedForeground = oklch(0.72, 0.014, 260);
  static final Color darkBorder = oklch(1, 0, 0, alpha: 0.12);

  static final SemanticColor darkPrimary = SemanticColor(
    base: oklch(0.7, 0.145, 256),
    foreground: oklch(0.18, 0.04, 258),
    subtle: oklch(0.29, 0.055, 258),
    border: oklch(0.42, 0.09, 258),
  );

  static final SemanticColor darkSupport = SemanticColor(
    base: oklch(0.7, 0.13, 288),
    foreground: oklch(0.19, 0.04, 288),
    subtle: oklch(0.29, 0.05, 288),
    border: oklch(0.42, 0.08, 288),
  );

  static final SemanticColor darkFeatured = SemanticColor(
    base: oklch(0.76, 0.145, 62),
    foreground: oklch(0.22, 0.05, 55),
    subtle: oklch(0.3, 0.055, 60),
    border: oklch(0.44, 0.09, 60),
  );

  static final SemanticColor darkSuccess = SemanticColor(
    base: oklch(0.72, 0.13, 157),
    foreground: oklch(0.88, 0.09, 157),
    subtle: oklch(0.28, 0.05, 157),
    border: oklch(0.4, 0.08, 157),
  );

  static final SemanticColor darkWarning = SemanticColor(
    base: oklch(0.8, 0.13, 80),
    foreground: oklch(0.9, 0.09, 82),
    subtle: oklch(0.3, 0.05, 78),
    border: oklch(0.43, 0.08, 78),
  );

  static final SemanticColor darkInfo = SemanticColor(
    base: oklch(0.72, 0.11, 235),
    foreground: oklch(0.88, 0.07, 235),
    subtle: oklch(0.28, 0.045, 235),
    border: oklch(0.41, 0.07, 235),
  );

  static final SemanticColor darkDanger = SemanticColor(
    base: oklch(0.66, 0.18, 25),
    foreground: oklch(0.9, 0.07, 25),
    subtle: oklch(0.29, 0.07, 25),
    border: oklch(0.43, 0.11, 25),
  );
}
