import 'dart:math' as math;
import 'dart:ui' show Color;

/// OKLCH -> sRGB conversion.
///
/// The Cirqles web design system declares every colour in OKLCH
/// (`app/globals.css` in the Unities repository). Re-deriving hex values by
/// hand would fork the palette the first time a token is tuned, so the mobile
/// tokens are declared with the *same numbers* as the web tokens and converted
/// here instead. One conversion, covered by a test, rather than fifty
/// hand-copied hex strings that silently drift.
///
/// [lightness] is 0..1, [chroma] is absolute (typically 0..0.4) and
/// [hueDegrees] is 0..360. Out-of-gamut results are clamped per channel, which
/// is what browsers do for these token values too.
Color oklch(
  double lightness,
  double chroma,
  double hueDegrees, {
  double alpha = 1,
}) {
  final hueRadians = hueDegrees * math.pi / 180.0;
  final a = chroma * math.cos(hueRadians);
  final b = chroma * math.sin(hueRadians);

  final lPrime = lightness + 0.3963377774 * a + 0.2158037573 * b;
  final mPrime = lightness - 0.1055613458 * a - 0.0638541728 * b;
  final sPrime = lightness - 0.0894841775 * a - 1.2914855480 * b;

  final l = lPrime * lPrime * lPrime;
  final m = mPrime * mPrime * mPrime;
  final s = sPrime * sPrime * sPrime;

  final red = 4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s;
  final green = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s;
  final blue = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s;

  return Color.fromARGB(
    _toByte(alpha),
    _toByte(_encodeGamma(red)),
    _toByte(_encodeGamma(green)),
    _toByte(_encodeGamma(blue)),
  );
}

/// Linear-light channel to sRGB, clamped before the transfer function so a
/// slightly out-of-gamut token cannot produce NaN.
double _encodeGamma(double channel) {
  final value = channel.clamp(0.0, 1.0);
  if (value <= 0.0031308) return 12.92 * value;
  return 1.055 * math.pow(value, 1 / 2.4).toDouble() - 0.055;
}

int _toByte(double value) => (value.clamp(0.0, 1.0) * 255).round();
