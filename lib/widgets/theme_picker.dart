import 'package:flutter/material.dart';
import 'package:power_diyala/settings/theme_control.dart';
import 'package:power_diyala/widgets/color_picker.dart';
import 'package:provider/provider.dart';

class ThemePicker extends StatefulWidget {
  const ThemePicker({super.key});

  @override
  ThemePickerState createState() => ThemePickerState();
}

class ThemePickerState extends State<ThemePicker> {
  late Color primaryColor;
  late Color secondaryColor;
  late Color accentColor;
  int selectedThemeIndex = 0;

  final List<Map<String, dynamic>> themes = [
    {
      'primary': const Color(0xffC95A3D),
      'secondary': const Color(0xffD9C3B2),
      'accent': const Color(0xff8E4B4A),
    },
    {
      'primary': const Color(0xff533DC9),
      'secondary': const Color(0xffBCB2D9),
      'accent': const Color(0xff524A8E),
    },
    {
      'primary': const Color(0xff000000),
      'secondary': const Color(0xffBDBDBD),
      'accent': const Color(0xff525252),
    },
    {
      'primary': const Color(0xff3d67c9),
      'secondary': const Color(0xffb2bdd9),
      'accent': const Color(0xff4a608e),
    },
    {
      'primary': const Color(0xff9c008d),
      'secondary': const Color(0xffd6b2d9),
      'accent': const Color(0xffad1aaa),
    },
    {
      'primary': const Color(0xff9C27B0),
      'secondary': const Color(0xffffb4cd),
      'accent': const Color(0xffF44336),
    },
  ];

  @override
  void initState() {
    super.initState();
    final themeControl = Provider.of<ThemeControl>(context, listen: false);
    primaryColor = themeControl.primaryColor;
    secondaryColor = themeControl.secondaryColor;
    accentColor = themeControl.accentColor;
    selectedThemeIndex = themes.indexWhere((theme) =>
        theme['primary'] == primaryColor &&
        theme['secondary'] == secondaryColor &&
        theme['accent'] == accentColor);
    if (selectedThemeIndex == -1) {
      selectedThemeIndex = 0;
    }
  }

  void resetToDefaultColors() {
    setState(() {
      final themeControl = Provider.of<ThemeControl>(context, listen: false);
      primaryColor = themes[0]['primary']!;
      secondaryColor = themes[0]['secondary']!;
      accentColor = themes[0]['accent']!;
      themeControl.saveColors(primaryColor, secondaryColor, accentColor);
    });
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
                        Icon(Icons.palette_rounded,
                            color: Colors.white, size: 32),
                        SizedBox(height: 8),
                        Text(
                          'Select Theme',
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
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: themes.length,
                    itemBuilder: (context, index) {
                      final theme = themes[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            primaryColor = theme['primary']!;
                            secondaryColor = theme['secondary']!;
                            accentColor = theme['accent']!;
                            selectedThemeIndex = index;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.black38
                                    : Colors.grey[300]!,
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey
                                    : Colors.grey[400]!,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                spreadRadius: 2,
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                            border: Border.all(
                              color: selectedThemeIndex == index
                                  ? theme['accent']!
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width: 12,
                                decoration: BoxDecoration(
                                  color: theme['primary'],
                                  borderRadius: const BorderRadius.horizontal(
                                      left: Radius.circular(5)),
                                ),
                              ),
                              Container(
                                width: 12,
                                decoration: BoxDecoration(
                                  color: theme['secondary'],
                                ),
                              ),
                              Container(
                                width: 12,
                                decoration: BoxDecoration(
                                  color: theme['accent'],
                                  borderRadius: const BorderRadius.horizontal(
                                      right: Radius.circular(5)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => const ColorPickerDialog(),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.fromLTRB(12, 5, 12, 5),
                        child: const Icon(Icons.colorize_rounded,
                            color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        final themeControl =
                            Provider.of<ThemeControl>(context, listen: false);
                        themeControl.saveColors(
                            primaryColor, secondaryColor, accentColor);
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(60),
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child:
                            const Icon(Icons.save_rounded, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.fromLTRB(12, 5, 12, 5),
                        child: const Icon(Icons.cancel, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
