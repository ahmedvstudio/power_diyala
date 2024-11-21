import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:power_diyala/Widgets/widgets.dart';
import 'package:power_diyala/data_helper/data_manager.dart';
import 'package:power_diyala/data_helper/sheets_helper/google_sheet.dart';
import 'package:power_diyala/data_helper/sheets_helper/ac_helper.dart';
import 'package:power_diyala/data_helper/sheets_helper/cp_inputs.dart';
import 'package:power_diyala/data_helper/sheets_helper/earth_load.dart';
import 'package:power_diyala/data_helper/sheets_helper/gen_input.dart';
import 'package:power_diyala/data_helper/sheets_helper/sheet_id_cells_helper.dart';
import 'package:power_diyala/data_helper/sheets_helper/toggles.dart';
import 'package:power_diyala/data_helper/sheets_helper/tank_input.dart';
import 'package:power_diyala/screens/main_screen.dart';
import 'package:power_diyala/settings/theme_control.dart';

class PmSheetPage extends StatefulWidget {
  final ThemeMode themeMode;
  final Function(ThemeMode) onThemeChanged;

  const PmSheetPage(
      {super.key, required this.themeMode, required this.onThemeChanged});

  @override
  PmSheetPageState createState() => PmSheetPageState();
}

class PmSheetPageState extends State<PmSheetPage> {
  final Logger logger =
      kDebugMode ? Logger() : Logger(printer: PrettyPrinter());
  List<Map<String, dynamic>>? _data;
  List<String> _siteNames = [];
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? _selectedSiteData;
  List<TextEditingController> genControllers = [];
  List<TextEditingController> genVLControllers = [];
  List<TextEditingController> tankControllers = [];
  List<TextEditingController> commentsControllers = [];
  TextEditingController siteController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  TextEditingController cpController = TextEditingController();
  TextEditingController kwhController = TextEditingController();
  String? _selectedName;
  final List<TextEditingController> acVoltControllers =
      List.generate(6, (index) => TextEditingController());
  final List<TextEditingController> acLoadControllers =
      List.generate(6, (index) => TextEditingController());
  final List<TextEditingController> acOtherController =
      List.generate(3, (index) => TextEditingController());
  bool _isLoading = false;
  final List<TextEditingController> groundControllers =
      List.generate(6, (index) => TextEditingController());
  final List<TextEditingController> externalLoadControllers =
      List.generate(6, (index) => TextEditingController());
  final List<TextEditingController> batteryTestControllers =
      List.generate(3, (index) => TextEditingController());
  bool _isSiteSelected = false;
  List<TextEditingController> voltageControllers = [];
  List<TextEditingController> loadControllers = [];
  final _random = Random();
  List<bool> toggleValues = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];
  List<bool> sepToggleValues = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
  ];
  bool isCpEnabled = true;
  bool isLowVoltage = false;
  bool isEarthEnabled = false;
  bool isBatteryTestEnabled = false;
  List<bool> stepCompleted = List.filled(7, false);
  List<bool> gensSwitches = [true, true];
  TimeOfDay? fromTime;
  TimeOfDay? toTime;
  int _currentStep = 0;
  final List<String> names = [
    'Ahmed Adnan Abdulwahab',
    'Ahmed Jassim Mohamed',
    'Ahmed Noori Jassim',
    'Mustafa Raad Nouman',
    'Ali Mahmod Ali',
    'Yahya Falih Hassan',
  ];

  @override
  void initState() {
    super.initState();

    genControllers = List.generate(5, (index) => TextEditingController());
    tankControllers = List.generate(5, (index) => TextEditingController());
    genVLControllers = List.generate(20, (index) => TextEditingController());
    commentsControllers = List.generate(9, (index) => TextEditingController());
    voltageControllers = List.generate(3, (index) => TextEditingController());
    loadControllers = List.generate(3, (index) => TextEditingController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDataFromManager();
    });
  }

  bool _isRandomGenerated = false;
  bool _isSiteDataLoaded = false;

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);

    if (_currentStep == 1) {
      _calculateAndDisplayCycles();
    }
    if (_currentStep == 4 && !_isSiteDataLoaded) {
      _isSiteDataLoaded = true;
      _loadSelectedSiteData();
    }
    if (_currentStep == 3 && !_isRandomGenerated) {
      _isRandomGenerated = true;
      _generateRandomValues();
    }
  }

  @override
  void dispose() {
    for (var controller in [
      ...genControllers,
      ...tankControllers,
      ...genVLControllers,
      ...commentsControllers,
      ...voltageControllers,
      ...loadControllers,
      ...acVoltControllers,
      ...acLoadControllers,
      ...acOtherController,
      ...groundControllers,
      ...externalLoadControllers,
      ...batteryTestControllers,
      siteController,
    ]) {
      controller.dispose();
    }

    super.dispose();
  }

  Future<void> _loadDataFromManager() async {
    try {
      _data = DataManager().getPMData();
      _siteNames = _data?.map((item) => item['site'] as String).toList() ?? [];

      logger.i("Loaded PM data: $_data");

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar('Error loading data: ${e.toString()}');
      }
    }
  }

  void _updateSelectedSiteData(String siteName) {
    final selectedSite = _data?.firstWhere((item) => item['site'] == siteName);
    setState(() {
      _selectedSiteData = selectedSite;
      siteController.text =
          siteName; // Update the site controller with the selected site name
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        _dateController.text = picked.toString().split(" ")[0];
      });
    }
  }

  Future<void> _selectFromTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: fromTime ?? TimeOfDay.now(),
        helpText: 'Time in');
    if (picked != null && picked != fromTime) {
      setState(() {
        fromTime = picked;
      });
    }
  }

  Future<void> _selectToTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: toTime ?? TimeOfDay.now(),
        helpText: 'Time out');
    if (picked != null && picked != toTime) {
      setState(() {
        toTime = picked;
      });
    }
  }

  void handleToggleChange(int index, bool value) {
    setState(() {
      toggleValues[index] = value;
    });
  }

  void handleSepToggleChange(int index, bool value) {
    setState(() {
      sepToggleValues[index] = value;
    });
  }

  double _calculateCycle(double inputValue) {
    int completedCycles = (inputValue / 3000).floor();
    double accountedAmount = completedCycles * 3000;
    double remainingAmount = inputValue - accountedAmount;

    if (remainingAmount > 2750) {
      return 3000;
    } else if (remainingAmount > 2500) {
      return 2750;
    } else if (remainingAmount > 2250) {
      return 2500;
    } else if (remainingAmount > 2000) {
      return 2250;
    } else if (remainingAmount > 1750) {
      return 2000;
    } else if (remainingAmount > 1500) {
      return 1750;
    } else if (remainingAmount > 1250) {
      return 1500;
    } else if (remainingAmount > 1000) {
      return 1250;
    } else if (remainingAmount > 750) {
      return 1000;
    } else if (remainingAmount > 500) {
      return 750;
    } else if (remainingAmount > 250) {
      return 500;
    } else if (remainingAmount > 0) {
      return 250;
    }
    return 0;
  }

  void _calculateAndDisplayCycles() {
    double valueFromController0 =
        double.tryParse(genControllers[0].text) ?? 0.0;
    double cycleForController0 = _calculateCycle(valueFromController0);

    double valueFromController1 =
        double.tryParse(genControllers[1].text) ?? 0.0;
    double cycleForController1 = _calculateCycle(valueFromController1);
    logger.i("Cycle for G1: $cycleForController0");
    logger.i("Cycle for G2: $cycleForController1");
  }

  void _generateRandomValues() {
    setState(() {
      acVoltControllers[0].text = (_random.nextInt(13) + 218).toString();
      acVoltControllers[1].text = (_random.nextInt(13) + 218).toString();
      acVoltControllers[2].text = (_random.nextInt(13) + 218).toString();
      acVoltControllers[3].text = (_random.nextInt(2) + 53).toString();
      acOtherController[0].text = (_random.nextInt(6) + 20).toString();
      acOtherController[1].text = '55';
      acOtherController[2].text = '45';
    });
  }

  void _loadSelectedSiteData() {
    if (_selectedSiteData != null) {
      setState(() {
        externalLoadControllers[0].text = _selectedSiteData!['owner'] ?? '';
        externalLoadControllers[1].text = _selectedSiteData!['neighbour'] ?? '';
        externalLoadControllers[2].text = _selectedSiteData!['3rdparty'] ?? '';
        isEarthEnabled = (_selectedSiteData!['earth'] == 'Yes');
      });
    }
  }

  Map<String, dynamic> _collectData() {
    double valueFromController0 =
        double.tryParse(genControllers[0].text) ?? 0.0;
    double cycleForController0 = _calculateCycle(valueFromController0);

    double valueFromController1 =
        double.tryParse(genControllers[1].text) ?? 0.0;
    double cycleForController1 = _calculateCycle(valueFromController1);
    return {
      //step1
      'sheet': _selectedSiteData?['sheet'] ?? '',
      'siteName': '${siteController.text}-${_selectedSiteData?['code'] ?? ''}',
      'location': _selectedSiteData?['Location'] ?? '',
      'date': _dateController.text,
      'engineer name': _selectedName,
      'timeIn': fromTime?.format(context) ?? '',
      'timeOut': toTime?.format(context) ?? '',
      'G1': genControllers[0].text,
      'cycleForG1': cycleForController0,
      'G2': genControllers[1].text,
      'cycleForG2': cycleForController1,
      'CP': cpController.text,
      'Kwh': kwhController.text,
      'T1': tankControllers[0].text,
      'T1 shape': _selectedSiteData?['T1_shape'] ?? '',
      'T2': tankControllers[1].text,
      'T2 shape': _selectedSiteData?['T2_Shape'] ?? '',
      'T3': tankControllers[2].text,
      'T3 shape': _selectedSiteData?['T3_shape'] ?? '',
      '--------------------': '----------------',
      //step2
      'g1 oil': toggleValues[0] ? 'Yes' : 'No',
      'g1 air': toggleValues[1] ? 'Yes' : 'No',

      'g1 coolant': toggleValues[2] ? 'Yes' : 'No',
      'g1 gen sep': _selectedSiteData?['gen1 sep'] == 'No'
          ? 'N/A'
          : (_selectedSiteData?['gen1 sep'] == 'Yes'
              ? (sepToggleValues[0] ? 'Yes' : 'No')
              : 'N/A'),
      'g1 tank sep': _selectedSiteData?['tank sep'] == 'No'
          ? 'N/A'
          : (_selectedSiteData?['tank sep'] == 'Yes'
              ? (sepToggleValues[1] ? 'Yes' : 'No')
              : 'N/A'),
      'clean g1 air': toggleValues[1] ? 'No' : 'Yes',
      'g2 oil': toggleValues[3] ? 'Yes' : 'No',
      'g2 air': toggleValues[4] ? 'Yes' : 'No',
      'g2 coolant': toggleValues[5] ? 'Yes' : 'No',
      'g2 gen sep': _selectedSiteData?['gen2 sep'] == 'No'
          ? 'N/A'
          : (_selectedSiteData?['gen2 sep'] == 'Yes'
              ? (sepToggleValues[2] ? 'Yes' : 'No')
              : 'N/A'),
      'g2 tank sep': _selectedSiteData?['tank sep'] == 'No'
          ? 'N/A'
          : (_selectedSiteData?['tank sep'] == 'Yes'
              ? (sepToggleValues[3] ? 'Yes' : 'No')
              : 'N/A'),
      'clean g2 air': toggleValues[4] ? 'No' : 'Yes',
      '-------------------': '----------------',
      //step3
      'Main available': _selectedSiteData?['cp'] == 'No'
          ? 'N/A'
          : (_selectedSiteData?['cp'] == 'Yes'
              ? (isCpEnabled ? 'Yes' : 'No')
              : 'N/A'),
      'Main v1': voltageControllers[0].text,
      'Main v2': voltageControllers[1].text,
      'Main v3': voltageControllers[2].text,
      'Main l1': loadControllers[0].text,
      'Main l2': loadControllers[1].text,
      'Main l3': loadControllers[2].text,
      'g1 switch': gensSwitches[0],
      'gen1 voltage ph-n1': genVLControllers[0].text,
      'gen1 voltage ph-n2': genVLControllers[1].text,
      'gen1 voltage ph-n3': genVLControllers[2].text,
      'gen1 voltage ph-l1': genVLControllers[3].text,
      'gen1 voltage ph-l2': genVLControllers[4].text,
      'gen1 voltage ph-l3': genVLControllers[5].text,
      'gen1 load 1': genVLControllers[6].text,
      'gen1 load 2': genVLControllers[7].text,
      'gen1 load 3': genVLControllers[8].text,
      'gen1 battery': genVLControllers[9].text,
      'g2 switch': gensSwitches[1],
      'gen2 voltage ph-n1': genVLControllers[10].text,
      'gen2 voltage ph-n2': genVLControllers[11].text,
      'gen2 voltage ph-n3': genVLControllers[12].text,
      'gen2 voltage ph-l1': genVLControllers[13].text,
      'gen2 voltage ph-l2': genVLControllers[14].text,
      'gen2 voltage ph-l3': genVLControllers[15].text,
      'gen2 load 1': genVLControllers[16].text,
      'gen2 load 2': genVLControllers[17].text,
      'gen2 load 3': genVLControllers[18].text,
      'gen2 battery': genVLControllers[19].text,
      '------------------': '----------------',
      //step4
      'ac1 volt': acVoltControllers[0].text,
      'ac2 volt': acVoltControllers[1].text,
      'ac3 volt': acVoltControllers[2].text,
      'outdoor volt': acVoltControllers[3].text,
      'ac1 load': acLoadControllers[0].text,
      'ac2 load': acLoadControllers[1].text,
      'ac3 load': acLoadControllers[2].text,
      'outdoor load': acLoadControllers[3].text,
      'room temp': acOtherController[0].text,
      'HP': acOtherController[1].text,
      'LP': acOtherController[2].text,
      '-----------------': '----------------',
      //step5
      'gen earth': isEarthEnabled ? groundControllers[0].text : '0',
      'tel earth': isEarthEnabled ? groundControllers[1].text : '0',
      'leg earth': isEarthEnabled ? groundControllers[3].text : '0',
      'light earth': isEarthEnabled ? groundControllers[2].text : '0',
      'owner load': externalLoadControllers[0].text,
      'neighbor load': externalLoadControllers[1].text,
      '3rd load': externalLoadControllers[2].text,
      'battery test': isBatteryTestEnabled ? 'Yes' : 'No',
      'start dc': isBatteryTestEnabled == false
          ? '0'
          : (isBatteryTestEnabled == true
              ? (batteryTestControllers[0].text)
              : '0'),
      'end dc': isBatteryTestEnabled == false
          ? '0'
          : (isBatteryTestEnabled == true
              ? (batteryTestControllers[1].text)
              : '0'),

      'fire': batteryTestControllers[2].text,
      '----------------------': '----------------',

      //step6
      'generalComments': commentsControllers[0].text,
      'g1Comments': commentsControllers[1].text,
      'g2Comments': commentsControllers[2].text,
      'acComments': commentsControllers[3].text,
      'electricComments': commentsControllers[4].text,
      // Add more fields as necessary
    };
  }

  Map<String, dynamic> collectDataForSheet(int sheetNumber) {
    final data = _collectData();
    logger.i('Raw Collected Data: $data');

    final mapper = SheetMapper();
    final cells = mapper.getSheetMapping(sheetNumber);

    // Proceed with mapping logic
    final mappedData = <String, dynamic>{};
    cells.forEach((cell, key) {
      if (data.containsKey(key)) {
        mappedData[cell] = data[key];
      } else {
        logger.w('Key $key not found in collected data.');
      }
    });

    logger.i('Mapped Data for Sheet $sheetNumber: $mappedData');
    return mappedData;
  }

  Future<void> submitData() async {
    if (_selectedSiteData != null && _selectedSiteData!['sheet'] != null) {
      int selectedSheetNumber =
          int.tryParse(_selectedSiteData!['sheet'].toString()) ?? 1;

      SheetMapper sheetMapper = SheetMapper();

      GoogleSheetHelper googleSheetHelper = GoogleSheetHelper(
        templateFileId: sheetMapper.getTemplateFileId(selectedSheetNumber),
        targetSheetName: sheetMapper.getSheetName(selectedSheetNumber),
        modifiedFileName: _collectData()['siteName'],
      );

      Map<String, dynamic> collectedData =
          collectDataForSheet(selectedSheetNumber);
      logger.i('Collected Data for Sheet $selectedSheetNumber: $collectedData');
      Map<String, dynamic> cellMappings =
          sheetMapper.getSheetMapping(selectedSheetNumber);
      logger.i('Cell Mappings for Sheet $selectedSheetNumber: $cellMappings');

      Map<String, String> updates = {};
      for (var entry in cellMappings.entries) {
        String cell = entry.key;
        String dataKey = entry.key;

        if (collectedData.containsKey(dataKey) &&
            collectedData[dataKey].toString().isNotEmpty) {
          updates[cell] = collectedData[dataKey].toString();
        } else {
          updates[cell] = '';
          logger.i(
              'Key $dataKey not found in collected data. Setting cell $cell to blank.');
        }
      }

      logger.i('Updates to apply: $updates');

      googleSheetHelper.setCellUpdates(updates);

      await googleSheetHelper.executeSheetOperations();
    } else {
      logger.e('Invalid site data or sheet selection.');
    }
  }

  void _showSnackbar(String message,
      {Duration duration = const Duration(seconds: 3)}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: duration),
    );
  }

  void _updateComments() {
    String baseText;
    if (_selectedSiteData?['cp'] == "Yes") {
      baseText = isCpEnabled ? "Gen Load on CP" : "CP load on Gen";
    } else if (_selectedSiteData?['cp'] == "No") {
      baseText = "The Site without CP";
    } else {
      baseText = "CP status unknown";
    }

    setState(() {
      commentsControllers[0].text = baseText;

      String commentText = "";
      if (!isEarthEnabled) {
        logger.i("Earth is No");
        commentText += "The Site without a point of ground measurement /";
      } else {
        logger.i("Earth is Yes");
      }
      if (!isBatteryTestEnabled) {
        logger.i("Battery test is not enabled");
        commentText +=
            " The Batteries were tested at (${_selectedSiteData!['batterytest']})";
      }

      // Set the final comment text to commentsControllers[4]
      commentsControllers[4].text = commentText;
    });
  }

  void _updateCPText() {
    String baseText;

    // Check the value of _selectedSiteData['cp']
    if (_selectedSiteData?['cp'] == "Yes") {
      baseText = isCpEnabled ? "Gen Load on CP" : "CP load on Gen";
    } else if (_selectedSiteData?['cp'] == "No") {
      baseText = "The Site without CP";
    } else {
      baseText = "CP status unknown";
    }

    if (isLowVoltage) {
      baseText += " / System low voltage";
    }

    setState(() {
      commentsControllers[0].text = baseText;
    });
  }

  void _handleCpEnabledChange(bool value) {
    setState(() {
      isCpEnabled = value;
      if (!isCpEnabled) {
        final random = Random();
        if (_selectedSiteData!['phase'].toLowerCase() == 'three phase') {
          voltageControllers[0].text = (random.nextInt(21) + 210).toString();
          voltageControllers[1].text = (random.nextInt(21) + 210).toString();
          voltageControllers[2].text = (random.nextInt(21) + 210).toString();
        } else if (_selectedSiteData!['phase'].toLowerCase() ==
            'single phase') {
          voltageControllers[0].text = (random.nextInt(21) + 210).toString();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PM Sheet', style: Theme.of(context).textTheme.titleLarge),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Confirm Restart'),
                    content: Text('Are you sure you want to restart?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PmSheetPage(
                                themeMode: widget.themeMode,
                                onThemeChanged: widget.onThemeChanged,
                              ),
                            ),
                          );
                        },
                        child: Text('Yes'),
                      ),
                    ],
                  );
                },
              );
            },
            icon: Icon(Icons.restart_alt_rounded),
            tooltip: 'Reset',
          ),
        ],
      ),
      body: SafeArea(
        child: _data == null
            ? const Center(child: CircularProgressIndicator())
            : Stepper(
                currentStep: _currentStep,
                type: StepperType.vertical,
                physics: ScrollPhysics(),
                controlsBuilder:
                    (BuildContext context, ControlsDetails controls) {
                  return Column(
                    children: [
                      SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _currentStep == 0
                                ? null
                                : () {
                                    controls.onStepCancel!();
                                  },
                            icon: Icon(Icons.arrow_back), // Back icon
                            label: Text('Back'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blue,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10), // Text color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    30.0), // Rounded corners
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: (_isSiteSelected)
                                ? () {
                                    if (_currentStep != 6) {
                                      controls.onStepContinue!();
                                    } else {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('All Done'),
                                            content: Text(
                                                'Are you sure you want to proceed?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('No'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pushReplacement(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const MainScreen(),
                                                    ),
                                                  );
                                                },
                                                child: Text('Yes'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  }
                                : null,
                            icon: Icon(_currentStep != 6
                                ? Icons.arrow_forward
                                : Icons.check),
                            label:
                                Text(_currentStep != 6 ? 'Continue' : 'Done'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor:
                                  _currentStep != 6 ? Colors.green : Colors.red,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10), // Text color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    30.0), // Rounded corners
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
                onStepTapped: (step) {
                  if (step == _currentStep) {
                    setState(() {
                      _currentStep = step;
                    });
                  }
                },
                onStepContinue: () {
                  if (_currentStep < 6) {
                    setState(() {
                      stepCompleted[_currentStep] = true;
                      _currentStep++;
                    });
                  }
                },
                onStepCancel: () {
                  if (_currentStep > 0) {
                    setState(() {
                      stepCompleted[_currentStep] = false;
                      _currentStep--;
                    });
                  }
                },
                steps: [
                  Step(
                    isActive: _currentStep == 0,
                    title: Text('General'),
                    subtitle: _currentStep == 0
                        ? Text('All Fields Are Required.')
                        : null,
                    content: Column(
                      children: [
                        const SizedBox(height: 8.0),
                        GestureDetector(
                          onTap: _isSiteSelected
                              ? () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Reset the page to change the site')),
                                  );
                                }
                              : () => showSearchableDropdown(
                                    context,
                                    _siteNames,
                                    (selected) {
                                      setState(() {
                                        _updateSelectedSiteData(selected);
                                        _isSiteSelected = true;
                                      });
                                    },
                                    _searchController,
                                  ),
                          child: AbsorbPointer(
                            child: TextField(
                              controller: siteController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.cell_tower_rounded,
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                                suffixIcon: _isSiteSelected
                                    ? Icon(
                                        Icons.check,
                                        color: Colors.green,
                                      )
                                    : null,
                                label: Text(
                                  _selectedSiteData != null
                                      ? 'Site Name:'
                                      : 'No site selected',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 16.0),
                                ),
                                filled: true,
                                labelStyle: TextStyle(
                                    color: ThemeControl.errorColor
                                        .withOpacity(0.8)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary,
                                      width: 2.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: const BorderSide(
                                      color: Colors.grey, width: 1.5),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16.0, horizontal: 12.0),
                              ),
                              keyboardType: TextInputType.number,
                              readOnly: true,
                              enabled: !_isSiteSelected,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        TextField(
                          onTap: () => _selectDate(context),
                          controller: _dateController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.calendar_month_rounded,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                            label: Text('Select Date'),
                            filled: true,
                            labelStyle: TextStyle(
                                color:
                                    ThemeControl.errorColor.withOpacity(0.8)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.tertiary,
                                  width: 2.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 16.0, horizontal: 12.0),
                          ),
                          keyboardType: TextInputType.number,
                          readOnly: true,
                        ),
                        const SizedBox(height: 12.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _selectFromTime(context),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 15.0, horizontal: 10.0),
                                  side: BorderSide(
                                      color: Colors.grey, width: 2.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                label: Text(
                                  fromTime != null
                                      ? fromTime!.format(context)
                                      : 'Time in',
                                ),
                                icon: Icon(Icons.access_time_rounded,
                                    color: fromTime != null
                                        ? Theme.of(context).colorScheme.tertiary
                                        : Colors.grey),
                              ),
                            ),
                            SizedBox(width: 15),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _selectToTime(context),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 15.0, horizontal: 10.0),
                                  side: BorderSide(
                                      color: Colors.grey, width: 2.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                label: Text(
                                  toTime != null
                                      ? toTime!.format(context)
                                      : 'Time out',
                                ),
                                icon: Icon(
                                  Icons.access_time_rounded,
                                  color: toTime != null
                                      ? Theme.of(context).colorScheme.tertiary
                                      : Colors.grey,
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        if (_selectedSiteData != null)
                          Row(
                            children: [
                              ...GenInput(_selectedSiteData!['sheet'])
                                  .genInputs(context, genControllers)
                                  .map((inputField) {
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: inputField,
                                  ),
                                );
                              }),
                            ],
                          ),
                        const SizedBox(height: 8.0),
                        if (_selectedSiteData != null)
                          CpInput(
                            cpValue: _selectedSiteData!['cp'],
                            cpController: cpController,
                            kwhController: kwhController,
                          ),
                        const SizedBox(height: 8.0),
                        if (_selectedSiteData != null)
                          Row(
                            children: [
                              ...TankInput(_selectedSiteData!['sheet'])
                                  .tankInputs(context, tankControllers)
                                  .map((inputField) {
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: inputField,
                                  ),
                                );
                              }),
                            ],
                          ),
                      ],
                    ),
                    state: stepCompleted[0]
                        ? StepState.complete
                        : StepState.indexed,
                  ),
                  Step(
                    isActive: _currentStep == 1,
                    title: Text('Generator'),
                    subtitle:
                        _currentStep == 1 ? Text('on => Yes, off => No') : null,
                    content: Column(
                      children: [
                        if (_selectedSiteData != null)
                          ...ReplacementSwitch(_selectedSiteData!['sheet'])
                              .genSwitches(toggleValues, handleToggleChange),
                        if (_selectedSiteData != null) ...[
                          ...SeparatorSwitch(_selectedSiteData!['sheet'],
                                  _selectedSiteData!.cast<String, String?>())
                              .sepSwitches(
                                  sepToggleValues, handleSepToggleChange),
                        ],
                      ],
                    ),
                    state: stepCompleted[1]
                        ? StepState.complete
                        : StepState.indexed,
                  ),
                  Step(
                    isActive: _currentStep == 2,
                    title: Text('Load & Voltage'),
                    subtitle:
                        _currentStep == 2 ? Text('Randomize First') : null,
                    content: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (_selectedSiteData != null)
                          CpPhaseInput(
                            cpValue: _selectedSiteData!['cp'],
                            phase: _selectedSiteData!['phase'],
                            voltageControllers: voltageControllers,
                            loadControllers: loadControllers,
                            isCpEnabled: isCpEnabled,
                            onCpEnabledChanged: _handleCpEnabledChange,
                          ),
                        SizedBox(height: 8),
                        if (_selectedSiteData != null)
                          GenVLInput(
                            sheetNumber: _selectedSiteData![
                                'sheet'], // Pass the sheet number here
                            controllers: genVLControllers,
                            gensSwitches: gensSwitches,
                            onSwitchChanged: (index, value) {
                              setState(() {
                                gensSwitches[index] = value;
                              });
                            },
                          ),
                      ],
                    ),
                    state: stepCompleted[2]
                        ? StepState.complete
                        : StepState.indexed,
                  ),
                  Step(
                    isActive: _currentStep == 3,
                    title: Text('AC'),
                    content: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (_selectedSiteData != null)
                          AcInput(
                            _selectedSiteData!['sheet'],
                            acVoltControllers: acVoltControllers,
                            acLoadControllers: acLoadControllers,
                            acOtherController: acOtherController,
                          ),
                      ],
                    ),
                    state: stepCompleted[3]
                        ? StepState.complete
                        : StepState.indexed,
                  ),
                  Step(
                    isActive: _currentStep == 4,
                    title: Text('Earth & External load'),
                    subtitle: _currentStep == 4
                        ? Column(
                            children: [
                              Text(
                                'Don\'t Switch Earth & External Load Unless its Showing Wrong Data.',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          )
                        : null,
                    content: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        EarthInputFields(
                            selectedSiteData: _selectedSiteData,
                            groundControllers: groundControllers,
                            externalLoadControllers: externalLoadControllers,
                            batteryTestControllers: batteryTestControllers,
                            isBatteryTestEnabled: isBatteryTestEnabled,
                            isEarthEnabled: isEarthEnabled,
                            onEarthEnabledChanged: (value) {
                              setState(() {
                                isEarthEnabled = value;
                              });
                            },
                            onBatteryTestEnabledChanged: (bool value) {
                              setState(() {
                                isBatteryTestEnabled = value;
                              });
                            }),
                      ],
                    ),
                    state: stepCompleted[4]
                        ? StepState.complete
                        : StepState.indexed,
                  ),
                  Step(
                    isActive: _currentStep == 5,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text('Comments')),
                        if (_currentStep == 5)
                          Text(
                            'Add Comments ->',
                            style: TextStyle(fontSize: 8, color: Colors.red),
                          ),
                        if (_currentStep == 5)
                          IconButton(
                            onPressed: () {
                              setState(() {
                                isCpEnabled = isCpEnabled;
                                isBatteryTestEnabled = isBatteryTestEnabled;
                              });
                              _updateComments();
                            },
                            icon: Icon(Icons.add),
                          ),
                      ],
                    ),
                    content: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        buildCommentField(
                            'General', commentsControllers[0], context),
                        Row(
                          children: [
                            Checkbox(
                              value: isLowVoltage,
                              onChanged: (value) {
                                setState(() {
                                  isLowVoltage = value ?? false;
                                });
                                _updateCPText();
                              },
                            ),
                            Text("System low voltage"),
                          ],
                        ),
                        buildCommentField(
                            'G1', commentsControllers[1], context),
                        buildCommentField(
                            'G2', commentsControllers[2], context),
                        buildCommentField(
                            'AC', commentsControllers[3], context),
                        buildCommentField(
                            'Electric', commentsControllers[4], context),
                        SizedBox(height: 10),
                        DropdownButton<String>(
                          hint: Text(
                            'Engineer Name..',
                            style: Theme.of(context).textTheme.titleLarge,
                          ), // Placeholder text
                          value: _selectedName,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedName =
                                  newValue; // Update the selected name
                            });
                          },
                          items: names
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style:
                                    Theme.of(context).textTheme.headlineLarge,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    state: stepCompleted[5]
                        ? StepState.complete
                        : StepState.indexed,
                  ),
                  Step(
                    isActive: _currentStep == 6,
                    title: Text('Submit'),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isLoading
                                    ? null
                                    : () async {
                                        setState(() {
                                          _isLoading = true; // Start loading
                                        });

                                        try {
                                          await submitData();
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  '/PowerDiyala/${_collectData()['siteName']}'),
                                            ),
                                          );
                                        } catch (error) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Error submitting data: $error'),
                                            ),
                                          );
                                        } finally {
                                          setState(() {
                                            _isLoading = false; // Stop loading
                                          });
                                        }
                                      },
                                onLongPress: () {
                                  if (_selectedSiteData != null &&
                                      _selectedSiteData!['sheet'] != null) {
                                    int selectedSheetNumber = int.tryParse(
                                            _selectedSiteData!['sheet']
                                                .toString()) ??
                                        1;
                                    Map<String, dynamic> data =
                                        collectDataForSheet(
                                            selectedSheetNumber);

                                    displayData(data);
                                  } else {
                                    if (kDebugMode) {
                                      print(
                                          'Invalid site data or sheet selection.');
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  backgroundColor: Color(0xff69F0AE),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        30.0), // Rounded corners
                                  ),
                                ),
                                child: _isLoading
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.black,
                                              strokeWidth: 2,
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Text('Submitting...'),
                                        ],
                                      )
                                    : Text('Submit'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    state: stepCompleted[6]
                        ? StepState.complete
                        : StepState.indexed,
                  ),
                ],
              ),
      ),
    );
  }

  void displayData(Map<String, dynamic> data) {
    // Option 1: Print to console (for debugging)
    if (kDebugMode) {
      print('Collected Data for Sheet:');
    }
    data.forEach((key, value) {
      if (kDebugMode) {
        print('$key: $value');
      }
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Collected Data'),
          content: SingleChildScrollView(
            child: ListBody(
              children: data.entries.map((entry) {
                return Text('${entry.key}: ${entry.value}');
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildCommentField(String labelText, TextEditingController controller,
      BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle:
                TextStyle(color: ThemeControl.errorColor.withOpacity(0.8)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.secondary),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.tertiary,
                width: 2.0,
              ),
            ),
            filled: true,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: Colors.grey, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
          ),
          keyboardType: TextInputType.text,
        ),
      ],
    );
  }
}
