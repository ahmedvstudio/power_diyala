import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:power_diyala/settings/constants.dart';
import 'package:power_diyala/data_helper/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';

final Logger logger = kDebugMode ? Logger() : Logger(printer: PrettyPrinter());

void _showToast(message) => Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.white,
      textColor: Colors.black,
      fontSize: 14.0,
    );

class ResetTextButton extends StatelessWidget {
  const ResetTextButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        bool? confirmReset = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Reset App'),
              content: const Text(
                  'Are you sure you want to reset the app? This will delete all data.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: const Text('Reset'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        );
        if (confirmReset == true) {
          await DatabaseHelper.deleteDatabase();
          // Reset SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.clear(); // Clear all saved state
          _showToast("App is resetting...");

          await Future.delayed(const Duration(seconds: 1));
          SystemNavigator.pop(); // This will exit the app
        }
      },
      child: const Text(
        'Reset',
      ),
    );
  }
}

class UpdateButton extends StatelessWidget {
  const UpdateButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        await _checkForUpdates(context);
      },
      child: const Text('Check For Updates'),
    );
  }
}

Future<void> _checkForUpdates(BuildContext context) async {
  const url = repoLink;

  try {
    final response =
        await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

    logger.i("Status Code: ${response.statusCode}");
    logger.i("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final latestVersion = data['tag_name'];

      if (appVersion == latestVersion) {
        if (context.mounted) {
          _showToast("This is the latest version.");
        }
      } else {
        if (context.mounted) {
          _showUpdateDialog(context, latestVersion);
        }
      }
    } else {
      if (context.mounted) {
        _showToast(
            "Failed to fetch updates. Status Code: ${response.statusCode}");
      }
    }
  } catch (e) {
    if (context.mounted) {
      _showToast("Network error or timeout occurred");
    }
  }
}

void _showUpdateDialog(BuildContext context, String latestVersion) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Update Available"),
        content: Text(
            "A new version ($latestVersion) is available. Would you like to download it?"),
        actions: <Widget>[
          TextButton(
            child: const Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text("Download"),
            onPressed: () async {
              Navigator.of(context).pop();
              _showToast("Redirecting to download...");
              const url = updateLink;

              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url),
                    mode: LaunchMode.externalApplication);
              } else {
                _showToast("Could not launch the download page.");
              }
            },
          ),
        ],
      );
    },
  );
}
