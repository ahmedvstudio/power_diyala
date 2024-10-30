import 'dart:async';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
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
// Default index of the first screen
  int _selectedIndex = 0;
  final List<Widget> _screens = [];
  late AnimationController _fabAnimationController;
  late AnimationController _borderRadiusAnimationController;
  late Animation<double> fabAnimation;
  late Animation<double> borderRadiusAnimation;
  late CurvedAnimation fabCurve;
  late CurvedAnimation borderRadiusCurve;
  final List<String> labels = [
    "Calculator", // For index 0
    "Teams", // For index 1
    "SPMS", // For index 2
    "Network", // For index 3
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
// Initialize screens
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

    _fabAnimationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _borderRadiusAnimationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    fabCurve = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
    );
    borderRadiusCurve = CurvedAnimation(
      parent: _borderRadiusAnimationController,
      curve: Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
    );

    fabAnimation = Tween<double>(begin: 0, end: 1).animate(fabCurve);
    borderRadiusAnimation = Tween<double>(begin: 0, end: 1).animate(
      borderRadiusCurve,
    );

    Future.delayed(
      Duration(seconds: 1),
      () => _fabAnimationController.forward(),
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
                  builder: (context) => PmSheetPage(
                        themeMode: themeControl.themeMode,
                        onThemeChanged: (value) {
                          themeControl.toggleTheme(value);
                        },
                      )));
            },
            icon: const Icon(Icons.add),
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
      body: NotificationListener<ScrollNotification>(
        child: _screens[_selectedIndex],
      ),
      floatingActionButton: FadeTransition(
        opacity: fabAnimation,
        child: FloatingActionButton(
          shape: CircleBorder(),
          child: Icon(
            Icons.add,
          ),
          onPressed: () {},
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
                  size: 20,
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
        notchSmoothness: NotchSmoothness.smoothEdge,
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
