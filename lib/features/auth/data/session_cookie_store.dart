import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/storage/key_value_store.dart';
import '../../../core/storage/storage_keys.dart';

/// Bridges the in-memory cookie jar and encrypted device storage.
///
/// Cirqles authenticates with an httpOnly Auth.js session cookie. A mobile app
/// gets no cookie persistence for free, so the session cookie is copied into
/// the platform keystore after sign-in and pushed back into the jar at launch.
/// Only the session cookie is kept — CSRF tokens are per-request and are
/// refetched.
///
/// The cookie is a bearer credential: it lives in secure storage, never in
/// preferences, and is never logged.
class SessionCookieStore {
  SessionCookieStore({
    required KeyValueStore secureStore,
    required CookieJar cookieJar,
    required Uri baseUri,
    required AppLogger logger,
  })  : _secureStore = secureStore,
        _cookieJar = cookieJar,
        _baseUri = baseUri,
        _logger = logger;

  final KeyValueStore _secureStore;
  final CookieJar _cookieJar;
  final Uri _baseUri;
  final AppLogger _logger;

  /// Auth.js v5 names the cookie `authjs.session-token`, and prefixes it with
  /// `__Secure-` over https. Matching on the suffix covers both, plus the
  /// legacy `next-auth.` prefix.
  static bool isSessionCookie(String name) => name.endsWith('session-token');

  /// Copies the current session cookie out of the jar into secure storage.
  Future<void> persist() async {
    final cookies = await _cookieJar.loadForRequest(_baseUri);
    final session = cookies.where((c) => isSessionCookie(c.name)).toList();
    if (session.isEmpty) {
      await _secureStore.delete(SecureKeys.sessionCookie);
      _logger.debug('no session cookie to persist');
      return;
    }
    await _secureStore.write(
      SecureKeys.sessionCookie,
      session.map((c) => '${c.name}=${c.value}').join('; '),
    );
    _logger.debug('session cookie persisted');
  }

  /// Pushes a stored session cookie back into the jar.
  ///
  /// Returns whether anything was restored. A true result is a *hint*, not
  /// proof of a valid session: only `/api/auth/session` can confirm that.
  Future<bool> restore() async {
    final stored = await _secureStore.read(SecureKeys.sessionCookie);
    if (stored == null || stored.isEmpty) return false;

    final cookies = <Cookie>[];
    for (final pair in stored.split('; ')) {
      final separator = pair.indexOf('=');
      if (separator <= 0) continue;
      final name = pair.substring(0, separator);
      final value = pair.substring(separator + 1);
      if (value.isEmpty) continue;
      cookies.add(
        Cookie(name, value)
          ..httpOnly = true
          ..path = '/'
          ..domain = _baseUri.host,
      );
    }
    if (cookies.isEmpty) return false;

    await _cookieJar.saveFromResponse(_baseUri, cookies);
    _logger.debug('session cookie restored into jar');
    return true;
  }

  /// Forgets the session everywhere on the device.
  Future<void> clear() async {
    await _cookieJar.deleteAll();
    await _secureStore.delete(SecureKeys.sessionCookie);
    _logger.debug('session cleared');
  }
}
