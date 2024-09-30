import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();
final DateTime defaultDate = DateTime(1970);

// For SPMS table
class Spms {
  final String siteName;
  final String siteCode;
  final double kvaG1;
  final double kvaG2;
  final DateTime starterG1;
  final DateTime starterG2;
  final DateTime dynamoG1;
  final DateTime dynamoG2;
  final DateTime protectionG1;
  final DateTime protectionG2;
  final DateTime avrG1;
  final DateTime avrG2;
  final DateTime chargerG1;
  final DateTime chargerG2;
  final DateTime selenoidG1;
  final DateTime selenoidG2;
  final DateTime radiatorG1;
  final DateTime radiatorG2;
  final DateTime fanbeltG1;
  final DateTime fanbeltG2;
  final DateTime waterpumpG1;
  final DateTime waterpumpG2;
  final DateTime waterpulleyG1;
  final DateTime waterpulleyG2;
  final DateTime levelsensorG1;
  final DateTime levelsensorG2;
  final DateTime oilsensorG1;
  final DateTime oilsensorG2;
  final DateTime rockerG1;
  final DateTime rockerG2;
  final DateTime cylinderG1;
  final DateTime cylinderG2;
  final DateTime rearG1;
  final DateTime rearG2;
  final DateTime frontG1;
  final DateTime frontG2;
  final DateTime panG1;
  final DateTime panG2;
  final DateTime timingG1;
  final DateTime timingG2;
  final DateTime injectionG1;
  final DateTime injectionG2;
  final DateTime liftpumpG1;
  final DateTime liftpumpG2;
  final DateTime noozleG1;
  final DateTime noozleG2;
  final DateTime batteryG1;
  final DateTime batteryG2;
  final DateTime tempG1;
  final DateTime tempG2;

