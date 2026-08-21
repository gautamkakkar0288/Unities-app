import 'package:flutter/material.dart';

import '../../app/theme/cirqles_colors.dart';
import '../../app/theme/sizing.dart';

/// Avatar with an initials fallback.
///
/// Most Cirqles accounts have no image (`users.image` is nullable), so initials
/// are the normal case rather than an error case. Network failures fall back to
/// the same treatment instead of a broken-image glyph.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    required this.initials,
    this.imageUrl,
    this.size = Sizing.avatarMd,
    this.semanticLabel,
    super.key,
  });

  final String initials;
  final String? imageUrl;
  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = CirqlesColors.of(context);
    final url = imageUrl;

    return Semantics(
      label: semanticLabel,
      image: url != null,
      child: Container(
        height: size,
        width: size,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colors.brand.subtle,
          shape: BoxShape.circle,
          border: Border.all(color: colors.brand.border),
        ),
        child: url == null
            ? _Initials(initials: initials, size: size)
            : Image.network(
                url,
                fit: BoxFit.cover,
                // A slow avatar must never delay the row it sits in.
                errorBuilder: (_, __, ___) =>
                    _Initials(initials: initials, size: size),
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : _Initials(initials: initials, size: size),
              ),
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  const _Initials({required this.initials, required this.size});

  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = CirqlesColors.of(context);
    final style = size >= Sizing.avatarLg
        ? theme.textTheme.titleLarge
        : theme.textTheme.labelLarge;

    return Center(
      child: Text(
        initials,
        style: style?.copyWith(color: colors.brand.base),
      ),
    );
  }
}
