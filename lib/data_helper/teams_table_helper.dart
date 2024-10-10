import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

final Logger logger = kDebugMode ? Logger() : Logger(printer: PrettyPrinter());
final DateTime defaultDate = DateTime(1970);

// For Teams table
class Teams {
  final String sitesPm;
  final DateTime datesPm;
  final String region;
  final String powerEng;
  final String genTech;
  final String electricTech;
  final String telecomEng;
  final String telecomTech;

  Teams({
    required this.sitesPm,
    required this.datesPm,
    required this.region,
    required this.powerEng,
    required this.genTech,
    required this.electricTech,
    required this.telecomEng,
    required this.telecomTech,
  });

  // Helper method to parse dates safely
  static DateTime parseDate(String? dateString) {
    if (dateString != null && dateString.isNotEmpty) {
      try {
        return DateFormat("d/M/yyyy").parse(dateString);
      } catch (e) {
        // Use logger instead of print
        logger.e("Error parsing date: $e");
      }
    }
    return defaultDate; // Return default date if null or parse fails
  }

  factory Teams.fromMap(Map<String, dynamic> map) {
    return Teams(
      sitesPm: (map['Sites'] as String?) ?? 'Unknown Site',
      datesPm: parseDate(map['Date']),
      region: (map['Region'] as String?) ?? 'Unknown Region',
      powerEng: (map['P_Eng'] as String?) ?? 'Unknown Engineer',
      genTech: (map['G_Tech'] as String?) ?? 'Unknown Technician',
      electricTech: (map['E_Tech'] as String?) ?? 'Unknown Technician',
      telecomEng: (map['T_Eng'] as String?) ?? 'Unknown Region',
      telecomTech: (map['T_Tech'] as String?) ?? 'Unknown Technician',
    );
  }

  dynamic getFieldByName(String fieldName) {
    switch (fieldName) {
      case 'sitesPm':
        return sitesPm;
      case 'datesPm':
        return datesPm;
      case 'region':
        return region;
      case 'powerEng':
        return powerEng;
      case 'genTech':
        return genTech;
      case 'electricTech':
        return electricTech;
      case 'telecomEng':
        return telecomEng;
      case 'telecomTech':
        return telecomTech;
      default:
        return null; // Return null if the field name is not recognized
    }
  }
}
