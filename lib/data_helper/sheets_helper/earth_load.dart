import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:power_diyala/settings/theme_control.dart';

class EarthInputFields extends StatefulWidget {
  final Map<String, dynamic>? selectedSiteData;

  const EarthInputFields({super.key, this.selectedSiteData});

  @override
  EarthInputFieldsState createState() => EarthInputFieldsState();
}

class EarthInputFieldsState extends State<EarthInputFields> {
  final Logger logger =
      kDebugMode ? Logger() : Logger(printer: PrettyPrinter());

  late TextEditingController _genfController;
  late TextEditingController _telController;
  late TextEditingController _legsController;
  late TextEditingController _lightController;
  late TextEditingController _ownerController;
  late TextEditingController _neighbourController;
  late TextEditingController _partyController;
  late TextEditingController _startDCController;
  late TextEditingController _endDCController;
  late TextEditingController _fireController;
  bool isBatteryTestEnabled = false; // Default to disabled
  bool isExternalLoadEnabled =
      false; // Track the toggle state for External Load
  bool isEarthEnabled = false; // Track the toggle state

  @override
  void initState() {
    super.initState();
    _genfController = TextEditingController();
    _telController = TextEditingController();
    _legsController = TextEditingController();
    _lightController = TextEditingController();
    _ownerController = TextEditingController();
    _neighbourController = TextEditingController();
    _partyController = TextEditingController();
    _startDCController = TextEditingController();
    _endDCController = TextEditingController();
    _fireController = TextEditingController();
    // Set initial values from selectedSiteData
    if (widget.selectedSiteData != null) {
      setState(() {
        _ownerController.text = widget.selectedSiteData!['owner'] ?? '';
        _neighbourController.text = widget.selectedSiteData!['neighbour'] ?? '';
        _partyController.text = widget.selectedSiteData!['3rdparty'] ?? '';
        isEarthEnabled = (widget.selectedSiteData!['earth'] ==
            'Yes'); // Initialize the toggle based on existing data
      });
    }
  }

  @override
  void dispose() {
    _genfController.dispose();
    _telController.dispose();
    _legsController.dispose();
    _lightController.dispose();
    _ownerController.dispose();
    _neighbourController.dispose();
    _partyController.dispose();
    _fireController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedSiteData == null) {
      return Container(); // Return empty if null
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            children: [
              Text(
                'Earth Readings',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      controller: _genfController,
                      decoration: InputDecoration(
                        labelText: 'Gen & Tank',
                        labelStyle: TextStyle(
                            color: ThemeControl.errorColor.withOpacity(0.8),
                            fontSize: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: ThemeControl().secondaryColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: ThemeControl().accentColor,
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 1.5),
                        ),
                      ),
                      enabled: isEarthEnabled, // Control enabled state
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _telController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Telecom',
                        labelStyle: TextStyle(
                            color: ThemeControl.errorColor.withOpacity(0.8),
                            fontSize: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: ThemeControl().secondaryColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: ThemeControl().accentColor,
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 1.5),
                        ),
                      ),
                      enabled: isEarthEnabled, // Control enabled state
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16), // Spacing between rows
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _legsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Lightening',
                        labelStyle: TextStyle(
                            color: ThemeControl.errorColor.withOpacity(0.8),
                            fontSize: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: ThemeControl().secondaryColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: ThemeControl().accentColor,
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 1.5),
                        ),
                      ),
                      enabled: isEarthEnabled, // Control enabled state
                    ),
                  ),
                  SizedBox(
                      width: 8), // Add some space between the two text fields
                  Expanded(
                    child: TextField(
                      controller: _lightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Tower Legs',
                        labelStyle: TextStyle(
                            color: ThemeControl.errorColor.withOpacity(0.8),
                            fontSize: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: ThemeControl().secondaryColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: ThemeControl().accentColor,
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 1.5),
                        ),
                      ),
                      enabled: isEarthEnabled, // Control enabled state
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'External Load',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Switch(
                    value: isExternalLoadEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        isExternalLoadEnabled = value;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ownerController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Owner',
                        labelStyle: TextStyle(
                            color: ThemeControl.errorColor.withOpacity(0.8),
                            fontSize: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: ThemeControl().secondaryColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: ThemeControl().accentColor,
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 1.5),
                        ),
                      ),
                      enabled: isExternalLoadEnabled, // Control enabled state
                    ),
                  ),
                  SizedBox(width: 3),
                  Expanded(
                    child: TextField(
                      controller: _neighbourController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Neighbour',
                        labelStyle: TextStyle(
                            color: ThemeControl.errorColor.withOpacity(0.8),
                            fontSize: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide:
                              BorderSide(color: ThemeControl().secondaryColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                                color: ThemeControl().accentColor, width: 2.0)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: const BorderSide(
                                color: Colors.grey, width: 1.5)),
                      ),
                      enabled: isExternalLoadEnabled, // Control enabled state
                    ),
                  ),
                  SizedBox(width: 3),
                  Expanded(
                    child: TextField(
                      controller: _partyController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '3rd Party',
                        labelStyle: TextStyle(
                            color: ThemeControl.errorColor.withOpacity(0.8),
                            fontSize: 12),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                                color: ThemeControl().secondaryColor)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                                color: ThemeControl().accentColor, width: 2.0)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: const BorderSide(
                                color: Colors.grey, width: 1.5)),
                      ),
                      enabled: isExternalLoadEnabled, // Control enabled state
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Battery Test',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Switch(
                    value: isBatteryTestEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        isBatteryTestEnabled = value;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _startDCController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Start DC',
                        labelStyle: TextStyle(
                            color: ThemeControl.errorColor.withOpacity(0.8),
                            fontSize: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: ThemeControl().secondaryColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: ThemeControl().accentColor,
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 1.5),
                        ),
                      ),
                      enabled: isBatteryTestEnabled, // Control enabled state
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _endDCController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'End DC',
                        labelStyle: TextStyle(
                            color: ThemeControl.errorColor.withOpacity(0.8),
                            fontSize: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: ThemeControl().secondaryColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: ThemeControl().accentColor,
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 1.5),
                        ),
                      ),
                      enabled: isBatteryTestEnabled, // Control enabled state
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _fireController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Fire Extinguisher Expire Date',
                        labelStyle: TextStyle(
                            color: ThemeControl.errorColor.withOpacity(0.8),
                            fontSize: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: ThemeControl().secondaryColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: ThemeControl().accentColor,
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}
