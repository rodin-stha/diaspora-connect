import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/image_cache_provider.dart';
import '../theme/colors.dart';
import '../theme/sizes.dart';
import 'skeleton.dart';

/// An image from the network, filling its box: a pulsing placeholder
/// while it loads, an icon if it can't.
///
/// Saved to the device once loaded, so it still shows offline.
class NetworkPhoto extends ConsumerWidget {
  final String url;

  /// [BoxFit.cover] crops to fill (carousel, thumbnail); [BoxFit.contain]
  /// shows it whole (full-screen view).
  final BoxFit fit;

  /// Shown instead if the image can't load. Defaults to a broken-image
  /// icon.
  final Widget? fallback;

  const NetworkPhoto({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;

    return LayoutBuilder(
      builder: (context, constraints) => CachedNetworkImage(
        imageUrl: url,
        cacheKey: imageCacheKey(url),
        cacheManager: ref.watch(imageCacheProvider),
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        // Decode at the size it's shown, not the original (often 2000px+
        // and over 1 MB): far less memory for the same sharpness.
        memCacheWidth:
            (constraints.maxWidth * MediaQuery.devicePixelRatioOf(context))
                .round(),
        placeholder: (context, url) => const Skeleton(
          child: SkeletonBox(height: double.infinity, radius: 0),
        ),
        errorWidget: (context, url, error) =>
            fallback ??
            ColoredBox(
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
