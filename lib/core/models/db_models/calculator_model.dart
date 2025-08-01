import 'package:power_diyala/core/utils/formatters/formatters.dart';

class CalculatorModel {
  final String siteName;
  final String siteCode;
  final DateTime pmDate;
  final double gen1Re;
  final double gen2Re;
  final double cp;
  final double oilG1;
  final double oilG2;
  final double airG1;
  final double airG2;
  final double coolantG1;
  final double coolantG2;

  CalculatorModel({
    required this.siteName,
    required this.siteCode,
    required this.pmDate,
    required this.gen1Re,
    required this.gen2Re,
    required this.cp,
    required this.oilG1,
    required this.oilG2,
    required this.airG1,
    required this.airG2,
    required this.coolantG1,
    required this.coolantG2,
  });
  factory CalculatorModel.fromMap(Map<String, dynamic> map) {
    return CalculatorModel(
      siteName: map['Site_name'] as String,
      siteCode: map['Site_Code'] as String,
      pmDate: VFormatters.advancedDateFormater(map['PM_Date']),
      gen1Re: double.tryParse(map['Gen1_Re']?.toString() ?? '0') ?? 0.0,
      gen2Re: double.tryParse(map['Gen2_Re']?.toString() ?? '0') ?? 0.0,
      cp: double.tryParse(map['CP']?.toString() ?? '0') ?? 0.0,
      oilG1: double.tryParse(map['Oil_G1']?.toString() ?? '0') ?? 0.0,
      oilG2: double.tryParse(map['Oil_G2']?.toString() ?? '0') ?? 0.0,
      airG1: double.tryParse(map['Air_G1']?.toString() ?? '0') ?? 0.0,
      airG2: double.tryParse(map['Air_G2']?.toString() ?? '0') ?? 0.0,
      coolantG1: double.tryParse(map['Coolant_G1']?.toString() ?? '0') ?? 0.0,
      coolantG2: double.tryParse(map['Coolant_G2']?.toString() ?? '0') ?? 0.0,
    );
  }
}
