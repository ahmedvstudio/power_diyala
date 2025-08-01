import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:power_diyala/core/utils/helpers/helper_functions.dart';
import 'package:power_diyala/core/utils/helpers/logger.dart';
import 'package:power_diyala/data_helper/data_manager.dart';
import 'package:restart_app/restart_app.dart';

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
    Vlogger.error('Storage permission denied. Please enable it in settings.');
  } else if (storageStatus.isPermanentlyDenied) {
    Vlogger.error(
        'Storage permission permanently denied. Please enable it in settings.');

    openAppSettings();
  }

  return false;
}

Future<void> updateDatabaseFromFilePicker(BuildContext context) async {
  // Check permissions before proceeding
  if (!await _checkPermissions()) {
    return; // Exit if permissions are not granted
  }

  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowedExtensions: null,
      type: FileType.any,
      dialogTitle: 'Select Database File',
    );

    final String? outputFileExtension =
        result?.files.single.extension.toString();

    if (result != null &&
        result.files.single.path != null &&
        outputFileExtension == 'db') {
      final selectedFilePath = result.files.single.path!;
      final selectedFile = File(selectedFilePath);
      // Show the loading dialog
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 120,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                          const Column(
                            children: [
                              Icon(Icons.hourglass_top_rounded,
                                  color: Colors.white, size: 32),
                              SizedBox(height: 8),
                              Text(
                                'Loading',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(height: 16),
                            const Text('Loading New Data...'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );

      // Verify the file exists
      if (!await selectedFile.exists()) {
        Vlogger.error("Selected file does not exist.");
        return;
      }

      // Get the app's directory to save the file
      final dir = await getApplicationDocumentsDirectory();
      final destinationPath = '${dir.path}/the_data.db';

      // Copy the selected file to the app's directory
      await selectedFile.copy(destinationPath);

      Vlogger.info("Database file updated successfully!");

      // Close the loading dialog
      if (context.mounted) {
        await DataManager().loadAllData();
        Restart.restartApp(
          notificationTitle: 'Database updated successfully!',
          notificationBody: 'Please tap here to open the app again.',
        );
      }
    } else {
      VHelperFunctions.showToasty(
          message: 'Wrong file type', backgroundColor: Colors.red);
    }
  } catch (e) {
    Vlogger.error("Error updating database: $e");
  }
}
