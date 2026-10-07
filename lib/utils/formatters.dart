import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class TFormatters {
  TFormatters._();

  /// "3 Sep, 10:42 AM", in the app's current language.
  static String dateTime(BuildContext context, DateTime date) => DateFormat(
    'd MMM, h:mm a',
    Localizations.localeOf(context).toLanguageTag(),
  ).format(date);

  /// "3 Sep 2026", in the app's current language.
  static String date(BuildContext context, DateTime date) => DateFormat(
    'd MMM yyyy',
    Localizations.localeOf(context).toLanguageTag(),
  ).format(date);

  /// "03/09/1995" (DD/MM/YYYY), for date inputs. Always Latin digits, to
  /// match what people type and what official forms use.
  static String shortDate(DateTime date) =>
      DateFormat('dd/MM/yyyy').format(date);

  /// "1:05", for recording timers and audio lengths.
  static String duration(Duration duration) {
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '${duration.inMinutes}:$seconds';
  }
}
