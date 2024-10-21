import 'package:flutter/material.dart';
import 'package:power_diyala/settings/theme_control.dart';

class GenInput {
  final int sheetNumber;
  GenInput(this.sheetNumber);

  List<Widget> genInputs(List<TextEditingController> controllers) {
    List<Widget> inputFields = [];

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
              labelStyle: TextStyle(color: ThemeControl.errorColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: ThemeControl().secondaryColor),
              ),
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
            labelStyle: TextStyle(color: ThemeControl.errorColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: ThemeControl().secondaryColor),
            ),
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
