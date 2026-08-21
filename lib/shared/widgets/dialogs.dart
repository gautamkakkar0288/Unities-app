import 'package:flutter/material.dart';

import '../../app/theme/radii.dart';
import '../../app/theme/spacing.dart';

/// Confirmation dialog for destructive or hard-to-undo actions.
///
/// Returns true only on explicit confirmation; a dismissal is a “no”. The
/// destructive variant colours the confirm action *and* names it (“Sign out”,
/// not “OK”), so the consequence is readable without relying on colour.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool isDestructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);
      return AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: Radii.card),
        title: Text(title, style: theme.textTheme.titleLarge),
        content: Text(message, style: theme.textTheme.bodyMedium),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: isDestructive
                ? FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: theme.colorScheme.onError,
                  )
                : null,
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

/// Standard bottom sheet: rounded top, drag handle, safe-area aware and
/// scrollable so a keyboard or a small phone cannot clip its content.
Future<T?> showCirqlesSheet<T>(
  BuildContext context, {
  required String title,
  required Widget child,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) {
      final theme = Theme.of(context);
      return Padding(
        padding: EdgeInsets.only(
          left: Spacing.md,
          right: Spacing.md,
          bottom: Spacing.md + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: theme.textTheme.titleLarge),
              const SizedBox(height: Spacing.md),
              child,
            ],
          ),
        ),
      );
    },
  );
}
