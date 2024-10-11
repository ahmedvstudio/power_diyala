import 'package:intl/intl.dart';

DateTime parseDate(String? date) {
  if (date == null || date.isEmpty) return DateTime.parse('1970-01-01');

  String format = detectDateFormat(date);

  if (format == 'Unknown') {
    return DateTime.parse('1970-01-01'); // Fallback
  }

  return DateFormat(format).parse(date);
}

String detectDateFormat(String? dateString) {
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
    r'^\w+, \d{1,2} \w+ \d{4}$': 'EEEE, d MMMM yyyy', // Monday, 1 January 2024
  };

  // Check the date string against each pattern
  for (var entry in formatPatterns.entries) {
    if (RegExp(entry.key).hasMatch(dateString)) {
      return entry.value; // Return the matched format
    }
  }

  return 'Unknown'; // If no format matches
}
