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
import '../../widgets/load_more_scroll_view.dart';
import '../../widgets/network_photo.dart';
import '../../widgets/skeleton.dart';
import 'data/notices_provider.dart';
import 'models/announcement.dart';

/// Wide, like the posters' usual shape. Tapping one shows it whole.
const _imageAspectRatio = 16 / 9;

// Placeholder cards while loading: enough to fill most of the screen.
const _skeletonCount = 3;

/// The Notice tab: every Embassy and DoFE announcement, newest first, a
/// page at a time as the user scrolls.
class NoticesScreen extends ConsumerWidget {
  const NoticesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final listAsync = ref.watch(noticesProvider);
    final list = listAsync.value;
    void loadMore() => ref.read(noticesProvider.notifier).loadMore();

    // Design uses 54px top padding, which sits just below the status bar.
    final topPadding = math.max(54.0, MediaQuery.paddingOf(context).top + 8);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: AppBackground(
        child: Scaffold(
          body: RefreshIndicator(
            onRefresh: () => ref.refresh(noticesProvider.future),
            child: LoadMoreScrollView(
              canLoadMore: list != null && list.hasMore && !list.loadMoreFailed,
              onLoadMore: loadMore,
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
                  switch (listAsync) {
                    // Checked first: while refreshing, keep showing the
                    // current list.
                    AsyncValue(:final value?) when value.items.isNotEmpty =>
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: TSizes.listGap,
                        children: [
                          for (final announcement in value.items)
                            _NoticeCard(announcement: announcement),
                          if (value.isLoadingMore || value.loadMoreFailed)
                            LoadMoreFooter(
                              isLoading: value.isLoadingMore,
                              failed: value.loadMoreFailed,
                              errorMessage: l10n.errorLoadAnnouncements,
                              onRetry: loadMore,
                              skeleton: const _NoticeCardSkeleton(),
                            ),
                        ],
                      ),
                    AsyncValue(hasValue: true) => EmptyState(
                      iconAsset: 'assets/icons/inbox.svg',
                      message: l10n.noNoticesYet,
                    ),
                    AsyncValue(hasError: true) => LoadError(
                      message: l10n.errorLoadAnnouncements,
                      onRetry: () => ref.invalidate(noticesProvider),
                    ),
                    _ => Skeleton(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: TSizes.listGap,
                        children: [
                          for (var i = 0; i < _skeletonCount; i++)
                            const _NoticeCardSkeleton(),
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

/// One announcement: its image (if it has one), then its title and the
/// start of its description. Tapping opens the whole notice.
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
            if (announcement.image case final image?)
              AspectRatio(
                aspectRatio: _imageAspectRatio,
                child: NetworkPhoto(url: image.url),
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

/// Placeholder for a [_NoticeCard] while it loads: the image, a title line
/// and two description lines. Put it inside a [Skeleton] so it pulses.
class _NoticeCardSkeleton extends StatelessWidget {
  const _NoticeCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(TSizes.cardRadius),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AspectRatio(
            aspectRatio: _imageAspectRatio,
            child: SkeletonBox(
              height: double.infinity,
              radius: TSizes.cardRadius,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(TSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: TSizes.sm,
              children: const [
                SkeletonBox(width: 160, height: 14),
                SkeletonBox(height: 10),
                SkeletonBox(width: 220, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
