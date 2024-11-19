import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:power_diyala/settings/download_data.dart';
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
    return OutlinedButton(
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
      onLongPress: () async {
        // Show password dialog before updating the database
        bool passwordCorrect = await _showPasswordDialog(context);
        if (passwordCorrect) {
          await updateDatabase(); // Call the updateDatabase method
          _showToast("Database updated successfully.");
          await Future.delayed(const Duration(seconds: 3));
          SystemNavigator.pop(); // Close the app
        } else {
          _showToast("Incorrect password. Update canceled.");
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

Future<bool> _showPasswordDialog(BuildContext context) async {
  String password = dotenv.env['DRIVE_PASSWORD'] ?? "";
  return await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          final TextEditingController controller = TextEditingController();
          bool isObscured = true;
          return AlertDialog(
            title: const Text('Enter Password'),
            content: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controller,
                      obscureText: isObscured,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .error
                                .withOpacity(0.8)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.secondary),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.tertiary,
                            width: 2.0,
                          ),
                        ),
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 12.0),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isObscured
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 18,
                          ),
                          onPressed: () {
                            setState(() {
                              isObscured = !isObscured;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                child: const Text('Confirm'),
                onPressed: () {
                  if (controller.text == password) {
                    Navigator.of(context).pop(true);
                  } else {
                    Navigator.of(context).pop(false);
                  }
                },
              ),
            ],
          );
        },
      ) ??
      false;
}
