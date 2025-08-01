import 'package:flutter/material.dart';

class VColors {
  VColors._();

  // App basic color
  static const Color kPrimary = Color(0xFF4b68ff);
  static const Color kSecondary = Color(0xFFFFe248);
  static const Color kAccent = Color(0xFFb0c7ff);

  // Light Color Palette
  static const Color primary = Color(0xFF335C67);
  static const Color onPrimary = Color(0xFF000000);
  static const Color secondary = Color(0xFF540B0E);
  static const Color onSecondary = Color(0xFF000000);
  static const Color surface = Color(0xFFF4F1F8);
  static const Color onSurface = Color(0xFF272727);

  // Dark Color Palette
  static const Color primaryDark = Color(0xFFE09F3E);
  static const Color onPrimaryDark = Color(0xFFF4F1F8);
  static const Color secondaryDark = Color(0xFF9E2A2B);
  static const Color onSecondaryDark = Color(0xFFF4F1F8);
  static const Color surfaceDark = Color(0xFFFFF3B0);
  static const Color onSurfaceDark = Color(0xFF000000);

  // Gradient Colors
  static const Gradient linearGradient = LinearGradient(
    begin: Alignment(0.0, 0.0),
    end: Alignment(0.707, -0.707),
    colors: [
      Color(0xFFff9a9e),
      Color(0xFFfad0c4),
      Color(0xFFfad0c4),
    ],
  );

  // Text Colors
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF6C7570);
  static const Color textWhite = Colors.white;

  // Background Colors
  static const Color light = Color(0xFFF6F6F6);
  static const Color dark = Color(0xFF272727);
  static const Color primaryBackground = Color(0xFFF3F5FF);

  // Background Container Colors
  static const Color lightContainer = Color(0xFFF6F6F6);
  static const Color darkContainer = Color(0xFFF6F6F6);

  // Button Colors
  static const Color buttonPrimary = Colors.blue;
  static const Color buttonSecondary = Color(0xFF6c757d);
  static const Color buttonDisabled = Color(0xFFc4c4c4);

  // Border Colors
  static const Color borderPrimary = Color(0xFFd9d9d9);
  static const Color borderSecondary = Color(0xFFe6e6e6);

  // Error and Validation Colors
  static const Color error = Color(0xFFd32f2f);
  static const Color onError = Color(0xFFe0e0e0);
  static const Color success = Color(0xFF388e3c);
  static const Color warning = Color(0xFFf57c00);
  static const Color info = Color(0xFF1976d2);

  // Neutral Colors
  static const Color black = Color(0xFF232323);
  static const Color white = Color.fromARGB(255, 255, 248, 248);
  static const Color darkerGrey = Color(0xFF4f4f4f);
  static const Color darkGrey = Color(0xFF939393);
  static const Color softGrey = Color(0xFFF4f4F4);
  static const Color lightGrey = Color(0xFFF9f9F9);
  static const Color grey = Color(0xFFe0e0e0);

  // White Alternatives
  static const Color ivory = Color(0xFFFFFFF0);
  static const Color marble = Color(0xFFF2F8FC);
  static const Color pearl = Color(0xFFFCFCF7);
  static const Color coldSteel = Color(0xFFF8F7F4);
  static const Color lavender = Color(0xFFF4F1F8);
}
