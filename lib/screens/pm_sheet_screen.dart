import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:power_diyala/Widgets/widgets.dart';
import 'package:power_diyala/data_helper/database_helper.dart';
import 'package:power_diyala/data_helper/sheets_helper/ac_helper.dart';
import 'package:power_diyala/data_helper/sheets_helper/cp_inputs.dart';
import 'package:power_diyala/data_helper/sheets_helper/earth_load.dart';
import 'package:power_diyala/data_helper/sheets_helper/gen_input.dart';
import 'package:power_diyala/data_helper/sheets_helper/toggles.dart';
import 'package:power_diyala/data_helper/sheets_helper/tank_input.dart';
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
  List<TextEditingController> acControllers = [];
  List<TextEditingController> tankControllers = [];
  List<TextEditingController> commentsControllers = [];
  TextEditingController siteController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  TextEditingController cpController = TextEditingController();
  TextEditingController kwhController = TextEditingController();
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
  List<bool> stepCompleted = List.filled(7, false); // Track completed steps

  TimeOfDay? fromTime;
  TimeOfDay? toTime;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    genControllers = List.generate(5, (index) => TextEditingController());
    tankControllers = List.generate(5, (index) => TextEditingController());
    genVLControllers = List.generate(20, (index) => TextEditingController());
    acControllers = List.generate(20, (index) => TextEditingController());
    commentsControllers = List.generate(9, (index) => TextEditingController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    for (var controller in genControllers) {
      controller.dispose();
    }
    for (var controller in tankControllers) {
      controller.dispose();
    }
    for (var controller in genVLControllers) {
      controller.dispose();
    }
    for (var controller in acControllers) {
      controller.dispose();
    }
    for (var controller in commentsControllers) {
      controller.dispose();
    }
    siteController.dispose(); // Dispose of the site controller
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
          title:
              Text('PM Sheet', style: Theme.of(context).textTheme.titleLarge)),
      body: SafeArea(
        child: _data == null
            ? const Center(child: CircularProgressIndicator())
            : Stepper(
                currentStep: _currentStep,
                type: StepperType.vertical,
                physics: ScrollPhysics(),
                controlsBuilder:
                    (BuildContext context, ControlsDetails controls) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          // Restart the page completely
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PmSheetPage(
                                  themeMode: widget.themeMode,
                                  onThemeChanged: widget.onThemeChanged),
                            ),
                          );
                        },
                        icon: Icon(Icons.restart_alt_rounded),
                        tooltip: 'Restart',
                      ),
                      ElevatedButton(
                        onPressed: controls.onStepCancel,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                        ),
                        child: Text('Back'),
                      ),
                      ElevatedButton(
                        onPressed: controls.onStepContinue,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                        ),
                        child: Text('Continue'),
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
                      stepCompleted[_currentStep] =
                          true; // Mark step as completed
                      _currentStep++;
                    });
                  }
                },
                onStepCancel: () {
                  if (_currentStep > 0) {
                    setState(() {
                      stepCompleted[_currentStep] =
                          false; // Reset current step on cancel
                      _currentStep--;
                    });
                  }
                },
                steps: [
                  Step(
                    isActive: _currentStep == 0,
                    title: Text('General'),
                    content: Column(
                      children: [
                        const SizedBox(height: 8.0),
                        TextField(
                          onTap: () => showSearchableDropdown(
                            context,
                            _siteNames,
                            (selected) {
                              setState(() {
                                _updateSelectedSiteData(selected);
                              });
                            },
                            _searchController,
                          ),
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
                              overflow: TextOverflow
                                  .ellipsis, // Handle long text with ellipsis
                              style: TextStyle(
                                fontSize: 16.0, // Adjust text size as needed
                              ),
                            ),
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
                              // Generate input fields based on sheet number
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
                          // Usage in some parent widget
                          CpInput(
                            cpValue: _selectedSiteData!['cp'],
                            cpController: cpController,
                            kwhController: kwhController,
                          ),
                        const SizedBox(height: 8.0),
                        if (_selectedSiteData != null)
                          Row(
                            children: [
                              // Generate input fields based on sheet number
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
                        const SizedBox(height: 8.0),
                        if (_selectedSiteData != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                _selectedSiteData != null
                                    ? '${_selectedSiteData!['sheet']}'
                                    : 'Location',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
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
                    content: Column(
                      children: [
                        if (_selectedSiteData != null)
                          ...ReplacementSwitch(_selectedSiteData!['sheet'])
                              .genSwitches(toggleValues, handleToggleChange),
                        if (_selectedSiteData != null) ...[
                          ...SeparatorSwitch(_selectedSiteData!['sheet'],
                                  _selectedSiteData!.cast<String, String?>())
                              .sepSwitches(toggleValues, handleToggleChange),
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
                    content: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (_selectedSiteData != null)
                          CpPhaseInputWidget(
                              cpValue: _selectedSiteData!['cp'],
                              phase: _selectedSiteData!['phase']),
                        SizedBox(height: 8),
                        if (_selectedSiteData != null)
                          GenVLInput(_selectedSiteData!['sheet'])
                              .genVLInputs(context, genVLControllers),
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
                          ...AcInput(_selectedSiteData!['sheet'])
                              .acInputs(context, acControllers)
                              .map((inputField) {
                            return inputField;
                          }),
                      ],
                    ),
                    state: stepCompleted[3]
                        ? StepState.complete
                        : StepState.indexed,
                  ),
                  Step(
                    isActive: _currentStep == 4,
                    title: Text('Earth & External load'),
                    content: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        EarthInputFields(selectedSiteData: _selectedSiteData),
                      ],
                    ),
                    state: stepCompleted[4]
                        ? StepState.complete
                        : StepState.indexed,
                  ),
                  Step(
                    isActive: _currentStep == 5,
                    title: Text('Comments'),
                    content: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(height: 5),
                        TextField(
                          controller: commentsControllers[0],
                          decoration: InputDecoration(
                            labelText: 'General',
                            labelStyle: TextStyle(
                                color:
                                    ThemeControl.errorColor.withOpacity(0.8)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.tertiary,
                                  width: 2.0),
                            ),
                            filled: true,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 16.0, horizontal: 12.0),
                          ),
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: commentsControllers[1],
                          decoration: InputDecoration(
                            labelText: 'G1',
                            labelStyle: TextStyle(
                                color:
                                    ThemeControl.errorColor.withOpacity(0.8)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.tertiary,
                                  width: 2.0),
                            ),
                            filled: true,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 16.0, horizontal: 12.0),
                          ),
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: commentsControllers[2],
                          decoration: InputDecoration(
                            labelText: 'G2',
                            labelStyle: TextStyle(
                                color:
                                    ThemeControl.errorColor.withOpacity(0.8)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.tertiary,
                                  width: 2.0),
                            ),
                            filled: true,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 16.0, horizontal: 12.0),
                          ),
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: commentsControllers[3],
                          decoration: InputDecoration(
                            labelText: 'AC',
                            labelStyle: TextStyle(
                                color:
                                    ThemeControl.errorColor.withOpacity(0.8)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.tertiary,
                                  width: 2.0),
                            ),
                            filled: true,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 16.0, horizontal: 12.0),
                          ),
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: commentsControllers[4],
                          decoration: InputDecoration(
                            labelText: 'Electric',
                            labelStyle: TextStyle(
                                color:
                                    ThemeControl.errorColor.withOpacity(0.8)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.tertiary,
                                  width: 2.0),
                            ),
                            filled: true,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 16.0, horizontal: 12.0),
                          ),
                          keyboardType: TextInputType.text,
                        ),
                      ],
                    ),
                    state: stepCompleted[5]
                        ? StepState.complete
                        : StepState.indexed,
                  ),
                  Step(
                    isActive: _currentStep == 6,
                    title: Text('Review'),
                    content: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [],
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
}
