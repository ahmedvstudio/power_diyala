import 'dart:async';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:logger/logger.dart';
import 'package:marquee/marquee.dart';
import 'package:power_diyala/screens/cm_sheet_screen.dart';
import 'package:power_diyala/screens/calc_screen.dart';
import 'package:power_diyala/screens/email_sender_screen.dart';
import 'package:power_diyala/screens/network_screen.dart';
import 'package:power_diyala/screens/pm_sheet_screen.dart';
import 'package:power_diyala/screens/setting_screen.dart';
import 'package:power_diyala/screens/spms_screen.dart';
import 'package:power_diyala/screens/teams_screen.dart';
import 'package:power_diyala/settings/check_connectivity.dart';
import 'package:power_diyala/settings/remote_config.dart';
import 'package:power_diyala/data_helper/note_helper.dart';
import 'package:power_diyala/test/note_list_page.dart';
import 'package:power_diyala/test/test_screen.dart';
import 'package:power_diyala/settings/theme_control.dart';
import 'package:power_diyala/settings/update_checker.dart';
import 'package:power_diyala/widgets/widgets.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  final Logger logger =
      kDebugMode ? Logger() : Logger(printer: PrettyPrinter());
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

  @override
  void initState() {
    super.initState();
    _initializeScreens();
    _fetchAndActivateRemoteConfig();
    UpdateChecker().checkForUpdates(context, toast: false);
    _borderRadiusAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    borderRadiusCurve = CurvedAnimation(
      parent: _borderRadiusAnimationController,
      curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
    );

    borderRadiusAnimation = Tween<double>(begin: 0, end: 1).animate(
      borderRadiusCurve,
    );

    Future.delayed(
      const Duration(seconds: 1),
      () => _borderRadiusAnimationController.forward(),
    );
  }

  Future<void> _fetchAndActivateRemoteConfig() async {
    try {
      final configValues = await fetchAndActivate();

      _updateLocalConfig(configValues);
    } catch (e) {
      logger.e('Error fetching remote config: $e');
    }
  }

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
      _initializeScreens();
    });
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
              : const NotAvailableWidget();
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
              : const NotAvailableWidget();
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
              : const NotAvailableWidget();
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
              : const NotAvailableWidget();
        },
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showFeatureUnavailable(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20), // Round all corners
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
                            Icon(Icons.warning, color: Colors.white, size: 32),
                            SizedBox(height: 8),
                            Text(
                              'OOPs...',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Under maintenance',
                              style: TextStyle(color: Colors.white),
                            )
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
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
                          'Try again',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
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

  @override
  Widget build(BuildContext context) {
    final isOnline = Provider.of<ConnectivityService>(context).isOnline;
    final themeControl = Provider.of<ThemeControl>(context);
    if (Provider.of<ConnectivityService>(context).isOnline) {
      fetchAndActivate();
    }
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Power ',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
              ),
              TextSpan(
                text: 'Diyala',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.normal,
                      color: isOnline ? const Color(0xff00E676) : Colors.red,
                    ),
              ),
            ],
          ),
        ),
        actions: [
          if (kDebugMode)
            IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => Test(
                          themeMode: themeControl.themeMode,
                          onThemeChanged: (value) {
                            themeControl.toggleTheme(value);
                          },
                        )));
              },
              icon: const Icon(Icons.code),
              tooltip: 'test',
            ),
          IconButton(
            onPressed: () async {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => NotesListPage(
                  themeMode: themeControl.themeMode,
                  onThemeChanged: (value) {
                    themeControl.toggleTheme(value);
                  },
                ),
              ));
            },
            icon: StreamBuilder<List<Map<String, dynamic>>>(
              stream:
                  NoteHelper().getNotesStream(), // Listen to the notes stream
              builder: (context, snapshot) {
                int noteCount = 0;

                // Check the state and count notes
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(); // Optionally show loading indicator
                } else if (snapshot.hasError) {
                  return const Icon(
                      Icons.error); // Show error icon if there's an error
                } else if (snapshot.hasData) {
                  noteCount =
                      snapshot.data!.length; // Count the number of notes
                }

                return Stack(
                  children: [
                    Icon(
                      noteCount > 0
                          ? Icons.notifications
                          : Icons.notifications_none_rounded,
                    ),
                    if (noteCount > 0)
                      Positioned(
                        right: 0,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$noteCount',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 10),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            tooltip: 'Notes',
          ),
          IconButton(
            onPressed: () async {
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
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              margin: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    Theme.of(context).secondaryHeaderColor
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withValues(alpha: 0.5),
                    blurRadius: 5.0,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                    color: Theme.of(context).colorScheme.tertiary, width: 0.5),
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
                          style: const TextStyle(
                              color: Colors.red,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 5.0),
                        SizedBox(
                          height: 20.0,
                          child: bannerText.isNotEmpty
                              ? Marquee(
                                  text: bannerText,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14.0,
                                  ),
                                  scrollAxis: Axis.horizontal,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  blankSpace: 20.0,
                                  velocity: 100.0,
                                  pauseAfterRound: const Duration(seconds: 1),
                                  startPadding: 10.0,
                                  accelerationDuration:
                                      const Duration(seconds: 1),
                                  accelerationCurve: Curves.linear,
                                  decelerationDuration:
                                      const Duration(milliseconds: 500),
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
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isBannerON = false;
                      });
                    },
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.black54,
                    ),
                  ),
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
              color: Colors.grey.withValues(alpha: 0.5),
              spreadRadius: 2,
              blurRadius: 7,
              offset: const Offset(0, 3),
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
              shape: const CircleBorder(),
              child: const Icon(Icons.assignment, color: Colors.white),
              backgroundColor: Colors.teal,
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
                  _showFeatureUnavailable(context);
                }
              },
            ),
            SpeedDialChild(
              shape: const CircleBorder(),
              child: const Icon(Icons.assessment, color: Colors.white),
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
                  _showFeatureUnavailable(context);
                }
              },
            ),
            SpeedDialChild(
              shape: const CircleBorder(),
              child: const Icon(Icons.mail, color: Colors.white),
              backgroundColor: Colors.blueAccent,
              label: 'Email',
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => EmailSender(
                    themeMode: themeControl.themeMode,
                    onThemeChanged: (value) {
                      themeControl.toggleTheme(value);
                    },
                  ),
                ));
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
          offset: const Offset(0, 1),
          blurRadius: 12,
          spreadRadius: 0.5,
          color: Theme.of(context).shadowColor,
        ),
      ),
    );
  }
}
