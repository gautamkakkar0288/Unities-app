import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router/routes.dart';
import '../../../app/theme/spacing.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/errors/error_messages.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../shared/widgets/cirqles_button.dart';
import '../../../shared/widgets/cirqles_text_field.dart';
import '../domain/auth_session.dart';
import '../domain/auth_validation.dart';
import 'auth_controller.dart';

/// Credentials sign-in against the existing Auth.js provider.
///
/// The form mirrors the backend's own validation rules and shows the server's
/// message when the two disagree. It never states which of email or password
/// was wrong, because the backend does not either.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  String? _emailError;
  String? _passwordError;
  AppError? _submitError;
  bool _isSubmitting = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    unawaited(_prefillEmail());
  }

  /// The last signed-in address is remembered so students on shared campus
  /// wifi do not retype it. The password never is.
  Future<void> _prefillEmail() async {
    final stored = await ref
        .read(preferencesStoreProvider)
        .read(PreferenceKeys.lastSignInEmail);
    if (!mounted || stored == null || _email.text.isNotEmpty) return;
    _email.text = stored;
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final emailError = AuthValidation.email(_email.text);
    final passwordError = AuthValidation.signInPassword(_password.text);
    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
      _submitError = null;
    });
    if (emailError != null || passwordError != null) return;

    setState(() => _isSubmitting = true);
    final error = await ref.read(authControllerProvider.notifier).signIn(
          email: _email.text,
          password: _password.text,
        );
    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
      _submitError = error;
      // A field-level message from the server attaches to the field.
      if (error is ValidationError) {
        _emailError = error.fieldErrors['email'];
        _passwordError = error.fieldErrors['password'];
      }
    });
    // On success the router redirects; no navigation call is needed here.
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // A session that ended mid-use explains itself here.
    final endedReason = switch (ref.watch(authControllerProvider)) {
      AuthSessionSignedOut(:final reason) => reason,
      _ => null,
    };
    final banner = _submitError ?? endedReason;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            // Keyboard-aware: the form scrolls instead of overflowing.
            padding: EdgeInsets.only(
              left: Spacing.pageGutter,
              right: Spacing.pageGutter,
              top: Spacing.xl,
              bottom: Spacing.xl + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Welcome back', style: theme.textTheme.displayLarge),
                  const SizedBox(height: Spacing.sm),
                  Text(
                    'Sign in with the email your campus gave you.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: Spacing.xl),
                  if (banner != null) ...<Widget>[
                    _AuthBanner(error: banner),
                    const SizedBox(height: Spacing.md),
                  ],
                  CirqlesTextField(
                    label: 'University email',
                    controller: _email,
                    hint: 'you@university.edu',
                    errorText: _emailError,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const <String>[AutofillHints.username],
                    enabled: !_isSubmitting,
                  ),
                  const SizedBox(height: Spacing.md),
                  CirqlesTextField(
                    label: 'Password',
                    controller: _password,
                    errorText: _passwordError,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    autofillHints: const <String>[AutofillHints.password],
                    enabled: !_isSubmitting,
                    onSubmitted: (_) => _submit(),
                    trailing: IconButton(
                      onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      tooltip: _obscurePassword
                          ? 'Show password'
                          : 'Hide password',
                    ),
                  ),
                  const SizedBox(height: Spacing.lg),
                  PrimaryButton(
                    label: 'Sign in',
                    isBusy: _isSubmitting,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: Spacing.md),
                  Center(
                    child: TextButton(
                      onPressed: () => context.push(Routes.signUp),
                      child: const Text('New to Cirqles? Create an account'),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Cirqles is open to students with a university email '
                    'address.',
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthBanner extends StatelessWidget {
  const _AuthBanner({required this.error});

  final AppError error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(Spacing.smPlus),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.error_outline_rounded,
            size: 20,
            color: theme.colorScheme.onErrorContainer,
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Semantics(
              liveRegion: true,
              child: Text(
                userFacingMessage(error),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
