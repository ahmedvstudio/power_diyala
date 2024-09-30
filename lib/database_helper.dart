import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';

class DatabaseHelper {
  static final Logger logger = Logger();
  static Database? _database;

  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;

    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'database10.db');

    if (!await File(path).exists()) {
      ByteData data = await rootBundle.load('assets/database10.db');
      List<int> bytes = data.buffer.asUint8List();
      await File(path).writeAsBytes(bytes);
      logger.i("Database copied from assets to: $path");
    } else {
      logger.i("Database already exists at: $path");
    }

    return _database = await openDatabase(path);
  }

//rename the tables
  static Future<List<Map<String, dynamic>>> loadCalculatorData() async {
    try {
      final db = await getDatabase();
      return await db.query('Calculator10');
    } catch (e) {
      logger.e("Error querying Calculator table: $e");
      throw Exception("Failed to load Calculator data");
    }
  }

  static Future<List<Map<String, dynamic>>> loadSPMSData() async {
    try {
      final db = await getDatabase();
      return await db.query('SPMS10');
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
