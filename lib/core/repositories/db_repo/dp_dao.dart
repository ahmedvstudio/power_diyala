import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:power_diyala/core/utils/helpers/logger.dart';

import '../../database/sqlite/db_helper.dart';
import '../../utils/helpers/helper_functions.dart';
import '../../utils/pickers/pickers.dart';

class DBDao {
  /// --> pick and replace db file from storage
  static Future<bool> pickAndReplaceDatabase(BuildContext context) async {
    final result = await VPickers.pickFile();

    final outputFileExtension = result?.files.single.extension?.toLowerCase();

    if (result != null &&
        result.files.isNotEmpty &&
        outputFileExtension == 'db') {
      final newDbPath = result.files.single.path;
      if (newDbPath == null) {
        Vlogger.error("Selected file path is null.");
        return false;
      }

      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String targetDbPath = join(documentsDirectory.path, 'the_data.db');

      try {
        await DbHelper.closeDatabase();

        // Proceed to replace the database...
        if (await File(targetDbPath).exists()) {
          await File(targetDbPath).delete();
          Vlogger.info("Old database deleted");
        }

        await File(newDbPath).copy(targetDbPath);
        Vlogger.info("Database replaced with: $targetDbPath");

        // Load fresh data after replacing the database
        await DbHelper.loadAllData();

        return true;
      } catch (e) {
        Vlogger.error("Error replacing database: $e");
      }
    } else {
      VHelperFunctions.showToasty(message: 'Wrong File Type');
    }
    return false;
  }

  /// --> check db data
  static Future<bool> checkDatabaseData(bool fileSelected) async {
    if (!fileSelected) {
      Vlogger.error("checkDatabaseData called without a valid file selection.");
      return false;
    }

    try {
      final result = await DbHelper.loadAllData();
      final allHaveData = result.every((table) => table.isNotEmpty);
      return allHaveData;
    } catch (e) {
      Vlogger.error("Error checking database data: $e");
    }

    return false;
  }

  /// --> delete db
  static Future<bool> deleteDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'the_data.db');

    Vlogger.info("Attempting to delete database at path: $path");
    final file = File(path);

    try {
      await DbHelper.closeDatabase();

      if (await file.exists()) {
        await file.delete();
        Vlogger.info("Database deleted successfully.");
        return true;
      } else {
        Vlogger.warning("Database file does not exist at path: $path");
        return false;
      }
    } catch (e) {
      Vlogger.error("Failed to delete database: $e");
      return false;
    }
  }
}
