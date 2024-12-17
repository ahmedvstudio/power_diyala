import 'dart:io';
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
    return IconButton(
      onPressed: () async {
        bool? confirmReset = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  color: Theme.of(context).cardColor,
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
                                Icon(Icons.rocket_launch_rounded,
                                    color: Colors.white, size: 32),
                                SizedBox(height: 8),
                                Text(
                                  'Nuke Everything!!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Would you like to reset the app ?',
                                  style: TextStyle(color: Colors.white),
                                ),
                                Text(
                                  '*Not Recommended',
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 10),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop(false);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.tertiary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding:
                                    const EdgeInsets.fromLTRB(16, 8, 16, 8),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop(true);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.tertiary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding:
                                    const EdgeInsets.fromLTRB(16, 8, 16, 8),
                                child: const Text(
                                  'Yes',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ),
                          ],
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
        if (confirmReset == true) {
          await DatabaseHelper.deleteDatabase();
          // Reset SharedPreferences
          final SharedPreferencesAsync prefs = SharedPreferencesAsync();
          await prefs.setBool('isSetupComplete', false);
          await prefs.setBool('permissionGranted', false);
          await prefs.setBool('dbReplaced', false);
          await prefs.setBool('dataLoadedCorrectly', false);
          _showToast("App is resetting...");
          await Future.delayed(const Duration(seconds: 1));
          SystemNavigator.pop();
          exit(0);
        }
      },
      icon: const Icon(Icons.restart_alt_rounded),
      tooltip: 'Reset',
    );
  }
}

class UpdateButton extends StatelessWidget {
  const UpdateButton({super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
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
      return Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            color: Theme.of(context).cardColor,
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
                      Column(
                        children: [
                          const Icon(Icons.update_rounded,
                              color: Colors.white, size: 32),
                          const SizedBox(height: 8),
                          const Text(
                            'Update Available',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "$appName ($latestVersion) available.",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.tertiary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
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
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.tertiary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: const Text(
                            'Download',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
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
}
