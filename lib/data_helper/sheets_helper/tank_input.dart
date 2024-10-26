import 'package:flutter/material.dart';
import 'package:power_diyala/settings/theme_control.dart';

class TankInput {
  final int? sheetNumber;
  TankInput(this.sheetNumber);

  List<Widget> tankInputs(List<TextEditingController> controllers) {
    List<Widget> inputFields = [];
    if (sheetNumber == null) {
      return inputFields; // Return empty list if sheetNumber is null
    }
    switch (sheetNumber) {
      case 1:
      case 16:
        //3 tank
        for (int i = 0; i < 3; i++) {
          inputFields.add(TextField(
            controller: controllers[i],
            decoration: InputDecoration(
              labelText: 'T${i + 1}',
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
        }
      case 2:
      case 4:
      case 6:
      case 8:
      case 10:
        // 2 tanks
        for (int i = 0; i < 2; i++) {
          inputFields.add(TextField(
            controller: controllers[i],
            decoration: InputDecoration(
              labelText: 'T${i + 1}',
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
      case 3:
      case 5:
      case 7:
      case 9:
      case 11:
      case 12:
      case 13:
      case 14:
        // 1 tank
        inputFields.add(TextField(
          controller: controllers[0],
          decoration: InputDecoration(
            labelText: 'T1',
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
