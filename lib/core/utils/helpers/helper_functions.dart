import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/colors.dart';
import '../formatters/formatters.dart';

class VHelperFunctions {
  VHelperFunctions._();
  // Colors Helper
  static Color? getColor(String value) {
    if (value == 'Green') {
      return Colors.green;
    } else if (value == 'Red') {
      return Colors.red;
    } else if (value == 'Blue') {
      return Colors.blue;
    } else if (value == 'Pink') {
      return Colors.pink;
    } else if (value == 'Grey') {
      return Colors.grey;
    } else if (value == 'Purple') {
      return Colors.purple;
    } else if (value == 'Black') {
      return Colors.black;
    } else if (value == 'White') {
      return Colors.white;
    } else if (value == 'Indigo') {
      return Colors.indigo;
    } else {
      return null;
    }
  }

  static String capitalize(String text) {
    if (text.isEmpty) {
      return text;
    }
    String capitalizedText = text[0].toUpperCase() + text.substring(1);
    return capitalizedText;
  }

  static void showSnackBar(
      {required BuildContext context,
      required String message,
      Color bgColor = VColors.error,
      Color messageColor = VColors.white,
      Color closeIconColor = VColors.white,
      bool showCloseIcon = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      dismissDirection: DismissDirection.horizontal,
      showCloseIcon: showCloseIcon,
      closeIconColor: closeIconColor,
      content: Text(
        message,
        style: const TextStyle().apply(color: messageColor),
      ),
      backgroundColor: bgColor,
    ));
  }

  static void showToasty(
          {required String message,
          Color backgroundColor = VColors.black,
          Color textColor = VColors.white,
          ToastGravity? gravity}) =>
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: gravity,
        timeInSecForIosWeb: 1,
        backgroundColor: backgroundColor,
        textColor: textColor,
        fontSize: 14.0,
      );
  static void showAlert(BuildContext context, String title, String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'))
            ],
          );
        });
  }

  static Future<void> showCustomDialog({
    required BuildContext context,
    required String title,
    required Widget content,
    required VoidCallback onSaved,
    String? buttonText,
  }) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: Text(title),
            content: content,
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: onSaved,
                child: Text(buttonText ?? 'Save'),
              )
            ],
          );
        });
  }

  static void navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    } else {
      return '${text.substring(0, maxLength)}...';
    }
  }

  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Size screenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  // static Future<void> scanBarcode(TextEditingController controller) async {
  //   final result = await BarcodeScanner.scan();
  //
  //   if (result.type == ResultType.Barcode) {
  //     controller.text =
  //         result.rawContent; // Update the controller with the scanned code
  //   }
  // }

  static String receiptNo(int id) {
    return '[#${id.toString().padLeft(4, '0')}]';
  }

  static String paymentStatus(double debtAmount) {
    return debtAmount == 0 ? 'Completed' : 'Pending';
  }

  static String calculateTotalPrice({
    required double subtotal,
    required double taxFee,
    required double discount,
    required double shippingFee,
  }) {
    final taxAmount = subtotal * (taxFee / 100);
    final discountAmount = subtotal * (discount / 100);
    final discountedAmount = subtotal - discountAmount;
    final total = discountedAmount + taxAmount + shippingFee;
    final formattedTotal = VFormatters.formatPrice(total);
    return formattedTotal;
  }

  static Future<void> makePhoneCall(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) return;
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    await launchUrl(launchUri);
  }

  static String detectDateFormat(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'Unknown'; // Handle null or empty case
    }

    // Define possible formats
    final formatPatterns = {
      // Common formats
      r'^\d{1,2}/\d{1,2}/\d{4}$': 'd/M/yyyy', // 1/9/2024 or 01/09/2024
      r'^\d{4}/\d{1,2}/\d{1,2}$': 'yyyy/M/d', // 2024/9/1 or 2024/09/01
      r'^\d{1,2}-\d{1,2}-\d{4}$': 'd-M-yyyy', // 1-9-2024 or 01-09-2024
      r'^\d{4}-\d{1,2}-\d{1,2}$': 'yyyy-M-d', // 2024-9-1 or 2024-09-01
      r'^\d{1,2}\.\d{1,2}\.\d{4}$': 'd.M.yyyy', // 1.9.2024 or 01.09.2024
      r'^\d{4}\.\d{1,2}\.\d{1,2}$': 'yyyy.M.d', // 2024.9.1 or 2024.09.01
      r'^\d{1,2} \d{1,2} \d{4}$': 'd M yyyy', // 1 9 2024 or 01 09 2024
      r'^\d{4} \d{1,2} \d{1,2}$': 'yyyy M d', // 2024 9 1 or 2024 09 01
      r'^\d{1,2}/\d{1,2}/\d{2}$': 'd/M/yy', // 1/9/24 or 01/09/24
      r'^\d{2}/\d{1,2}/\d{1,2}$': 'yy/M/d', // 24/9/1 or 24/09/01

      // Extended formats
      r'^\d{1,2} \w+ \d{4}$': 'd MMMM yyyy', // 1 January 2024
      r'^\w+ \d{1,2}, \d{4}$': 'MMMM d, yyyy', // January 1, 2024
      r'^\w+ \d{1,2} \d{4}$': 'MMMM d yyyy', // January 1 2024
      r'^\w+ \d{1,2}, \d{2}$': 'MMMM d, yy', // January 1, 24

      // ISO formats
      r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$':
          'yyyy-MM-ddTHH:mm:ssZ', // ISO 8601 with time
      r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\+\d{2}:\d{2}$':
          'yyyy-MM-ddTHH:mm:ss±HH:mm', // ISO with timezone

      // Other formats
      r'^\w+, \d{1,2} \w+ \d{4}$':
          'EEEE, d MMMM yyyy', // Monday, 1 January 2024
    };

    // Check the date string against each pattern
    for (var entry in formatPatterns.entries) {
      if (RegExp(entry.key).hasMatch(dateString)) {
        return entry.value; // Return the matched format
      }
    }

    return 'Unknown'; // If no format matches
  }
}
