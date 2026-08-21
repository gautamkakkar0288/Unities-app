/// Marker for enums whose members map to a database value in the Cirqles
/// schema (`lib/db/schema/enums.ts` in the Unities repository).
///
/// Wire values are SCREAMING_SNAKE_CASE Postgres enum labels. They are
/// declared once, here and in the enum definitions, so no feature file ever
/// compares against a bare string like `'PUBLISHED'`.
abstract interface class WireEnum {
  String get wire;
}

/// Resolves a wire value, returning null for unknown input.
///
/// Unknown values are tolerated on purpose: the backend may add an enum member
/// (a new event kind, say) before an app release ships, and one unrecognised
/// label should degrade a single card, not fail the whole response.
T? enumFromWire<T extends WireEnum>(List<T> values, Object? raw) {
  if (raw is! String) return null;
  for (final value in values) {
    if (value.wire == raw) return value;
  }
  return null;
}
