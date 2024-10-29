import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:power_diyala/settings/theme_control.dart';

class EarthInputFields extends StatefulWidget {
  final Map<String, dynamic>? selectedSiteData;
  final List<TextEditingController> groundControllers;
  final List<TextEditingController> externalLoadControllers;
  final List<TextEditingController> batteryTestControllers;
  final bool isBatteryTestEnabled;
  final ValueChanged<bool> onBatteryTestEnabledChanged;
  final bool isEarthEnabled;

  const EarthInputFields({
    super.key,
    this.selectedSiteData,
    required this.groundControllers,
    required this.externalLoadControllers,
    required this.batteryTestControllers,
    required this.isBatteryTestEnabled,
    required this.onBatteryTestEnabledChanged,
    required this.isEarthEnabled,
  });

  @override
  EarthInputFieldsState createState() => EarthInputFieldsState();
}

class EarthInputFieldsState extends State<EarthInputFields> {
  final Logger logger = Logger(printer: PrettyPrinter());

  // Text controllers for different sections
  final TextEditingController _genfController = TextEditingController();
  final TextEditingController _telController = TextEditingController();
  final TextEditingController _legsController = TextEditingController();
  final TextEditingController _lightController = TextEditingController();
  final TextEditingController _ownerController = TextEditingController();
  final TextEditingController _neighbourController = TextEditingController();
  final TextEditingController _partyController = TextEditingController();
  final TextEditingController _startDCController = TextEditingController();
  final TextEditingController _endDCController = TextEditingController();
  final TextEditingController _fireController = TextEditingController();

  // Toggles for enabling/disabling sections
  bool isBatteryTestEnabled = false;
  bool isExternalLoadEnabled = false;
  bool isEarthEnabled = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    // Add controllers to respective lists
    widget.groundControllers.addAll([
      _genfController,
      _telController,
      _legsController,
      _lightController,
    ]);

    widget.externalLoadControllers.addAll([
      _ownerController,
      _neighbourController,
      _partyController,
    ]);

    widget.batteryTestControllers.addAll([
      _startDCController,
      _endDCController,
      _fireController,
    ]);
  }

  Widget _buildEarthReadingsSection() {
    return Container(
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
                  controller: widget.groundControllers[0],
                  decoration: InputDecoration(
                    labelText: 'Gen & Tank',
                    labelStyle: TextStyle(
                        color: ThemeControl.errorColor.withOpacity(0.8),
                        fontSize: 12),
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
                        width: 2.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1.5),
                    ),
                  ),
                  enabled: widget.isEarthEnabled, // Control enabled state
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: widget.groundControllers[1],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Telecom',
                    labelStyle: TextStyle(
                        color: ThemeControl.errorColor.withOpacity(0.8),
                        fontSize: 12),
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
                        width: 2.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1.5),
                    ),
                  ),
                  enabled: widget.isEarthEnabled,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.groundControllers[2],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Lightening',
                    labelStyle: TextStyle(
                        color: ThemeControl.errorColor.withOpacity(0.8),
                        fontSize: 12),
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
                        width: 2.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1.5),
                    ),
                  ),
                  enabled: widget.isEarthEnabled, // Control enabled state
                ),
              ),
              SizedBox(width: 8), // Add some space between the two text fields
              Expanded(
                child: TextField(
                  controller: widget.groundControllers[3],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Tower Legs',
                    labelStyle: TextStyle(
                        color: ThemeControl.errorColor.withOpacity(0.8),
                        fontSize: 12),
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
                        width: 2.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1.5),
                    ),
                  ),
                  enabled: widget.isEarthEnabled, // Control enabled state
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExternalLoadSection() {
    return Container(
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
                  controller: widget.externalLoadControllers[0],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Owner',
                    labelStyle: TextStyle(
                        color: ThemeControl.errorColor.withOpacity(0.8),
                        fontSize: 12),
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
                  controller: widget.externalLoadControllers[1],
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
                            color: Theme.of(context).colorScheme.tertiary,
                            width: 2.0)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 1.5)),
                  ),
                  enabled: isExternalLoadEnabled, // Control enabled state
                ),
              ),
              SizedBox(width: 3),
              Expanded(
                child: TextField(
                  controller: widget.externalLoadControllers[2],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: '3rd Party',
                    labelStyle: TextStyle(
                        color: ThemeControl.errorColor.withOpacity(0.8),
                        fontSize: 12),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide:
                            BorderSide(color: ThemeControl().secondaryColor)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.tertiary,
                            width: 2.0)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 1.5)),
                  ),
                  enabled: isExternalLoadEnabled, // Control enabled state
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBatteryTestSection() {
    return Container(
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
                value: widget.isBatteryTestEnabled,
                onChanged: (bool value) {
                  widget.onBatteryTestEnabledChanged(value);
                },
              ),
            ],
          ),
          SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.batteryTestControllers[0],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Start DC',
                    labelStyle: TextStyle(
                        color: ThemeControl.errorColor.withOpacity(0.8),
                        fontSize: 12),
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
                        width: 2.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1.5),
                    ),
                  ),
                  enabled: widget.isBatteryTestEnabled, // Control enabled state
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: widget.batteryTestControllers[1],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'End DC',
                    labelStyle: TextStyle(
                        color: ThemeControl.errorColor.withOpacity(0.8),
                        fontSize: 10),
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
                        width: 2.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1.5),
                    ),
                  ),
                  enabled: widget.isBatteryTestEnabled, // Control enabled state
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.batteryTestControllers[2],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Fire Extinguisher Expire Date',
                    labelStyle: TextStyle(
                        color: ThemeControl.errorColor.withOpacity(0.8),
                        fontSize: 12),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedSiteData == null) {
      return Container(); // Return empty if null
    }

    return Column(
      children: [
        _buildEarthReadingsSection(),
        SizedBox(height: 8),
        _buildExternalLoadSection(),
        SizedBox(height: 8),
        _buildBatteryTestSection(),
      ],
    );
  }
}
