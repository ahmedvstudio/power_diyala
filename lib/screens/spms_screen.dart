import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:power_diyala/Data_helper/spms_tables_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:power_diyala/data_helper/database_helper.dart';
import 'package:power_diyala/Widgets/widgets.dart';
import 'package:logger/logger.dart';
import 'package:power_diyala/screens/statistics_screen.dart';

class SpmsScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final Function(ThemeMode) onThemeChanged;

  const SpmsScreen(
      {super.key, required this.themeMode, required this.onThemeChanged});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<SpmsScreen> {
  final Logger logger =
      kDebugMode ? Logger() : Logger(printer: PrettyPrinter());
  List<Map<String, dynamic>>? _data;
  String? _selectedSiteName;
  List<String> _siteNames = [];
  final List<Map<String, dynamic>> components = [
    {
      'title': 'Battery',
      'field1': 'batteryG1',
      'field2': 'batteryG2',
      'color': const Color(0xffFFCDD2)
    },
    {
      'title': 'Starter Motor',
      'field1': 'starterG1',
      'field2': 'starterG2',
      'color': const Color(0xffF8BBD0)
    },
    {
      'title': 'Dynamo',
      'field1': 'dynamoG1',
      'field2': 'dynamoG2',
      'color': const Color(0xffE1BEE7)
    },
    {
      'title': 'Radiator',
      'field1': 'radiatorG1',
      'field2': 'radiatorG2',
      'color': const Color(0xffD1C4E9)
    },
    {
      'title': 'Fan Belt',
      'field1': 'fanbeltG1',
      'field2': 'fanbeltG2',
      'color': const Color(0xffC5CAE9)
    },
    {
      'title': 'AVR',
      'field1': 'avrG1',
      'field2': 'avrG2',
      'color': const Color(0xffBBDEFB)
    },
    {
      'title': 'Protection Control',
      'field1': 'protectionG1',
      'field2': 'protectionG2',
      'color': const Color(0xffB3E5FC)
    },
    {
      'title': 'Charger',
      'field1': 'chargerG1',
      'field2': 'chargerG2',
      'color': const Color(0xffB2EBF2)
    },
    {
      'title': 'Selenoid',
      'field1': 'seleniodG1',
      'field2': 'seleniodG2',
      'color': const Color(0xffB2DFDB)
    },
    {
      'title': 'Water Pump',
      'field1': 'waterpumpG1',
      'field2': 'waterpumpG2',
      'color': const Color(0xffC8E6C9)
    },
    {
      'title': 'Water Pump Pulley',
      'field1': 'waterpulleyG1',
      'field2': 'waterpulleyG2',
      'color': const Color(0xffDCEDC8)
    },
    {
      'title': 'Coolant Level Sensor',
      'field1': 'levelsensorG1',
      'field2': 'levelsensorG2',
      'color': const Color(0xffF0F4C3)
    },
    {
      'title': 'Oil Sensor',
      'field1': 'oilsensorG1',
      'field2': 'oilsensorG2',
      'color': const Color(0xffFFF9C4)
    },
    {
      'title': 'Rocker Arm Gasket',
      'field1': 'rockerG1',
      'field2': 'rockerG2',
      'color': const Color(0xffFFECB3)
    },
    {
      'title': 'Cylinder Head Cover Gasket',
      'field1': 'cylinderG1',
      'field2': 'cylinderG2',
      'color': const Color(0xffFFE0B2)
    },
    {
      'title': 'Rear Oil Seal',
      'field1': 'rearG1',
      'field2': 'rearG2',
      'color': const Color(0xffFFCCBC)
    },
    {
      'title': 'Front Oil Seal',
      'field1': 'frontG1',
      'field2': 'frontG2',
      'color': const Color(0xffD7CCC8)
    },
    {
      'title': 'Oil Pan Gasket',
      'field1': 'panG1',
      'field2': 'panG2',
      'color': const Color(0xffF5F5F5)
    },
    {
      'title': 'Timing Case Washer',
      'field1': 'timingG1',
      'field2': 'timingG2',
      'color': const Color(0xffCFD8DC)
    },
    {
      'title': 'Fuel Injection Pump',
      'field1': 'injectionG1',
      'field2': 'injectionG2',
      'color': const Color(0xffFFCDD2)
    },
    {
      'title': 'Fuel Lift Pump',
      'field1': 'liftpumpG1',
      'field2': 'liftpumpG2',
      'color': const Color(0xffB3E5FC)
    },
    {
      'title': 'Nozzle',
      'field1': 'noozleG1',
      'field2': 'noozleG2',
      'color': const Color(0xffC5CAE9)
    },
    {
      'title': 'Temp. Sensor',
      'field1': 'tempG1',
      'field2': 'tempG2',
      'color': const Color(0xffF0F4C3)
    },
  ];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      List<Map<String, dynamic>> data = await DatabaseHelper.loadSPMSData();
      logger.i(data);

      if (mounted) {
        setState(() {
          _data = data;
          _siteNames = data.map((item) => item['Sitename'] as String).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar('Error loading data: ${e.toString()}');
      }
    }
  }

  void _showSnackbar(String message,
      {Duration duration = const Duration(seconds: 3)}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: duration),
    );
  }

  Spms? _getSPMS() {
    if (_selectedSiteName == null) return null;

    final filteredData = _data!.firstWhere(
      (item) => item['Sitename'] == _selectedSiteName,
      orElse: () => throw Exception('Site not found'),
    );
    return Spms.fromMap(filteredData);
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => showSearchableDropdown(
                      context,
                      _siteNames,
                      (selected) {
                        setState(() {
                          _selectedSiteName = selected;
                        });
                      },
                      _searchController,
                    ),
                    child: Text(
                      _getSitename(),
                      style: Theme.of(context).textTheme.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => StatisticsScreen(),
                        ));
                      },
                      icon: Icon(Icons.insert_chart_outlined_rounded)),
                ],
              ),
            ),
          ],
        ),
        const Divider(thickness: 0.5, color: Colors.red),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(_getSitecode(), style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(width: 20),
            Text(_getKvaG1(), style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(width: 8),
            Text(_getKvaG2(), style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
        const Divider(thickness: 0.5, color: Colors.red),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('Item', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(width: 20),
            Text('G1', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(width: 8),
            Text('G2', style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
      ],
    );
  }

  String _getSitename() => _getStringSite(_getSPMS()?.siteName);
  String _getSitecode() => _getStringValue(_getSPMS()?.siteCode);
  String _getKvaG1() => _getStringValue(_getSPMS()?.kvaG1);
  String _getKvaG2() => _getStringValue(_getSPMS()?.kvaG2);

  String _getFormattedDate(DateTime? date) {
    return (date == null || date.isAtSameMomentAs(defaultDate))
        ? 'Not Available'
        : DateFormat("yyyy-MM-dd").format(date);
  }

  String _getFormattedField(String fieldName) {
    final date = _getSPMS()?.getFieldByName(fieldName);
    return _getFormattedDate(date);
  }

  String _getStringSite(dynamic value,
      [String defaultValue = 'Select Site Name']) {
    if (value == null) {
      return defaultValue;
    }
    return value.toString();
  }

  String _getStringValue(dynamic value, [String defaultValue = '  N/A']) {
    if (value == null) {
      return defaultValue;
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _data == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildContent(context),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: components.length,
                      itemBuilder: (context, index) {
                        var component = components[index];
                        return ComponentRow(
                          title: component['title'],
                          value1: _getFormattedField(component['field1']),
                          result1: _calculateDaysSince(
                              _getFormattedField(component['field1'])),
                          value2: _getFormattedField(component['field2']),
                          result2: _calculateDaysSince(
                              _getFormattedField(component['field2'])),
                          color: component['color'],
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class ComponentRow extends StatelessWidget {
  final String title;
  final String value1;
  final DaysSinceResult result1;
  final String value2;
  final DaysSinceResult result2;
  final Color color;

  const ComponentRow({
    super.key,
    required this.title,
    required this.value1,
    required this.result1,
    required this.value2,
    required this.result2,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 16, color: Colors.black, letterSpacing: 1))),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value1,
                    style:
                        const TextStyle(fontSize: 14, color: Colors.black54)),
                Text(
                  result1.days == -1 ? 'N/A' : '${result1.days} days',
                  style: TextStyle(
                    fontSize: 12,
                    color: result1.isOverAYear ? Colors.red : Colors.black54,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value2,
                    style:
                        const TextStyle(fontSize: 14, color: Colors.black54)),
                Text(
                  result2.days == -1 ? 'N/A' : '${result2.days} days',
                  style: TextStyle(
                    fontSize: 12,
                    color: result2.isOverAYear ? Colors.red : Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DaysSinceResult {
  final int days;
  final bool isOverAYear;

  DaysSinceResult(this.days, this.isOverAYear);
}

DaysSinceResult _calculateDaysSince(String dateStr) {
  if (dateStr == 'Not Available') {
    return DaysSinceResult(-1, false); // Use -1 to signify 'N/A'
  }

  DateTime? componentDate =
      DateFormat("yyyy-MM-dd").parse(dateStr, true).toLocal();
  DateTime today = DateTime.now();

  Duration difference = today.difference(componentDate);
  bool isOverAYear = difference.inDays > 365;

  return DaysSinceResult(difference.inDays, isOverAYear);
}
