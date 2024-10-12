import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:power_diyala/settings/theme_control.dart';
import 'package:provider/provider.dart';

class ColorPickerDialog extends StatefulWidget {
  const ColorPickerDialog({super.key});

  @override
  ColorPickerDialogState createState() => ColorPickerDialogState();
}

class ColorPickerDialogState extends State<ColorPickerDialog> {
  late Color primaryColor;
  late Color secondaryColor;
  late Color accentColor;

  @override
  void initState() {
    super.initState();
    final themeControl = Provider.of<ThemeControl>(context, listen: false);
    primaryColor = themeControl.primaryColor;
    secondaryColor = themeControl.secondaryColor;
    accentColor = themeControl.accentColor;
  }

  void resetToDefaultColors() {
    setState(() {
      final themeControl = Provider.of<ThemeControl>(context, listen: false);
      primaryColor = const Color(0xffC95A3D);
      secondaryColor = const Color(0xffD9C3B2);
      accentColor = const Color(0xff8E4B4A);
      themeControl.saveColors(primaryColor, secondaryColor, accentColor);
    });
  }

  // Function to open a color picker for any color
  void _pickColor(Color currentColor, ValueChanged<Color> onColorChanged) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Color'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: currentColor,
              onColorChanged: onColorChanged,
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Select'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Theme Colors'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildColorButton('Primary', primaryColor, (color) {
            setState(() {
              primaryColor = color;
            });
          }),
          const SizedBox(height: 10),
          _buildColorButton('Secondary', secondaryColor, (color) {
            setState(() {
              secondaryColor = color;
            });
          }),
          const SizedBox(height: 10),
          _buildColorButton('Accent', accentColor, (color) {
            setState(() {
              accentColor = color;
            });
          }),
        ],
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        IconButton(
          onPressed: resetToDefaultColors,
          icon: const Icon(Icons.restart_alt_rounded),
          tooltip: 'Reset to Default',
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.cancel),
              tooltip: 'Cancel',
            ),
            IconButton(
              onPressed: () {
                final themeControl =
                    Provider.of<ThemeControl>(context, listen: false);
                themeControl.saveColors(
                    primaryColor, secondaryColor, accentColor);
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.save_rounded),
              tooltip: 'Save',
            ),
          ],
        ),
      ],
    );
  }

  // Button to pick color for each section
  Widget _buildColorButton(
      String title, Color currentColor, ValueChanged<Color> onColorChanged) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: currentColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () {
              _pickColor(currentColor, onColorChanged);
            },
            child: const Text('Pick'),
          ),
        ),
      ],
    );
  }
}
