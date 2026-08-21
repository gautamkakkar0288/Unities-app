import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/logging/app_logger.dart';
import '../core/network/api_client.dart';
import '../core/network/dio_api_client.dart';
import '../core/network/network_logging_interceptor.dart';
import '../core/network/unauthorized_signal.dart';
import '../core/storage/key_value_store.dart';
import '../core/storage/secure_key_value_store.dart';
import '../features/auth/data/auth_js_client.dart';
import '../features/auth/data/auth_repository_impl.dart';
import '../features/auth/data/session_cookie_store.dart';
import '../features/auth/domain/auth_repository.dart';
import 'config/app_config.dart';

/// Dependency injection.
///
/// Riverpod providers rather than a service locator: dependencies are typed,
/// resolution is checked at compile time, and any test can substitute a fake
/// with an override instead of mutating global state.

/// Overridden in `main()` with the compiled configuration.
final appConfigProvider = Provider<AppConfig>((ref) {
  throw UnimplementedError('appConfigProvider must be overridden in main()');
});

/// Overridden in `main()` once SharedPreferences has opened. Falls back to an
/// in-memory store so widget tests need no platform channels.
final preferencesStoreProvider = Provider<KeyValueStore>(
  (ref) => InMemoryKeyValueStore(),
);

final loggerProvider = Provider<AppLogger>((ref) {
  return AppLogger.forConfig('app', ref.watch(appConfigProvider));
});

final secureStoreProvider = Provider<KeyValueStore>((ref) {
  return SecureKeyValueStore(
    logger: ref.watch(loggerProvider).child('secure-store'),
  );
});

final unauthorizedSignalProvider = Provider<UnauthorizedSignal>((ref) {
  final signal = UnauthorizedSignal();
  ref.onDispose(signal.dispose);
  return signal;
});

/// Cookies live in memory for the process; the session cookie alone is
/// persisted, encrypted, by [SessionCookieStore].
final cookieJarProvider = Provider<CookieJar>((ref) => CookieJar());

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      // Deadlines rather than hanging spinners on a patchy campus network.
      connectTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      responseType: ResponseType.json,
      headers: const <String, Object?>{'Accept': 'application/json'},
      // Auth.js answers sign-out with a redirect; following it would discard
      // the Set-Cookie we need to observe.
      followRedirects: false,
      validateStatus: (status) =>
          status != null && (status < 400 || status == 302),
    ),
  );

  dio.interceptors.add(CookieManager(ref.watch(cookieJarProvider)));
  dio.interceptors.add(
    NetworkLoggingInterceptor(ref.watch(loggerProvider).child('http')),
  );
  ref.onDispose(dio.close);
  return dio;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final signal = ref.watch(unauthorizedSignalProvider);
  return DioApiClient(
    dio: ref.watch(dioProvider),
    logger: ref.watch(loggerProvider).child('api'),
    onUnauthorized: signal.emit,
  );
});

final sessionCookieStoreProvider = Provider<SessionCookieStore>((ref) {
  final config = ref.watch(appConfigProvider);
  return SessionCookieStore(
    secureStore: ref.watch(secureStoreProvider),
    cookieJar: ref.watch(cookieJarProvider),
    baseUri: config.apiBaseUri,
    logger: ref.watch(loggerProvider).child('session-cookie'),
  );
});

final authJsClientProvider = Provider<AuthJsClient>((ref) {
  return AuthJsClient(
    api: ref.watch(apiClientProvider),
    logger: ref.watch(loggerProvider).child('authjs'),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    client: ref.watch(authJsClientProvider),
    cookieStore: ref.watch(sessionCookieStoreProvider),
    preferences: ref.watch(preferencesStoreProvider),
    config: ref.watch(appConfigProvider),
    logger: ref.watch(loggerProvider).child('auth-repo'),
  );
});
