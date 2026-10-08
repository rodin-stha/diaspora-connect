import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/colors.dart';
import '../../../theme/sizes.dart';
import '../../../theme/text_styles.dart';
import '../models/announcement.dart';
import 'announcement_image.dart';

/// Opens [announcement] full screen, over the bottom nav.
void showAnnouncement(BuildContext context, Announcement announcement) =>
    showDialog<void>(
      context: context,
      useSafeArea: false,
      builder: (_) => AnnouncementViewer(announcement: announcement),
    );

/// An announcement's image, whole and zoomable (pinch, double-tap drag),
/// on a dark background, with its title and description if it has them.
/// Posters often have small print, unreadable in the carousel's crop.
class AnnouncementViewer extends StatelessWidget {
  final Announcement announcement;

  const AnnouncementViewer({super.key, required this.announcement});

  static const _maxZoom = 4.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final title = announcement.title;
    final description = announcement.description;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // White status bar icons on the dark background.
      value: SystemUiOverlayStyle.light,
      child: Dialog.fullscreen(
        backgroundColor: colors.inverseSurface,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  icon: Icon(Icons.close, color: colors.onInverseSurface),
                ),
              ),
              Expanded(
                child: InteractiveViewer(
                  maxScale: _maxZoom,
                  child: AnnouncementImage(
                    url: announcement.imageUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              if (title != null || description != null)
                // At most half the screen; a long description scrolls.
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(TSizes.pagePadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: TSizes.xs,
                      children: [
                        if (title != null)
                          Text(
                            title,
                            style: TTextStyles.titleMedium.copyWith(
                              color: colors.onInverseSurface,
                            ),
                          ),
                        if (description != null)
                          Text(
                            description,
                            style: TTextStyles.body.copyWith(
                              color: colors.onInverseSurface,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
