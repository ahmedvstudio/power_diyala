import 'dart:math';
import 'package:flutter/material.dart';
import 'package:power_diyala/settings/theme_control.dart';

class GenInput {
  final int? sheetNumber; // Make sheetNumber nullable
  GenInput(this.sheetNumber);

  List<Widget> genInputs(
      BuildContext context, List<TextEditingController> controllers) {
    List<Widget> inputFields = [];

    // Check for null or invalid sheetNumber
    if (sheetNumber == null) {
      return inputFields; // Return empty list if sheetNumber is null
    }
    switch (sheetNumber) {
      case 1:
      case 2:
      case 3:
      case 4:
      case 5:
      case 6:
      case 7:
      case 8:
      case 9:
      case 16:
        // Generate two inputs for sheets 1-9 and 16
        for (int i = 0; i < 2; i++) {
          inputFields.add(TextField(
            controller: controllers[i],
            decoration: InputDecoration(
              labelText: 'G${i + 1}',
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
                    color: Theme.of(context).colorScheme.tertiary, width: 2.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: Colors.grey, width: 1.5),
              ),
              filled: true,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
            ),
            keyboardType: TextInputType.number,
          ));
        }
        break;
      case 10:
      case 11:
      case 12:
      case 13:
      case 14:
        // Generate one input for sheets 10-14
        inputFields.add(TextField(
          controller: controllers[0],
          decoration: InputDecoration(
            labelText: 'G1',
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
        ));
        break;
      case 15:
        // Generate none for sheet 15
        break;
      default:
        // Handle any unexpected sheet numbers if necessary
        break;
    }

    return inputFields;
  }
}

//==============================volt load=====================
class GenVLInput extends StatefulWidget {
  final int? sheetNumber;
  final List<TextEditingController> controllers; // Expose external controllers
  final List<bool> gensSwitches; // Expose external switch states
  final Function(int index, bool value)
      onSwitchChanged; // Callback for switch changes

  const GenVLInput({
    super.key,
    required this.sheetNumber,
    required this.controllers,
    required this.gensSwitches,
    required this.onSwitchChanged,
  });

  @override
  GenVLInputState createState() => GenVLInputState();
}

class GenVLInputState extends State<GenVLInput> {
  @override
  Widget build(BuildContext context) {
    return genVLInputs(context, widget.controllers);
  }

  Widget genVLInputs(
      BuildContext context, List<TextEditingController> controllers) {
    List<Widget> inputFields = [];

    if (widget.sheetNumber == null) {
      return Container();
    }

    bool g1Enabled = widget.gensSwitches[0]; // Check if G1 is enabled
    bool g2Enabled = widget.gensSwitches[1]; // Check if G2 is enabled

    switch (widget.sheetNumber) {
      case 1:
      case 2:
      case 3:
      case 4:
      case 5:
      case 6:
      case 7:
      case 8:
      case 9:
      case 16:
        inputFields.addAll(
            _generateInputs(context, controllers, 'PH-N', 0, 3, g1Enabled));
        inputFields.addAll(
            _generateInputs(context, controllers, 'PH-L', 3, 3, g1Enabled));
        inputFields.addAll(
            _generateInputs(context, controllers, 'Load', 6, 3, g1Enabled));
        inputFields.add(_createTextField(
            context, controllers[9], 'Battery Voltage', g1Enabled));

        inputFields.addAll(
            _generateInputs(context, controllers, 'PH-N', 10, 3, g2Enabled));
        inputFields.addAll(
            _generateInputs(context, controllers, 'PH-L', 13, 3, g2Enabled));
        inputFields.addAll(
            _generateInputs(context, controllers, 'Load', 6, 3, g2Enabled));
        inputFields.add(_createTextField(
            context, controllers[19], 'Battery Voltage', g2Enabled));
        break;

      case 10:
      case 11:
      case 12:
      case 13:
      case 14:
        inputFields.addAll(
            _generateInputs(context, controllers, 'PH-N', 0, 3, g1Enabled));
        inputFields.addAll(
            _generateInputs(context, controllers, 'PH-L', 3, 3, g1Enabled));
        inputFields.addAll(
            _generateInputs(context, controllers, 'Load', 6, 3, g1Enabled));
        inputFields.add(_createTextField(
            context, controllers[9], 'Battery Voltage', g1Enabled));
        break;

      case 15:
        return Container();
      default:
        break;
    }

    return _buildBorderedContainer(inputFields);
  }

