import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:logger/logger.dart';
import 'package:power_diyala/Widgets/widgets.dart';
import 'package:power_diyala/data_helper/sheets_helper/cm_cells_helper.dart';
import 'package:power_diyala/data_helper/sheets_helper/cm_type_helper.dart';
import 'package:power_diyala/data_helper/sheets_helper/quantity_helper.dart';
import 'package:power_diyala/data_helper/sheets_helper/spare_item_class.dart';
import 'package:power_diyala/data_helper/sheets_helper/used_for_helper.dart';
import 'package:power_diyala/data_helper/database_helper.dart';
import 'package:power_diyala/data_helper/sheets_helper/google_sheet.dart';
import 'package:power_diyala/data_helper/sheets_helper/cp_inputs.dart';
import 'package:power_diyala/data_helper/sheets_helper/gen_input.dart';
import 'package:power_diyala/data_helper/sheets_helper/tank_input.dart';
import 'package:power_diyala/screens/main_screen.dart';
import 'package:power_diyala/settings/constants.dart';
import 'package:power_diyala/settings/theme_control.dart';
import 'package:url_launcher/url_launcher.dart';

class CmSheetPage extends StatefulWidget {
  final ThemeMode themeMode;
  final Function(ThemeMode) onThemeChanged;

  const CmSheetPage(
      {super.key, required this.themeMode, required this.onThemeChanged});

  @override
  CmSheetPageState createState() => CmSheetPageState();
}

class CmSheetPageState extends State<CmSheetPage> {
  final Logger logger =
      kDebugMode ? Logger() : Logger(printer: PrettyPrinter());
  List<Map<String, dynamic>>? _siteData;
  List<Map<String, dynamic>>? _spareData;
  List<String> _siteNames = [];
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? _selectedSiteData;
  final List<SpareItem> _selectedSpareItems = [];
  List<String> _spareNames = [];
  List<String> _spareCode = [];
  final TextEditingController _spareController = TextEditingController();
  List<TextEditingController> _genControllers = [];
  List<TextEditingController> _tankControllers = [];
  List<TextEditingController> _commentsControllers = [];
  TextEditingController siteController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  TextEditingController cpController = TextEditingController();
  TextEditingController kwhController = TextEditingController();
  String? _selectedEngName;
  String? _selectedTechName;
  bool _isLoading = false;
  bool _isSiteSelected = false;
  bool _isCMTypeSelected = false;
  bool isDuringPM = false;
  List<bool> stepCompleted = List.filled(3, false);
  TimeOfDay? fromTime;
  TimeOfDay? toTime;
  TimeOfDay? escalatedTime;
  int _currentStep = 0;
  String? _selectedCMType;
  String? _selectedCategory;
  String? _selectedExtraType;
  String? _selectedType;
  final List<String> engNames = [
    'Ahmed Adnan',
    'Ahmed Jassim',
    'Ahmed Noori',
    'Mustafa Raad',
    'Ali Mahmod',
    'Yahya Falih',
  ];
  final List<String> techNames = [
    'Ali Adnan',
    'Shams Ahmed',
    'Raed Ahmed',
    'Abdulwahab Ahmed',
    'Amer Shalal',
    'Bashar Shuker',
    'Mahmod Hashim',
    'Haider Ahmed',
    'Mustafa Hussein',
    'Hussein Mahmod'
  ];

