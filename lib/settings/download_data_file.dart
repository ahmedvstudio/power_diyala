import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:power_diyala/settings/remote_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Logger logger = kDebugMode ? Logger() : Logger(printer: PrettyPrinter());

Future<bool> _checkPermissions() async {
  PermissionStatus storageStatus;

  if (Platform.isAndroid) {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    final AndroidDeviceInfo info = await deviceInfoPlugin.androidInfo;

    if (info.version.sdkInt >= 33) {
      storageStatus = await Permission.manageExternalStorage.request();
    } else {
      storageStatus = await Permission.storage.request();
    }
  } else {
    storageStatus = await Permission.storage.request();
  }

  if (storageStatus.isGranted) {
    return true;
  } else if (storageStatus.isDenied) {
    logger.e('Storage permission denied. Please enable it in settings.');
  } else if (storageStatus.isPermanentlyDenied) {
    logger.e(
        'Storage permission permanently denied. Please enable it in settings.');
    openAppSettings();
  }

  return false;
}

//Download from a link
const String lastUpdateTimeKey = 'lastUpdateTime';
void _showToast(message, bgColor) => Fluttertoast.showToast(
      msg: message,
      backgroundColor: bgColor,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      textColor: Colors.black,
      fontSize: 14.0,
    );

Future<void> updateDatabase(BuildContext context) async {
  // Check if 24 hours have passed since the last update
  if (!await _canUpdateDatabase()) {
    _showToast("No New Data Update.", Colors.white);
    return;
  }

  // Check permissions before proceeding
  if (!await _checkPermissions()) {
    return;
  }

  try {
    SharedPreferencesAsync prefs = SharedPreferencesAsync();
    final url = await prefs.getString('dataFile_url');
    logger.i(url);
    // Download the file
    final response = await http.get(Uri.parse(url!));
    if (response.statusCode == 200) {
      // Get the local path to save the file
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/the_data.db';

      // Save the file
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      await fetchAndActivate();
      // Save the current time as the last update time
      SharedPreferencesAsync prefs = SharedPreferencesAsync();
      await prefs.setInt(
          lastUpdateTimeKey, DateTime.now().millisecondsSinceEpoch);
      _showToast("Data Updated successfully\nPlease restart the app.",
          Colors.tealAccent);
      logger.i("Database updated successfully!");
    } else {
      logger.e("Failed to download file: ${response.statusCode}");
    }
  } catch (e) {
    logger.e("Error updating database: $e");
  }
}

Future<bool> _canUpdateDatabase() async {
  SharedPreferencesAsync prefs = SharedPreferencesAsync();
  final lastUpdateTimeMillis = await prefs.getInt(lastUpdateTimeKey);

  if (lastUpdateTimeMillis == null) {
    // If no update has occurred, allow it
    return true;
  }

  final lastUpdateTime =
      DateTime.fromMillisecondsSinceEpoch(lastUpdateTimeMillis);
  final currentTime = DateTime.now();

  // Check if 24 hours have passed since the last update
  return currentTime.difference(lastUpdateTime).inHours >= 24;
}
