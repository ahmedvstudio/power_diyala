import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:power_diyala/settings/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateChecker {
  Future<void> checkForUpdates(BuildContext context,
      {bool toast = true, bool isButtonPress = false}) async {
    SharedPreferencesAsync prefs = SharedPreferencesAsync();
    final now = DateTime.now();
    final lastCheck = await prefs.getString('lastUpdateCheck');

    if (!isButtonPress && lastCheck != null) {
      final lastCheckTime = DateTime.parse(lastCheck);
      if (now.difference(lastCheckTime).inHours < 6) {
        if (toast) _showToast('This is the latest version.');
        return;
      }
    }

    try {
      final response = await http
          .get(Uri.parse(repoLink))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latestVersion = data['tag_name'];

        prefs.setString('lastUpdateCheck', now.toIso8601String());

        if (appVersion != latestVersion) {
          if (context.mounted) {
            _showUpdateDialog(context, latestVersion);
          }
        } else {
          if (toast) _showToast("This is the latest version.");
        }
      } else {
        if (toast) {
          _showToast(
              "Failed to fetch updates. Status Code: ${response.statusCode}");
        }
      }
    } catch (e) {
      if (toast) _showToast("Network error or timeout occurred");
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
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
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
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
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

  void _showToast(message) => Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 14.0,
      );
}
