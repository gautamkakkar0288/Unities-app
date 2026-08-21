import 'package:cirqles/core/logging/app_logger.dart';
import 'package:flutter_test/flutter_test.dart';

/// Redaction is a security rule, not a nicety: a log line containing a session
/// cookie is a credential leak. It is tested so it cannot regress quietly.
void main() {
  test('redacts credential-bearing keys regardless of case', () {
    final redacted = AppLogger.redact(<String, Object?>{
      'password': 'hunter2',
      'Authorization': 'Bearer abc',
      'Set-Cookie': 'authjs.session-token=xyz',
      'csrfToken': 'tok',
      'email': 'student@university.edu',
      'status': 200,
    });

    expect(redacted['password'], '<redacted>');
    expect(redacted['Authorization'], '<redacted>');
    expect(redacted['Set-Cookie'], '<redacted>');
    expect(redacted['csrfToken'], '<redacted>');
    // Personal data is redacted too, not just secrets.
    expect(redacted['email'], '<redacted>');
    // Diagnostic values survive, or the logs would be useless.
    expect(redacted['status'], 200);
  });

  test('no redacted value appears anywhere in the output', () {
    final redacted = AppLogger.redact(<String, Object?>{
      'password': 'hunter2',
      'cookie': 'session=abc',
    });

    expect(redacted.values.join(), isNot(contains('hunter2')));
    expect(redacted.values.join(), isNot(contains('session=abc')));
  });

  test('child loggers inherit verbosity and namespace the scope', () {
    const logger = AppLogger('network', verbose: true);
    final child = logger.child('auth');

    expect(child.scope, 'network.auth');
    expect(child.verbose, isTrue);
  });
}
