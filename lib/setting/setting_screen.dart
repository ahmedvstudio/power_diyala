import 'package:flutter/material.dart';
import 'package:power_diyala/pages/licences.dart';

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
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = _getSelectedIndex(widget.themeMode);
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
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.announcement_outlined),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const LicenceSimple()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showDialog(context);
            },
          ),
        ],
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Image.asset(
                  'assets/aaa.png',
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
                              topRight: Radius.circular(index == 2 ? 20.0 : 0),
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

              Text(
                'Last update: 30/9/2024',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              Text(
                'Version: stable 0.24.10',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Who made this'),
        content: const Text('Ahmed Adnan\n-Call me for feedback\n07501101484'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('Okay'),
          ),
        ],
      );
    },
  );
}
