import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:power_diyala/Data_helper/database_helper.dart';
import 'package:power_diyala/Widgets/buttons.dart';
import 'package:power_diyala/Screens/licences.dart';
import 'package:logger/logger.dart';
import 'package:power_diyala/Widgets/constants.dart';
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
        // Assuming we're interested in the first item
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.arrow_back_ios),
                      tooltip: 'Back',
                    ),
                    IconButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        const url =
                            'https://github.com/Ahmed47v/power_diyala/issues/new/choose';
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(Uri.parse(url),
                              mode: LaunchMode.externalApplication);
                        } else {}
                      },
                      icon: const Icon(Icons.report_gmailerrorred_rounded),
                      color: Colors.red.withOpacity(0.8),
                      tooltip: 'Report an issue',
                    ),
                  ],
                ),
                Center(
                  child: Image.asset(
                    iconPath,
                    width: 250,
                  ),
                ),
                Text(
                  'Theme:',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 10), // Spacing
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
                                const SizedBox(
                                    width: 8), // Space between icon and text

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
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const UpdateButton(),
                    const SizedBox(height: 8),
                    TextButton(
                      child: const Text(
                        'Open Sources Licences',
                      ),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const LicenceSimple()));
                      },
                    ),
                    const SizedBox(height: 8),
                    const ResetTextButton(),
                    Center(
                      child: Text(
                        appName,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                    Center(
                      child: Text(
                        'Stable $appVersion',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                    Center(
                      child: Text(
                        'Last update: $lastUpdate',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                    if (_infoData != null &&
                        _infoData!.containsKey('last_update'))
                      Center(
                        child: Text(
                          'Data version: ${_infoData!['last_update'] ?? 'N/A'}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    Center(
                      child: Text(
                        appLegalese,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            const url = 'https://www.facebook.com/ahmed47v/';
                            if (await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(Uri.parse(url),
                                  mode: LaunchMode.externalApplication);
                            } else {}
                          },
                          icon: const Icon(
                            SimpleIcons.facebook,
                            color: SimpleIconColors.trakt,
                            size: iconSize,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            const url = 'https://github.com/Ahmed47v/';
                            if (await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(Uri.parse(url),
                                  mode: LaunchMode.externalApplication);
                            } else {}
                          },
                          icon: const Icon(
                            SimpleIcons.github,
                            color: SimpleIconColors.trakt,
                            size: iconSize,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            const url = 'https://x.com/ahmed47v';
                            if (await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(Uri.parse(url),
                                  mode: LaunchMode.externalApplication);
                            } else {}
                          },
                          icon: const Icon(
                            SimpleIcons.x,
                            color: SimpleIconColors.trakt,
                            size: iconSize,
                          ),
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