  Spms({
    required this.siteName,
    required this.siteCode,
    required this.kvaG1,
    required this.kvaG2,
    required this.starterG1,
    required this.starterG2,
    required this.dynamoG1,
    required this.dynamoG2,
    required this.protectionG1,
    required this.protectionG2,
    required this.avrG1,
    required this.avrG2,
    required this.chargerG1,
    required this.chargerG2,
    required this.selenoidG1,
    required this.selenoidG2,
    required this.radiatorG1,
    required this.radiatorG2,
    required this.fanbeltG1,
    required this.fanbeltG2,
    required this.waterpumpG1,
    required this.waterpumpG2,
    required this.waterpulleyG1,
    required this.waterpulleyG2,
    required this.levelsensorG1,
    required this.levelsensorG2,
    required this.oilsensorG1,
    required this.oilsensorG2,
    required this.rockerG1,
    required this.rockerG2,
    required this.cylinderG1,
    required this.cylinderG2,
    required this.rearG1,
    required this.rearG2,
    required this.frontG1,
    required this.frontG2,
    required this.panG1,
    required this.panG2,
    required this.timingG1,
    required this.timingG2,
    required this.injectionG1,
    required this.injectionG2,
    required this.liftpumpG1,
    required this.liftpumpG2,
    required this.noozleG1,
    required this.noozleG2,
    required this.batteryG1,
    required this.batteryG2,
    required this.tempG1,
    required this.tempG2,
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

  // Method to convert DateTime to String, returning 'N/A' if null or default date
  String formatDate(DateTime? date) {
    if (date == null || date == defaultDate) {
      return 'N/A';
    }
    return DateFormat('d/M/yyyy').format(date);
  }

  factory Spms.fromMap(Map<String, dynamic> map) {
    return Spms(
      siteName: (map['Sitename'] as String?) ?? 'Unknown Site',
      siteCode: (map['SiteCode'] as String?) ?? 'Unknown Code',
      kvaG1: double.tryParse(map['KVA_G1']?.toString() ?? '0') ?? 0.0,
      kvaG2: double.tryParse(map['KVA_G2']?.toString() ?? '0') ?? 0.0,
      starterG1: parseDate(map['StarterMotor_G1']),
      starterG2: parseDate(map['StarterMotor_G2']),
      dynamoG1: parseDate(map['Dynamo_G1']),
      dynamoG2: parseDate(map['Dynamo_G2']),
      protectionG1: parseDate(map['ProtectionControl_G1']),
      protectionG2: parseDate(map['ProtectionControl_G2']),
      avrG1: parseDate(map['AVR_G1']),
      avrG2: parseDate(map['AVR_G2']),
      chargerG1: parseDate(map['Charger_G1']),
      chargerG2: parseDate(map['Charger_G2']),
      selenoidG1: parseDate(map['Solenoid_G1']),
      selenoidG2: parseDate(map['Solenoid_G2']),
      radiatorG1: parseDate(map['Radiator_G1']),
      radiatorG2: parseDate(map['Radiator_G2']),
      fanbeltG1: parseDate(map['Fanbelt_G1']),
      fanbeltG2: parseDate(map['Fanbelt_G2']),
      waterpumpG1: parseDate(map['WaterPump_G1']),
      waterpumpG2: parseDate(map['WaterPump_G2']),
      waterpulleyG1: parseDate(map['WaterPumpPulley_G1']),
      waterpulleyG2: parseDate(map['WaterPumpPulley_G2']),
      levelsensorG1: parseDate(map['CoolantLevelSensor_G1']),
      levelsensorG2: parseDate(map['CoolantLevelSensor_G2']),
      oilsensorG1: parseDate(map['OilSensor_G1']),
      oilsensorG2: parseDate(map['OilSensor_G2']),
      rockerG1: parseDate(map['RockerArmGasket_G1']),
      rockerG2: parseDate(map['RockerArmGasket_G2']),
      cylinderG1: parseDate(map['CylinderHeadCoverGasket_G1']),
      cylinderG2: parseDate(map['CylinderHeadCoverGasket_G2']),
      rearG1: parseDate(map['RearOilSeal_G1']),
      rearG2: parseDate(map['RearOilSeal_G2']),
      frontG1: parseDate(map['FrontOilSeal_G1']),
      frontG2: parseDate(map['FrontOilSeal_G2']),
      panG1: parseDate(map['OilPanGasket_G1']),
      panG2: parseDate(map['OilPanGasket_G2']),
      timingG1: parseDate(map['TimingCaseWasher_G1']),
      timingG2: parseDate(map['TimingCaseWasher_G2']),
      injectionG1: parseDate(map['FuelInjectionPump_G1']),
      injectionG2: parseDate(map['FuelInjectionPump_G2']),
      liftpumpG1: parseDate(map['FuelLiftPump_G1']),
      liftpumpG2: parseDate(map['FuelLiftPump_G2']),
      noozleG1: parseDate(map['FuelInjectionNozzle_G1']),
      noozleG2: parseDate(map['FuelInjectionNozzle_G2']),
      batteryG1: parseDate(map['Battery_G1']),
      batteryG2: parseDate(map['Battery_G2']),
      tempG1: parseDate(map['WaterSensor_G1']),
      tempG2: parseDate(map['WaterSensor_G2']),
    );
  }

  // New method to get field by name

  dynamic getFieldByName(String fieldName) {
    switch (fieldName) {
      case 'siteName':
        return siteName;
      case 'siteCode':
        return siteCode;
      case 'kvaG1':
        return kvaG1;
      case 'kvaG2':
        return kvaG2;
      case 'starterG1':
        return starterG1;
      case 'starterG2':
        return starterG2;
      case 'dynamoG1':
        return dynamoG1;
      case 'dynamoG2':
        return dynamoG2;
      case 'protectionG1':
        return protectionG1;
      case 'protectionG2':
        return protectionG2;
      case 'avrG1':
        return avrG1;
      case 'avrG2':
        return avrG2;
      case 'chargerG1':
        return chargerG1;
      case 'chargerG2':
        return chargerG2;
      case 'seleniodG1':
        return selenoidG1;
      case 'seleniodG2':
        return selenoidG2;
      case 'radiatorG1':
        return radiatorG1;
      case 'radiatorG2':
        return radiatorG2;
      case 'fanbeltG1':
        return fanbeltG1;
      case 'fanbeltG2':
        return fanbeltG2;
      case 'waterpumpG1':
        return waterpumpG1;
      case 'waterpumpG2':
        return waterpumpG2;
      case 'waterpulleyG1':
        return waterpulleyG1;
      case 'waterpulleyG2':
        return waterpulleyG2;
      case 'levelsensorG1':
        return levelsensorG1;
      case 'levelsensorG2':
        return levelsensorG2;
      case 'oilsensorG1':
        return oilsensorG1;
      case 'oilsensorG2':
        return oilsensorG2;
      case 'rockerG1':
        return rockerG1;
      case 'rockerG2':
        return rockerG2;
      case 'cylinderG1':
        return cylinderG1;
      case 'cylinderG2':
        return cylinderG2;
      case 'rearG1':
        return rearG1;
      case 'rearG2':
        return rearG2;
      case 'frontG1':
        return frontG1;
      case 'frontG2':
        return frontG2;
      case 'panG1':
        return panG1;
      case 'panG2':
        return panG2;
      case 'timingG1':
        return timingG1;
      case 'timingG2':
        return timingG2;
      case 'injectionG1':
        return injectionG1;
      case 'injectionG2':
        return injectionG2;
      case 'liftpumpG1':
        return liftpumpG1;
      case 'liftpumpG2':
        return liftpumpG2;
      case 'noozleG1':
        return noozleG1;
      case 'noozleG2':
        return noozleG2;
      case 'batteryG1':
        return batteryG1;
      case 'batteryG2':
        return batteryG2;
      case 'tempG1':
        return tempG1;
      case 'tempG2':
        return tempG2;

      default:
        return null; // Return null if the field name is not recognized
    }
  }
}
