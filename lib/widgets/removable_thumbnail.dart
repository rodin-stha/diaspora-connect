import 'dart:io';

import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/sizes.dart';

/// A small square preview of a photo on this device, with a ✕ in the
/// corner to remove it.
class RemovableThumbnail extends StatelessWidget {
  final String imagePath;
  final VoidCallback onRemove;

  const RemovableThumbnail({
    super.key,
    required this.imagePath,
    required this.onRemove,
  });

  static const double size = 64;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox.square(
      dimension: size,
      child: Stack(
        // Lets the ✕ hang slightly over the corner.
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(TSizes.inputRadius),
            child: Image.file(
              File(imagePath),
              width: size,
              height: size,
              fit: BoxFit.cover,
              // Decode at thumbnail size, not the photo's full resolution.
              cacheWidth: (size * MediaQuery.devicePixelRatioOf(context))
                  .round(),
            ),
          ),
          Positioned(
            top: -6,
            right: -6,
            child: Material(
              color: colors.textPrimary,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onRemove,
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: Icon(
                    Icons.close,
                    size: TSizes.iconXs,
                    color: colors.surface,
                    semanticLabel: MaterialLocalizations.of(
                      context,
                    ).deleteButtonTooltip,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
