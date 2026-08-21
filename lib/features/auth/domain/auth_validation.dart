/// Client-side mirrors of the backend Zod schemas (`lib/schemas/auth.ts`).
///
/// These exist to give immediate feedback, not to be the rule. The server
/// re-validates everything; if the two ever disagree, the server wins and its
/// message is displayed. The bounds below are copied deliberately — the 72
/// character password ceiling is bcrypt's truncation point, not a style choice.
class AuthValidation {
  const AuthValidation._();

  static const int passwordMinLength = 8;
  static const int passwordMaxLength = 72;
  static const int nameMinLength = 2;
  static const int nameMaxLength = 80;

  /// Intentionally permissive: the authoritative check is the server's, and an
  /// over-strict regex locks out valid campus addresses.
  static final RegExp _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return 'Enter your university email';
    if (!_email.hasMatch(input)) return 'Enter a valid email address';
    return null;
  }

  /// Sign-in only requires a non-empty password: the backend accepts whatever
  /// was set previously and rejecting locally would lock out old accounts.
  static String? signInPassword(String? value) {
    if (value == null || value.isEmpty) return 'Enter your password';
    return null;
  }

  static String? newPassword(String? value) {
    final input = value ?? '';
    if (input.isEmpty) return 'Choose a password';
    if (input.length < passwordMinLength) {
      return 'Use at least $passwordMinLength characters';
    }
    if (input.length > passwordMaxLength) {
      return 'Use at most $passwordMaxLength characters';
    }
    return null;
  }

  static String? name(String? value) {
    final input = value?.trim() ?? '';
    if (input.length < nameMinLength) return 'Enter your full name';
    if (input.length > nameMaxLength) {
      return 'Keep it under $nameMaxLength characters';
    }
    return null;
  }
}
