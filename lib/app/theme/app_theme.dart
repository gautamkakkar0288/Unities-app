import 'package:flutter/material.dart';

import 'app_typography.dart';
import 'cirqles_colors.dart';
import 'color_tokens.dart';
import 'radii.dart';
import 'sizing.dart';
import 'spacing.dart';

/// Builds the Material 3 themes from Cirqles tokens.
///
/// Light mode is the primary experience (DESIGN_SYSTEM.md §3). Dark mode is
/// built from its own token set rather than by inverting light.
class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final colors = CirqlesColors.light();
    final scheme = ColorScheme(
      brightness: Brightness.light,
      primary: colors.brand.base,
      onPrimary: colors.brand.foreground,
      primaryContainer: colors.brand.subtle,
      onPrimaryContainer: ColorTokens.foreground,
      secondary: colors.support.base,
      onSecondary: colors.support.foreground,
      secondaryContainer: colors.support.subtle,
      onSecondaryContainer: ColorTokens.foreground,
      tertiary: colors.featured.base,
      onTertiary: colors.featured.foreground,
      error: colors.danger.base,
      onError: colors.danger.foreground,
      errorContainer: colors.danger.subtle,
      onErrorContainer: colors.danger.foreground,
      surface: ColorTokens.card,
      onSurface: ColorTokens.foreground,
      surfaceContainerLowest: ColorTokens.card,
      surfaceContainerLow: ColorTokens.background,
      surfaceContainer: ColorTokens.muted,
      onSurfaceVariant: ColorTokens.mutedForeground,
      outline: ColorTokens.border,
      outlineVariant: ColorTokens.border,
    );
    return _build(scheme, colors, ColorTokens.background);
  }

  static ThemeData dark() {
    final colors = CirqlesColors.dark();
    final scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: colors.brand.base,
      onPrimary: colors.brand.foreground,
      primaryContainer: colors.brand.subtle,
      onPrimaryContainer: ColorTokens.darkForeground,
      secondary: colors.support.base,
      onSecondary: colors.support.foreground,
      secondaryContainer: colors.support.subtle,
      onSecondaryContainer: ColorTokens.darkForeground,
      tertiary: colors.featured.base,
      onTertiary: colors.featured.foreground,
      error: colors.danger.base,
      onError: colors.danger.foreground,
      errorContainer: colors.danger.subtle,
      onErrorContainer: colors.danger.foreground,
      surface: ColorTokens.darkCard,
      onSurface: ColorTokens.darkForeground,
      surfaceContainerLowest: ColorTokens.darkBackground,
      surfaceContainerLow: ColorTokens.darkBackground,
      surfaceContainer: ColorTokens.darkMuted,
      onSurfaceVariant: ColorTokens.darkMutedForeground,
      outline: ColorTokens.darkBorder,
      outlineVariant: ColorTokens.darkBorder,
    );
    return _build(scheme, colors, ColorTokens.darkBackground);
  }

  static ThemeData _build(
    ColorScheme scheme,
    CirqlesColors colors,
    Color canvas,
  ) {
    final textTheme = AppTypography.textTheme(
      scheme.onSurface,
      scheme.onSurfaceVariant,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: canvas,
      textTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[colors],
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: canvas,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: Spacing.md,
      ),
      iconTheme: IconThemeData(size: Sizing.iconLg, color: scheme.onSurface),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.smPlus,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        labelStyle: textTheme.labelLarge,
        border: OutlineInputBorder(
          borderRadius: Radii.control,
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: Radii.control,
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: Radii.control,
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: Radii.control,
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: Radii.control,
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(Sizing.minTouchTarget),
          textStyle: textTheme.labelLarge,
          shape: const RoundedRectangleBorder(borderRadius: Radii.control),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(Sizing.minTouchTarget),
          textStyle: textTheme.labelLarge,
          side: BorderSide(color: scheme.outline),
          shape: const RoundedRectangleBorder(borderRadius: Radii.control),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(Sizing.minTouchTarget, Sizing.minTouchTarget),
          textStyle: textTheme.labelLarge,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: Sizing.bottomNavHeight,
        backgroundColor: scheme.surface,
        indicatorColor: colors.brand.subtle,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStatePropertyAll<TextStyle?>(
          textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.onSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.surface,
        ),
        shape: const RoundedRectangleBorder(borderRadius: Radii.control),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: Radii.sheet),
        showDragHandle: true,
      ),
    );
  }
}
