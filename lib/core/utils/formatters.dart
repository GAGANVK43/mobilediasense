import 'package:intl/intl.dart';

class Formatters {
  static String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatDateTime(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  static String formatPercentage(double? value) {
    if (value == null) return '0%';
    return '%';
  }

  static String formatDecimal(double? value, {int fractionDigits = 1}) {
    if (value == null) return '0';
    return value.toStringAsFixed(fractionDigits);
  }
}
