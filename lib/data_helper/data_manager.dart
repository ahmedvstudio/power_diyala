import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:power_diyala/data_helper/database_helper.dart';

class DataManager {
  static final DataManager _instance = DataManager._internal();
  factory DataManager() => _instance;

  final Logger logger =
      kDebugMode ? Logger() : Logger(printer: PrettyPrinter());

  List<Map<String, dynamic>>? calculatorData;
  List<Map<String, dynamic>>? spmsData;
  List<Map<String, dynamic>>? networkData;
  List<Map<String, dynamic>>? teamData;
  List<Map<String, dynamic>>? infoData;
  List<Map<String, dynamic>>? pmData;
  List<Map<String, dynamic>>? spareData;

  DataManager._internal();

  Future<void> loadAllData() async {
    try {
      calculatorData = await DatabaseHelper.loadCalculatorData();
      spmsData = await DatabaseHelper.loadSPMSData();
      networkData = await DatabaseHelper.loadNetworkData();
      teamData = await DatabaseHelper.loadTeamData();
      infoData = await DatabaseHelper.loadInfoData();
      pmData = await DatabaseHelper.loadPMData();
      spareData = await DatabaseHelper.loadSpareData();

      logger.i("All data loaded successfully.");
    } catch (e) {
      logger.e("Error loading all data: $e");
    }
  }

  List<Map<String, dynamic>>? getCalculatorData() => calculatorData;
  List<Map<String, dynamic>>? getSpmsData() => spmsData;
  List<Map<String, dynamic>>? getNetworkData() => networkData;
  List<Map<String, dynamic>>? getTeamData() => teamData;
  List<Map<String, dynamic>>? getInfoData() => infoData;
  List<Map<String, dynamic>>? getPMData() => pmData;
  List<Map<String, dynamic>>? getSpareData() => spareData;
}
