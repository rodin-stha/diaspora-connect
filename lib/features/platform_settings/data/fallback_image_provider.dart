import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../app/api/api_exception.dart';
import '../../../app/locale_provider.dart';
import '../models/platform_settings.dart';
import 'platform_settings_provider.dart';

/// The name of the saved file, so it's found again after a restart.
const _savedFileKey = 'fallback_image_file';

/// The fallback image (see [PlatformSettings.fallbackImage]) as a file on
/// the device, or null if there's none.
///
/// Downloaded once and kept in the app's private storage: the API's link
/// expires after about an hour, and a saved copy also works offline.
/// Downloaded again only when the admins change the image.
final fallbackImageProvider = FutureProvider<File?>((ref) async {
  final prefs = ref.read(sharedPreferencesProvider);
  final dir = await getApplicationSupportDirectory();

  File? savedFile() {
    final name = prefs.getString(_savedFileKey);
    if (name == null) return null;
    final file = File('${dir.path}/$name');
    return file.existsSync() ? file : null;
  }

  final PlatformSettings settings;
  try {
    settings = await ref.watch(platformSettingsProvider.future);
  } on ApiException {
    // Couldn't reach the API (offline…): use the copy from last time.
    return savedFile();
  }

  final image = settings.fallbackImage;
  if (image == null) {
    // The admins removed it.
    savedFile()?.deleteSync();
    await prefs.remove(_savedFileKey);
    return null;
  }

  // The id in the name: a new image gets a new file.
  final extension = image.fileName.contains('.')
      ? image.fileName.substring(image.fileName.lastIndexOf('.'))
      : '';
  final name = 'fallback_image_${image.id}$extension';
  final file = File('${dir.path}/$name');
  if (file.existsSync()) return file;

  try {
    // To a temporary name first, so a half-finished download is never
    // mistaken for the image.
    final partial = '${file.path}.part';
    await Dio().download(image.url, partial);
    await File(partial).rename(file.path);
  } on DioException {
    return savedFile(); // try again next launch
  } on FileSystemException {
    return savedFile();
  }

  // Replace the old image, if any.
  final old = savedFile();
  if (old != null && old.path != file.path) old.deleteSync();
  await prefs.setString(_savedFileKey, name);
  return file;
});
