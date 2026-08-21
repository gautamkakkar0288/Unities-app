/// Every persisted key in one place, so it is obvious at a glance what the app
/// keeps on the device — and which store it belongs in.
class SecureKeys {
  const SecureKeys._();

  /// The Auth.js session cookie. Secure storage only: Keychain on iOS,
  /// EncryptedSharedPreferences on Android.
  static const String sessionCookie = 'auth.session_cookie';
}

class PreferenceKeys {
  const PreferenceKeys._();

  /// 'system' | 'light' | 'dark'.
  static const String themeMode = 'ui.theme_mode';

  /// Whether the local intro has been seen. Product onboarding state lives on
  /// the server; this is only about the device.
  static const String introCompleted = 'ui.intro_completed';

  /// Last signed-in email, to prefill the sign-in field. Non-sensitive on its
  /// own and never logged.
  static const String lastSignInEmail = 'auth.last_email';
}
