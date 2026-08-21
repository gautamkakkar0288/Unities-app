import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/utils/result.dart';
import '../../../shared/models/cirqles_user.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_session.dart';

/// Owns the session for the whole app.
///
/// The router listens to this, so every protected screen is protected by
/// construction rather than by each screen remembering to check.
class AuthController extends Notifier<AuthSession> {
  StreamSubscription<void>? _unauthorizedSubscription;

  @override
  AuthSession build() {
    // Any 401 from any request ends the session once, centrally.
    final signal = ref.watch(unauthorizedSignalProvider);
    _unauthorizedSubscription = signal.stream.listen((_) {
      if (state is AuthSessionActive) {
        _logger.warn('unauthorized response; ending session');
        unawaited(_repository.signOut());
        state = const AuthSessionSignedOut(
          reason: UnauthorizedError(debugMessage: '401 from API'),
        );
      }
    });
    ref.onDispose(() => _unauthorizedSubscription?.cancel());

    unawaited(restore());
    return const AuthSessionUnknown();
  }

  AuthRepository get _repository => ref.read(authRepositoryProvider);
  AppLogger get _logger => ref.read(loggerProvider).child('auth');

  /// Launch path: decide whether we have a session before the first real frame.
  Future<void> restore() async {
    final result = await _repository.restoreSession();
    state = result.fold(
      onSuccess: (session) => session,
      // Cannot reach the server: treat as signed out but keep the reason so the
      // sign-in screen can say “you are offline” instead of “wrong password”.
      onFailure: (error) => AuthSessionSignedOut(reason: error),
    );
  }

  /// Returns the failure for the form to display, or null on success.
  Future<AppError?> signIn({
    required String email,
    required String password,
  }) async {
    final result = await _repository.signIn(email: email, password: password);
    return result.fold(
      onSuccess: (SessionUser user) {
        state = AuthSessionActive(user);
        return null;
      },
      onFailure: (error) => error,
    );
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = const AuthSessionSignedOut();
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthSession>(
  AuthController.new,
);
