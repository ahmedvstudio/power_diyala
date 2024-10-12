import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:power_diyala/screens/calc_screen.dart';
import 'package:power_diyala/screens/teams_screen.dart';
import 'package:power_diyala/screens/spms_screen.dart';
import 'package:power_diyala/screens/network_screen.dart';
import 'package:power_diyala/screens/setting_screen.dart';
import 'package:power_diyala/settings/theme_control.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [];

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
    _screens.add(
      Consumer<ThemeControl>(
        builder: (context, themeControl, child) {
          return SettingsScreen(
            themeMode: themeControl.themeMode,
            onThemeChanged: (value) {
              themeControl.toggleTheme(value);
            },
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

  @override
  Widget build(BuildContext context) {
    final themeControl = Provider.of<ThemeControl>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Power Diyala',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => _screens[4]));
            },
            icon: const Icon(Icons.engineering),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8.0,
              offset: const Offset(0, -2),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.calculate),
                label: 'Calculator',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.groups_sharp),
                label: 'Teams',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.home_repair_service),
                label: 'SPMS',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.webhook),
                label: 'Network',
              ),
            ],
            currentIndex: _selectedIndex,
            unselectedItemColor: Colors.grey,
            selectedItemColor: themeControl.primaryColor,
            showUnselectedLabels: true,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
          ),
        ),
      ),
    );
  }
}
