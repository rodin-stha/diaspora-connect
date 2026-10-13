import 'package:flutter/widgets.dart';

/// [BouncingScrollPhysics] with a softer spring: after an overscroll (e.g. a
/// pull-to-refresh) the content glides back slowly instead of snapping.
class SoftBouncingScrollPhysics extends BouncingScrollPhysics {
  const SoftBouncingScrollPhysics({super.parent});

  // Physics objects are immutable and get chained with `applyTo`; without
  // this override the chain would rebuild a plain BouncingScrollPhysics and
  // lose our spring.
  @override
  SoftBouncingScrollPhysics applyTo(ScrollPhysics? ancestor) =>
      SoftBouncingScrollPhysics(parent: buildParent(ancestor));

  // The spring that pulls overscrolled content back. Lower stiffness = a
  // longer return (Flutter's default is 100, about 0.4s; this is about
  // 0.8s). Ratio 1 = settles without wobbling.
  @override
  SpringDescription get spring =>
      SpringDescription.withDampingRatio(mass: 1, stiffness: 90, ratio: 1);
}
