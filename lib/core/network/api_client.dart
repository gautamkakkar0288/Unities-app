/// Decodes a parsed JSON body into a typed model.
///
/// Every request declares one, which is what keeps `Map<String, dynamic>` out
/// of the feature layers.
typedef JsonDecoder<T> = T Function(Object? json);

/// The app's only outbound HTTP surface.
///
/// Feature code depends on this interface, never on dio, so the transport can
/// change and tests can supply a fake without a running server.
abstract interface class ApiClient {
  Future<T> get<T>(
    String path, {
    required JsonDecoder<T> decode,
    Map<String, Object?>? query,
    Duration? timeout,
  });

  Future<T> post<T>(
    String path, {
    required JsonDecoder<T> decode,
    Object? body,
    Map<String, Object?>? query,

    /// Auth.js credentials endpoints require `application/x-www-form-urlencoded`.
    bool formUrlEncoded = false,
    Duration? timeout,
  });

  Future<T> put<T>(
    String path, {
    required JsonDecoder<T> decode,
    Object? body,
    Map<String, Object?>? query,
  });

  Future<T> patch<T>(
    String path, {
    required JsonDecoder<T> decode,
    Object? body,
    Map<String, Object?>? query,
  });

  Future<T> delete<T>(
    String path, {
    required JsonDecoder<T> decode,
    Object? body,
    Map<String, Object?>? query,
  });
}

/// Decoders for the handful of shapes that are not domain models.
class Decoders {
  const Decoders._();

  static void unit(Object? _) {}

  static Map<String, Object?> jsonObject(Object? json) {
    if (json is Map<String, Object?>) return json;
    if (json is Map) return json.cast<String, Object?>();
    return const <String, Object?>{};
  }

  static List<Object?> jsonArray(Object? json) =>
      json is List ? json : const <Object?>[];
}
