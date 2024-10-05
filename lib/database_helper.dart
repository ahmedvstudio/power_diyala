import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:power_diyala/calculator/calc_table_helper.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';

class DatabaseHelper {
  static final Logger logger = Logger();
  static Database? _database;

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

    // Open the database with a passphrase for encryption
    return _database = await openDatabase(
      path,
      password: dotenv.env['DB_PASSWORD'], // Set your secure password
    );
  }

//rename the tables
  static Future<List<Map<String, dynamic>>> loadCalculatorData() async {
    try {
      final db = await getDatabase();
      return await db.query('Calculator');
    } catch (e) {
      logger.e("Error querying Calculator table: $e");
      throw Exception("Failed to load Calculator data");
    }
  }

  static Future<List<Map<String, dynamic>>> loadSPMSData() async {
    try {
      final db = await getDatabase();
      return await db.query('SPMS');
    } catch (e) {
      logger.e("Error querying SPMS table: $e");
      throw Exception("Failed to load SPMS data");
    }
  }

  static Future<List<Map<String, dynamic>>> loadNetworkData() async {
    try {
      final db = await getDatabase();
      return await db.query('Network');
    } catch (e) {
      logger.e("Error querying Network table: $e");
      throw Exception("Failed to load Network data");
    }
  }

  static Future<List<Map<String, dynamic>>> loadTeamData() async {
    try {
      final db = await getDatabase();
      return await db.query('Teams');
    } catch (e) {
      logger.e("Error querying Network table: $e");
      throw Exception("Failed to load Teams data");
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

      // Check permission immediately and show dialog if necessary
      if (!context.mounted) return; // Check if the widget is still mounted
      if (status.isGranted) {
        logger.i("Manage external storage permission granted");
      } else {
        // Show dialog explaining why the permission is needed
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Permission Required'),
            content: const Text(
              'Manage external storage permission is required to access files. '
              'This allows the app to read from and write to your device storage, '
              'enabling file management features.',
            ),
            actions: [
              TextButton(
                child: const Text('Open Settings'),
                onPressed: () {
                  openAppSettings();
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          ),
        );
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

        showDialog(
          context: localContext,
          builder: (context) => AlertDialog(
            title: const Text('Invalid File'),
            content:
                const Text('Please select a valid SQLite database file (.db)'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(localContext).pop(),
              ),
            ],
          ),
        );
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
      } catch (e) {
        logger.e("Error replacing database: $e");
        // Check if the widget is still mounted before showing the dialog
        if (!localContext.mounted) return;

        showDialog(
          context: localContext,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to replace database: $e'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(localContext).pop(),
              ),
            ],
          ),
        );
      }
    } else {
      logger.e('No file selected.');
    }
  }
}
