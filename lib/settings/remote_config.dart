import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, dynamic>> fetchAndActivate() async {
  final remoteConfig = FirebaseRemoteConfig.instance;

  // Set the config settings
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(minutes: 1),
    minimumFetchInterval: const Duration(hours: 6),
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
    'dataFile_url': 'default_id',
  });

  try {
    // Fetch and activate remote config values
    await remoteConfig.fetchAndActivate();
    _printFetchedData(remoteConfig);
    // Get the fetched values in a map
    final configValues = _getConfigValues(remoteConfig);

    // Save the fetched values locally
    await _saveToLocal(configValues);

    return configValues;
  } catch (e) {
    if (kDebugMode) {
      print('Error fetching remote config: $e');
    }

    return await _loadFromLocal();
  }
}

void _printFetchedData(FirebaseRemoteConfig remoteConfig) {
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
    print('url==> ${remoteConfig.getString('dataFile_url')}');
  }
}

Map<String, dynamic> _getConfigValues(FirebaseRemoteConfig remoteConfig) {
  return {
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
    'dataFile_url': remoteConfig.getString('dataFile_url'),
  };
}

Future<void> _saveToLocal(Map<String, dynamic> configValues) async {
  SharedPreferencesAsync prefs = SharedPreferencesAsync();
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
  await prefs.setString('dataFile_url', configValues['dataFile_url']);
}

Future<Map<String, dynamic>> _loadFromLocal() async {
  SharedPreferencesAsync prefs = SharedPreferencesAsync();
  // Load values from local storage
  Map<String, dynamic> configValues = {
    'isCalculatorHere': await prefs.getBool('isCalculatorHere') ?? true,
    'isTeamsHere': await prefs.getBool('isTeamsHere') ?? true,
    'isSPMSHere': await prefs.getBool('isSPMSHere') ?? true,
    'isNetworkHere': await prefs.getBool('isNetworkHere') ?? true,
    'isPMsheetON': await prefs.getBool('isPMsheetON') ?? true,
    'isCMsheetON': await prefs.getBool('isCMsheetON') ?? true,
    'isBannerON': await prefs.getBool('isBannerON') ?? false,
    'bannerText': await prefs.getString('bannerText') ?? "",
    'bannerTitle': await prefs.getString('bannerTitle') ?? "",
    'database_download_id':
        await prefs.getString('database_download_id') ?? "default_id",
    'dataFile_url': await prefs.getString('dataFile_url') ?? "default_id",
  };
  if (kDebugMode) {
    print('Local values loaded: $configValues');
  }
  return configValues;
}
