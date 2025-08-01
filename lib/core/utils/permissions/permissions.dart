import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:power_diyala/core/utils/helpers/logger.dart';

class VPermissions {
  VPermissions._();

  /// --> External Storage Permission
  static Future<void> requestExternalStoragePermission(
      BuildContext context) async {
    var status = await Permission.manageExternalStorage.status;

    if (!status.isGranted) {
      status = await Permission.manageExternalStorage.request();

      if (!context.mounted) return;
      if (status.isGranted) {
        Vlogger.info('External storage permission granted');
      } else {
        Vlogger.warning('External storage permission denied');
      }
    }
  }
}
