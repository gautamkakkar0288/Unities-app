import 'package:flutter/material.dart';

import '../../app/theme/spacing.dart';

/// Labelled text input.
///
/// The label is a real, always-visible label rather than a placeholder that
/// disappears on focus: a hint-only field is unreadable to a screen reader and
/// unrecoverable for anyone who forgot what they were typing.
class CirqlesTextField extends StatelessWidget {
  const CirqlesTextField({
    required this.label,
    required this.controller,
    this.hint,
    this.errorText,
    this.helperText,
    this.keyboardType,
    this.obscureText = false,
    this.textInputAction,
    this.autofillHints,
    this.enabled = true,
    this.onSubmitted,
    this.trailing,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? errorText;
  final String? helperText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final bool enabled;
  final ValueChanged<String>? onSubmitted;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: textTheme.labelLarge),
        const SizedBox(height: Spacing.xs),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          enabled: enabled,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          onSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            helperText: helperText,
            // Two lines of helper/error text must not resize the form.
            helperMaxLines: 2,
            errorMaxLines: 2,
            suffixIcon: trailing,
          ),
        ),
      ],
    );
  }
}

/// Search input for the Explore surface.
class SearchField extends StatelessWidget {
  const SearchField({
    required this.controller,
    required this.hintText,
    this.enabled = true,
    this.onSubmitted,
    this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final String hintText;
  final bool enabled;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      textInputAction: TextInputAction.search,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search_rounded),
      ),
    );
  }
}
