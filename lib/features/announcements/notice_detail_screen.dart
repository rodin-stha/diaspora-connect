import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/sizes.dart';
import '../../theme/text_styles.dart';
import '../../widgets/app_background.dart';
import '../../widgets/back_title_bar.dart';
import '../../widgets/image_viewer.dart';
import '../../widgets/load_error.dart';
import '../../widgets/skeleton.dart';
import 'data/announcements_provider.dart';
import 'models/announcement.dart';

/// Shape of the placeholder while the image loads; the real one keeps its
/// own shape.
const _placeholderAspectRatio = 16 / 9;

/// One notice in full: its image, title and whole description.
class NoticeDetailScreen extends ConsumerWidget {
  final int id;

  const NoticeDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    // There's no endpoint for a single announcement, so find it in the
    // Notice list (already loaded when coming from the Notice tab).
    final announcementsAsync = ref.watch(allAnnouncementsProvider);

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
                switch (announcementsAsync) {
                  AsyncValue(:final value?) => switch (value
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
                    onRetry: () => ref.invalidate(allAnnouncementsProvider),
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

class _NoticeContent extends StatelessWidget {
  final Announcement announcement;

  const _NoticeContent({required this.announcement});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final title = announcement.title;
    final description = announcement.description;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: TSizes.lg,
      children: [
        // Tap to zoom: posters often have small print.
        Semantics(
          button: true,
          label: l10n.zoomImage,
          child: GestureDetector(
            onTap: () => showImageViewer(context, announcement.imageUrl),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(TSizes.cardRadius),
              child: _WholeImage(url: announcement.imageUrl),
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
///
/// Not [NetworkPhoto]: that one fills a box of a given size, and here the
/// height comes from the image.
class _WholeImage extends StatelessWidget {
  final String url;

  const _WholeImage({required this.url});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return LayoutBuilder(
      builder: (context, constraints) => Image.network(
        url,
        width: double.infinity,
        fit: BoxFit.fitWidth,
        // Decode at the size it's shown, not the original (often 2000px+).
        cacheWidth:
            (constraints.maxWidth * MediaQuery.devicePixelRatioOf(context))
                .round(),
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : const Skeleton(
                child: AspectRatio(
                  aspectRatio: _placeholderAspectRatio,
                  child: SkeletonBox(height: double.infinity, radius: 0),
                ),
              ),
        errorBuilder: (context, error, stackTrace) => AspectRatio(
          aspectRatio: _placeholderAspectRatio,
          child: ColoredBox(
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
      ),
    );
  }
}
