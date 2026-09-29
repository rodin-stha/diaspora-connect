import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class TFormatters {
  TFormatters._();

  /// "3 Sep, 10:42 AM", in the app's current language.
  static String dateTime(BuildContext context, DateTime date) => DateFormat(
    'd MMM, h:mm a',
    Localizations.localeOf(context).toLanguageTag(),
  ).format(date);
}
