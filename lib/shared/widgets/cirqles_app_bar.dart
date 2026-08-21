import 'package:flutter/material.dart';

import '../../app/theme/spacing.dart';

/// App bar for the top-level tabs.
///
/// Left-aligned title with an optional eyebrow line above it (“Good evening”,
/// a campus name), which is how the tabs stay calm without a hero image on
/// every screen.
class CirqlesAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CirqlesAppBar({
    required this.title,
    this.eyebrow,
    this.actions = const <Widget>[],
    super.key,
  });

  final String title;
  final String? eyebrow;
  final List<Widget> actions;

  @override
  Size get preferredSize => Size.fromHeight(eyebrow == null ? 56 : 72);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      toolbarHeight: preferredSize.height,
      titleSpacing: Spacing.pageGutter,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (eyebrow != null)
            Text(eyebrow!, style: theme.textTheme.labelSmall),
          Text(title, style: theme.textTheme.headlineMedium),
        ],
      ),
      actions: <Widget>[
        ...actions,
        const SizedBox(width: Spacing.sm),
      ],
    );
  }
}
