import 'package:shared_preferences/shared_preferences.dart';

import 'key_value_store.dart';

/// Non-sensitive device preferences. Never used for tokens or cookies.
class PreferencesKeyValueStore implements KeyValueStore {
  PreferencesKeyValueStore(this._preferences);

  final SharedPreferences _preferences;

  static Future<PreferencesKeyValueStore> open() async =>
      PreferencesKeyValueStore(await SharedPreferences.getInstance());

  @override
  Future<String?> read(String key) async => _preferences.getString(key);

  @override
  Future<void> write(String key, String value) async =>
      _preferences.setString(key, value);

  @override
  Future<void> delete(String key) async => _preferences.remove(key);

  @override
  Future<void> clear() async => _preferences.clear();
}
