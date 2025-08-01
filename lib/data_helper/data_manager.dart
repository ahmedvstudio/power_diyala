import 'package:power_diyala/data_helper/database_helper.dart';

import '../core/utils/helpers/logger.dart';

class DataManager {
  static final DataManager _instance = DataManager._internal();
  factory DataManager() => _instance;

  List<Map<String, dynamic>>? calculatorData;
  List<Map<String, dynamic>>? spmsData;
  List<Map<String, dynamic>>? networkData;
  List<Map<String, dynamic>>? teamData;
  List<Map<String, dynamic>>? infoData;
  List<Map<String, dynamic>>? pmData;
  List<Map<String, dynamic>>? spareData;
  List<Map<String, dynamic>>? namesData;
  List<Map<String, dynamic>>? emailsData;

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
      namesData = await DatabaseHelper.loadNamesData();
      emailsData = await DatabaseHelper.loadEmailsData();
      Vlogger.info("All data loaded successfully.");
    } catch (e) {
      Vlogger.error("Error loading all data: $e");
    }
  }

  List<Map<String, dynamic>>? getCalculatorData() => calculatorData;
  List<Map<String, dynamic>>? getSpmsData() => spmsData;
  List<Map<String, dynamic>>? getNetworkData() => networkData;
  List<Map<String, dynamic>>? getTeamData() => teamData;
  List<Map<String, dynamic>>? getInfoData() => infoData;
  List<Map<String, dynamic>>? getPMData() => pmData;
  List<Map<String, dynamic>>? getSpareData() => spareData;
  List<Map<String, dynamic>>? getNamesData() => namesData;
  List<Map<String, dynamic>>? getEmailsData() => emailsData;
}
