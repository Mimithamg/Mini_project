// TODO Implement this library.
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

const String dateTimeFormatPattern = 'dd/MM/yyyy';

extension DateTimeExtension on DateTime {
  /// Return a string representing [date] formatted according to our 1
  String format({
    String pattern = dateTimeFormatPattern,
    String? locale,
  }) {
    if (locale != null && locale.isNotEmpty) {
      initializeDateFormatting(locale);
    }

    return DateFormat(pattern, locale).format(this);
  }
}
