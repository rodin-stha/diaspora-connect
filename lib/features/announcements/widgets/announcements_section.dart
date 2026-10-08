import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/colors.dart';
import '../../../theme/sizes.dart';
import '../../../theme/text_styles.dart';
import '../../../widgets/load_error.dart';
import '../../../widgets/page_dots.dart';
import '../../../widgets/skeleton.dart';
import '../data/announcements_provider.dart';
import '../models/announcement.dart';
import 'announcement_image.dart';
import 'announcement_viewer.dart';

/// Wide, like a banner. Posters are cropped to fit; tapping one shows it
/// whole.
const _aspectRatio = 16 / 9;

/// "Announcements" on Home: a swipeable carousel of the latest Embassy and
/// DoFE announcement images. Shows nothing if there are none.
///
/// Includes the space below it, so Home has no gap when it's hidden.
class AnnouncementsSection extends ConsumerWidget {
  const AnnouncementsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final announcementsAsync = ref.watch(announcementsProvider);

    final Widget content;
    switch (announcementsAsync) {
      // Checked first: while refetching for fresh image links, keep
      // showing the current ones.
      case AsyncValue(:final value?) when value.isNotEmpty:
        content = _Carousel(announcements: value);
      case AsyncValue(value: []):
        return const SizedBox.shrink();
      case AsyncValue(hasError: true):
        content = LoadError(
          message: l10n.errorLoadAnnouncements,
          onRetry: () => ref.invalidate(announcementsProvider),
        );
      case _:
        content = const Skeleton(
          child: AspectRatio(
            aspectRatio: _aspectRatio,
            child: SkeletonBox(
              height: double.infinity,
              radius: TSizes.cardRadius,
            ),
          ),
        );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: TSizes.spaceBtwSections),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: TSizes.md,
        children: [
          Text(
            l10n.announcements,
            style: TTextStyles.titleSmall.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          content,
        ],
      ),
    );
  }
}

class _Carousel extends StatefulWidget {
  final List<Announcement> announcements;

  const _Carousel({required this.announcements});

  @override
  State<_Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<_Carousel> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final announcements = widget.announcements;
    // A refetch can bring fewer announcements than before.
    final page = _page.clamp(0, announcements.length - 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: TSizes.md,
      children: [
        AspectRatio(
          aspectRatio: _aspectRatio,
          child: PageView.builder(
            controller: _controller,
            itemCount: announcements.length,
            onPageChanged: (index) => setState(() => _page = index),
            itemBuilder: (context, index) {
              final announcement = announcements[index];
              return Semantics(
                button: true,
                label:
                    announcement.title ??
                    l10n.announcementLabel(index + 1, announcements.length),
                child: GestureDetector(
                  onTap: () => showAnnouncement(context, announcement),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(TSizes.cardRadius),
                    child: AnnouncementImage(url: announcement.imageUrl),
                  ),
                ),
              );
            },
          ),
        ),
        if (announcements.length > 1)
          PageDots(count: announcements.length, current: page),
      ],
    );
  }
}
