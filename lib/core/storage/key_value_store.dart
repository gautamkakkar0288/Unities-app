/// Minimal persistence contract.
///
/// Two implementations exist and the distinction is deliberate:
/// [SecureKeyValueStore] for anything that grants access, and
/// [PreferencesKeyValueStore] for anything that is merely a preference.
abstract interface class KeyValueStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
  Future<void> clear();
}

/// In-memory implementation for tests and for the first frame before platform
/// storage is ready.
class InMemoryKeyValueStore implements KeyValueStore {
  final Map<String, String> _values = <String, String>{};

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async => _values[key] = value;

  @override
  Future<void> delete(String key) async => _values.remove(key);

  @override
  Future<void> clear() async => _values.clear();
}
