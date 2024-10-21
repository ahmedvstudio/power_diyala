import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:power_diyala/Widgets/widgets.dart';
import 'package:power_diyala/data_helper/database_helper.dart';
import 'package:power_diyala/data_helper/sheets_helper/input_helper.dart';

class PmSheetPage extends StatefulWidget {
  const PmSheetPage({super.key});

  @override
  PmSheetPageState createState() => PmSheetPageState();
}

class PmSheetPageState extends State<PmSheetPage> {
  final Logger logger =
      kDebugMode ? Logger() : Logger(printer: PrettyPrinter());
  List<Map<String, dynamic>>? _data;
  List<String> _siteNames = [];
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? _selectedSiteData; // To hold the selected site's data
  List<TextEditingController> genControllers = [];
  DateTime? _selectedDate;
  TimeOfDay? fromTime; // To hold the start time
  TimeOfDay? toTime; // To hold the end time
  int _currentStep = 0; // Current step in the stepper

  @override
  void initState() {
    super.initState();
    genControllers = List.generate(8, (index) => TextEditingController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    for (var controller in genControllers) {
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

  void _updateSelectedSiteData(String siteName) {
    final selectedSite = _data?.firstWhere((item) => item['site'] == siteName);
    setState(() {
      _selectedSiteData = selectedSite;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
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
                type: StepperType.horizontal,
                onStepTapped: (step) => setState(() => _currentStep = step),
                onStepContinue: () {
                  if (_currentStep < 2) {
                    // Change this to the number of steps you have minus one
                    setState(() => _currentStep++);
                  }
                },
                onStepCancel: () {
                  if (_currentStep > 0) {
                    setState(() => _currentStep--);
                  }
                },
                steps: [
                  Step(
                    title: Text('Input Fields'),
                    isActive: true,
                    content: Column(
                      children: [
                        GestureDetector(
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
                                // Wrap the text in Expanded to avoid overflow
                                Expanded(
                                  child: Text(
                                    _selectedSiteData != null
                                        ? '${_selectedSiteData!['site']}'
                                        : 'No site selected',
                                    overflow: TextOverflow
                                        .ellipsis, // Handle long text with ellipsis
                                    style: TextStyle(
                                      fontSize:
                                          16.0, // Adjust text size as needed
                                    ),
                                  ),
                                ),
                                Icon(Icons.arrow_drop_down,
                                    color: Colors.grey[700]),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                              onPressed: () => _selectDate(context),
                              child: Text(
                                _selectedDate != null
                                    ? "${_selectedDate!.toLocal()}"
                                        .split(' ')[0]
                                    : "Select Date",
                                style: TextStyle(
                                  color: _selectedDate != null
                                      ? Colors.greenAccent
                                      : Colors.red,
                                ),
                              ),
                            ),
                            Text(
                              _selectedSiteData != null
                                  ? '${_selectedSiteData!['sheet']}'
                                  : 'Sheet',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _selectedSiteData != null
                                  ? '${_selectedSiteData!['Location']}'
                                  : 'Location',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => _selectFromTime(context),
                                child: Text(
                                  fromTime != null
                                      ? fromTime!.format(context)
                                      : 'Time in',
                                  style: TextStyle(
                                    color: fromTime != null
                                        ? Colors.greenAccent
                                        : Colors.red,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextButton(
                                onPressed: () => _selectToTime(context),
                                child: Text(
                                  toTime != null
                                      ? toTime!.format(context)
                                      : 'Time out',
                                  style: TextStyle(
                                    color: toTime != null
                                        ? Colors.greenAccent
                                        : Colors.red,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12.0),
                        if (_selectedSiteData != null)
                          Row(
                            children: [
                              // Safely map and expand the generated input fields
                              ...GenInput(_selectedSiteData!['sheet'])
                                  .genInputs(genControllers)
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
                  ),
                  Step(
                    title: Text('Next Step'),
                    content: Center(child: Text('Content for next step')),
                  ),
                  // Add more steps as needed
                ],
              ),
      ),
    );
  }
}

class DateSelectionButton extends StatelessWidget {
  final DateTime? selectedDate;
  final VoidCallback onPressed;

  const DateSelectionButton({
    super.key,
    required this.selectedDate,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(
            vertical: 16, horizontal: 24), // Text color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // Rounded corners
        ),
        elevation: 5, // Add elevation for shadow
      ),
      child: Text(
        selectedDate != null
            ? "${selectedDate!.toLocal()}".split(' ')[0]
            : "Select Date",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: selectedDate != null ? Colors.greenAccent : Colors.red,
        ),
      ),
    );
  }
}
