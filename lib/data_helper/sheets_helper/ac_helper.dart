import 'package:flutter/material.dart';
import 'package:power_diyala/settings/theme_control.dart';

class AcInput extends StatefulWidget {
  final int? sheetNumber;
  final List<TextEditingController> acVoltControllers;
  final List<TextEditingController> acLoadControllers;
  final List<TextEditingController> acOtherController;

  const AcInput(
    this.sheetNumber, {
    super.key,
    required this.acVoltControllers,
    required this.acLoadControllers,
    required this.acOtherController,
  });

  @override
  AcInputState createState() => AcInputState();
}

class AcInputState extends State<AcInput> {
  List<Widget> _buildInputFields(BuildContext context) {
    List<Widget> inputFields = [];
    if (widget.sheetNumber == null) return inputFields;

    switch (widget.sheetNumber) {
      case 1:
      case 2:
      case 3:
      case 10:
      case 11:
        for (int i = 0; i < 3; i++) {
          inputFields.add(_buildRow(context, i));
        }
        inputFields.add(_buildHPLPRow(context));
        break;

      case 4:
      case 5:
      case 13:
        for (int i = 0; i < 2; i++) {
          inputFields.add(_buildRow(context, i));
        }
        inputFields.add(_buildHPLPRow(context));
        break;

      case 6:
      case 7:
      case 14:
        inputFields.add(_buildOutdoorRow(context));
        inputFields.add(_buildRow(context, 2));
        inputFields.add(_buildHPLPRow(context));
        break;

      case 8:
      case 9:
      case 12:
        inputFields.add(_buildOutdoorRow(context));
        inputFields.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller:
                        widget.acOtherController[0], // Room temp. controller
                    decoration: InputDecoration(
                      labelText: 'Room temp.',
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
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '*';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
        );
        break;

      case 15:
        inputFields.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller:
                        widget.acOtherController[0], // Room temp. controller
                    decoration: InputDecoration(
                      labelText: 'Room temp.',
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
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '*';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
        );
        break;

      case 16:
        for (int i = 0; i < 3; i++) {
          inputFields.add(_buildRow(context, i));
        }
        inputFields.add(_buildOutdoorRow(context));
        inputFields.add(_buildHPLPRow(context));
        break;

      default:
        break;
    }

    return inputFields;
  }

  Widget _buildRow(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text('AC ${index + 1}'),
          const SizedBox(width: 8.0),
          _generateTextField(
              context, widget.acVoltControllers[index], 'V ${index + 1}'),
          const SizedBox(width: 8.0),
          _generateTextField(
              context, widget.acLoadControllers[index], 'Load ${index + 1}'),
        ],
      ),
    );
  }

  Widget _buildHPLPRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          _generateTextField(context, widget.acOtherController[1], 'HP'),
          const SizedBox(width: 8.0),
          _generateTextField(context, widget.acOtherController[2], 'LP'),
          const SizedBox(width: 8.0),
          _generateTextField(
              context, widget.acOtherController[0], 'Room temp.'),
        ],
      ),
    );
  }

  Widget _buildOutdoorRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Text('Outdoor'),
          const SizedBox(width: 8.0),
          _generateTextField(context, widget.acVoltControllers[3], 'V'),
          const SizedBox(width: 8.0),
          _generateTextField(context, widget.acLoadControllers[3], 'Load'),
        ],
      ),
    );
  }

  Widget _generateTextField(BuildContext context,
      TextEditingController controller, String labelText) {
    return Expanded(
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            color: ThemeControl.errorColor.withValues(alpha: 0.8),
            fontSize: 12,
          ),
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
            borderSide: const BorderSide(color: Colors.grey, width: 1.5),
          ),
        ),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '*';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _buildInputFields(context),
    );
  }
}
