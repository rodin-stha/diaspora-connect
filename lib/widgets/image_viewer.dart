import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/colors.dart';
import 'network_photo.dart';

/// Opens the image at [url] full screen, over the bottom nav.
void showImageViewer(BuildContext context, String url) => showDialog<void>(
  context: context,
  useSafeArea: false,
  builder: (_) => _ImageViewer(url: url),
);

/// A network image, whole and zoomable (pinch, double-tap drag), on a dark
/// background with ✕ to close.
class _ImageViewer extends StatelessWidget {
  final String url;

  const _ImageViewer({required this.url});

  static const _maxZoom = 4.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
                  child: NetworkPhoto(url: url, fit: BoxFit.contain),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
