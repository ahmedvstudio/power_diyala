import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:logger/logger.dart';
import 'package:power_diyala/Widgets/widgets.dart';
import 'package:power_diyala/data_helper/data_manager.dart';
import 'package:power_diyala/data_helper/sheets_helper/cm_cells_helper.dart';
import 'package:power_diyala/data_helper/sheets_helper/cm_type_helper.dart';
import 'package:power_diyala/data_helper/sheets_helper/quantity_helper.dart';
import 'package:power_diyala/data_helper/sheets_helper/spare_item_class.dart';
import 'package:power_diyala/data_helper/sheets_helper/used_for_helper.dart';
import 'package:power_diyala/data_helper/sheets_helper/google_sheet.dart';
import 'package:power_diyala/data_helper/sheets_helper/cp_inputs.dart';
import 'package:power_diyala/data_helper/sheets_helper/gen_input.dart';
import 'package:power_diyala/data_helper/sheets_helper/tank_input.dart';
import 'package:power_diyala/main.dart';
import 'package:power_diyala/settings/check_connectivity.dart';
import 'package:power_diyala/settings/theme_control.dart';
import 'package:provider/provider.dart';

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
  List<Map<String, dynamic>>? _nameData;
  List<String> _siteNames = [];
  List<String> _cmNames = [];
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? _selectedSiteData;
  final List<SpareItem> _selectedSpareItems = [];
  List<String> _spareNames = [];
  List<String> _spareCode = [];
  final TextEditingController _spareController = TextEditingController();
  List<TextEditingController> _genControllers = [];
  List<TextEditingController> _tankControllers = [];
  List<TextEditingController> _commentsControllers = [];
  List<TextEditingController> _nameController = [];
  TextEditingController siteController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  TextEditingController cpController = TextEditingController();
  TextEditingController kwhController = TextEditingController();
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

  @override
  void initState() {
    super.initState();
    _genControllers = List.generate(5, (index) => TextEditingController());
    _tankControllers = List.generate(5, (index) => TextEditingController());
    _commentsControllers = List.generate(3, (index) => TextEditingController());
    _nameController = List.generate(2, (index) => TextEditingController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDataFromManager();
    });
  }

  @override
  void dispose() {
    for (var controller in [
      ..._genControllers,
      ..._tankControllers,
      ..._commentsControllers,
      ..._nameController,
      siteController,
    ]) {
      controller.dispose();
    }

    super.dispose();
  }

  Future<void> _loadDataFromManager() async {
    try {
      // Create a single instance of DataManager
      final dataManager = DataManager();

      // Load PM Data
      _siteData = dataManager.getPMData();
      _siteNames =
          _siteData?.map((item) => item['site'] as String).toList() ?? [];

      // Load Spare Data
      _spareData = dataManager.getSpareData();
      _spareNames =
          _spareData?.map((item) => item['Item name'] as String).toList() ?? [];
      _spareCode =
          _spareData?.map((item) => item['Code'] as String).toList() ?? [];

      // Load Names Data
      _nameData = dataManager.getNamesData();
      _cmNames =
          _nameData?.map((item) => item['CM Name'] as String).toList() ?? [];

      logger.i("Loaded PM data: $_siteData");
      logger.i("Loaded Spare data: $_spareData");
      logger.i("Loaded Name data: $_nameData");

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      logger.e("Error loading data: ${e.toString()}"); // Log the error
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
      siteController.text = siteName;
    });
  }

  void _updateEngName(String name) {
    _nameData?.firstWhere((item) => item['CM Name'] == name);
    setState(() {
      _nameController[0].text = name;
    });
  }

  void _updateTechName(String name) {
    _nameData?.firstWhere((item) => item['CM Name'] == name);

    setState(() {
      _nameController[1].text = name;
    });
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
        String period = picked.hour >= 12 ? 'PM' : 'AM';
        int hour = picked.hour % 12;
        hour = hour == 0 ? 12 : hour;

        String formattedTime =
            '${hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')} $period';

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
      'engineer name': _nameController[0].text,
      'tech name': _nameController[1].text,
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
      case 'Site Management':
        return '$siteName SM';
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
    final isOnline = Provider.of<ConnectivityService>(context).isOnline;
    return Scaffold(
      appBar: AppBar(
        title: _isCMTypeSelected
            ? Text(_selectedCMType ?? '',
                style: Theme.of(context).textTheme.titleLarge)
            : Text('CM Sheet', style: Theme.of(context).textTheme.titleLarge),
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
                                  icon: Icon(Icons.arrow_back),
                                  label: Text('Back'),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.black,
                                    backgroundColor:
                                        Theme.of(context).secondaryHeaderColor,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
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
                                                return Dialog(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    child: Container(
                                                      color: Theme.of(context)
                                                          .cardColor,
                                                      child: SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.5,
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Stack(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              children: [
                                                                Container(
                                                                  height: 120,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .tertiary,
                                                                ),
                                                                Column(
                                                                  children: [
                                                                    Icon(
                                                                        Icons
                                                                            .task_alt_rounded,
                                                                        color: Colors
                                                                            .white,
                                                                        size:
                                                                            32),
                                                                    const SizedBox(
                                                                        height:
                                                                            8),
                                                                    Text(
                                                                      'All Done',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            18,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        height:
                                                                            8),
                                                                    Text(
                                                                      'Would you like to exit?',
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.white),
                                                                    )
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                                height: 30),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceEvenly,
                                                              children: [
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Theme.of(
                                                                              context)
                                                                          .colorScheme
                                                                          .tertiary,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                    ),
                                                                    padding: EdgeInsets
                                                                        .fromLTRB(
                                                                            16,
                                                                            8,
                                                                            16,
                                                                            8),
                                                                    child: Text(
                                                                      'No',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              16),
                                                                    ),
                                                                  ),
                                                                ),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pushAndRemoveUntil(
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                const MyApp(),
                                                                      ),
                                                                      (Route<dynamic>
                                                                              route) =>
                                                                          false,
                                                                    );
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Theme.of(
                                                                              context)
                                                                          .colorScheme
                                                                          .tertiary,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                    ),
                                                                    padding: EdgeInsets
                                                                        .fromLTRB(
                                                                            16,
                                                                            8,
                                                                            16,
                                                                            8),
                                                                    child: Text(
                                                                      'Yes',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              16),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                                height: 16),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
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
                                        ? Theme.of(context).primaryColor
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
                                    style: TextStyle(
                                        color: ThemeControl.errorColor),
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
                              if (_selectedCMType == 'Generator' ||
                                  _selectedCMType == 'AC')
                                buildCommentField('Comment 2',
                                    _commentsControllers[2], context),
                              SizedBox(height: 10),
                              GestureDetector(
                                onTap: () => showSearchableDropdown(
                                  context,
                                  _cmNames,
                                  (selected) {
                                    setState(() {
                                      _updateEngName(selected);
                                    });
                                  },
                                  _searchController,
                                ),
                                child: AbsorbPointer(
                                  child: TextField(
                                    controller: _nameController[0],
                                    style: TextStyle(
                                        color: ThemeControl.errorColor),
                                    decoration: InputDecoration(
                                      label: Text(
                                        _selectedSiteData != null
                                            ? 'Engineer Name:'
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
                              SizedBox(height: 10),
                              GestureDetector(
                                onTap: () => showSearchableDropdown(
                                  context,
                                  _cmNames,
                                  (selected) {
                                    setState(() {
                                      _updateTechName(selected);
                                    });
                                  },
                                  _searchController,
                                ),
                                child: AbsorbPointer(
                                  child: TextField(
                                    controller: _nameController[1],
                                    style: TextStyle(
                                        color: ThemeControl.errorColor),
                                    decoration: InputDecoration(
                                      label: Text(
                                        _selectedSiteData != null
                                            ? 'Technician Name:'
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
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: isOnline
                                          ? _isLoading
                                              ? null
                                              : () async {
                                                  setState(() {
                                                    _isLoading = true;
                                                  });

                                                  try {
                                                    await _submitData();

                                                    if (!context.mounted) {
                                                      return;
                                                    }
                                                    _showSnackbar(
                                                      '/PowerDiyala/${_generateModifiedFileName(_selectedCMType ?? 'Generator')}',
                                                    );
                                                  } catch (error) {
                                                    _showSnackbar(
                                                        'Error submitting data: $error');
                                                  } finally {
                                                    setState(() {
                                                      _isLoading = false;
                                                    });
                                                  }
                                                }
                                          : () {
                                              _showNoInternetDialog();
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
                                        backgroundColor: isOnline
                                            ? Colors.tealAccent
                                            : Colors.grey,
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
                                                Text('Downloading...'),
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
                    backgroundColor: Colors.blue,
                    label: 'AC',
                    onTap: () => _showCMTypeDialog("AC"),
                  ),
                  SpeedDialChild(
                    shape: CircleBorder(),
                    child: Icon(Icons.construction, color: Colors.white),
                    backgroundColor: Colors.indigoAccent,
                    label: 'Civil',
                    onTap: () => _showCMTypeDialog("Civil"),
                  ),
                  SpeedDialChild(
                    shape: CircleBorder(),
                    child: Icon(Icons.manage_accounts_rounded,
                        color: Colors.white),
                    backgroundColor: Colors.brown,
                    label: 'Site Management',
                    onTap: () => _showCMTypeDialog("Site Management"),
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
            suffixIcon: IconButton(
                onPressed: () {
                  showMenu<String>(
                    context: context,
                    position: RelativeRect.fromLTRB(175.0, 200.0, 250.0, 100.0),
                    items: [
                      PopupMenuItem<String>(
                        value: 'Materials Used During PM',
                        child: Text('During PM'),
                      ),
                      PopupMenuItem<String>(
                        value: 'Replaced required items',
                        child: Text('Required'),
                      ),
                      PopupMenuItem<String>(
                        value: 'Replaced faulty items',
                        child: Text('Faulty'),
                      ),
                    ],
                  ).then((String? value) {
                    if (value != null) {
                      controller.text = value;
                    }
                  });
                },
                icon: Icon(Icons.add)),
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
        QuantitySelector(
          initialQuantity: item.quantity,
          onQuantityChanged: (newQuantity) {
            setState(() {
              _selectedSpareItems[index] = item.copyWith(quantity: newQuantity);
            });
          },
          onDelete: () {
            setState(() {
              _selectedSpareItems.removeAt(index);
            });
          },
        ),
      ],
    );
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              color: Theme.of(context).cardColor,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 120,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        Column(
                          children: [
                            Icon(Icons.wifi_off_rounded,
                                color: Colors.white, size: 32),
                            const SizedBox(height: 8),
                            Text(
                              'OOPs...',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No Internet Connection!',
                              style: TextStyle(color: Colors.white),
                            )
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: Text(
                          'Try again',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
