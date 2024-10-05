import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:power_diyala/database_helper.dart';
import 'package:power_diyala/main.dart'; // Make sure to import this

class StepperScreen extends StatefulWidget {
  const StepperScreen({super.key});

  @override
  StepperScreenState createState() => StepperScreenState();
}

class StepperScreenState extends State<StepperScreen> {
  static final Logger logger = Logger();
  int _currentStep = 0;
  bool _permissionGranted = false; // Track permission status
  bool _dbReplaced = false; // Track database replacement status
  bool _dataLoadedCorrectly = false; // Track if data loaded correctly
  List<Map<String, dynamic>> _dataFromDatabase =
      []; // Store data from the database

  List<Step> _getSteps() {
    return [
      Step(
        title: const Text('Permission Request'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('We need permission to manage external storage.'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final localContext = context; // Capture the BuildContext

                // Request external storage permission
                await DBHelper.requestManageExternalStoragePermission(
                    localContext);

                // Check permission status
                var status = await Permission.manageExternalStorage.status;
                if (!localContext.mounted) return;
                if (status.isGranted) {
                  setState(() {
                    _permissionGranted = true; // Update permission status
                    _currentStep++; // Move to next step
                  });
                } else {
                  logger.e("Manage external storage permission not granted.");
                  showDialog(
                    context: localContext,
                    builder: (context) => AlertDialog(
                      title: const Text('Permission Denied'),
                      content: const Text(
                          'Manage external storage permission is required to proceed.'),
                      actions: [
                        TextButton(
                          child: const Text('OK'),
                          onPressed: () => Navigator.of(localContext).pop(),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: const Text('Request Permission'),
            ),
          ],
        ),
        isActive: true,
      ),
      Step(
        title: const Text('Choose and Replace Database'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'Please select a database file to replace the existing one.'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final localContext = context; // Capture the BuildContext

                // Delete existing database before selecting a new one
                try {
                  await DatabaseHelper
                      .deleteDatabase(); // Delete existing database
                  if (!context.mounted) return;
                  // Proceed to pick and replace the database
                  await DBHelper.pickAndReplaceDatabase(localContext);

                  // Check if the data loaded correctly after replacement
                  bool isDataValid = await DBHelper.checkDatabaseData();

                  if (isDataValid) {
                    setState(() {
                      _dbReplaced = true; // Update database replacement status
                      _dataLoadedCorrectly = true; // Update data loading status
                      _currentStep++; // Move to next step after successful operation
                    });
                    // Load data from the newly replaced database
                    _dataFromDatabase = await DatabaseHelper
                        .loadCalculatorData(); // Load specific data
                  } else {
                    logger.e("Database replaced but data validation failed.");
                    if (!context.mounted) return;
                    showDialog(
                      context: localContext,
                      builder: (context) => AlertDialog(
                        title: const Text('Data Validation Failed'),
                        content: const Text(
                            'The database was replaced, but the data could not be validated. Please try again.'),
                        actions: [
                          TextButton(
                            child: const Text('OK'),
                            onPressed: () => Navigator.of(localContext).pop(),
                          ),
                        ],
                      ),
                    );
                  }
                } catch (e) {
                  logger.e("Failed to delete or replace the database: $e");
                  if (!context.mounted) return;
                  showDialog(
                    context: localContext,
                    builder: (context) => AlertDialog(
                      title: const Text('Database Operation Failed'),
                      content: const Text(
                          'Failed to delete or replace the database. Please try again.'),
                      actions: [
                        TextButton(
                          child: const Text('OK'),
                          onPressed: () => Navigator.of(localContext).pop(),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: const Text('Select Database'),
            ),
          ],
        ),
        isActive: _permissionGranted, // Only active if permission is granted
      ),
      Step(
        title: const Text('Data Overview'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Here is the data from the selected database:'),
            const SizedBox(height: 10),
            if (_dataFromDatabase.isEmpty)
              const Text('No data loaded.')
            else
              ..._dataFromDatabase.map((data) => ListTile(
                    title: Text(
                        data.toString()), // Customize this display as needed
                  )),
          ],
        ),
        isActive: _dbReplaced &&
            _dataLoadedCorrectly, // Only active if db replaced and data loaded correctly
      ),
    ];
  }

  void _onStepContinue() {
    if (_currentStep == 0 && !_permissionGranted) {
      return;
    }

    if (_currentStep == 1 && (!_dbReplaced || !_dataLoadedCorrectly)) {
      return;
    }

    if (_currentStep < _getSteps().length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      // All steps completed, navigate to MainScreen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setup')),
      body: Stepper(
        currentStep: _currentStep,
        steps: _getSteps(),
        onStepContinue: _onStepContinue,
        onStepCancel: _onStepCancel,
      ),
    );
  }
}

//app reset
class ResetIconButton extends StatelessWidget {
  const ResetIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.refresh),
      tooltip: 'Reset App',
      onPressed: () async {
        // Show confirmation dialog
        bool? confirmReset = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Reset App'),
              content: const Text(
                  'Are you sure you want to reset the app? This will delete all data.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: const Text('Reset'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        );

        // If confirmed, delete the database and exit the app
        if (confirmReset == true) {
          await DatabaseHelper.deleteDatabase();
          // Exit the app
          SystemNavigator.pop(); // This will exit the app
        }
      },
    );
  }
}
