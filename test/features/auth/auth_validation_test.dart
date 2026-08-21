import 'package:cirqles/features/auth/domain/auth_validation.dart';
import 'package:flutter_test/flutter_test.dart';

/// These rules are copied from `lib/schemas/auth.ts` in the Unities repository.
/// The app validates locally only to save a round trip; if these ever disagree
/// with the backend, the backend wins — and this test is where the drift shows.
void main() {
  group('email', () {
    test('accepts a normal campus address', () {
      expect(AuthValidation.email('student@university.edu'), isNull);
    });

    test('rejects empty and malformed addresses', () {
      expect(AuthValidation.email(''), isNotNull);
      expect(AuthValidation.email('student'), isNotNull);
      expect(AuthValidation.email('student@'), isNotNull);
    });
  });

  group('sign-in password', () {
    test('requires only a non-empty value, like the backend schema', () {
      expect(AuthValidation.signInPassword('x'), isNull);
      expect(AuthValidation.signInPassword(''), isNotNull);
    });
  });

  group('new password', () {
    test('enforces the 8 to 72 character range', () {
      expect(AuthValidation.newPassword('shortie'), isNotNull);
      expect(AuthValidation.newPassword('longenough1'), isNull);
      // 72 bytes is the bcrypt truncation limit the backend documents.
      expect(AuthValidation.newPassword('a' * 72), isNull);
      expect(AuthValidation.newPassword('a' * 73), isNotNull);
    });
  });

  group('name', () {
    test('enforces the trimmed 2 to 80 character range', () {
      expect(AuthValidation.name('A'), isNotNull);
      expect(AuthValidation.name('  A  '), isNotNull);
      expect(AuthValidation.name('Aditi'), isNull);
      expect(AuthValidation.name('a' * 81), isNotNull);
    });
  });
}