  @override
  void initState() {
    super.initState();
    _genControllers = List.generate(5, (index) => TextEditingController());
    _tankControllers = List.generate(5, (index) => TextEditingController());
    _commentsControllers = List.generate(3, (index) => TextEditingController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _loadSpareData();
    });
  }

  @override
  void dispose() {
    for (var controller in [
      ..._genControllers,
      ..._tankControllers,
      ..._commentsControllers,
      siteController,
    ]) {
      controller.dispose();
    }

    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      List<Map<String, dynamic>> data = await DatabaseHelper.loadPMData();
      logger.i(data);

      if (mounted) {
        setState(() {
          _siteData = data;
          _siteNames = data.map((item) => item['site'] as String).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar('Error loading data: ${e.toString()}');
      }
    }
  }

  void _updateSelectedSiteData(String siteName) {
    final selectedSite =
        _siteData?.firstWhere((item) => item['site'] == siteName);
    setState(() {
      _selectedSiteData = selectedSite;
      siteController.text =
          siteName; // Update the site controller with the selected site name
    });
  }

  Future<void> _loadSpareData() async {
    try {
      List<Map<String, dynamic>> spareData =
          await DatabaseHelper.loadSpareData();
      logger.i(spareData);

      if (mounted) {
        setState(() {
          _spareData = spareData;
          _spareNames =
              spareData.map((item) => item['Item name'] as String).toList();
          _spareCode = spareData.map((item) => item['Code'] as String).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar('Error loading data: ${e.toString()}');
      }
    }
  }

  void _updateSelectedSpareName(String spareName) {
    _spareData?.firstWhere((item) => item['Item name'] == spareName);
    setState(() {
      _spareController.text = spareName;
    });
  }

  void _updateSelectedSpareCode(String spareCode) {
    _spareData?.firstWhere((item) => item['Code'] == spareCode);
    setState(() {
      _spareController.text = spareCode;
    });
  }

  void showCombinedSearchableDropdown(
    BuildContext context,
    List<Map<String, dynamic>> spareData,
    TextEditingController searchController,
    Function(String) onItemSelected,
  ) {
    final List<String> combinedList = spareData.map((item) {
      String itemName = item['Item name'] as String;
      String itemCode = item['Code'] as String;
      return '$itemCode -- $itemName';
    }).toList();

    showSearchableDropdown(
      context,
      combinedList,
      (selected) {
        String itemName = selected.split(' -- ')[1];
        String itemCode = selected.split(' -- ')[0];

        if (itemName.isNotEmpty) {
          if (_selectedSpareItems.length < 15) {
            setState(() {
              _selectedSpareItems.add(SpareItem(
                name: itemName,
                code: itemCode,
                quantity: 1,
                usage: '',
                where: '',
              ));
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Too Much Items')),
            );
          }
        }
      },
      searchController,
    );
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

  Future<void> _selectEscalatedTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: escalatedTime ?? TimeOfDay.now(),
      helpText: 'Select Time',
    );

    if (picked != null) {
      setState(() {
        String formattedTime =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
        _commentsControllers[0].text = formattedTime;
      });
    }
  }

  void _showCMTypeDialog(String label) {
    CMTypeDialog(
      context,
      label,
      (String? category, String? extraType, String? type) {
        setState(() {
          _isCMTypeSelected = true;
          _selectedCMType = label;
          _selectedCategory = category;
          _selectedExtraType = extraType;
          _selectedType = type;
        });
      },
    ).show();
  }

  void _updateEscalatedText() {
    String baseText;
    baseText = "";
    if (isDuringPM) {
      baseText += "PM";
    }
    setState(() {
      _commentsControllers[0].text = baseText;
    });
  }

  Map<String, dynamic> _collectData() {
    return {
      //step1
      'cm': _selectedCMType ?? '',
      'cmCategory': _selectedCategory ?? '',
      'cmType': _selectedType ?? '',
      'extraType': _selectedExtraType ?? '',
      'siteName': siteController.text,
      'siteCode': _selectedSiteData?['code'] ?? '',
      'location': _selectedSiteData?['Location'] ?? '',
      'date': _dateController.text,
      'time':
          'Time in: ${fromTime?.format(context) ?? ''} & Time out: ${toTime?.format(context) ?? ''}',
      'escalated': _commentsControllers[0].text,
      'G1': _genControllers[0].text,
      'G2': _genControllers[1].text,
      'CP': cpController.text,
      'Kwh': kwhController.text,
      'T1': _tankControllers[0].text,
      'T2': _tankControllers[1].text,
      'T3': _tankControllers[2].text,
      '--------------------': '----------------',
      //item1
      'item1Code':
          _selectedSpareItems.isNotEmpty ? _selectedSpareItems[0].code : '',
      'item1Quantity':
          _selectedSpareItems.isNotEmpty ? _selectedSpareItems[0].quantity : '',
      'item1UsedFor':
          _selectedSpareItems.isNotEmpty ? _selectedSpareItems[0].usage : '',
      'item1Where':
          _selectedSpareItems.isNotEmpty ? _selectedSpareItems[0].where : '',
      //item2
      'item2Code':
          _selectedSpareItems.length > 1 ? _selectedSpareItems[1].code : '',
      'item2Quantity':
          _selectedSpareItems.length > 1 ? _selectedSpareItems[1].quantity : '',
      'item2UsedFor':
          _selectedSpareItems.length > 1 ? _selectedSpareItems[1].usage : '',
      'item2Where':
          _selectedSpareItems.length > 1 ? _selectedSpareItems[1].where : '',
      //item3
      'item3Code':
          _selectedSpareItems.length > 2 ? _selectedSpareItems[2].code : '',
      'item3Quantity':
          _selectedSpareItems.length > 2 ? _selectedSpareItems[2].quantity : '',
      'item3UsedFor':
          _selectedSpareItems.length > 2 ? _selectedSpareItems[2].usage : '',
      'item3Where':
          _selectedSpareItems.length > 2 ? _selectedSpareItems[2].where : '',
      //item4
      'item4Code':
          _selectedSpareItems.length > 3 ? _selectedSpareItems[3].code : '',
      'item4Quantity':
          _selectedSpareItems.length > 3 ? _selectedSpareItems[3].quantity : '',
      'item4UsedFor':
          _selectedSpareItems.length > 3 ? _selectedSpareItems[3].usage : '',
      'item4Where':
          _selectedSpareItems.length > 3 ? _selectedSpareItems[3].where : '',
      //item5
      'item5Code':
          _selectedSpareItems.length > 4 ? _selectedSpareItems[4].code : '',
      'item5Quantity':
          _selectedSpareItems.length > 4 ? _selectedSpareItems[4].quantity : '',
      'item5UsedFor':
          _selectedSpareItems.length > 4 ? _selectedSpareItems[4].usage : '',
      'item5Where':
          _selectedSpareItems.length > 4 ? _selectedSpareItems[4].where : '',
      //item6
      'item6Code':
          _selectedSpareItems.length > 5 ? _selectedSpareItems[5].code : '',
      'item6Quantity':
          _selectedSpareItems.length > 5 ? _selectedSpareItems[5].quantity : '',
      'item6UsedFor':
          _selectedSpareItems.length > 5 ? _selectedSpareItems[5].usage : '',
      'item6Where':
          _selectedSpareItems.length > 5 ? _selectedSpareItems[5].where : '',
      //item7
      'item7Code':
          _selectedSpareItems.length > 6 ? _selectedSpareItems[6].code : '',
      'item7Quantity':
          _selectedSpareItems.length > 6 ? _selectedSpareItems[6].quantity : '',
      'item7UsedFor':
          _selectedSpareItems.length > 6 ? _selectedSpareItems[6].usage : '',
      'item7Where':
          _selectedSpareItems.length > 6 ? _selectedSpareItems[6].where : '',
      //item8
      'item8Code':
          _selectedSpareItems.length > 7 ? _selectedSpareItems[7].code : '',
      'item8Quantity':
          _selectedSpareItems.length > 7 ? _selectedSpareItems[7].quantity : '',
      'item8UsedFor':
          _selectedSpareItems.length > 7 ? _selectedSpareItems[7].usage : '',
      'item8Where':
          _selectedSpareItems.length > 7 ? _selectedSpareItems[7].where : '',
      //item9
      'item9Code':
          _selectedSpareItems.length > 8 ? _selectedSpareItems[8].code : '',
      'item9Quantity':
          _selectedSpareItems.length > 8 ? _selectedSpareItems[8].quantity : '',
      'item9UsedFor':
          _selectedSpareItems.length > 8 ? _selectedSpareItems[8].usage : '',
      'item9Where':
          _selectedSpareItems.length > 8 ? _selectedSpareItems[8].where : '',
      //item10
      'item10Code':
          _selectedSpareItems.length > 9 ? _selectedSpareItems[9].code : '',
      'item10Quantity':
          _selectedSpareItems.length > 9 ? _selectedSpareItems[9].quantity : '',
      'item10UsedFor':
          _selectedSpareItems.length > 9 ? _selectedSpareItems[9].usage : '',
      'item10Where':
          _selectedSpareItems.length > 9 ? _selectedSpareItems[9].where : '',
      //item11
      'item11Code':
          _selectedSpareItems.length > 10 ? _selectedSpareItems[10].code : '',
      'item11Quantity': _selectedSpareItems.length > 10
          ? _selectedSpareItems[10].quantity
          : '',
      'item11UsedFor':
          _selectedSpareItems.length > 10 ? _selectedSpareItems[10].usage : '',
      'item11Where':
          _selectedSpareItems.length > 10 ? _selectedSpareItems[10].where : '',
      //item12
      'item12Code':
          _selectedSpareItems.length > 11 ? _selectedSpareItems[11].code : '',
      'item12Quantity': _selectedSpareItems.length > 11
          ? _selectedSpareItems[11].quantity
          : '',
      'item12UsedFor':
          _selectedSpareItems.length > 11 ? _selectedSpareItems[11].usage : '',
      'item12Where':
          _selectedSpareItems.length > 11 ? _selectedSpareItems[11].where : '',
      //item13
      'item13Code':
          _selectedSpareItems.length > 12 ? _selectedSpareItems[12].code : '',
      'item13Quantity': _selectedSpareItems.length > 12
          ? _selectedSpareItems[12].quantity
          : '',
      'item13UsedFor':
          _selectedSpareItems.length > 12 ? _selectedSpareItems[12].usage : '',
      'item13Where':
          _selectedSpareItems.length > 12 ? _selectedSpareItems[12].where : '',
      //item14
      'item14Code':
          _selectedSpareItems.length > 13 ? _selectedSpareItems[13].code : '',
      'item14Quantity': _selectedSpareItems.length > 13
          ? _selectedSpareItems[13].quantity
          : '',
      'item14UsedFor':
          _selectedSpareItems.length > 13 ? _selectedSpareItems[13].usage : '',
      'item14Where':
          _selectedSpareItems.length > 13 ? _selectedSpareItems[13].where : '',
      //item15
      'item15Code':
          _selectedSpareItems.length > 14 ? _selectedSpareItems[14].code : '',
      'item15Quantity': _selectedSpareItems.length > 14
          ? _selectedSpareItems[14].quantity
          : '',
      'item15UsedFor':
          _selectedSpareItems.length > 14 ? _selectedSpareItems[14].usage : '',
      'item15Where':
          _selectedSpareItems.length > 14 ? _selectedSpareItems[14].where : '',
      '------------------': '----------------',
      //step3
      'Comments1': _commentsControllers[1].text,
      'Comments2': _commentsControllers[2].text,
      'engineer name': _selectedEngName ?? '',
      'tech name': _selectedTechName ?? '',
    };
  }

  Map<String, dynamic> _collectDataForCm(String sheetType) {
    final data = _collectData();
    logger.i('Raw Collected Data: $data');

    final mapper = CMMapper();
    final cells = mapper.getCMMapping(sheetType);

    // Proceed with mapping logic
    final mappedData = <String, dynamic>{};
    cells.forEach((cell, key) {
      if (data.containsKey(key)) {
        mappedData[cell] = data[key];
      } else {
        logger.w('Key $key not found in collected data.');
      }
    });

    logger.i('Mapped Data for Sheet $sheetType: $mappedData');
    return mappedData;
  }

  String _generateModifiedFileName(String selectedSheetType) {
    String siteName = _collectData()['siteName'];

    switch (selectedSheetType) {
      case 'Generator':
        return '$siteName G';
      case 'Electric':
        return '$siteName Ele';
      case 'AC':
        return '$siteName AC';
      case 'Civil':
        return '$siteName Civil';
      default:
        return siteName;
    }
  }

  Future<void> _submitData() async {
    if (_selectedSiteData != null && _selectedSiteData!['sheet'] != null) {
      String selectedSheetType = _selectedCMType!;

      CMMapper sheetMapper = CMMapper();

      GoogleSheetHelper googleSheetHelper = GoogleSheetHelper(
        templateFileId: sheetMapper.getCMTemplateFileId(selectedSheetType),
        targetSheetName: sheetMapper.getCMSheetName(selectedSheetType),
        modifiedFileName: _generateModifiedFileName(selectedSheetType),
      );

      Map<String, dynamic> collectedData = _collectDataForCm(selectedSheetType);
      logger.i('Collected Data for Sheet $selectedSheetType: $collectedData');
      Map<String, dynamic> cellMappings =
          sheetMapper.getCMMapping(selectedSheetType);
      logger.i('Cell Mappings for Sheet $selectedSheetType: $cellMappings');

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isCMTypeSelected
            ? Text(_selectedCMType ?? '',
                style: Theme.of(context).textTheme.titleLarge)
            : Text('CM Sheet', style: Theme.of(context).textTheme.titleLarge),
        actions: [
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Beta Feature'),
                    content: Text(
                        'This feature is under testing.\nfeel free to report a problem.'),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          const url = reportIssue;
                          if (await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(Uri.parse(url),
                                mode: LaunchMode.externalApplication);
                          } else {}
                        },
                        child: Text(
                          'Report',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              );
            },
            child: Text(
              'Beta',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
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
                              builder: (context) => CmSheetPage(
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
            color: Colors.red,
          ),
        ],
      ),
      body: !_isCMTypeSelected
          ? Center(
              child: Text(
              'Create New CM ...',
              style: Theme.of(context).textTheme.titleLarge,
            ))
          : SafeArea(
              child: _siteData == null
                  ? const Center(child: CircularProgressIndicator())
                  : Stepper(
                      currentStep: _currentStep,
                      type: StepperType.horizontal,
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
                                        horizontal: 20,
                                        vertical: 10), // Text color
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          30.0), // Rounded corners
                                    ),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: (_isSiteSelected)
                                      ? () {
                                          if (_currentStep != 2) {
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
                                                        Navigator.of(context)
                                                            .pop();
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
                                  icon: Icon(_currentStep != 2
                                      ? Icons.arrow_forward
                                      : Icons.check),
                                  label: Text(
                                      _currentStep != 2 ? 'Continue' : 'Done'),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: _currentStep != 2
                                        ? Colors.green
                                        : Colors.red,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10), // Text color
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
                        if (_currentStep < 2) {
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
                          title: Text(''),
                          content: Column(
                            children: [
                              GestureDetector(
                                onTap: () => showSearchableDropdown(
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
                                        color: Theme.of(context)
                                            .colorScheme
                                            .tertiary,
                                      ),
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
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .tertiary,
                                            width: 2.0),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        borderSide: const BorderSide(
                                            color: Colors.grey, width: 1.5),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 16.0, horizontal: 12.0),
                                    ),
                                    keyboardType: TextInputType.number,
                                    readOnly: true,
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
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                  ),
                                  label: Text('Select Date'),
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
                              ),
                              const SizedBox(height: 12.0),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                      ),
                                      label: Text(
                                        fromTime != null
                                            ? fromTime!.format(context)
                                            : 'Time in',
                                      ),
                                      icon: Icon(Icons.access_time_rounded,
                                          color: fromTime != null
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .tertiary
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
                                          borderRadius:
                                              BorderRadius.circular(10.0),
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
                                            ? Theme.of(context)
                                                .colorScheme
                                                .tertiary
                                            : Colors.grey,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 12.0),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: TextField(
                                      onTap: () =>
                                          _selectEscalatedTime(context),
                                      controller: _commentsControllers[0],
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.trending_up_rounded,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .tertiary,
                                        ),
                                        label: Text('Escalated'),
                                        filled: true,
                                        labelStyle: TextStyle(
                                            color: ThemeControl.errorColor
                                                .withOpacity(0.8)),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .tertiary,
                                              width: 2.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                          borderSide: const BorderSide(
                                              color: Colors.grey, width: 1.5),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 16.0,
                                                horizontal: 12.0),
                                      ),
                                      readOnly: true,
                                    ),
                                  ),
                                  SizedBox(width: 45),
                                  Checkbox(
                                    value: isDuringPM,
                                    onChanged: (value) {
                                      setState(() {
                                        isDuringPM = value ?? false;
                                      });
                                      _updateEscalatedText();
                                    },
                                  ),
                                  Text("During PM"),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              if (_selectedSiteData != null)
                                Row(
                                  children: [
                                    ...GenInput(_selectedSiteData!['sheet'])
                                        .genInputs(context, _genControllers)
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
                                        .tankInputs(context, _tankControllers)
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
                          title: Text(''),
                          content: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _selectedSpareItems.clear();
                                      });
                                    },
                                    icon: Icon(Icons.clear, size: 16),
                                    label: Text('Clear'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Theme.of(context)
                                          .colorScheme
                                          .secondary, // Use theme color
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    onPressed: () =>
                                        showCombinedSearchableDropdown(
                                      context,
                                      _spareData ?? [],
                                      _searchController,
                                      (selected) {
                                        setState(() {
                                          if (_spareNames.contains(selected)) {
                                            _updateSelectedSpareName(selected);
                                          } else if (_spareCode
                                              .contains(selected)) {
                                            _updateSelectedSpareCode(selected);
                                          }
                                        });
                                      },
                                    ),
                                    icon: Icon(Icons.add, size: 16),
                                    label: Text('Add Item'),
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.55,
                                child: _selectedSpareItems.isNotEmpty
                                    ? ListView.builder(
                                        itemCount: _selectedSpareItems.length,
                                        itemBuilder: (context, index) {
                                          final item =
                                              _selectedSpareItems[index];
                                          return _buildItemCard(item, index);
                                        },
                                      )
                                    : Center(child: Text('No items selected')),
                              ),
                            ],
                          ),
                          state: stepCompleted[1]
                              ? StepState.complete
                              : StepState.indexed,
                        ),
                        Step(
                          isActive: _currentStep == 2,
                          title: Text(''),
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildCommentField('Comment 1',
                                  _commentsControllers[1], context),
                              buildCommentField('Comment 2',
                                  _commentsControllers[2], context),
                              SizedBox(height: 10),
                              DropdownButton<String>(
                                isExpanded: true,
                                hint: Text(
                                  'Engineer Name..',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ), // Placeholder text
                                value: _selectedEngName,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedEngName = newValue;
                                  });
                                },
                                items: engNames.map<DropdownMenuItem<String>>(
                                    (String value) {
                                  return DropdownMenuItem<String>(
                                    alignment: Alignment.center,
                                    value: value,
                                    child: Text(
                                      value,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineLarge,
                                    ),
                                  );
                                }).toList(),
                              ),
                              DropdownButton<String>(
                                isExpanded: true,
                                hint: Text(
                                  'Tech Name..',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ), // Placeholder text
                                value: _selectedTechName,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedTechName = newValue;
                                  });
                                },
                                items: techNames.map<DropdownMenuItem<String>>(
                                    (String value) {
                                  return DropdownMenuItem<String>(
                                    alignment: Alignment.center,
                                    value: value,
                                    child: Text(
                                      value,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineLarge,
                                    ),
                                  );
                                }).toList(),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _isLoading
                                          ? null
                                          : () async {
                                              setState(() {
                                                _isLoading = true;
                                              });

                                              try {
                                                await _submitData();

                                                if (!context.mounted) return;
                                                _showSnackbar(
                                                  '/PowerDiyala/${_generateModifiedFileName(_selectedCMType ?? 'Generator')}',
                                                );
                                              } catch (error) {
                                                _showSnackbar(
                                                    'Error submitting data: $error');
                                              } finally {
                                                setState(() {
                                                  _isLoading =
                                                      false; // Stop loading
                                                });
                                              }
                                            },
                                      onLongPress: () {
                                        if (_selectedSiteData != null &&
                                            _selectedSiteData!['sheet'] !=
                                                null) {
                                          String selectedSheetType =
                                              _selectedCMType!;
                                          Map<String, dynamic> data =
                                              _collectDataForCm(
                                                  selectedSheetType);

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
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                        ),
                                      ),
                                      child: _isLoading
                                          ? Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
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
                          state: stepCompleted[2]
                              ? StepState.complete
                              : StepState.indexed,
                        ),
                      ],
                    ),
            ),
      floatingActionButton: _isCMTypeSelected
          ? null
          : Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Theme.of(context).secondaryHeaderColor,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: SpeedDial(
                animatedIcon: AnimatedIcons.add_event,
                overlayColor: Colors.black,
                overlayOpacity: 0.5,
                spacing: 10,
                spaceBetweenChildren: 10,
                children: [
                  SpeedDialChild(
                    shape: CircleBorder(),
                    child:
                        Icon(Icons.g_mobiledata_rounded, color: Colors.white),
                    backgroundColor: Colors.green,
                    label: 'Generator',
                    onTap: () => _showCMTypeDialog("Generator"),
                  ),
                  SpeedDialChild(
                    shape: CircleBorder(),
                    child:
                        Icon(Icons.electric_bolt_rounded, color: Colors.white),
                    backgroundColor: Colors.red,
                    label: 'Electric',
                    onTap: () => _showCMTypeDialog("Electric"),
                  ),
                  SpeedDialChild(
                    shape: CircleBorder(),
                    child: Icon(Icons.ac_unit, color: Colors.white),
                    backgroundColor: Colors.green,
                    label: 'AC',
                    onTap: () => _showCMTypeDialog("AC"),
                  ),
                  SpeedDialChild(
                    shape: CircleBorder(),
                    child: Icon(Icons.construction, color: Colors.white),
                    backgroundColor: Colors.red,
                    label: 'Civil',
                    onTap: () => _showCMTypeDialog("Civil"),
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

  Widget _buildItemCard(SpareItem item, int index) {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.name,
              style: TextStyle(fontSize: 18),
              softWrap: true,
              overflow: TextOverflow.visible,
              maxLines: null,
            ),
            Text(
              item.code,
              style:
                  Theme.of(context).listTileTheme.leadingAndTrailingTextStyle,
            ),
          ],
        ),
        subtitle: _buildItemSubtitle(item, index),
      ),
    );
  }

  Widget _buildItemSubtitle(SpareItem item, int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        UsedForHelper(
          cmType: _selectedCMType!,
          onSelected: (usage, where, _) {
            if (kDebugMode) {
              print('Updating usage: $usage');
              print('Updating where: $where');
            }

            setState(() {
              _selectedSpareItems[index] = _selectedSpareItems[index].copyWith(
                  usage: usage ?? _selectedSpareItems[index].usage,
                  where: where ?? _selectedSpareItems[index].where);
            });
          },
        ),
        SizedBox(width: 30),
        SizedBox(
          width: 60,
          child: QuantitySelector(
            initialQuantity: item.quantity,
            onQuantityChanged: (newQuantity) {
              setState(() {
                _selectedSpareItems[index] =
                    item.copyWith(quantity: newQuantity);
              });
            },
            onDelete: () {
              setState(() {
                _selectedSpareItems.removeAt(index);
              });
            },
          ),
        ),
      ],
    );
  }
}
