import 'dart:async';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:power_diyala/screens/calc_screen.dart';
import 'package:power_diyala/screens/network_screen.dart';
import 'package:power_diyala/screens/pm_sheet_screen.dart';
import 'package:power_diyala/screens/setting_screen.dart';
import 'package:power_diyala/screens/spms_screen.dart';
import 'package:power_diyala/screens/teams_screen.dart';
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

    _screens.add(
      Consumer<ThemeControl>(
        builder: (context, themeControl, child) {
          return CalculatorScreen(
            themeMode: themeControl.themeMode,
            onThemeChanged: (value) {
              themeControl.toggleTheme(value);
            },
          );
        },
      ),
    );
    _screens.add(
      Consumer<ThemeControl>(
        builder: (context, themeControl, child) {
          return TeamsScreen(
            themeMode: themeControl.themeMode,
            onThemeChanged: (value) {
              themeControl.toggleTheme(value);
            },
          );
        },
      ),
    );

    _screens.add(
      Consumer<ThemeControl>(
        builder: (context, themeControl, child) {
          return SpmsScreen(
            themeMode: themeControl.themeMode,
            onThemeChanged: (value) {
              themeControl.toggleTheme(value);
            },
          );
        },
      ),
    );
    _screens.add(
      Consumer<ThemeControl>(
        builder: (context, themeControl, child) {
          return NetworkScreen(
            themeMode: themeControl.themeMode,
            onThemeChanged: (value) {
              themeControl.toggleTheme(value);
            },
          );
        },
      ),
    );

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
      body: NotificationListener<ScrollNotification>(
        child: _screens[_selectedIndex],
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        spacing: 10,
        spaceBetweenChildren: 10,
        children: [
          SpeedDialChild(
            shape: CircleBorder(),
            child: Icon(Icons.add_chart, color: Colors.white),
            backgroundColor: Colors.green,
            label: 'CM',
            onTap: () {},
          ),
          SpeedDialChild(
            shape: CircleBorder(),
            child: Icon(Icons.assessment, color: Colors.white),
            backgroundColor: Colors.red,
            label: 'PM',
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => PmSheetPage(
                        themeMode: themeControl.themeMode,
                        onThemeChanged: (value) {
                          themeControl.toggleTheme(value);
                        },
                      )));
            },
          ),
        ],
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
