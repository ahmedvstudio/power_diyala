import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:power_diyala/screens/setup_screen.dart';
import 'package:power_diyala/settings/check_connectivity.dart';
import 'package:power_diyala/settings/theme_control.dart';
import 'package:provider/provider.dart' as provider;

class PowerDiyala extends StatefulWidget {
  const PowerDiyala({super.key});

  @override
  State<PowerDiyala> createState() => _PowerDiyalaState();
}

class _PowerDiyalaState extends State<PowerDiyala> {
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
    return provider.MultiProvider(
      providers: [
        provider.ChangeNotifierProvider(create: (_) => ThemeControl()),
        provider.ChangeNotifierProvider(create: (_) => ConnectivityService()),
      ],
      child: provider.Consumer2<ThemeControl, ConnectivityService>(
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
