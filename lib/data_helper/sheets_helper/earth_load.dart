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
  final ValueChanged<bool> onEarthEnabledChanged;

  const EarthInputFields({
    super.key,
    this.selectedSiteData,
    required this.groundControllers,
    required this.externalLoadControllers,
    required this.batteryTestControllers,
    required this.isBatteryTestEnabled,
    required this.onBatteryTestEnabledChanged,
    required this.isEarthEnabled,
    required this.onEarthEnabledChanged,
  });

  @override
  EarthInputFieldsState createState() => EarthInputFieldsState();
}

class EarthInputFieldsState extends State<EarthInputFields> {
  final Logger logger = Logger(printer: PrettyPrinter());

  final TextEditingController _genfController = TextEditingController();
  final TextEditingController _telController = TextEditingController();
  final TextEditingController _legsController = TextEditingController();
  final TextEditingController _lightController = TextEditingController();
  final TextEditingController _ownerController = TextEditingController();
  final TextEditingController _neighbourController = TextEditingController();
  final TextEditingController _partyController = TextEditingController();
  final TextEditingController _partyController2 = TextEditingController();
  final TextEditingController _startDCController = TextEditingController();
  final TextEditingController _endDCController = TextEditingController();
  final TextEditingController _fireController = TextEditingController();

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
      _partyController2,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Earth Readings',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onDoubleTap: () {
                  widget.onEarthEnabledChanged(!widget.isEarthEnabled);
                },
                child: Switch(
                  value: widget.isEarthEnabled,
                  onChanged: (bool value) {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  controller: widget.groundControllers[0],
                  decoration: InputDecoration(
                    labelText: 'Gen & Tank',
                    labelStyle: TextStyle(
                        color: ThemeControl.errorColor.withValues(alpha: 0.8),
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
                  validator: widget.isEarthEnabled
                      ? (value) {
                          if (value == null || value.isEmpty) {
                            return '*';
                          }
                          return null;
                        }
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: widget.groundControllers[1],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Telecom',
                    labelStyle: TextStyle(
                        color: ThemeControl.errorColor.withValues(alpha: 0.8),
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
                  validator: widget.isEarthEnabled
                      ? (value) {
                          if (value == null || value.isEmpty) {
                            return '*';
                          }
                          return null;
                        }
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: widget.groundControllers[2],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Lightening',
                    labelStyle: TextStyle(
                        color: ThemeControl.errorColor.withValues(alpha: 0.8),
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
                  validator: widget.isEarthEnabled
                      ? (value) {
                          if (value == null || value.isEmpty) {
                            return '*';
                          }
                          return null;
                        }
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: widget.groundControllers[3],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Tower Legs',
                    labelStyle: TextStyle(
                        color: ThemeControl.errorColor.withValues(alpha: 0.8),
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
                  validator: widget.isEarthEnabled
                      ? (value) {
                          if (value == null || value.isEmpty) {
                            return '*';
                          }
                          return null;
                        }
                      : null,
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
              const Text(
                'External Load',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onDoubleTap: () {
                  setState(() {
                    isExternalLoadEnabled = !isExternalLoadEnabled;
                  });
                },
                child: Switch(
                  value: isExternalLoadEnabled,
                  onChanged: (bool value) {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.externalLoadControllers[0],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Owner',
                    labelStyle: TextStyle(
                        color: ThemeControl.errorColor.withValues(alpha: 0.8),
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
                  enabled: isExternalLoadEnabled,
                ),
              ),
              const SizedBox(width: 3),
              Expanded(
                child: TextField(
                  controller: widget.externalLoadControllers[1],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Neighbour',
                    labelStyle: TextStyle(
                        color: ThemeControl.errorColor.withValues(alpha: 0.8),
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
                  enabled: isExternalLoadEnabled,
                ),
              ),
              const SizedBox(width: 3),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.externalLoadControllers[2],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: '3rd Party',
                    labelStyle: TextStyle(
                        color: ThemeControl.errorColor.withValues(alpha: 0.8),
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
                  enabled: isExternalLoadEnabled,
                ),
              ),
              const SizedBox(width: 3),
              Expanded(
                child: TextField(
                  controller: widget.externalLoadControllers[3],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: '3rd Party',
                    labelStyle: TextStyle(
                        color: ThemeControl.errorColor.withValues(alpha: 0.8),
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
                  enabled: isExternalLoadEnabled,
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
              const Text(
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
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: widget.batteryTestControllers[0],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Start DC',
                    labelStyle: TextStyle(
                        color: ThemeControl.errorColor.withValues(alpha: 0.8),
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
                  enabled: widget.isBatteryTestEnabled,
                  validator: widget.isBatteryTestEnabled
                      ? (value) {
                          if (value == null || value.isEmpty) {
                            return '*';
                          }
                          return null;
                        }
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: widget.batteryTestControllers[1],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'End DC',
                    labelStyle: TextStyle(
                        color: ThemeControl.errorColor.withValues(alpha: 0.8),
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
                  enabled: widget.isBatteryTestEnabled,
                  validator: widget.isBatteryTestEnabled
                      ? (value) {
                          if (value == null || value.isEmpty) {
                            return '*';
                          }
                          return null;
                        }
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.batteryTestControllers[2],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Fire Extinguisher Expire Date',
                    labelStyle: TextStyle(
                        color: ThemeControl.errorColor.withValues(alpha: 0.8),
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
      return Container();
    }

    return Column(
      children: [
        _buildEarthReadingsSection(),
        const SizedBox(height: 8),
        _buildExternalLoadSection(),
        const SizedBox(height: 8),
        _buildBatteryTestSection(),
      ],
    );
  }
}
