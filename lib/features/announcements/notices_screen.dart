import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/sizes.dart';
import '../../theme/text_styles.dart';
import '../../widgets/app_background.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/load_error.dart';
import '../../widgets/network_photo.dart';
import '../../widgets/skeleton.dart';
import 'data/announcements_provider.dart';
import 'models/announcement.dart';

/// Wide, like the posters' usual shape. Tapping one shows it whole.
const _imageAspectRatio = 16 / 9;

// Placeholder cards while loading: enough to fill most of the screen.
const _skeletonCount = 3;

/// The Notice tab: every Embassy and DoFE announcement, newest first.
class NoticesScreen extends ConsumerWidget {
  const NoticesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final announcementsAsync = ref.watch(allAnnouncementsProvider);

    // Design uses 54px top padding, which sits just below the status bar.
    final topPadding = math.max(54.0, MediaQuery.paddingOf(context).top + 8);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: AppBackground(
        child: Scaffold(
          body: RefreshIndicator(
            onRefresh: () => ref.refresh(allAnnouncementsProvider.future),
            child: SingleChildScrollView(
              // Lets the pull work even when the list is too short to scroll.
              physics: const AlwaysScrollableScrollPhysics(),
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
                  Text(
                    l10n.noticesTitle,
                    style: TTextStyles.titleLarge.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  switch (announcementsAsync) {
                    // Checked first: while refetching for fresh image links,
                    // keep showing the current ones.
                    AsyncValue(:final value?) when value.isNotEmpty => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: TSizes.listGap,
                      children: [
                        for (final announcement in value)
                          _NoticeCard(announcement: announcement),
                      ],
                    ),
                    AsyncValue(value: []) => EmptyState(
                      iconAsset: 'assets/icons/inbox.svg',
                      message: l10n.noNoticesYet,
                    ),
                    AsyncValue(hasError: true) => LoadError(
                      message: l10n.errorLoadAnnouncements,
                      onRetry: () => ref.invalidate(allAnnouncementsProvider),
                    ),
                    _ => Skeleton(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: TSizes.listGap,
                        children: [
                          for (var i = 0; i < _skeletonCount; i++)
                            const AspectRatio(
                              aspectRatio: _imageAspectRatio,
                              child: SkeletonBox(
                                height: double.infinity,
                                radius: TSizes.cardRadius,
                              ),
                            ),
                        ],
                      ),
                    ),
                  },
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One announcement: its image, then its title and the start of its
/// description. Tapping opens the whole notice.
class _NoticeCard extends StatelessWidget {
  final Announcement announcement;

  const _NoticeCard({required this.announcement});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final title = announcement.title;
    final description = announcement.description;

    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TSizes.cardRadius),
        side: BorderSide(color: colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/notices/${announcement.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: _imageAspectRatio,
              child: NetworkPhoto(url: announcement.imageUrl),
            ),
            if (title != null || description != null)
              Padding(
                padding: const EdgeInsets.all(TSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: TSizes.xs,
                  children: [
                    if (title != null)
                      Text(
                        title,
                        style: TTextStyles.titleSmall.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    if (description != null)
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TTextStyles.bodySmall.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
