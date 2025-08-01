import 'package:intl/intl.dart';
import 'package:power_diyala/core/utils/helpers/helper_functions.dart';

class VFormatters {
  VFormatters._();
  //
  static String formatDate(DateTime date) {
    return DateFormat('dd-MM-yyy').format(date);
  }

  //
  static formatPrice(double price) => price.toStringAsFixed(2);

  //
  static String formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'en_US', symbol: '\$').format(amount);
  }

  //
  static formatPhoneNumber(String phoneNumber) {
    // Assuming format : (123) 456-7890
    if (phoneNumber.length == 10) {
      return '(${phoneNumber.substring(0, 3)}) ${phoneNumber.substring(3, 6)} ${phoneNumber.substring(6)}';
    } else if (phoneNumber.length == 11) {
      return '(${phoneNumber.substring(0, 4)}) ${phoneNumber.substring(4, 7)} ${phoneNumber.substring(7)}';
    }

    // Add more formatting if needed
    return phoneNumber;
  }

  static String buildFullAddress(List<String?> components) {
    return components.where((e) => e != null && e.isNotEmpty).join(', ');
  }

  static DateTime advancedDateFormater(String? date) {
    if (date == null || date.isEmpty) return DateTime.parse('1970-01-01');
    String format = VHelperFunctions.detectDateFormat(date);
    if (format == 'Unknown') {
      return DateTime.parse('1970-01-01'); // Fallback
    }

    return DateFormat(format).parse(date);
  }
}
