import 'package:flutter/material.dart';
import 'package:power_diyala/settings/theme_control.dart';

class CpInput {
  final String? cpValue;

  CpInput(this.cpValue);

  List<Widget> cpInputs(
      TextEditingController cpController, TextEditingController kwhController) {
    List<Widget> cpFields = [];
    // Check for null or empty cpValue
    if (cpValue == null || cpValue!.isEmpty) {
      return cpFields;
    }

    if (cpValue!.toLowerCase() == 'yes') {
      // Handle case sensitivity
      cpFields.add(TextField(
        controller: cpController,
        decoration: InputDecoration(
          labelText: 'CP',
          labelStyle:
              TextStyle(color: ThemeControl.errorColor.withOpacity(0.8)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: ThemeControl().secondaryColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide:
                BorderSide(color: ThemeControl().accentColor, width: 2.0),
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
      ));

      cpFields.add(TextField(
        controller: kwhController,
        decoration: InputDecoration(
          labelText: 'Kwh',
          labelStyle:
              TextStyle(color: ThemeControl.errorColor.withOpacity(0.8)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: ThemeControl().secondaryColor),
          ),
          filled: true,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide:
                BorderSide(color: ThemeControl().accentColor, width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.grey, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        ),
        keyboardType: TextInputType.number,
      ));
    }
    // If cpValue is 'no', generate no inputs.

    return cpFields;
  }

  List<Widget> cpPhaseInputs(String? phase) {
    List<Widget> phaseFields = [];
    if (phase == null || phase.isEmpty) {
      return phaseFields;
    }

    if (phase.toLowerCase() == 'three phase') {
      // Create a row for V inputs
      List<Widget> vInputs = [];
      List<Widget> loadInputs = [];

      for (int i = 1; i <= 3; i++) {
        vInputs.add(Expanded(
          child: Padding(
            padding: const EdgeInsets.all(1.0),
            child: TextField(
              controller: TextEditingController(),
              decoration: InputDecoration(
                labelText: 'V$i',
                labelStyle: TextStyle(
                    color: ThemeControl.errorColor.withOpacity(0.8),
                    fontSize: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: ThemeControl().secondaryColor),
                ),
                filled: true,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide:
                      BorderSide(color: ThemeControl().accentColor, width: 2.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Colors.grey, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 12.0),
              ),
              keyboardType: TextInputType.number,
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
                  borderSide: BorderSide(color: ThemeControl().secondaryColor),
                ),
                filled: true,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide:
                      BorderSide(color: ThemeControl().accentColor, width: 2.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Colors.grey, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 12.0),
              ),
              keyboardType: TextInputType.number,
            ),
          ),
        ));
      }

      // Add rows to the phaseFields
      phaseFields.add(Column(
        children: [
          Row(children: vInputs), // Row for V inputs
          SizedBox(height: 8), // Space between rows
          Row(children: loadInputs), // Row for Load inputs
        ],
      ));
    } else if (phase.toLowerCase() == 'single phase') {
      phaseFields.add(Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: TextEditingController(),
                  decoration: InputDecoration(
                    labelText: 'V1',
                    labelStyle: TextStyle(
                        color: ThemeControl.errorColor.withOpacity(0.8),
                        fontSize: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide:
                          BorderSide(color: ThemeControl().secondaryColor),
                    ),
                    filled: true,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                          color: ThemeControl().accentColor, width: 2.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 12.0),
                  ),
                  keyboardType: TextInputType.number,
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
                      borderSide:
                          BorderSide(color: ThemeControl().secondaryColor),
                    ),
                    filled: true,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                          color: ThemeControl().accentColor, width: 2.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 12.0),
                  ),
                  keyboardType: TextInputType.number,
                ),
              )
            ],
          ),
        ],
      ));
    }

    // Wrap the inputs in a bordered container with a label
    return [
      Container(
        padding: const EdgeInsets.all(16.0), // Padding around the contents
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey), // Border color
          borderRadius: BorderRadius.circular(8.0), // Rounded corners
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Main', // Label for the inputs
              style: TextStyle(fontSize: 18), // Title style
            ),
            SizedBox(height: 8), // Space between title and input fields
            ...phaseFields, // Add the generated phase input fields here
          ],
        ),
      ),
    ]; // Return the wrapped phase inputs
  }
}
