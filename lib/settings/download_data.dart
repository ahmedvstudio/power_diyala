import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

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

Future<String> _fetchDownloadId() async {
  final remoteConfig = FirebaseRemoteConfig.instance;

  // Set default values for remote config
  await remoteConfig.setDefaults({
    'database_download_id': 'default_id', // Default value
  });

  // Fetch and activate remote config values
  await remoteConfig.fetchAndActivate();

  return remoteConfig.getString('database_download_id');
}

Future<void> updateDatabase() async {
  // Check permissions before proceeding
  if (!await _checkPermissions()) {
    return; // Exit if permissions are not granted
  }

  try {
    // Fetch the dynamic download ID from Remote Config
    String downloadId = await _fetchDownloadId();

    // Direct download link from Google Drive using the fetched ID
    final url = 'https://drive.google.com/uc?export=download&id=$downloadId';

    // Download the file
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      // Get the local path to save the file
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/the_data.db';

      // Save the file
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      logger.i("Database updated successfully!");
    } else {
      logger.e("Failed to download file: ${response.statusCode}");
    }
  } catch (e) {
    logger.e("Error updating database: $e");
  }
}
