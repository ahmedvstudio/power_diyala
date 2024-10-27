import 'dart:math';
import 'package:flutter/material.dart';
import 'package:power_diyala/settings/theme_control.dart';

class CpInput extends StatefulWidget {
  final String? cpValue;
  final TextEditingController cpController;
  final TextEditingController kwhController;

  const CpInput({
    super.key,
    required this.cpValue,
    required this.cpController,
    required this.kwhController,
  });

  @override
  CpInputState createState() => CpInputState();
}

class CpInputState extends State<CpInput> {
  @override
  Widget build(BuildContext context) {
    List<Widget> cpFields = [];
    if (widget.cpValue != null && widget.cpValue!.toLowerCase() == 'yes') {
      cpFields.add(
        Expanded(
          child: TextField(
            controller: widget.cpController,
            decoration: InputDecoration(
              labelText: 'CP',
              labelStyle:
                  TextStyle(color: ThemeControl.errorColor.withOpacity(0.8)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.tertiary, width: 2.0),
              ),
              filled: true,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: Colors.grey, width: 1.5),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
            ),
            keyboardType: TextInputType.number,
          ),
        ),
      );
      cpFields.add(SizedBox(width: 4));
      cpFields.add(
        Expanded(
          child: TextField(
            controller: widget.kwhController,
            decoration: InputDecoration(
              labelText: 'Kwh',
              labelStyle:
                  TextStyle(color: ThemeControl.errorColor.withOpacity(0.8)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              filled: true,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.tertiary, width: 2.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: Colors.grey, width: 1.5),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
            ),
            keyboardType: TextInputType.number,
          ),
        ),
      );
    }
    return Row(
      children: cpFields,
    );
  }
}

//====================================

class CpPhaseInputWidget extends StatefulWidget {
  final String? cpValue;
  final String? phase;

  const CpPhaseInputWidget(
      {super.key, required this.cpValue, required this.phase});

  @override
  CpPhaseInputWidgetState createState() => CpPhaseInputWidgetState();
}

class CpPhaseInputWidgetState extends State<CpPhaseInputWidget> {
  final Random _random = Random();
  bool isCpEnabled = false;

  int _generateRandomVoltage() {
    // Function to generate a random number between 209 and 220
    return _random.nextInt(12) + 209; // 0 to 11 + 209 gives 209 to 220
  }

  @override
  Widget build(BuildContext context) {
    // If the cp value is not "yes", return an empty Container
    if (widget.cpValue == null || widget.cpValue!.toLowerCase() != 'yes') {
      return Container();
    }

    // Create the phase input fields based on the phase type
    List<Widget> phaseFields = [];
    if (widget.phase != null && widget.phase!.isNotEmpty) {
      if (widget.phase!.toLowerCase() == 'three phase') {
        phaseFields = _buildThreePhaseInputs();
      } else if (widget.phase!.toLowerCase() == 'single phase') {
        phaseFields = _buildSinglePhaseInputs();
      }
    }

    return Container(
      padding: const EdgeInsets.all(16.0), // Padding around the contents
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey), // Border color
        borderRadius: BorderRadius.circular(8.0), // Rounded corners
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Main', // Label for the inputs
                style: TextStyle(fontSize: 18), // Title style
              ),
              Switch(
                value: isCpEnabled,
                onChanged: (bool value) {
                  setState(() {
                    isCpEnabled = value;
                  });
                },
              ),
            ],
          ),

          SizedBox(height: 8), // Space between title and input fields
          ...phaseFields, // Add the generated phase input fields here
        ],
      ),
    );
  }

  List<Widget> _buildThreePhaseInputs() {
    List<Widget> vInputs = [];
    List<Widget> loadInputs = [];

    for (int i = 1; i <= 3; i++) {
      vInputs.add(Expanded(
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: TextField(
            controller: TextEditingController(
                text: _generateRandomVoltage().toString()), // Random value
            decoration: InputDecoration(
              labelText: 'V$i',
              labelStyle: TextStyle(
                  color: ThemeControl.errorColor.withOpacity(0.8),
                  fontSize: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.secondary),
              ),
              filled: true,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.tertiary, width: 2.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: Colors.grey, width: 1.5),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
            ),
            keyboardType: TextInputType.number,
            enabled: isCpEnabled,
          ),
        ),
      ));

      loadInputs.add(Expanded(
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: TextField(
            controller: TextEditingController(),
            decoration: InputDecoration(
              labelText: 'Load $i',
              labelStyle: TextStyle(
                  color: ThemeControl.errorColor.withOpacity(0.8),
                  fontSize: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              filled: true,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.tertiary, width: 2.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: Colors.grey, width: 1.5),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
            ),
            keyboardType: TextInputType.number,
            enabled: isCpEnabled,
          ),
        ),
      ));
    }

    return [
      Row(children: vInputs), // Row for V inputs
      SizedBox(height: 8), // Space between rows
      Row(children: loadInputs), // Row for Load inputs
    ];
  }

  List<Widget> _buildSinglePhaseInputs() {
    return [
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: TextEditingController(
                  text: _generateRandomVoltage().toString()), // Random value
              decoration: InputDecoration(
                labelText: 'V1',
                labelStyle: TextStyle(
                    color: ThemeControl.errorColor.withOpacity(0.8),
                    fontSize: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.secondary),
                ),
                filled: true,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.tertiary,
                      width: 2.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Colors.grey, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 12.0),
              ),
              keyboardType: TextInputType.number, enabled: isCpEnabled,
            ),
          )
        ],
      ),
      SizedBox(height: 8), // Space between Phase and Load
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: TextEditingController(),
              decoration: InputDecoration(
                labelText: 'Load 1',
                labelStyle: TextStyle(
                    color: ThemeControl.errorColor.withOpacity(0.8),
                    fontSize: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.secondary),
                ),
                filled: true,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.tertiary,
                      width: 2.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Colors.grey, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 12.0),
              ),
              keyboardType: TextInputType.number,
              enabled: isCpEnabled,
            ),
          )
        ],
      ),
    ];
  }
}
