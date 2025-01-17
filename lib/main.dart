import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:power_diyala/data_helper/data_manager.dart';
import 'package:power_diyala/firebase_options.dart';
import 'package:power_diyala/screens/setup_screen.dart';
import 'package:flutter/material.dart';
import 'package:power_diyala/settings/check_connectivity.dart';
import 'package:power_diyala/settings/notifications_services.dart';
import 'package:power_diyala/settings/remote_config.dart';
import 'package:provider/provider.dart';
import 'settings/theme_control.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:timezone/data/latest.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: WidgetsBinding.instance);

  final Logger logger =
      kDebugMode ? Logger() : Logger(printer: PrettyPrinter());

  try {
    await dotenv.load(fileName: ".env");
    if (dotenv.env['DB_PASSWORD'] == null) {
      throw Exception('DATABASE_PASSWORD not found in .env file');
    }
  } catch (e) {
    logger.e('Error loading .env file: $e');
  }

  await DataManager().loadAllData();

  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    logger.e('Firebase initialization failed: $e');
  }
  LocalNotificationService().requestNotificationPermission();

  LocalNotificationService().initNotification();
  tz.initializeTimeZones();

  await fetchAndActivate();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initialization();
  }

  void initialization() async {
    await Future.delayed(const Duration(seconds: 1));
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeControl()),
        ChangeNotifierProvider(create: (_) => ConnectivityService()),
      ],
      child: Consumer2<ThemeControl, ConnectivityService>(
        builder: (context, themeControl, connectivityService, child) {
          return MaterialApp(
            title: 'Power Diyala',
            theme: themeControl.appTheme(isDarkMode: false),
            darkTheme: themeControl.appTheme(isDarkMode: true),
            themeMode: themeControl.themeMode,
            home: const SetupScreen(),
          );
        },
      ),
    );
  }
}
