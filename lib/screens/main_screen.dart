import 'dart:async';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:marquee/marquee.dart';
import 'package:power_diyala/data_helper/calc_table_helper.dart';
import 'package:power_diyala/screens/cm_sheet_screen.dart';
import 'package:power_diyala/screens/calc_screen.dart';
import 'package:power_diyala/screens/network_screen.dart';
import 'package:power_diyala/screens/pm_sheet_screen.dart';
import 'package:power_diyala/screens/setting_screen.dart';
import 'package:power_diyala/screens/spms_screen.dart';
import 'package:power_diyala/screens/teams_screen.dart';
import 'package:power_diyala/settings/remote_config.dart';
import 'package:power_diyala/settings/theme_control.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  final autoSizeGroup = AutoSizeGroup();
  int _selectedIndex = 0;
  final List<Widget> _screens = [];
  late AnimationController _borderRadiusAnimationController;
  late Animation<double> borderRadiusAnimation;
  late CurvedAnimation borderRadiusCurve;
  // Default values
  bool isCalculatorHere = true;
  bool isTeamsHere = true;
  bool isSPMSHere = true;
  bool isNetworkHere = true;
  bool isPMsheetON = true;
  bool isCMsheetON = true;
  bool isBannerON = false;
  String bannerText = "";
  String bannerTitle = "";
  bool check = true;
  final List<String> labels = [
    "Calculator",
    "Teams",
    "SPMS",
    "Network",
  ];

  final iconList = <IconData>[
    Icons.calculate_rounded,
    Icons.group_rounded,
    Icons.home_repair_service_rounded,
    Icons.webhook_rounded,
  ];
  // Firebase Remote Config instance
  late FirebaseRemoteConfig remoteConfig;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
    _initializeScreens();

    _borderRadiusAnimationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    borderRadiusCurve = CurvedAnimation(
      parent: _borderRadiusAnimationController,
      curve: Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
    );

    borderRadiusAnimation = Tween<double>(begin: 0, end: 1).animate(
      borderRadiusCurve,
    );

    Future.delayed(
      Duration(seconds: 1),
      () => _borderRadiusAnimationController.forward(),
    );
  }

  void _initializeScreens() {
    _screens.add(
      Consumer<ThemeControl>(
        builder: (context, themeControl, child) {
          return isCalculatorHere
              ? CalculatorScreen(
                  themeMode: themeControl.themeMode,
                  onThemeChanged: (value) {
                    themeControl.toggleTheme(value);
                  },
                )
              : Center(
                  child: Text('Not available'),
                );
        },
      ),
    );
    _screens.add(
      Consumer<ThemeControl>(
        builder: (context, themeControl, child) {
          return isTeamsHere
              ? TeamsScreen(
                  themeMode: themeControl.themeMode,
                  onThemeChanged: (value) {
                    themeControl.toggleTheme(value);
                  },
                )
              : Center(
                  child: Text('Not available'),
                );
        },
      ),
    );

    _screens.add(
      Consumer<ThemeControl>(
        builder: (context, themeControl, child) {
          return isSPMSHere
              ? SpmsScreen(
                  themeMode: themeControl.themeMode,
                  onThemeChanged: (value) {
                    themeControl.toggleTheme(value);
                  },
                )
              : Center(
                  child: Text('Not available'),
                );
        },
      ),
    );
    _screens.add(
      Consumer<ThemeControl>(
        builder: (context, themeControl, child) {
          return isNetworkHere
              ? NetworkScreen(
                  themeMode: themeControl.themeMode,
                  onThemeChanged: (value) {
                    themeControl.toggleTheme(value);
                  },
                )
              : Center(
                  child: Text('Not available'),
                );
        },
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _initializeFirebase() async {
    // Fetch and activate remote config values initially
    await _fetchAndActivateRemoteConfig();
    _fetchAndActivateRemoteConfig();
  }

// Fetch and activate remote config, then update local state
  Future<void> _fetchAndActivateRemoteConfig() async {
    try {
      final configValues = await fetchAndActivate();

      // Update local state with fetched values
      _updateLocalConfig(configValues);
    } catch (e) {
      logger.e('Error fetching remote config: $e');
    }
  }

// Update local state variables based on fetched config values
  void _updateLocalConfig(Map<String, dynamic> configValues) {
    setState(() {
      isCalculatorHere = configValues['isCalculatorHere'];
      isTeamsHere = configValues['isTeamsHere'];
      isSPMSHere = configValues['isSPMSHere'];
      isNetworkHere = configValues['isNetworkHere'];
      isPMsheetON = configValues['isPMsheetON'];
      isCMsheetON = configValues['isCMsheetON'];
      isBannerON = configValues['isBannerON'];
      bannerText = configValues['bannerText'];
      bannerTitle = configValues['bannerTitle'];
    });
  }

  void _showFeatureUnavailableDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Unavailable'),
          content: Text('This feature is not available.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeControl = Provider.of<ThemeControl>(context);
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(
          'Power Diyala',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          if (kDebugMode)
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.code),
              tooltip: 'test',
            ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                        themeMode: themeControl.themeMode,
                        onThemeChanged: (value) {
                          themeControl.toggleTheme(value);
                        },
                      )));
            },
            icon: const Icon(Icons.engineering),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          if (isBannerON)
            Container(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).secondaryHeaderColor,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor,
                    blurRadius: 8.0,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bannerTitle,
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic),
                        ),
                        SizedBox(height: 5.0),
                        SizedBox(
                          height: 20.0,
                          child: bannerText.isNotEmpty
                              ? Marquee(
                                  text: bannerText,
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                    fontSize: 14.0,
                                  ),
                                  scrollAxis: Axis.horizontal,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  blankSpace: 20.0,
                                  velocity: 100.0,
                                  pauseAfterRound: Duration(seconds: 1),
                                  startPadding: 10.0,
                                  accelerationDuration: Duration(seconds: 1),
                                  accelerationCurve: Curves.linear,
                                  decelerationDuration:
                                      Duration(milliseconds: 500),
                                  decelerationCurve: Curves.easeOut,
                                )
                              : Text(
                                  'No banner available',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                    fontSize: 14.0,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          isBannerON = false;
                        });
                      },
                      icon: Icon(Icons.close)),
                ],
              ),
            ),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              child: _screens[_selectedIndex],
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Theme.of(context).secondaryHeaderColor,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          overlayColor: Colors.black,
          overlayOpacity: 0.5,
          spacing: 10,
          spaceBetweenChildren: 10,
          children: [
            SpeedDialChild(
              shape: CircleBorder(),
              child: Icon(Icons.assignment, color: Colors.white),
              backgroundColor: Colors.green,
              label: 'CM',
              onTap: () {
                if (isCMsheetON) {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => CmSheetPage(
                      themeMode: themeControl.themeMode,
                      onThemeChanged: (value) {
                        themeControl.toggleTheme(value);
                      },
                    ),
                  ));
                } else {
                  _showFeatureUnavailableDialog(context);
                }
              },
            ),
            SpeedDialChild(
              shape: CircleBorder(),
              child: Icon(Icons.assessment, color: Colors.white),
              backgroundColor: Colors.red,
              label: 'PM',
              onTap: () {
                if (isPMsheetON) {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => PmSheetPage(
                      themeMode: themeControl.themeMode,
                      onThemeChanged: (value) {
                        themeControl.toggleTheme(value);
                      },
                    ),
                  ));
                } else {
                  _showFeatureUnavailableDialog(context);
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: iconList.length,
        tabBuilder: (int index, bool isActive) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(iconList[index],
                  size: 25,
                  color: isActive
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).secondaryHeaderColor),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: AutoSizeText(
                  labels[index],
                  maxLines: 1,
                  style: TextStyle(
                      color: isActive
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).secondaryHeaderColor),
                  group: autoSizeGroup,
                ),
              )
            ],
          );
        },
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        activeIndex: _selectedIndex,
        splashColor: Theme.of(context).colorScheme.tertiary,
        notchAndCornersAnimation: borderRadiusAnimation,
        splashSpeedInMilliseconds: 300,
        notchSmoothness: NotchSmoothness.defaultEdge,
        gapLocation: GapLocation.center,
        leftCornerRadius: 32,
        rightCornerRadius: 32,
        onTap: _onItemTapped,
        shadow: BoxShadow(
          offset: Offset(0, 1),
          blurRadius: 12,
          spreadRadius: 0.5,
          color: Theme.of(context).shadowColor,
        ),
      ),
    );
  }
}
