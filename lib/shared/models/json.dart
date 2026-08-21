import '../../core/errors/app_error.dart';

/// Decoding helpers.
///
/// Every model parses through these so a contract mismatch with the Unities
/// backend surfaces as a [DecodingError] naming the field, instead of a cast
/// exception 20 frames deep in the widget tree.
class Json {
  const Json._();

  static Map<String, Object?> asMap(Object? value, {String context = 'object'}) {
    if (value is Map<String, Object?>) return value;
    if (value is Map) return value.cast<String, Object?>();
    throw DecodingError(debugMessage: 'Expected a JSON object for $context');
  }

  static Map<String, Object?>? asMapOrNull(Object? value) {
    if (value is Map<String, Object?>) return value;
    if (value is Map) return value.cast<String, Object?>();
    return null;
  }

  static String requireString(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is String && value.isNotEmpty) return value;
    throw DecodingError(debugMessage: 'Missing required string field "$key"');
  }

  static String? optionalString(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is String && value.isNotEmpty) return value;
    return null;
  }

  static int requireInt(Map<String, Object?> json, String key) {
    final value = optionalInt(json, key);
    if (value != null) return value;
    throw DecodingError(debugMessage: 'Missing required int field "$key"');
  }

  /// Tolerates numeric strings: Postgres `bigint` columns arrive as strings
  /// through some serialisers.
  static int? optionalInt(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static bool optionalBool(
    Map<String, Object?> json,
    String key, {
    bool fallback = false,
  }) {
    final value = json[key];
    if (value is bool) return value;
    return fallback;
  }

  static DateTime requireDateTime(Map<String, Object?> json, String key) {
    final value = optionalDateTime(json, key);
    if (value != null) return value;
    throw DecodingError(debugMessage: 'Missing required date field "$key"');
  }

  /// Parses ISO-8601 (what `JSON.stringify` produces for a JS `Date`) or epoch
  /// milliseconds. Always returned in UTC; format at the edge, in the widget.
  static DateTime? optionalDateTime(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is String) {
      return DateTime.tryParse(value)?.toUtc();
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
    }
    return null;
  }

  static List<String> stringList(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is! List) return const <String>[];
    return value.whereType<String>().toList(growable: false);
  }

  static List<T> listOf<T>(
    Object? value,
    T Function(Map<String, Object?> json) fromJson,
  ) {
    if (value is! List) return <T>[];
    return value
        .map(asMapOrNull)
        .whereType<Map<String, Object?>>()
        .map(fromJson)
        .toList(growable: false);
  }

  /// ISO-8601 for outbound payloads.
  static String? encodeDateTime(DateTime? value) =>
      value?.toUtc().toIso8601String();
}
