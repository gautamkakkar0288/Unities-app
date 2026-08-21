import 'package:flutter/material.dart';

import '../../app/theme/cirqles_colors.dart';
import '../../app/theme/motion.dart';
import '../../app/theme/radii.dart';
import '../../app/theme/spacing.dart';

/// A single shimmering placeholder block.
///
/// Loading states mirror the shape of the content that will replace them, so
/// the screen does not reflow when data lands. A spinner in the middle of an
/// empty screen tells the student nothing about what is coming.
class Skeleton extends StatefulWidget {
  const Skeleton({
    required this.height,
    this.width,
    this.borderRadius = Radii.control,
    super.key,
  });

  const Skeleton.text({double width = double.infinity, super.key})
      : height = 14,
        width = width,
        borderRadius = Radii.control;

  final double height;
  final double? width;
  final BorderRadius borderRadius;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Motion.slow * 3,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = CirqlesColors.of(context);
    // Reduced-motion users get the resting colour, no pulse.
    final animate = !MediaQuery.of(context).disableAnimations;

    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = animate
              ? Curves.easeInOut.transform(_controller.value)
              : 0.35;
          return Container(
            height: widget.height,
            width: widget.width,
            decoration: BoxDecoration(
              color: Color.lerp(
                colors.skeletonBase,
                colors.skeletonHighlight,
                t,
              ),
              borderRadius: widget.borderRadius,
            ),
          );
        },
      ),
    );
  }
}

/// Skeleton in the shape of an [SurfaceCard]-based list item.
class CardSkeleton extends StatelessWidget {
  const CardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: Radii.card,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[
          Skeleton(height: 12, width: 96),
          SizedBox(height: Spacing.sm),
          Skeleton(height: 18),
          SizedBox(height: Spacing.sm),
          Skeleton(height: 12, width: 160),
        ],
      ),
    );
  }
}

/// A short run of card skeletons, used while a first page loads.
class CardSkeletonList extends StatelessWidget {
  const CardSkeletonList({this.count = 3, super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (var index = 0; index < count; index++)
          Padding(
            padding: EdgeInsets.only(
              bottom: index == count - 1 ? 0 : Spacing.smPlus,
            ),
            child: const CardSkeleton(),
          ),
      ],
    );
  }
}
