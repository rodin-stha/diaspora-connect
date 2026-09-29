import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/colors.dart';
import '../theme/sizes.dart';
import '../theme/text_styles.dart';

/// A full-width button with a dashed outline, for "add something" actions
/// ("+ Upload new document").
class DashedButton extends StatelessWidget {
  final String label;
  final String iconAsset;
  final VoidCallback? onPressed;

  const DashedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.iconAsset = 'assets/icons/plus_small.svg',
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final borderRadius = BorderRadius.circular(TSizes.inputRadius);

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onPressed,
        borderRadius: borderRadius,
        child: CustomPaint(
          painter: _DashedRRectPainter(
            color: colors.border,
            radius: TSizes.inputRadius,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: TSizes.sm,
              children: [
                SvgPicture.asset(
                  iconAsset,
                  width: TSizes.iconSm,
                  height: TSizes.iconSm,
                  colorFilter: ColorFilter.mode(
                    colors.iconDefault,
                    BlendMode.srcIn,
                  ),
                ),
                Flexible(
                  child: Text(
                    label,
                    style: TTextStyles.body.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Draws a dashed rounded-rectangle outline (Flutter's borders are solid
/// only). Walks along the outline and draws every other short piece.
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
