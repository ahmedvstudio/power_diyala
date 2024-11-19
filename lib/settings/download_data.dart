import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

final Logger logger = kDebugMode ? Logger() : Logger(printer: PrettyPrinter());

Future<bool> _checkPermissions() async {
  PermissionStatus storageStatus;

  if (Platform.isAndroid) {
    // Use DeviceInfoPlugin to get Android version
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    final AndroidDeviceInfo info = await deviceInfoPlugin.androidInfo;

    // Request appropriate permissions based on SDK version
    if (info.version.sdkInt >= 33) {
      // Request manage external storage permission for Android 13+
      storageStatus = await Permission.manageExternalStorage.request();
    } else {
      // Request storage permission for older Android versions
      storageStatus = await Permission.storage.request();
    }
  } else {
    // For non-Android platforms, request storage permission
    storageStatus = await Permission.storage.request();
  }

  // Handle the result of the permission request
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

Future<void> updateDatabase() async {
  // Check permissions before proceeding
  if (!await _checkPermissions()) {
    return; // Exit if permissions are not granted
  }

  try {
    // Direct download link from Google Drive
    final url =
        'https://drive.google.com/uc?export=download&id=1rXhw07eodsbvK9iUvBFsgbwXLKCvzcBj';

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
