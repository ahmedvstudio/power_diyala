import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

class GoogleSheetHelper extends StatefulWidget {
  final String templateFileId;
  final String targetSheetName;
  final Map<String, dynamic> data;

  const GoogleSheetHelper({
    super.key,
    required this.templateFileId,
    required this.targetSheetName,
    required this.data,
  });

  @override
  GoogleSheetHelperState createState() => GoogleSheetHelperState();
}

class GoogleSheetHelperState extends State<GoogleSheetHelper> {
  final Logger logger = Logger();
  String copiedFileId = '';
  bool isFileCopied = false;
  final Map<String, String> cellUpdates = {};
  int? sheetId;

  Future<void> _copySheetAsTemplate(BuildContext context) async {
    try {
      final serviceAccountJson =
          await rootBundle.loadString('assets/powerdiyala.json');
      final accountCredentials =
          ServiceAccountCredentials.fromJson(serviceAccountJson);
      final scopes = [
        drive.DriveApi.driveScope,
        sheets.SheetsApi.spreadsheetsScope
      ];

      final client = await clientViaServiceAccount(accountCredentials, scopes);
      final driveApi = drive.DriveApi(client);

      // Copy the file
      final copiedFile =
          await driveApi.files.copy(drive.File(), widget.templateFileId);
      copiedFileId = copiedFile.id!;

      // Get the spreadsheet details to retrieve the sheet ID
      final sheetsApi = sheets.SheetsApi(client);
      final spreadsheet = await sheetsApi.spreadsheets.get(copiedFileId);

      // Assuming you want to work with the first sheet
      final sheetId = spreadsheet.sheets!.first.properties!.sheetId;

      setState(() {
        isFileCopied = true;
        this.sheetId = sheetId; // Store the sheet ID
      });

      _showSnackbar('File copied as template: ${copiedFile.name}');
    } catch (e) {
      logger.e('Error copying the file: $e');
      _showSnackbar('An error occurred while copying the file: $e');
    }
  }

  Future<bool> _checkPermissions(BuildContext context) async {
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

    if (storageStatus.isGranted) {
      return true;
    } else {
      _showSnackbar('Please provide the necessary permissions.');
      return false;
    }
  }

  Future<void> _downloadCopiedSheet(BuildContext context) async {
    bool hasPermissions = await _checkPermissions(context);
    if (!hasPermissions) return;

    try {
      final serviceAccountJson =
          await rootBundle.loadString('assets/powerdiyala.json');
      final accountCredentials =
          ServiceAccountCredentials.fromJson(serviceAccountJson);
      final scopes = [drive.DriveApi.driveScope];

      final client = await clientViaServiceAccount(accountCredentials, scopes);
      final accessToken = (client).credentials.accessToken.data;

      final response = await http.get(
        Uri.parse(
            'https://www.googleapis.com/drive/v3/files/$copiedFileId/export?mimeType=application/vnd.openxmlformats-officedocument.spreadsheetml.sheet&alt=media'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final downloadsDirectory = Directory('/storage/emulated/0/PowerDiyala');
        final filePath = '${downloadsDirectory.path}/modified_gen.xlsx';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        _showSnackbar('File downloaded successfully to $filePath');
      } else {
        _showSnackbar('Error downloading the file: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackbar('Error downloading the file: $e');
    }
  }

  Future<void> _deleteCopiedSheet(BuildContext context) async {
    try {
      final serviceAccountJson =
          await rootBundle.loadString('assets/powerdiyala.json');
      final accountCredentials =
          ServiceAccountCredentials.fromJson(serviceAccountJson);
      final scopes = [drive.DriveApi.driveScope];

      final client = await clientViaServiceAccount(accountCredentials, scopes);
      final driveApi = drive.DriveApi(client);

      await driveApi.files.delete(copiedFileId);
      _showSnackbar('Copied file deleted successfully.');
    } catch (e) {
      logger.e('Error deleting the file: $e');
      _showSnackbar('An error occurred while deleting: $e');
    }
  }

  Future<void> _modifyCells(BuildContext context) async {
    if (copiedFileId.isEmpty || cellUpdates.isEmpty) return;

    try {
      final serviceAccountJson =
          await rootBundle.loadString('assets/powerdiyala.json');
      final accountCredentials =
          ServiceAccountCredentials.fromJson(serviceAccountJson);
      final scopes = [sheets.SheetsApi.spreadsheetsScope];

      final client = await clientViaServiceAccount(accountCredentials, scopes);
      final sheetsApi = sheets.SheetsApi(client);

      // Prepare the batch update request
      var requests = <sheets.Request>[];

      cellUpdates.forEach((cell, value) {
        requests.add(sheets.Request(
          updateCells: sheets.UpdateCellsRequest(
            rows: [
              sheets.RowData(values: [
                sheets.CellData(
                    userEnteredValue: sheets.ExtendedValue(stringValue: value))
              ])
            ],
            fields: 'userEnteredValue',
            range: sheets.GridRange(
              sheetId: sheetId, // Use the correct sheet ID
              startRowIndex: int.parse(cell.substring(1)) - 1,
              endRowIndex: int.parse(cell.substring(1)),
              startColumnIndex: cell.codeUnitAt(0) - 'A'.codeUnitAt(0),
              endColumnIndex: cell.codeUnitAt(0) - 'A'.codeUnitAt(0) + 1,
            ),
          ),
        ));
      });

      // Perform batch update
      await sheetsApi.spreadsheets.batchUpdate(
        sheets.BatchUpdateSpreadsheetRequest(requests: requests),
        copiedFileId,
      );

      _showSnackbar('Cells updated successfully.');
    } catch (e) {
      logger.e('Error updating cells: $e');
      _showSnackbar('Failed to update cells: $e');
    }
  }

  Future<void> _handleSheetOperations() async {
    try {
      // Step 1: Copy the sheet as a template
      await _copySheetAsTemplate(context);
      if (!mounted) return;

      // Step 2: Modify cells
      await _modifyCells(context);
      if (!mounted) return;

      // Step 3: Download the copied sheet
      await _downloadCopiedSheet(context);
      if (!mounted) return;

      // Step 4: Delete the copied sheet
      await _deleteCopiedSheet(context);
      if (!mounted) return;

      // Show a success message outside async gaps
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Operations completed successfully!')),
        );
      }
    } catch (error) {
      // Show error message outside async gaps
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $error')),
        );
      }
    }
  }

  void _showSnackbar(String message,
      {Duration duration = const Duration(seconds: 2)}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: duration),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Google Sheets Template Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: "Enter cell-value pairs (e.g., A1=Value1,B2=Value2)",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // Split input by comma to process each pair
                cellUpdates.clear(); // Clear previous entries
                for (var pair in value.split(',')) {
                  var parts = pair.split('=');
                  if (parts.length == 2) {
                    cellUpdates[parts[0].trim()] =
                        parts[1].trim(); // Store cell-value pairs
                  }
                }
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleSheetOperations,
              child: Text('Execute Sheet Operations'),
            ),
          ],
        ),
      ),
    );
  }
}
