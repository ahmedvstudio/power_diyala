import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:power_diyala/data_helper/calc_table_helper.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';

class DatabaseHelper {
  static Logger logger =
      kDebugMode ? Logger() : Logger(printer: PrettyPrinter());
  static Database? _database;

  // Define constants for table names
  static const String calculatorTable = 'Calculator';
  static const String spmsTable = 'SPMS';
  static const String networkTable = 'Network';
  static const String teamsTable = 'Teams';
  static const String infoTable = 'info';
  static const String pmHelperTable = 'PM_helper';

  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;

    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'the_data.db');

    if (!await File(path).exists()) {
      ByteData data = await rootBundle.load('assets/the_data.db');
      List<int> bytes = data.buffer.asUint8List();
      await File(path).writeAsBytes(bytes);
      logger.i("Database copied from assets to: $path");
    } else {
      logger.i("Database already exists at: $path");
    }

    return _database = await openDatabase(
      path,
      password: dotenv.env['DB_PASSWORD'],
    );
  }

  static Future<List<Map<String, dynamic>>> loadData(String tableName) async {
    try {
      final db = await getDatabase();
      return await db.query(tableName);
    } catch (e) {
      logger.e("Error querying $tableName table: $e");
      throw Exception("Failed to load data from $tableName");
    }
  }

  static Future<List<Map<String, dynamic>>> loadCalculatorData() async {
    return loadData(calculatorTable);
  }

  static Future<List<Map<String, dynamic>>> loadSPMSData() async {
    return loadData(spmsTable);
  }

  static Future<List<Map<String, dynamic>>> loadNetworkData() async {
    return loadData(networkTable);
  }

  static Future<List<Map<String, dynamic>>> loadTeamData() async {
    return loadData(teamsTable);
  }

  static Future<List<Map<String, dynamic>>> loadInfoData() async {
    return loadData(infoTable);
  }

  static Future<List<Map<String, dynamic>>> loadPMData() async {
    return loadData(pmHelperTable);
  }

  static Future<void> deleteDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'the_data.db');

    logger.i("Attempting to delete database at path: $path");

    final file = File(path);
    if (await file.exists()) {
      await file.delete();
      logger.i("Database deleted successfully.");
    } else {
      logger.w("Database file does not exist at path: $path");
    }
  }
}

//Replacement helper
class DBHelper {
  static Future<void> requestManageExternalStoragePermission(
      BuildContext context) async {
    var status = await Permission.manageExternalStorage.status;

    if (!status.isGranted) {
      status = await Permission.manageExternalStorage.request();

      if (!context.mounted) return;
      if (status.isGranted) {
        logger.i("Manage external storage permission granted");
      } else {
        logger.w("Manage external storage permission denied.");
      }
    }
  }

  static Future<void> pickAndReplaceDatabase(BuildContext context) async {
    final localContext = context; // Capture the BuildContext

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.isNotEmpty) {
      String newDbPath = result.files.single.path!;

      if (!newDbPath.endsWith('.db')) {
        // Check if the widget is still mounted
        if (!localContext.mounted) return;

        return;
      }

      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String targetDbPath = join(documentsDirectory.path, 'the_data.db');

      try {
        // Close the database if it's open
        if (DatabaseHelper._database != null) {
          await DatabaseHelper._database!.close();
          DatabaseHelper._database = null;
        }

        // Proceed to replace the database...
        if (await File(targetDbPath).exists()) {
          await File(targetDbPath).delete();
          logger.i("Old database deleted successfully.");
        }

        await File(newDbPath).copy(targetDbPath);
        logger.i("Database replaced successfully with: $targetDbPath");

        // Load fresh data after replacing the database
        await DatabaseHelper.loadCalculatorData();
        await DatabaseHelper.loadSPMSData();
        await DatabaseHelper.loadNetworkData();
        await DatabaseHelper.loadTeamData();
        await DatabaseHelper.loadInfoData();
        await DatabaseHelper.loadPMData();
      } catch (e) {
        logger.e("Error replacing database: $e");
        // Check if the widget is still mounted before showing the dialog
        if (!localContext.mounted) return;
      }
    } else {
      logger.e('No file selected.');
    }
  }

  static Future<bool> checkDatabaseData() async {
    // Implement logic to check if required data is present
    try {
      // Example query to check for expected records
      final result = await DatabaseHelper.loadCalculatorData();
      await DatabaseHelper.loadSPMSData();
      await DatabaseHelper.loadNetworkData();
      await DatabaseHelper.loadTeamData();
      await DatabaseHelper.loadInfoData();
      await DatabaseHelper.loadPMData();

      if (result.isNotEmpty) {
        // Perform additional checks as needed
        return true; // Data loaded correctly
      }
    } catch (e) {
      logger.e("Error checking database data: $e");
    }

    return false; // Data not loaded correctly or error occurred
  }
}
