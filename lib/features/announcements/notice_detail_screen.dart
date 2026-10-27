import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/image_cache_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/sizes.dart';
import '../../theme/text_styles.dart';
import '../../widgets/app_background.dart';
import '../../widgets/back_title_bar.dart';
import '../../widgets/image_viewer.dart';
import '../../widgets/load_error.dart';
import '../../widgets/skeleton.dart';
import 'data/notices_provider.dart';
import 'models/announcement.dart';
import 'widgets/announcement_photo.dart';

/// Shape of the placeholder while the image loads; the real one keeps its
/// own shape.
const _placeholderAspectRatio = 16 / 9;

/// One notice in full: its image (if it has one), title and whole
/// description.
class NoticeDetailScreen extends ConsumerWidget {
  final int id;

  const NoticeDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    // There's no endpoint for a single announcement, so find it in the
    // Notice list (already loaded when coming from the Notice tab).
    final feedAsync = ref.watch(noticesProvider);

    // Design uses 54px top padding, which sits just below the status bar.
    final topPadding = math.max(54.0, MediaQuery.paddingOf(context).top + 8);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: AppBackground(
        child: Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              TSizes.pagePadding,
              topPadding,
              TSizes.pagePadding,
              30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: TSizes.lg,
              children: [
                BackTitleBar(
                  title: l10n.noticeDetailTitle,
                  fallbackLocation: '/notices',
                ),
                switch (feedAsync) {
                  AsyncValue(:final value?) => switch (value.items
                      .where((announcement) => announcement.id == id)
                      .firstOrNull) {
                    final announcement? => _NoticeContent(
                      announcement: announcement,
                    ),
                    // E.g. removed by the admins since the list was loaded.
                    null => Text(
                      l10n.noticeNotFound,
                      textAlign: TextAlign.center,
                      style: TTextStyles.body.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  },
                  AsyncValue(hasError: true) => LoadError(
                    message: l10n.errorLoadAnnouncements,
                    onRetry: () => ref.invalidate(noticesProvider),
                  ),
                  _ => const Skeleton(
                    child: AspectRatio(
                      aspectRatio: _placeholderAspectRatio,
                      child: SkeletonBox(
                        height: double.infinity,
                        radius: TSizes.cardRadius,
                      ),
                    ),
                  ),
                },
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NoticeContent extends ConsumerWidget {
  final Announcement announcement;

  const _NoticeContent({required this.announcement});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final title = announcement.title;
    final description = announcement.description;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: TSizes.lg,
      children: [
        if (announcement.image == null && hasFallbackImage(ref))
          // No image of its own: the fallback, cropped like in the list.
          // Not zoomable: it's decoration, not content.
          ClipRRect(
            borderRadius: BorderRadius.circular(TSizes.cardRadius),
            child: const AspectRatio(
              aspectRatio: _placeholderAspectRatio,
              child: AnnouncementPhoto(image: null),
            ),
          ),
        if (announcement.image case final image?)
          // Tap to zoom: posters often have small print.
          Semantics(
            button: true,
            label: l10n.zoomImage,
            child: GestureDetector(
              onTap: () => showImageViewer(context, image.url),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(TSizes.cardRadius),
                child: _WholeImage(url: image.url),
              ),
            ),
          ),
        if (title != null)
          Text(
            title,
            style: TTextStyles.headlineSmall.copyWith(
              color: colors.textPrimary,
            ),
          ),
        if (description != null)
          Text(
            description,
            style: TTextStyles.body.copyWith(color: colors.textPrimary),
          ),
      ],
    );
  }
}

/// A network image at full width and its own height, so nothing is cropped.
/// Saved to the device once loaded, so it still shows offline.
///
/// Not [NetworkPhoto]: that one fills a box of a given size, and here the
/// height comes from the image.
class _WholeImage extends ConsumerWidget {
  final String url;

  const _WholeImage({required this.url});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) => CachedNetworkImage(
        imageUrl: url,
        cacheKey: imageCacheKey(url),
        cacheManager: ref.watch(imageCacheProvider),
        width: double.infinity,
        fit: BoxFit.fitWidth,
        // Decode at the size it's shown, not the original (often 2000px+).
        memCacheWidth:
            (constraints.maxWidth * MediaQuery.devicePixelRatioOf(context))
                .round(),
        placeholder: (context, url) => const Skeleton(
          child: AspectRatio(
            aspectRatio: _placeholderAspectRatio,
            child: SkeletonBox(height: double.infinity, radius: 0),
          ),
        ),
        // Broken link: the fallback image instead.
        errorWidget: (context, url, error) => const AspectRatio(
          aspectRatio: _placeholderAspectRatio,
          child: AnnouncementPhoto(image: null),
        ),
      ),
    );
  }
}
