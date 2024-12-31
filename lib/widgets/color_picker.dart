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

  void _pickColor(Color currentColor, ValueChanged<Color> onColorChanged) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color tempColor = currentColor;
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              color: Theme.of(context).cardColor,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 120,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        const Column(
                          children: [
                            Icon(Icons.palette_rounded,
                                color: Colors.white, size: 32),
                            SizedBox(height: 8),
                            Text(
                              'Select Color',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SingleChildScrollView(
                        child: ColorPicker(
                          pickerColor: currentColor,
                          onColorChanged: (color) {
                            tempColor = color;
                          },
                          labelTypes: const [
                            ColorLabelType.rgb,
                            ColorLabelType.hex
                          ],
                          pickerAreaHeightPercent: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: () {
                        onColorChanged(tempColor);
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: const Text(
                          'Select',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          color: Theme.of(context).cardColor,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 120,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    const Column(
                      children: [
                        Icon(Icons.color_lens_rounded,
                            color: Colors.white, size: 32),
                        SizedBox(height: 8),
                        Text(
                          'Customize Theme',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontStyle: FontStyle.normal,
                            color: Colors.white,
                            fontSize: 18,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildColorButton('Primary Color', primaryColor, (color) {
                        setState(() {
                          primaryColor = color;
                        });
                      }),
                      const SizedBox(height: 10),
                      _buildColorButton('Secondary Color', secondaryColor,
                          (color) {
                        setState(() {
                          secondaryColor = color;
                        });
                      }),
                      const SizedBox(height: 10),
                      _buildColorButton('Accent Color', accentColor, (color) {
                        setState(() {
                          accentColor = color;
                        });
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: resetToDefaultColors,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: const Icon(Icons.restart_alt_rounded,
                            color: Colors.white),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.tertiary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child:
                                const Icon(Icons.cancel, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            final themeControl = Provider.of<ThemeControl>(
                                context,
                                listen: false);
                            themeControl.saveColors(
                                primaryColor, secondaryColor, accentColor);
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.tertiary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: const Icon(Icons.save_rounded,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorButton(
      String title, Color currentColor, ValueChanged<Color> onColorChanged) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            title,
            style: TextStyle(
                fontSize: 17, fontWeight: FontWeight.w500, color: currentColor),
          ),
        ),
        Expanded(
          flex: 1,
          child: GestureDetector(
            onTap: () {
              _pickColor(currentColor, onColorChanged);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: currentColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
