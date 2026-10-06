import 'package:flutter/material.dart';

import '../theme/colors.dart';

/// Gently pulses its [child] while content loads. Put [SkeletonBox]es
/// inside, shaped like the content that's coming.
///
/// One animation for the whole group, so the boxes pulse together.
class Skeleton extends StatefulWidget {
  final Widget child;

  const Skeleton({super.key, required this.child});

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  // `vsync: this` ties the animation to the screen's frames, so it pauses
  // when the widget isn't visible (e.g. another tab is open).
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0.45).animate(_controller),
      child: widget.child,
    );
  }
}

/// A grey rounded bar standing in for text, a pill or an image.
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.colors.border,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