  double generateRandomVoltage(double min, double max) {
    final random = Random();
    return (min + random.nextDouble() * (max - min));
  }

  List<Widget> _generateInputs(
      BuildContext context,
      List<TextEditingController> controllers,
      String prefix,
      int startIndex,
      int count,
      bool enabled) {
    List<Widget> inputs = [];

    for (int i = startIndex; i < startIndex + count; i++) {
      String labelText = '$prefix ${i - startIndex + 1}';
      inputs.add(_createTextField(context, controllers[i], labelText, enabled));
    }
    return inputs;
  }

  Widget _createTextField(BuildContext context,
      TextEditingController controller, String labelText, bool enabled) {
    return TextField(
      controller: controller,
      enabled: enabled, // Set enabled state
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
            color: Theme.of(context).colorScheme.error.withOpacity(0.8),
            fontSize: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide:
              BorderSide(color: Theme.of(context).colorScheme.secondary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.tertiary, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.grey, width: 1.5),
        ),
        filled: true,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
      ),
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildBorderedContainer(List<Widget> inputFields) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('G1', style: TextStyle(fontSize: 18)),
              ..._buildG1Switch(),
            ],
          ),
          _groupInRows(inputFields.sublist(0,
              inputFields.length > 10 ? 10 : inputFields.length)), // G1 Inputs

          if (widget.sheetNumber == 1 ||
              widget.sheetNumber == 2 ||
              widget.sheetNumber == 3 ||
              widget.sheetNumber == 4 ||
              widget.sheetNumber == 5 ||
              widget.sheetNumber == 6 ||
              widget.sheetNumber == 7 ||
              widget.sheetNumber == 8 ||
              widget.sheetNumber == 9 ||
              widget.sheetNumber == 16) ...[
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('G2', style: TextStyle(fontSize: 18)),
                ..._buildG2Switch(),
              ],
            ),
            _groupInRows(inputFields.sublist(10)), // G2 Inputs
          ],

          // Add switches for gens
          SizedBox(height: 16), // Space for switches
        ],
      ),
    );
  }

  List<Widget> _buildG1Switch() {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Switch(
            value: widget.gensSwitches[0], // Assuming first switch is for G1
            onChanged: (value) {
              setState(() {
                widget.onSwitchChanged(
                    0, value); // Notify parent on change for G1
                if (!value) {
                  // Generate random values when switch is off
                  for (int i = 0; i < 3; i++) {
                    widget.controllers[i].text = (220 + Random().nextInt(11))
                        .toString(); // Random between 220-230 for PH-N
                    for (int i = 3; i < 6; i++) {
                      widget.controllers[i].text = (385 + Random().nextInt(16))
                          .toString(); // Random between 385-400 for PH-L
                    }
                  }
                  widget.controllers[9].text = generateRandomVoltage(13.4, 14.0)
                      .toStringAsFixed(1); // Battery Voltage
                }
              });
            },
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildG2Switch() {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Switch(
            value: widget.gensSwitches[1],
            onChanged: (value) {
              setState(() {
                widget.onSwitchChanged(1, value);
                if (!value) {
                  for (int i = 10; i < 13; i++) {
                    widget.controllers[i].text =
                        (220 + Random().nextInt(11)).toString();
                    for (int i = 13; i < 16; i++) {
                      widget.controllers[i].text =
                          (385 + Random().nextInt(16)).toString();
                    }
                  }
                  widget.controllers[19].text =
                      generateRandomVoltage(13.4, 14.0).toStringAsFixed(1);
                }
              });
            },
          ),
        ],
      ),
    ];
  }

  Widget _groupInRows(List<Widget> inputFields) {
    List<Widget> rows = [];

    for (int i = 0; i < inputFields.length; i += 3) {
      List<Widget> rowItems = [];

      for (int j = 0; j < 3; j++) {
        int index = i + j;
        if (index < inputFields.length) {
          rowItems.add(
            Expanded(
              child: Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4),
                child: inputFields[index],
              ),
            ),
          );
        }
      }

      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: rowItems,
      ));
    }

    return Column(children: rows);
  }
}
