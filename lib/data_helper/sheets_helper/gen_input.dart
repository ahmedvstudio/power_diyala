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

class GenVLInput {
  final int? sheetNumber;
  GenVLInput(this.sheetNumber);

  Widget genVLInputs(
      BuildContext context, List<TextEditingController> controllers) {
    List<Widget> inputFields = [];

    if (sheetNumber == null) {
      return Container();
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
        inputFields.addAll(_generateInputs(context, controllers, 'PH-N', 0, 3));
        inputFields.addAll(_generateInputs(context, controllers, 'PH-L', 3, 3));
        inputFields.addAll(_generateInputs(context, controllers, 'Load', 6, 3));
        inputFields.add(_createTextField(
            context, controllers[18], 'Battery Voltage')); // G1 Battery Voltage

        inputFields.addAll(_generateInputs(context, controllers, 'PH-N', 9, 3));
        inputFields
            .addAll(_generateInputs(context, controllers, 'PH-L', 12, 3));
        inputFields
            .addAll(_generateInputs(context, controllers, 'Load', 15, 3));
        inputFields.add(_createTextField(
            context, controllers[19], 'Battery Voltage')); // G2 Battery Voltage
        break;

      case 10:
      case 11:
      case 12:
      case 13:
      case 14:
        inputFields.addAll(_generateInputs(context, controllers, 'PH-N', 0, 3));
        inputFields.addAll(_generateInputs(context, controllers, 'PH-L', 3, 3));
        inputFields.addAll(_generateInputs(context, controllers, 'Load', 6, 3));
        inputFields.add(_createTextField(
            context, controllers[9], 'Battery Voltage')); // Battery Voltage
        break;

      case 15:
        return Container();
      default:
        break;
    }

    return _buildBorderedContainer(inputFields);
  }

  List<Widget> _generateInputs(
      BuildContext context,
      List<TextEditingController> controllers,
      String prefix,
      int startIndex,
      int count) {
    List<Widget> inputs = [];
    for (int i = startIndex; i < startIndex + count; i++) {
      inputs.add(_createTextField(
          context, controllers[i], '$prefix ${i - startIndex + 1}'));
    }
    return inputs;
  }

  Widget _createTextField(BuildContext context,
      TextEditingController controller, String labelText) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
            color: ThemeControl.errorColor.withOpacity(0.8), fontSize: 12),
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
          Text(
            'G1',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 8),
          _groupInRows(inputFields.sublist(0,
              inputFields.length > 10 ? 10 : inputFields.length)), // G1 Inputs

          if (sheetNumber == 1 ||
              sheetNumber == 2 ||
              sheetNumber == 3 ||
              sheetNumber == 4 ||
              sheetNumber == 5 ||
              sheetNumber == 6 ||
              sheetNumber == 7 ||
              sheetNumber == 8 ||
              sheetNumber == 9 ||
              sheetNumber == 16) ...[
            SizedBox(height: 16),
            Text(
              'G2',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            _groupInRows(inputFields.sublist(10)), // G2 Inputs
          ],
        ],
      ),
    );
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
