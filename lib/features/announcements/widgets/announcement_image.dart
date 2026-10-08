import 'package:flutter/material.dart';

import '../../../theme/colors.dart';
import '../../../theme/sizes.dart';
import '../../../widgets/skeleton.dart';

/// An announcement's image from the network, filling its box: a pulsing
/// placeholder while it loads, an icon if it can't.
class AnnouncementImage extends StatelessWidget {
  final String url;

  /// [BoxFit.cover] crops to fill (carousel); [BoxFit.contain] shows it
  /// whole (full-screen view).
  final BoxFit fit;

  const AnnouncementImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return LayoutBuilder(
      builder: (context, constraints) => Image.network(
        url,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        // Decode at the size it's shown, not the original (often 2000px+
        // and over 1 MB): far less memory for the same sharpness.
        cacheWidth:
            (constraints.maxWidth * MediaQuery.devicePixelRatioOf(context))
                .round(),
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : const Skeleton(
                child: SkeletonBox(height: double.infinity, radius: 0),
              ),
        errorBuilder: (context, error, stackTrace) => ColoredBox(
          color: colors.border,
          child: Center(
            child: Icon(
              Icons.broken_image_outlined,
              size: TSizes.iconLg,
              color: colors.iconInactive,
            ),
          ),
        ),
      ),
    );
  }
}
