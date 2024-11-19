import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Fetch and activate remote config values
Future<Map<String, dynamic>> fetchAndActivate() async {
  final remoteConfig = FirebaseRemoteConfig.instance;

  // Set the config settings
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(minutes: 1),
    minimumFetchInterval: const Duration(seconds: 30),
  ));

  // Set default values
  await remoteConfig.setDefaults(const {
    'isCalculatorHere': true,
    'isTeamsHere': true,
    'isSPMSHere': true,
    'isNetworkHere': true,
    'isPMsheetON': true,
    'isCMsheetON': true,
    'isBannerON': false,
    'bannerText': "",
    'bannerTitle': "",
    'database_download_id': 'default_id',
  });

  try {
    // Fetch and activate remote config values
    await remoteConfig.fetchAndActivate();
    if (kDebugMode) {
      print('Calculator==> ${remoteConfig.getBool('isCalculatorHere')}');
      print('Teams==> ${remoteConfig.getBool('isTeamsHere')}');
      print('SPMS==> ${remoteConfig.getBool('isSPMSHere')}');
      print('Network==> ${remoteConfig.getBool('isNetworkHere')}');
      print('PM Sheet==> ${remoteConfig.getBool('isPMsheetON')}');
      print('CM Sheet==> ${remoteConfig.getBool('isCMsheetON')}');
      print('Banner==> ${remoteConfig.getBool('isBannerON')}');
      print('Banner Title==> ${remoteConfig.getString('bannerTitle')}');
      print('Banner Text==> ${remoteConfig.getString('bannerText')}');
      print('ID==> ${remoteConfig.getString('database_download_id')}');
    }
    // Get the fetched values in a map
    final configValues = {
      'isCalculatorHere': remoteConfig.getBool('isCalculatorHere'),
      'isTeamsHere': remoteConfig.getBool('isTeamsHere'),
      'isSPMSHere': remoteConfig.getBool('isSPMSHere'),
      'isNetworkHere': remoteConfig.getBool('isNetworkHere'),
      'isPMsheetON': remoteConfig.getBool('isPMsheetON'),
      'isCMsheetON': remoteConfig.getBool('isCMsheetON'),
      'isBannerON': remoteConfig.getBool('isBannerON'),
      'bannerText': remoteConfig.getString('bannerText'),
      'bannerTitle': remoteConfig.getString('bannerTitle'),
      'database_download_id': remoteConfig.getString('database_download_id'),
    };

    // Save the fetched values locally
    await _saveToLocal(configValues);

    return configValues;
  } catch (e) {
    if (kDebugMode) {
      print('Error fetching remote config: $e');
    }

    // If fetch fails (e.g., due to offline), return last known values
    return await _loadFromLocal();
  }
}

// Method to save config values to SharedPreferences
Future<void> _saveToLocal(Map<String, dynamic> configValues) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isCalculatorHere', configValues['isCalculatorHere']);
  await prefs.setBool('isTeamsHere', configValues['isTeamsHere']);
  await prefs.setBool('isSPMSHere', configValues['isSPMSHere']);
  await prefs.setBool('isNetworkHere', configValues['isNetworkHere']);
  await prefs.setBool('isPMsheetON', configValues['isPMsheetON']);
  await prefs.setBool('isCMsheetON', configValues['isCMsheetON']);
  await prefs.setBool('isBannerON', configValues['isBannerON']);
  await prefs.setString('bannerText', configValues['bannerText']);
  await prefs.setString(
      'database_download_id', configValues['database_download_id']);
}

// Method to load config values from SharedPreferences
Future<Map<String, dynamic>> _loadFromLocal() async {
  final prefs = await SharedPreferences.getInstance();
  return {
    'isCalculatorHere': prefs.getBool('isCalculatorHere') ?? true,
    'isTeamsHere': prefs.getBool('isTeamsHere') ?? true,
    'isSPMSHere': prefs.getBool('isSPMSHere') ?? true,
    'isNetworkHere': prefs.getBool('isNetworkHere') ?? true,
    'isPMsheetON': prefs.getBool('isPMsheetON') ?? true,
    'isCMsheetON': prefs.getBool('isCMsheetON') ?? true,
    'isBannerON': prefs.getBool('isBannerON') ?? false,
    'bannerText': prefs.getString('bannerText') ?? "",
    'bannerTitle': prefs.getString('bannerTitle') ?? "",
    'database_download_id':
        prefs.getString('database_download_id') ?? "default_id",
  };
}
