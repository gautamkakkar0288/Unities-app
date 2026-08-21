import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../logging/app_logger.dart';
import 'key_value_store.dart';

/// Platform-encrypted storage for credentials: the session cookie and nothing
/// else. Reads degrade to null rather than throwing, because a corrupt keystore
/// entry should send the student to the sign-in screen, not crash the launch.
class SecureKeyValueStore implements KeyValueStore {
  SecureKeyValueStore({FlutterSecureStorage? storage, required AppLogger logger})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            ),
        _logger = logger;

  final FlutterSecureStorage _storage;
  final AppLogger _logger;

  @override
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (error) {
      _logger.warn('secure read failed', data: <String, Object?>{'key': key});
      return null;
    }
  }

  @override
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (error) {
      _logger.warn('secure write failed', data: <String, Object?>{'key': key});
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (error) {
      _logger.warn('secure delete failed', data: <String, Object?>{'key': key});
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _storage.deleteAll();
    } catch (error) {
      _logger.warn('secure clear failed');
    }
  }
}
