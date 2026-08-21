import 'package:flutter/material.dart';

import '../../app/theme/spacing.dart';
import '../../core/errors/app_error.dart';
import '../../core/errors/error_messages.dart';
import 'cirqles_button.dart';
import 'empty_state.dart';

/// Renders an [AppError] as something a student can act on.
///
/// Copy comes from the central mapper, so no screen invents its own wording
/// and no backend detail or stack trace can leak into the UI. Retry is offered
/// only for errors where retrying can actually help.
class ErrorStateView extends StatelessWidget {
  const ErrorStateView({required this.error, this.onRetry, super.key});

  final AppError error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (error is MissingBackendCapabilityError) {
      final missing = error as MissingBackendCapabilityError;
      return EmptyState.notAvailableYet(
        title: 'Not in the app yet',
        message: missing.detail,
        capability: missing.capability,
      );
    }

    final canRetry = isRetryable(error) && onRetry != null;
    return EmptyState(
      icon: switch (error) {
        NetworkError() || TimeoutError() => Icons.wifi_off_rounded,
        UnauthorizedError() => Icons.lock_outline_rounded,
        ForbiddenError() => Icons.no_encryption_gmailerrorred_rounded,
        NotFoundError() => Icons.search_off_rounded,
        _ => Icons.error_outline_rounded,
      },
      title: userFacingTitle(error),
      message: userFacingMessage(error),
      actionLabel: canRetry ? 'Try again' : null,
      onAction: canRetry ? onRetry : null,
    );
  }
}

/// Inline variant for failures inside an otherwise working screen, such as one
/// section of the home feed.
class InlineErrorBanner extends StatelessWidget {
  const InlineErrorBanner({required this.error, this.onRetry, super.key});

  final AppError error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            userFacingMessage(error),
            style: theme.textTheme.bodySmall,
          ),
        ),
        if (isRetryable(error) && onRetry != null) ...<Widget>[
          const SizedBox(width: Spacing.sm),
          SecondaryButton(
            label: 'Retry',
            onPressed: onRetry,
            isFullWidth: false,
          ),
        ],
      ],
    );
  }
}
