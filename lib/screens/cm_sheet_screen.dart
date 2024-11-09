import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:power_diyala/Widgets/widgets.dart';
import 'package:power_diyala/data_helper/database_helper.dart';
import 'package:power_diyala/data_helper/sheets_helper/cm_type_helper.dart';
import 'package:power_diyala/data_helper/sheets_helper/google_sheet.dart';
import 'package:power_diyala/data_helper/sheets_helper/cp_inputs.dart';
import 'package:power_diyala/data_helper/sheets_helper/gen_input.dart';
import 'package:power_diyala/data_helper/sheets_helper/sheet_id_cells_helper.dart';
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
  List<Map<String, dynamic>>? _data;
  List<Map<String, dynamic>>? _spareData;
  List<String> _siteNames = [];
  List<String> _spareNames = [];
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _searchSpareController = TextEditingController();
  Map<String, dynamic>? _selectedSiteData;
  Map<String, dynamic>? _selectedSpareData;
  List<TextEditingController> genControllers = [];
  List<TextEditingController> tankControllers = [];
  List<TextEditingController> commentsControllers = [];
  TextEditingController siteController = TextEditingController();
  TextEditingController spareController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  TextEditingController cpController = TextEditingController();
  TextEditingController kwhController = TextEditingController();
  String? _selectedEngineerName;
  String? _selectedTechName;
  String? _selectedCmType;
  String? selectedOption1;
  String? selectedOption2;
  String? selectedOption3;
  final List<TextEditingController> typeControllers = [
    TextEditingController(),
    TextEditingController()
  ];
  final List<SpareItem> _selectedSpareItems = [];
  bool _isLoading = false;
  bool _isTypeSelected = false;
  List<bool> stepCompleted = List.filled(5, false);
  TimeOfDay? fromTime;
  TimeOfDay? toTime;
  int _currentStep = 0;
  final List<String> cmType = [
    'Generator',
    'Electric',
    'AC',
    'Civil',
  ];
  final List<String> engineerNames = [
    'Ahmed Adnan',
    'Ahmed Jassim',
    'Ahmed Noori',
    'Mustafa Raad',
    'Ali Mahmod',
    'Yahya Falih',
  ];

  final List<String> techNames = [
    'Shams Ahmed',
    'Raed Ahmed',
    'Ali Adnan',
    'Abdulwahab Ahmed',
    'Bashar Shuker',
    'Mahmod Hashim',
    'Haider Ahmed',
    'Mustafa Hussein',
    'Hussein Mahmod',
  ];

  @override
  void initState() {
    super.initState();
    genControllers = List.generate(5, (index) => TextEditingController());
    tankControllers = List.generate(5, (index) => TextEditingController());
    commentsControllers = List.generate(9, (index) => TextEditingController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _loadSpareData();
    });
  }

  @override
  void dispose() {
    for (var controller in [
      ...genControllers,
      ...tankControllers,
      ...commentsControllers,
      siteController,
      spareController,
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
          _data = data;
          _siteNames = data.map((item) => item['site'] as String).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar('Error loading data: ${e.toString()}');
      }
    }
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

          // Initialize the filtered lists
        });
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
      siteController.text = siteName;
    });
  }

  void _updateSelectedSpareData(String spareName) {
    final selectedSpare =
        _spareData?.firstWhere((item) => item['Item name'] == spareName);
    setState(() {
      _selectedSpareData = selectedSpare;
      spareController.text = spareName;
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

  Map<String, dynamic> _collectData() {
    return {
      //step1
      'Corrective': _selectedCmType ?? '',
      'CM type': selectedOption1 ?? '',
      'Extra type': selectedOption1 == 'Extra' ? (selectedOption2 ?? '') : '',
      'CM when': selectedOption3 ?? '',
      '-----------------': '---------------',
      //Step2
      'siteName': siteController.text,
      'siteCode': _selectedSiteData?['code'] ?? '',
      'location': _selectedSiteData?['Location'] ?? '',
      'date': _dateController.text,
      'time':
          'Time in: ${fromTime?.format(context) ?? ''} & Time out: ${toTime?.format(context) ?? ''}',
      'G1': genControllers[0].text,
      'G2': genControllers[1].text,
      'CP': cpController.text,
      'Kwh': kwhController.text,
      'T1': tankControllers[0].text,
      'T2': tankControllers[1].text,
      'T3': tankControllers[2].text,
      '--------------------': '----------------',
      //step3
      'spareName': _selectedSpareData?['Item name'] ?? '',
      'spare': _selectedSpareData?['Code'] ?? '',
      'cod': _selectedSpareData?['Cost \$'] ?? '',
      //step6
      'Comments1': commentsControllers[0].text,
      'Comments2': commentsControllers[1].text,
      'engineer name': _selectedEngineerName ?? '',
      'tech name': _selectedTechName ?? '',
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

  Future<void> _submitData() async {
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

  void _showAddToCartDialog(String spareName) {
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController usageController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Item to Cart'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Item: $spareName'),
              SizedBox(height: 10),
              TextField(
                controller: quantityController,
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              TextField(
                controller: usageController,
                decoration: InputDecoration(labelText: 'Usage'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Add item to cart with entered details
                int quantity = int.tryParse(quantityController.text) ??
                    1; // Default to 1 if parsing fails
                String usage = usageController.text;

                if (quantity > 0 && usage.isNotEmpty) {
                  _addSpareToCart(
                      spareName, quantity, usage); // Add to cart with details
                  Navigator.of(context).pop(); // Close dialog
                } else {
                  _showSnackbar(
                      'Please enter valid quantity and usage.'); // Show error message
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addSpareToCart(String spareName, int quantity, String usage) {
    final selectedSpare = _spareData?.firstWhere(
      (item) => item['Item name'] == spareName,
      orElse: () => {
        'Item name': spareName,
        'Code': '',
        'Cost \$': 0
      }, // Provide a default value
    );

    if (selectedSpare != null) {
      setState(() {
        // Check if item is already added
        if (!_selectedSpareItems
            .any((item) => item.name == selectedSpare['Item name'])) {
          _selectedSpareItems.add(SpareItem(
            name: selectedSpare['Item name'],
            quantity: quantity,
            usage: usage,
          ));
        }
      });
    } else {
      // Handle the case where the selected spare part was not found
      _showSnackbar('Selected spare part not found.'); // Show error message
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
        title: Text('CM Sheet', style: Theme.of(context).textTheme.titleLarge),
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
                          Navigator.of(context).pop(); // Close the dialog
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
                            onPressed: (_isTypeSelected)
                                ? () {
                                    if (_currentStep != 4) {
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
                            icon: Icon(_currentStep != 4
                                ? Icons.arrow_forward
                                : Icons.check),
                            label:
                                Text(_currentStep != 4 ? 'Continue' : 'Done'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor:
                                  _currentStep != 4 ? Colors.green : Colors.red,
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
                  if (step != _currentStep) {
                    setState(() {
                      _currentStep = step;
                    });
                  }
                },
                onStepContinue: () {
                  if (_currentStep < 4) {
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
                    title: Text('Corrective Type'),
                    content: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).shadowColor,
                                blurRadius: 5,
                                offset: Offset(1, 2),
                              ),
                            ],
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .tertiary
                                  .withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          child: DropdownButton<String>(
                            hint: Text('Select a CM ...',
                                style: TextStyle(
                                    color: Colors.grey[700], fontSize: 17)),
                            value: _selectedCmType,
                            isExpanded: true,
                            underline: SizedBox(),
                            icon: AnimatedSwitcher(
                              duration: Duration(milliseconds: 300),
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                return ScaleTransition(
                                    scale: animation, child: child);
                              },
                              child: _selectedCmType == null
                                  ? Icon(Icons.arrow_drop_down,
                                      key: ValueKey('arrow'),
                                      color: Colors.grey[600])
                                  : Icon(Icons.check,
                                      key: ValueKey('check'),
                                      color: Colors.green),
                            ),
                            dropdownColor: Theme.of(context).cardColor,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedCmType = newValue;
                                selectedOption1 = null;
                                selectedOption2 = null;
                                selectedOption3 = null;
                                _isTypeSelected = true;
                              });
                            },
                            items: cmType
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                alignment: AlignmentDirectional.center,
                                child: Text(
                                  value,
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.normal,
                                      letterSpacing: 1),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(height: 20.0),
                        ...CMType(_selectedCmType).cmTypeDrop(
                          context,
                          typeControllers,
                          selectedOption1,
                          selectedOption2,
                          selectedOption3,
                          (value) {
                            setState(() {
                              selectedOption1 = value;
                            });
                          },
                          (value) {
                            setState(() {
                              selectedOption2 = value;
                            });
                          },
                          (value) {
                            setState(() {
                              selectedOption3 = value;
                            });
                          },
                        ),
                      ],
                    ),
                    state: stepCompleted[0]
                        ? StepState.complete
                        : StepState.indexed,
                  ),
                  Step(
                    isActive: _currentStep == 1,
                    title: Text('General'),
                    subtitle: _currentStep == 1
                        ? Text('All Fields Are Required.')
                        : null,
                    content: Column(
                      children: [
                        const SizedBox(height: 8.0),
                        GestureDetector(
                          onTap: () => showSearchableDropdown(
                            context,
                            _siteNames,
                            (selected) {
                              setState(() {
                                _updateSelectedSiteData(selected);
                                _isTypeSelected = true;
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
                    state: stepCompleted[1]
                        ? StepState.complete
                        : StepState.indexed,
                  ),
                  Step(
                    isActive: _currentStep == 2,
                    title: Text('Items'),
                    content: Column(
                      children: [
                        SizedBox(height: 10),
                        IconButton(
                          onPressed: () => showSearchableDropdown(
                            context,
                            _spareNames,
                            (selected) {
                              _showAddToCartDialog(
                                  selected); // Show dialog for quantity and usage
                            },
                            _searchSpareController,
                          ),
                          icon: Icon(Icons.add),
                        ),
                        // IconButton(
                        //     onPressed: () {
                        //       Navigator.of(context).push(MaterialPageRoute(
                        //         builder: (context) => CartScreen(
                        //           themeMode: themeControl.themeMode,
                        //           onThemeChanged: (value) {
                        //             themeControl.toggleTheme(value);
                        //           },
                        //         ),
                        //       ));
                        //     },
                        //     icon: Icon(Icons.roundabout_left)),
                        GestureDetector(
                          onTap: () => showSearchableDropdown(
                            context,
                            _spareNames,
                            (selected) {
                              setState(() {
                                _updateSelectedSpareData(selected);
                                _isTypeSelected = true;
                              });
                            },
                            _searchSpareController,
                          ),
                          child: AbsorbPointer(
                            child: TextField(
                              controller: spareController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.cell_tower_rounded,
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                                label: Text(
                                  _selectedSpareData != null
                                      ? 'Spare Name:'
                                      : 'No spare selected',
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
                            ),
                          ),
                        ),
                        SizedBox(height: 10), // Spacing between widgets
                      ],
                    ),
                    state: stepCompleted[2]
                        ? StepState.complete
                        : StepState.indexed,
                  ),
                  Step(
                    isActive: _currentStep == 3,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text('Comments')),
                      ],
                    ),
                    content: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        buildCommentField(
                            'Comment 1', commentsControllers[0], context),
                        buildCommentField(
                            'Comment 2', commentsControllers[1], context),
                        SizedBox(height: 10),
                        DropdownButton<String>(
                          hint: Text(
                            'Engineer Name..',
                            style: Theme.of(context).textTheme.titleLarge,
                          ), // Placeholder text
                          value: _selectedEngineerName,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedEngineerName = newValue;
                            });
                          },
                          items: engineerNames
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
                        DropdownButton<String>(
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
                          items: techNames
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
                    state: stepCompleted[3]
                        ? StepState.complete
                        : StepState.indexed,
                  ),
                  Step(
                    isActive: _currentStep == 4,
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
                                          await _submitData();
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
                        ..._collectData().entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text('${entry.key}: ${entry.value}'),
                          );
                        }),
                      ],
                    ),
                    state: stepCompleted[4]
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

class SpareItem {
  final String name;
  int quantity;
  String usage;

  SpareItem({required this.name, required this.quantity, required this.usage});
}
