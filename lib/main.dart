import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:power_diyala/data_helper/calc_table_helper.dart';
import 'package:power_diyala/screens/stepper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'settings/theme_control.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
