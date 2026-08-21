import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_error.dart';
import 'error_state.dart';
import 'skeleton.dart';

/// Renders the three states of an async read consistently.
///
/// Every list in the app has the same loading, error and empty behaviour, so it
/// is written once: a skeleton shaped like the content, the shared error view
/// with retry only where retry helps, and the caller's empty state.
class AsyncSection<T> extends StatelessWidget {
  const AsyncSection({
    required this.value,
    required this.builder,
    this.onRetry,
    this.loading,
    super.key,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final VoidCallback? onRetry;
  final Widget? loading;

  @override
  Widget build(BuildContext context) {
    return value.when(
      skipLoadingOnRefresh: true,
      data: builder,
      loading: () => loading ?? const CardSkeletonList(),
      error: (error, stackTrace) => ErrorStateView(
        // Repositories only ever throw AppError; anything else is a bug and is
        // shown as a generic failure rather than leaked verbatim.
        error: error is AppError
            ? error
            : UnknownError(debugMessage: error.toString()),
        onRetry: onRetry,
      ),
    );
  }
}
