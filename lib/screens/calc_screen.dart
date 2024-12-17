import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:power_diyala/data_helper/calc_table_helper.dart';
import 'package:flutter/material.dart';
import 'package:power_diyala/data_helper/data_manager.dart';
import 'package:power_diyala/settings/remote_config.dart';
import 'package:power_diyala/widgets/calculations.dart';
import 'package:power_diyala/settings/constants.dart';
import 'package:power_diyala/widgets/widgets.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class CalculatorScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final Function(ThemeMode) onThemeChanged;

  const CalculatorScreen(
      {super.key, required this.themeMode, required this.onThemeChanged});

  @override
  CalculatorScreenState createState() => CalculatorScreenState();
}

class CalculatorScreenState extends State<CalculatorScreen> {
  final Logger logger =
      kDebugMode ? Logger() : Logger(printer: PrettyPrinter());
  final calculatorData = DataManager().getCalculatorData();

  List<Map<String, dynamic>>? _data;
  String? _selectedSiteName;
  List<String> _siteNames = [];
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _g1Controller = TextEditingController();
  final TextEditingController _g2Controller = TextEditingController();
  final TextEditingController _cpController = TextEditingController();

  DateTime? _selectedDate;
  double? _calculatedG1,
      _calculatedG2,
      _calculatedCP,
      _total,
      _totalGen,
      _genDifference;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDataFromManager();
    });

    _g1Controller.addListener(_onInputChanged);
    _g2Controller.addListener(_onInputChanged);
    _cpController.addListener(_onInputChanged);
  }

  Future<void> _loadDataFromManager() async {
    List<Map<String, dynamic>>? data = DataManager().getCalculatorData();

    if (data != null) {
      logger.i(data);

      if (mounted) {
        setState(() {
          _data = data;
          _siteNames = data.map((item) => item['Site_name'] as String).toList();
        });
      }
    } else {
      if (mounted) {
        _showSnackbar('No data found');
      }
    }
  }

  void _onInputChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _g1Controller.text = removeLeadingZeros(_g1Controller.text);
        _g2Controller.text = removeLeadingZeros(_g2Controller.text);
        _cpController.text = removeLeadingZeros(_cpController.text);

        _calculatedG1 =
            calculate(_g1Controller.text, double.parse(_getGen1Re()));

        _calculatedG2 =
            calculate(_g2Controller.text, double.parse(_getGen2Re()));
        _calculatedCP = calculate(_cpController.text, double.parse(_getCp()));
        _total =
            (_calculatedG1 ?? 0) + (_calculatedG2 ?? 0) + (_calculatedCP ?? 0);
        _totalGen = (_calculatedG1 ?? 0) + (_calculatedG2 ?? 0);
        _genDifference = (_calculatedG1 ?? 0) - (_calculatedG2 ?? 0);
      });
    });
  }

  double? _calculateOilG1() =>
      calculate(_g1Controller.text, double.parse(_getOilG1()));

  double? _calculateOilG2() =>
      calculate(_g2Controller.text, double.parse(_getOilG2()));

  double? _calculateAirG1() =>
      calculate(_g1Controller.text, double.parse(_getAirG1()));

  double? _calculateAirG2() =>
      calculate(_g2Controller.text, double.parse(_getAirG2()));

  double? _calculateCoolantG1() =>
      calculate(_g1Controller.text, double.parse(_getCoolantG1()));

  double? _calculateCoolantG2() =>
      calculate(_g2Controller.text, double.parse(_getCoolantG2()));

  Site? _getSite() {
    if (_selectedSiteName == null) return null;

    final filteredData = _data!.firstWhere(
      (item) => item['Site_name'] == _selectedSiteName,
      orElse: () => throw Exception('Site not found'),
    );
    return Site.fromMap(filteredData);
  }

  String _getSiteCode() {
    final site = _getSite();
    return _getStringValue(site?.siteCode, 'N/A');
  }

  String _getPMDate() {
    final site = _getSite();
    return site != null ? DateFormat("yyyy-MM-dd").format(site.pmDate) : 'N/A';
  }

  String _getGen1Re() {
    return _getStringValue(_getSite()?.gen1Re);
  }

  String _getGen2Re() {
    return _getStringValue(_getSite()?.gen2Re);
  }

  String _getCp() {
    return _getStringValue(_getSite()?.cp);
  }

  DateTime? _getPMDateAsDateTime() {
    return _getSite()?.pmDate;
  }

  String _getOilG1() {
    return _getStringValue(_getSite()?.oilG1);
  }

  String _getOilG2() {
    return _getStringValue(_getSite()?.oilG2);
  }

  String _getAirG1() {
    return _getStringValue(_getSite()?.airG1);
  }

  String _getAirG2() {
    return _getStringValue(_getSite()?.airG2);
  }

  String _getCoolantG1() {
    return _getStringValue(_getSite()?.coolantG1);
  }

  String _getCoolantG2() {
    return _getStringValue(_getSite()?.coolantG2);
  }

  String _getStringValue(dynamic value, [String defaultValue = '0']) {
    if (value == null) {
      return defaultValue;
    }
    return value.toString();
  }

  void _showSnackbar(String message,
      {Duration duration = const Duration(seconds: 2)}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: duration),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    if (_selectedSiteName == null) {
      _showSnackbar('Select Site first');
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _showSnackbar(
          'Selected date: ${_selectedDate!.toLocal().toString().split(' ')[0]}');
    }
  }

  Map<String, int> _calculateDateDifferences() {
    if (_selectedDate != null && (_getPMDateAsDateTime() != null)) {
      DateTime pmDate = _getPMDateAsDateTime()!;
      Duration difference = _selectedDate!.difference(pmDate);
      return {
        'days': difference.inDays,
        'hours': difference.inHours,
      };
    }
    return {'days': 0, 'hours': 0}; // Default if no date is selected
  }

  int _calculateTotalHoursDifference() {
    return _calculateDateDifferences()['hours'] ?? 0;
  }

  int _calculateTotalDaysDifference() {
    return _calculateDateDifferences()['days'] ?? 0;
  }

  String _calculateGenPerDay() {
    if (_calculateTotalDaysDifference() > 0 && (_totalGen != null)) {
      return (_totalGen! / _calculateTotalDaysDifference()).toStringAsFixed(2);
    }
    return 'N/A';
  }

  String _calculateTotalDifference() {
    return '${_total != null ? (_total! - _calculateTotalHoursDifference()) : 'N/A'}';
  }

  String _calculateHoursDifference() {
    final differences = _calculateDateDifferences();
    return '${differences['hours']} hours';
  }

  String _calculateDaysDifference() {
    final differences = _calculateDateDifferences();
    return '${differences['days']} Days';
  }

  void _clearSelection() {
    setState(() {
      _selectedSiteName = null;
      _selectedDate = null;
      _g1Controller.clear();
      _g2Controller.clear();
      _cpController.clear();

      _calculatedG1 = null;
      _calculatedG2 = null;
      _calculatedCP = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Selection cleared')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _data == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          showSearchableDropdown(
                            context,
                            _siteNames,
                            (selected) {
                              setState(() {
                                _selectedSiteName = selected;
                              });
                            },
                            _searchController,
                          );
                          await fetchAndActivate();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 16.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  _selectedSiteName ?? 'Select a Site Name',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(
                                Icons.arrow_drop_down,
                                color: Colors.grey[700],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              buildLabelValue(
                                  context,
                                  'Site Code:',
                                  _selectedSiteName != null
                                      ? _getSiteCode()
                                      : 'N/A'),
                              ElevatedButton.icon(
                                onPressed: () => _selectDate(context),
                                icon: const Icon(Icons.calendar_today),
                                label: const Text('Select Date'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  buildLabelValue(
                                      context,
                                      'Last PM Date:',
                                      _selectedSiteName != null
                                          ? _getPMDate()
                                          : 'N/A'),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Selected Date:',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall),
                                  Text(_selectedDate != null
                                      ? "${_selectedDate!.toLocal()}"
                                          .split(' ')[0]
                                      : 'Not Selected'),
                                ],
                              ),
                              Text(
                                _calculateDaysDifference(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              buildTextField(_g1Controller, 'G1', context),
                              const SizedBox(width: 10),
                              buildTextField(_g2Controller, 'G2', context),
                              const SizedBox(width: 10),
                              buildTextField(_cpController, 'CP', context),
                            ],
                          ),
                          const SizedBox(height: 16.0),
                          RuntimeCalculations(
                            calculatedG1: _calculatedG1,
                            calculatedG2: _calculatedG2,
                            calculatedCP: _calculatedCP,
                            totalGen: _totalGen,
                            genDifference: _genDifference,
                            genPerDay: _calculateGenPerDay(),
                            totalRT: _total,
                            duration: _calculateHoursDifference(),
                            difference: _calculateTotalDifference(),
                          ),
                          const SizedBox(height: 8.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildHeaderColumn(['#', 'G1', 'G2']),
                              const SizedBox(width: 8.0),
                              Expanded(
                                child: Card(
                                  color: Theme.of(context).cardColor,
                                  elevation: 2,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: buildValueColumn(
                                      'Oil',
                                      _calculateOilG1(),
                                      _calculateOilG2(),
                                      oilCheck,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Card(
                                  color: Theme.of(context).cardColor,
                                  elevation: 2,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 4.0), // Margin around card
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                        2.0), // Padding inside the card
                                    child: buildValueColumn(
                                      'Air Filter',
                                      _calculateAirG1(),
                                      _calculateAirG2(),
                                      airCheck, // Thresholds for Air
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Card(
                                  color: Theme.of(context).cardColor,
                                  elevation: 2,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 4.0), // Margin around card
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                        2.0), // Padding inside the card
                                    child: buildValueColumn(
                                      'Coolant',
                                      _calculateCoolantG1(),
                                      _calculateCoolantG2(),
                                      coolantCheck,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    _clearSelection();
                                    await fetchAndActivate();
                                  },
                                  label: const Text('Clear'),
                                  icon: const Icon(Icons.delete_sweep),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
