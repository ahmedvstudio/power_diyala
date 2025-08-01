import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:power_diyala/core/utils/constants/text_strings.dart';
import 'package:power_diyala/core/utils/helpers/logger.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

class DbHelper {
  static Database? db;

  static Future<Database> getDatabase() async {
    if (db != null) return db!;

    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'the_data.db');

    if (!await File(path).exists()) {
      ByteData data = await rootBundle.load('assets/the_data.db');
      List<int> bytes = data.buffer.asUint8List();
      await File(path).writeAsBytes(bytes);
      Vlogger.info("Database copied from assets to: $path");
    } else {
      Vlogger.info("Database already exists at: $path");
    }

    return db = await openDatabase(
      path,
      password: dotenv.env['DB_PASSWORD'],
    );
  }

  static Future<List<Map<String, dynamic>>> loadData(String tableName) async {
    try {
      final database = await getDatabase();
      return await database.query(tableName);
    } catch (e) {
      Vlogger.error("Error querying $tableName table: $e");
      throw Exception("Failed to load data from $tableName");
    }
  }

  static Future<List<Map<String, dynamic>>> loadCalculatorData() async {
    return loadData(VText.calculatorTable);
  }

  static Future<List<Map<String, dynamic>>> loadSPMSData() async {
    return loadData(VText.spmsTable);
  }

  static Future<List<Map<String, dynamic>>> loadNetworkData() async {
    return loadData(VText.networkTable);
  }

  static Future<List<Map<String, dynamic>>> loadTeamData() async {
    return loadData(VText.teamsTable);
  }

  static Future<List<Map<String, dynamic>>> loadInfoData() async {
    return loadData(VText.infoTable);
  }

  static Future<List<Map<String, dynamic>>> loadPMData() async {
    return loadData(VText.pmHelperTable);
  }

  static Future<List<Map<String, dynamic>>> loadSpareData() async {
    return loadData(VText.spareHelperTable);
  }

  static Future<List<Map<String, dynamic>>> loadNamesData() async {
    return loadData(VText.nameHelperTable);
  }

  static Future<List<Map<String, dynamic>>> loadEmailsData() async {
    return loadData(VText.emailsHelperTable);
  }

  static Future<List<List<Map<String, dynamic>>>> loadAllData() async {
    return await Future.wait([
      loadCalculatorData(),
      loadSPMSData(),
      loadNetworkData(),
      loadTeamData(),
      loadInfoData(),
      loadPMData(),
      loadSpareData(),
      loadNamesData(),
      loadEmailsData(),
    ]);
  }

  static Future<void> closeDatabase() async {
    if (db != null) {
      await db!.close();
      db = null;
    }
  }
}
