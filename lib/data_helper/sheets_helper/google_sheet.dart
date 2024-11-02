import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

class GoogleSheetHelper {
  final String templateFileId;
  final String targetSheetName;
  final String modifiedFileName;
  final Logger logger =
      kDebugMode ? Logger() : Logger(printer: PrettyPrinter());
  String copiedFileId = '';
  final Map<String, String> cellUpdates = {};
  int? sheetId;

  GoogleSheetHelper({
    required this.templateFileId,
    required this.targetSheetName,
    required this.modifiedFileName,
  });

  Future<AutoRefreshingAuthClient> _initializeClient(
      List<String> scopes) async {
    final serviceAccountJson =
        await rootBundle.loadString('assets/powerdiyala.json');
    final accountCredentials =
        ServiceAccountCredentials.fromJson(serviceAccountJson);
    return await clientViaServiceAccount(accountCredentials, scopes);
  }

  Future<void> copySheetAsTemplate() async {
    try {
      final client = await _initializeClient(
          [drive.DriveApi.driveScope, sheets.SheetsApi.spreadsheetsScope]);
      final driveApi = drive.DriveApi(client);

      // Copy the file
      final copiedFile =
          await driveApi.files.copy(drive.File(), templateFileId);
      copiedFileId = copiedFile.id!;

      // Get the spreadsheet details to retrieve the sheet ID
      final sheetsApi = sheets.SheetsApi(client);
      final spreadsheet = await sheetsApi.spreadsheets.get(copiedFileId);

      // Assuming you want to work with the first sheet
      sheetId = spreadsheet.sheets!.first.properties!.sheetId;

      logger.i('File copied as template: ${copiedFile.name}');
    } catch (e) {
      logger.e('Error copying the file: $e');
    }
  }

  Future<bool> checkPermissions() async {
    PermissionStatus storageStatus;

    if (Platform.isAndroid) {
      final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      final AndroidDeviceInfo info = await deviceInfoPlugin.androidInfo;

      storageStatus = info.version.sdkInt >= 33
          ? await Permission.manageExternalStorage.request()
          : await Permission.storage.request();
    } else {
      storageStatus = await Permission.storage.request();
    }

    if (!storageStatus.isGranted) {
      logger.e('Storage permission not granted.');
      return false;
    }
    return true;
  }

  Future<void> modifyCells() async {
    logger.i('Attempting to modify cells...');
    logger.i(
        'Current State - copiedFileId: $copiedFileId, cellUpdates: $cellUpdates, sheetId: $sheetId');

    if (copiedFileId.isEmpty || cellUpdates.isEmpty || sheetId == null) {
      logger.e('Cannot modify cells: Invalid state.');
      return;
    }

    try {
      final client =
          await _initializeClient([sheets.SheetsApi.spreadsheetsScope]);
      final sheetsApi = sheets.SheetsApi(client);

      // Prepare the batch update request
      var requests = <sheets.Request>[];

      cellUpdates.forEach((cell, value) {
        logger.i('Preparing to update cell $cell with value $value');

        // Extract column letters and row number
        String columnLetters =
            RegExp(r'^([A-Z]+)').firstMatch(cell)?.group(0) ?? '';
        String rowNumberString =
            RegExp(r'([0-9]+)$').firstMatch(cell)?.group(0) ?? '';

        if (rowNumberString.isNotEmpty) {
          int rowIndex = int.parse(rowNumberString) - 1; // Extract row index
          int colIndex = _columnLetterToIndex(
              columnLetters); // Convert column letters to index

          requests.add(sheets.Request(
            updateCells: sheets.UpdateCellsRequest(
              rows: [
                sheets.RowData(values: [
                  sheets.CellData(
                      userEnteredValue:
                          sheets.ExtendedValue(stringValue: value))
                ])
              ],
              fields: 'userEnteredValue',
              range: sheets.GridRange(
                sheetId: sheetId!,
                startRowIndex: rowIndex,
                endRowIndex: rowIndex + 1,
                startColumnIndex: colIndex,
                endColumnIndex: colIndex + 1,
              ),
            ),
          ));
        } else {
          logger.e('Row number could not be parsed from cell $cell.');
        }
      });

      if (requests.isEmpty) {
        logger.e('No valid requests to execute.');
        return; // Early exit if there are no valid requests
      }

      // Log the requests
      logger.i('Executing batch update with ${requests.length} requests.');

      // Perform batch update
      await sheetsApi.spreadsheets.batchUpdate(
        sheets.BatchUpdateSpreadsheetRequest(requests: requests),
        copiedFileId,
      );

      logger.i('Cells updated successfully.');
    } catch (e) {
      logger.e('Error updating cells: $e');
    }
  }

// Helper function to convert column letters to index
  int _columnLetterToIndex(String column) {
    int index = 0;
    for (int i = 0; i < column.length; i++) {
      index = index * 26 + (column.codeUnitAt(i) - 'A'.codeUnitAt(0) + 1);
    }
    return index - 1; // Adjust for zero-based indexing
  }

  Future<void> downloadCopiedSheet() async {
    if (!await checkPermissions()) return;

    try {
      final client = await _initializeClient([drive.DriveApi.driveScope]);
      final accessToken = client.credentials.accessToken.data;

      final response = await http.get(
        Uri.parse(
            'https://www.googleapis.com/drive/v3/files/$copiedFileId/export?mimeType=application/vnd.openxmlformats-officedocument.spreadsheetml.sheet&alt=media'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final downloadsDirectory = Directory('/storage/emulated/0/PowerDiyala');
        if (!await downloadsDirectory.exists()) {
          await downloadsDirectory.create(
              recursive: true); // Ensure directory exists
        }

        final filePath = '${downloadsDirectory.path}/$modifiedFileName.xlsx';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        logger.i('File downloaded successfully to $filePath');
      } else {
        logger.e('Error downloading the file: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error downloading the file: $e');
    }
  }

  Future<void> deleteCopiedSheet() async {
    try {
      final client = await _initializeClient([drive.DriveApi.driveScope]);
      final driveApi = drive.DriveApi(client);

      await driveApi.files.delete(copiedFileId);
      logger.i('Copied file deleted successfully.');
    } catch (e) {
      logger.e('Error deleting the file: $e');
    }
  }

  Future<void> executeSheetOperations() async {
    if (!await checkPermissions()) return;

    // Step 1: Copy the sheet as a template
    await copySheetAsTemplate();

    // Step 2: Modify cells
    await modifyCells();

    // Step 3: Download the copied sheet
    await downloadCopiedSheet();

    // Step 4: Delete the copied sheet
    await deleteCopiedSheet();
  }

  void setCellUpdates(Map<String, String> updates) {
    cellUpdates.clear(); // Clear previous entries
    cellUpdates.addAll(updates); // Store new cell-value pairs
  }
}
