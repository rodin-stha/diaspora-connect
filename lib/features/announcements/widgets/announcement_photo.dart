import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/colors.dart';
import '../../../theme/sizes.dart';
import '../../../widgets/network_photo.dart';
import '../../platform_settings/data/fallback_image_provider.dart';
import '../models/announcement.dart';

/// An announcement's picture, filling its box: its own image, or the
/// admins' fallback image when it has none or it can't load.
class AnnouncementPhoto extends ConsumerWidget {
  final AnnouncementImage? image;
  final BoxFit fit;

  const AnnouncementPhoto({
    super.key,
    required this.image,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fallback = _Fallback(
      file: ref.watch(fallbackImageProvider).value,
      fit: fit,
    );
    final image = this.image;
    if (image == null) return fallback;
    return NetworkPhoto(url: image.url, fit: fit, fallback: fallback);
  }
}

/// Whether there's a fallback image to show for announcements without one.
/// Until there is, those have no picture area at all.
bool hasFallbackImage(WidgetRef ref) =>
    ref.watch(fallbackImageProvider).value != null;

class _Fallback extends StatelessWidget {
  final File? file;
  final BoxFit fit;

  const _Fallback({required this.file, required this.fit});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // No fallback (not set, or not downloaded yet): the same plain box a
    // broken image gets.
    final placeholder = ColoredBox(
      color: colors.border,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: TSizes.iconLg,
          color: colors.iconInactive,
        ),
      ),
    );
    final file = this.file;
    if (file == null) return placeholder;

    return LayoutBuilder(
      builder: (context, constraints) => Image.file(
        file,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        // Decode at the size it's shown (the file is often 1 MB+).
        cacheWidth:
            (constraints.maxWidth * MediaQuery.devicePixelRatioOf(context))
                .round(),
        errorBuilder: (context, error, stackTrace) => placeholder,
      ),
    );
  }
}
