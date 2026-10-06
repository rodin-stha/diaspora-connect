import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../l10n/app_localizations.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

/// Asks "Take photo" or "Choose from gallery", then opens the camera or the
/// photo library. Returns the picked image, or null if the user cancelled
/// either step.
///
/// Shows a message instead if the user has denied camera or photo access.
Future<XFile?> pickImage(BuildContext context) async {
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: context.colors.surface,
    showDragHandle: true,
    builder: (_) => const _ImageSourceSheet(),
  );
  if (source == null || !context.mounted) return null;

  try {
    return await ImagePicker().pickImage(
      source: source,
      // Document photos stay readable at this size, and it keeps uploads
      // small on slow connections.
      maxWidth: 2000,
      imageQuality: 85,
    );
  } on PlatformException {
    // Thrown when access was denied, e.g. "camera_access_denied" on iOS.
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).errorImageAccess),
        ),
      );
    }
    return null;
  }
}

class _ImageSourceSheet extends StatelessWidget {
  const _ImageSourceSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final textStyle = TTextStyles.body.copyWith(color: colors.textPrimary);

    // Popping with a value is how a sheet returns its result, like
    // resolving a promise.
    Widget option(IconData icon, String label, ImageSource source) => ListTile(
      leading: Icon(icon, color: colors.iconDefault),
      title: Text(label, style: textStyle),
      onTap: () => Navigator.pop(context, source),
    );

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          option(
            Icons.photo_camera_outlined,
            l10n.takePhoto,
            ImageSource.camera,
          ),
          option(
            Icons.photo_library_outlined,
            l10n.chooseFromGallery,
            ImageSource.gallery,
          ),
        ],
      ),
    );
  }
}
