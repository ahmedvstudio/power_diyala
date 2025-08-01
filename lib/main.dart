import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:power_diyala/data_helper/data_manager.dart';
import 'package:power_diyala/firebase_options.dart';
import 'package:power_diyala/power_diyala.dart';
import 'package:flutter/material.dart';
import 'package:power_diyala/settings/notifications_services.dart';
import 'package:power_diyala/settings/remote_config.dart';
import 'core/utils/helpers/logger.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:timezone/data/latest.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: WidgetsBinding.instance);

  // --> init .env
  await dotenv.load(fileName: ".env");

  // --> load all the data
  await DataManager().loadAllData();

  // --> init firebase
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    Vlogger.error('Firebase initialization failed: $e');
  }

  // -- > init local Notification
  LocalNotificationService().requestNotificationPermission();
  LocalNotificationService().initNotification();
  tz.initializeTimeZones();

  // --> init Remote Config
  try {
    await fetchAndActivate();
  } catch (e) {
    Vlogger.error('Remote Config initialization failed: $e');
  }

  // --> force Portrait
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(
      const PowerDiyala(),
    );
  });
}
