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
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label: semanticLabel,
      image: imageUrl != null,
      child: Container(
        height: size,
        width: size,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colors.brand.subtle,
          shape: BoxShape.circle,
          border: Border.all(color: colors.brand.border),
        ),
        child: imageUrl == null
            ? _Initials(initials: initials, size: size, colors: colors)
            : Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                // A slow avatar must never delay the row it sits in.
                errorBuilder: (_, __, ___) =>
                    _Initials(initials: initials, size: size, colors: colors),
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : _Initials(
                        initials: initials,
                        size: size,
                        colors: colors,
                      ),
              ),
      ),
    );
  }

  static TextStyle? _styleFor(TextTheme theme, double size) =>
      size >= Sizing.avatarLg ? theme.titleLarge : theme.labelLarge;
}

class _Initials extends StatelessWidget {
  const _Initials({
    required this.initials,
    required this.size,
    required this.colors,
  });

  final String initials;
  final double size;
  final CirqlesColors colors;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initials,
        style: UserAvatar._styleFor(Theme.of(context).textTheme, size)
            ?.copyWith(color: colors.brand.foreground == null
                ? null
                : colors.brand.base),
      ),
    );
  }
}
