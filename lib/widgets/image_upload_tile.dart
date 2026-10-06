import 'dart:io';

import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/sizes.dart';
import '../theme/text_styles.dart';
import 'dashed_tile.dart';

/// An upload slot for one photo ("Photo page"). Empty, it's a dashed "+"
/// tile; once a photo is picked it shows a preview. Tapping either calls
/// [onTap] to pick (or replace) the photo.
class ImageUploadTile extends StatelessWidget {
  final String label;

  /// Path of the picked photo on this device; null shows the empty tile.
  final String? imagePath;
  final VoidCallback? onTap;
  final bool hasError;

  const ImageUploadTile({
    super.key,
    required this.label,
    required this.imagePath,
    required this.onTap,
    this.hasError = false,
  });

  static const double _previewHeight = 72;

  @override
  Widget build(BuildContext context) {
    final path = imagePath;
    if (path == null) {
      return DashedTile.large(
        label: label,
        iconAsset: 'assets/icons/plus_bold.svg',
        onTap: onTap,
        hasError: hasError,
      );
    }

    final colors = context.colors;
    final radius = BorderRadius.circular(TSizes.inputRadius);

    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: colors.border),
      ),
      // Clips the photo and the tap ripple to the rounded corners.
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Image.file(
              File(path),
              height: _previewHeight,
              width: double.infinity,
              fit: BoxFit.cover,
              // Decode at preview size, not the photo's full resolution.
              cacheHeight:
                  (_previewHeight * MediaQuery.devicePixelRatioOf(context))
                      .round(),
            ),
            Padding(
              padding: const EdgeInsets.all(TSizes.sm),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TTextStyles.bodySmall.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
