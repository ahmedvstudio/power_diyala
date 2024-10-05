import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:power_diyala/calculator/calc_table_helper.dart';
import 'package:power_diyala/pages/stepper.dart';
import 'package:power_diyala/setting/setting_screen.dart';
import 'package:power_diyala/teams/teams_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'calculator/calc_screen.dart';
import 'theme_control.dart';
import 'package:power_diyala/spms/spms_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure Flutter bindings are initialized
  try {
    await dotenv.load(fileName: ".env");
    if (dotenv.env['DB_PASSWORD'] == null) {
      throw Exception('DATABASE_PASSWORD not found in .env file');
    }
  } catch (e) {
    logger.e('Error loading .env file: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeControl(),
      child: Consumer<ThemeControl>(
        builder: (context, themeControl, child) {
          return MaterialApp(
            title: 'Power Diyala',
            theme: themeControl.appTheme(isDarkMode: false),
            darkTheme: themeControl.appTheme(isDarkMode: true),
            themeMode: themeControl.themeMode,
            home: const StepperScreen(),
          );
        },
      ),
    );
  }
}

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
          return SpmsScreen(
            themeMode: themeControl.themeMode,
            onThemeChanged: (value) {
              themeControl.toggleTheme(value);
            },
          );
        },
      ),
    ); // SPMS screen placeholder
    _screens.add(Consumer<ThemeControl>(
      builder: (context, themeControl, child) {
        return TeamsScreen(
          themeMode: themeControl.themeMode,
          onThemeChanged: (value) {
            themeControl.toggleTheme(value);
          },
        );
      },
    ));
    _screens.add(Container(
      color: Colors.blueGrey,
      child: const Center(child: Text('Soon ...')),
    ));
    _screens.add(Consumer<ThemeControl>(
      builder: (context, themeControl, child) {
        return SettingsScreen(
          themeMode: themeControl.themeMode,
          onThemeChanged: (value) {
            themeControl.toggleTheme(value);
          },
        );
      },
    ));
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8.0,
              offset: const Offset(0, -2), // Shadow above the bar
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
                icon: Icon(Icons.home_repair_service),
                label: 'SPMS',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.groups_sharp),
                label: 'Teams',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.webhook),
                label: 'Test',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
            currentIndex: _selectedIndex,
            unselectedItemColor: Colors.grey,
            selectedItemColor: ThemeControl.primaryColor,
            showUnselectedLabels: true,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
          ),
        ),
      ),
    );
  }
}
