import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:power_diyala/data_helper/database_helper.dart';
import 'package:power_diyala/widgets/color_picker.dart';
import 'package:power_diyala/widgets/buttons.dart';
import 'package:power_diyala/screens/licences.dart';
import 'package:logger/logger.dart';
import 'package:power_diyala/settings/constants.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  const SettingsScreen({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  final Logger logger =
      kDebugMode ? Logger() : Logger(printer: PrettyPrinter());
  late int _selectedIndex;
  Map<String, dynamic>? _infoData;

  @override
  void initState() {
    super.initState();
    _selectedIndex = _getSelectedIndex(widget.themeMode);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      List<Map<String, dynamic>> data = await DatabaseHelper.loadInfoData();
      logger.i(data);

      if (data.isNotEmpty) {
        _infoData = data.first;
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar('Error loading data: ${e.toString()}');
      }
    }
  }

  void _showSnackbar(String message,
      {Duration duration = const Duration(seconds: 3)}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: duration),
    );
  }

  int _getSelectedIndex(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 1;
      case ThemeMode.dark:
        return 2;
      case ThemeMode.system:
      default:
        return 0;
    }
  }

  void _onToggle(int index) {
    setState(() {
      _selectedIndex = index;

      switch (index) {
        case 0:
          widget.onThemeChanged(ThemeMode.system);
          break;
        case 1:
          widget.onThemeChanged(ThemeMode.light);
          break;
        case 2:
          widget.onThemeChanged(ThemeMode.dark);
          break;
      }
    });
  }

  // Define a list of icons for each theme mode
  final List<IconData> themeIcons = [
    Icons.settings_system_daydream, // System
    Icons.wb_sunny, // Light
    Icons.nights_stay, // Dark
  ];

  @override
  Widget build(BuildContext context) {
    const double iconSize = 30;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => ColorPickerDialog(),
                );
              },
              icon: Icon(Icons.color_lens_rounded),
              tooltip: 'Color Palette'),
          IconButton(
            onPressed: () async {
              Navigator.of(context).pop();
              const url = reportIssue;
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url),
                    mode: LaunchMode.externalApplication);
              } else {}
            },
            icon: Icon(Icons.bug_report_rounded),
            tooltip: 'Report a bug',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Image.asset(
                    iconPath,
                    width: 250,
                  ),
                ),
                SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(3, (index) {
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => _onToggle(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              color: _selectedIndex == index
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).secondaryHeaderColor,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(index == 0 ? 20.0 : 0),
                                bottomLeft:
                                    Radius.circular(index == 0 ? 20.0 : 0),
                                topRight:
                                    Radius.circular(index == 2 ? 20.0 : 0),
                                bottomRight:
                                    Radius.circular(index == 2 ? 20.0 : 0),
                              ),
                              border: Border.all(
                                color: _selectedIndex == index
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context).primaryColor,
                                width: 1.0, // Adjust the width as needed
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Display icon next to the selected theme text
                                if (_selectedIndex == index)
                                  Icon(
                                    themeIcons[index],
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                const SizedBox(width: 8),

                                Text(
                                  index == 0
                                      ? 'System'
                                      : index == 1
                                          ? 'Light'
                                          : 'Dark',
                                  style: TextStyle(
                                      color: _selectedIndex == index
                                          ? Colors.white
                                          : Colors.black,
                                      fontStyle: FontStyle.italic),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const UpdateButton(),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      child: const Text('Open Sources Licences'),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const LicencePage(),
                        ));
                      },
                    ),
                    const SizedBox(height: 8),
                    const ResetTextButton(),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        appName,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                    Center(
                      child: Text('Stable $appVersion',
                          style: Theme.of(context).textTheme.labelSmall),
                    ),
                    if (_infoData != null &&
                        _infoData!.containsKey('last_update'))
                      Center(
                        child: Text(
                            'Data version: ${_infoData!['last_update'] ?? 'N/A'}',
                            style: Theme.of(context).textTheme.labelSmall),
                      ),
                    Center(
                      child: Text(appLegalese,
                          style: Theme.of(context).textTheme.labelSmall),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: () async {
                            const url = faceBook;
                            if (await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(Uri.parse(url),
                                  mode: LaunchMode.externalApplication);
                            } else {}
                          },
                          icon: Icon(SimpleIcons.facebook, size: iconSize),
                        ),
                        IconButton(
                          onPressed: () async {
                            const url = gitHub;
                            if (await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(Uri.parse(url),
                                  mode: LaunchMode.externalApplication);
                            } else {}
                          },
                          icon: Icon(SimpleIcons.github, size: iconSize),
                        ),
                        IconButton(
                          onPressed: () async {
                            const url = xTwitter;
                            if (await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(Uri.parse(url),
                                  mode: LaunchMode.externalApplication);
                            } else {}
                          },
                          icon: Icon(SimpleIcons.x, size: iconSize),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
