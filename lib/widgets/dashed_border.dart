import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/sizes.dart';

/// Wraps [child] in a dashed rounded-rectangle outline (Flutter's own
/// borders are solid only). Used for "add something" buttons and tiles.
class DashedBorder extends StatelessWidget {
  final Widget child;
  final double radius;

  /// Outline color; defaults to the theme's border color.
  final Color? color;

  const DashedBorder({
    super.key,
    required this.child,
    this.radius = TSizes.inputRadius,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRRectPainter(
        color: color ?? context.colors.border,
        radius: radius,
      ),
      child: child,
    );
  }
}

/// Walks along the outline and draws every other short piece.
class _DashedRRectPainter extends CustomPainter {
  final Color color;
  final double radius;
  static const double _dash = 4;
  static const double _gap = 4;

  const _DashedRRectPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    // Inset by half the stroke so the line isn't clipped at the edges.
    final outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(0.5),
          Radius.circular(radius),
        ),
      );

    for (final metric in outline.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += _dash + _gap) {
        canvas.drawPath(
          metric.extractPath(d, math.min(d + _dash, metric.length)),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRRectPainter old) =>
      old.color != color || old.radius != radius;
}
