import 'package:flutter/material.dart';

import '../../app/theme/sizing.dart';
import '../../app/theme/spacing.dart';

/// Primary action. One per screen region — if two buttons compete, neither is
/// primary.
///
/// Owns its own busy state so callers never have to disable a button *and*
/// swap in a spinner; the size stays fixed so the layout does not jump.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isBusy = false,
    this.isFullWidth = true,
    this.semanticLabel,
    super.key,
  });

  final String label;

  /// Null disables the button. Passing null while [isBusy] is the normal way to
  /// block double submits.
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isBusy;
  final bool isFullWidth;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final button = FilledButton(
      onPressed: isBusy ? null : onPressed,
      child: isBusy
          ? SizedBox(
              height: Sizing.iconMd,
              width: Sizing.iconMd,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: scheme.onPrimary,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  Icon(icon, size: Sizing.iconMd),
                  const SizedBox(width: Spacing.sm),
                ],
                Flexible(
                  child: Text(label, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
    );

    return Semantics(
      button: true,
      // Screen readers should hear the action, and hear that it is running.
      label: semanticLabel ?? label,
      value: isBusy ? 'In progress' : null,
      child: ExcludeSemantics(
        child: isFullWidth
            ? SizedBox(width: double.infinity, child: button)
            : button,
      ),
    );
  }
}

/// Secondary action: outlined, equal weight in size but not in emphasis.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isFullWidth = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: Sizing.iconMd),
            const SizedBox(width: Spacing.sm),
          ],
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );

    return isFullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}
