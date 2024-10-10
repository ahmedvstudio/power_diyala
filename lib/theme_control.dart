import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeControl with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  static const Color primaryColor = Color(0xffC95A3D);
  static const Color secondaryColor = Color(0xffD9C3B2);
  static const Color accentColor = Color(0xff8E4B4A);
  static const Color warningColor = Color(0xFFFF7D00);
  static const Color errorColor = Color(0xFFFF3D00);
  static const Color lightBackgroundColor =
      Color(0xFFF5F5F5); // Light background
  static const Color lightSurfaceColor = Colors.white;
  static const Color darkBackgroundColor = Color(0xFF2F2F2F);
  static const Color darkSurfaceColor = Color(0xFF1E1E1E);
  static const Color lightShadowColor = Color(0x1F000000);
  static const Color darkShadowColor = Color(0x37FFFFFF);

  ThemeMode get themeMode => _themeMode;

  ThemeControl() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedTheme = prefs.getString('theme_mode');

    if (savedTheme != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.toString() == savedTheme,
        orElse: () => ThemeMode.system,
      );
    }
    notifyListeners();
  }

  Future<void> toggleTheme(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    // Save the selected theme in shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode.toString());
  }

  ThemeData appTheme({required bool isDarkMode}) {
    return ThemeData(
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor:
          isDarkMode ? darkBackgroundColor : lightBackgroundColor,
      secondaryHeaderColor: secondaryColor,
      cardColor: isDarkMode ? darkSurfaceColor : lightSurfaceColor,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: isDarkMode ? secondaryColor : accentColor,
        foregroundColor:
            isDarkMode ? darkBackgroundColor : lightBackgroundColor,
      ),
      shadowColor: isDarkMode ? darkShadowColor : lightShadowColor,
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
          foregroundColor: WidgetStateProperty.all(
            isDarkMode ? Colors.white : primaryColor,
          ), // Icon color
          padding: WidgetStateProperty.all(const EdgeInsets.all(16)),
        ),
      ),
      dividerColor: isDarkMode ? Colors.white70 : primaryColor,
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            isDarkMode ? lightBackgroundColor : darkBackgroundColor,
        contentTextStyle:
            TextStyle(color: isDarkMode ? Colors.black : Colors.white),
      ),
      colorScheme: ColorScheme(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: isDarkMode ? darkSurfaceColor : lightSurfaceColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: isDarkMode ? lightBackgroundColor : darkSurfaceColor,
        onSurface: Colors.black,
        onError: Colors.white,
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
      listTileTheme: ListTileThemeData(
          titleTextStyle: TextStyle(
              color: isDarkMode ? lightBackgroundColor : Colors.black,
              fontSize: 17),
          iconColor: isDarkMode
              ? lightBackgroundColor.withOpacity(0.8)
              : darkBackgroundColor.withOpacity(0.8),
          leadingAndTrailingTextStyle: TextStyle(
              color: isDarkMode ? Colors.amber : accentColor, fontSize: 14),
          subtitleTextStyle: TextStyle(
              color: isDarkMode ? Colors.amber.withOpacity(0.8) : accentColor,
              fontSize: 14)),
      expansionTileTheme: ExpansionTileThemeData(
          textColor: isDarkMode ? warningColor : primaryColor,
          collapsedIconColor: isDarkMode ? secondaryColor : accentColor,
          collapsedTextColor: isDarkMode ? Colors.white : Colors.black),
      textTheme: TextTheme(
        labelMedium: TextStyle(
            fontSize: 14.0,
            color: isDarkMode ? Colors.blueGrey : Colors.blueGrey),
        labelSmall: const TextStyle(color: secondaryColor),
        headlineLarge: const TextStyle(fontSize: 20.0, color: warningColor),
        headlineSmall: const TextStyle(
            fontSize: 15.0, fontWeight: FontWeight.bold, color: accentColor),
        headlineMedium: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? warningColor : primaryColor),
        bodyLarge: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
        bodyMedium: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        bodySmall:
            TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87),
        titleLarge: TextStyle(
            fontSize: 20.0,
            fontStyle: FontStyle.italic,
            color: isDarkMode ? Colors.white : primaryColor),
        titleMedium: TextStyle(
            fontSize: 18.0,
            // fontWeight: FontWeight.bold,
            color: isDarkMode ? secondaryColor : Colors.black),
        titleSmall: TextStyle(
            fontSize: 16.0, color: isDarkMode ? Colors.white70 : Colors.grey),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: accentColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        iconColor: isDarkMode ? Colors.white : Colors.black,
        surfaceTintColor: accentColor,
        color: isDarkMode ? darkSurfaceColor : lightSurfaceColor,
        textStyle: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontSize: 16.0,
        ),
        labelTextStyle: WidgetStateProperty.all<TextStyle>(
            TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: isDarkMode ? darkSurfaceColor : lightSurfaceColor,
        headerBackgroundColor:
            isDarkMode ? darkBackgroundColor : lightBackgroundColor,
        headerForegroundColor: isDarkMode ? Colors.white : Colors.black,
        dayStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        yearStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        weekdayStyle:
            TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        rangePickerBackgroundColor:
            isDarkMode ? darkSurfaceColor : lightSurfaceColor,
        dividerColor: isDarkMode ? Colors.white : Colors.black,
        rangeSelectionBackgroundColor: isDarkMode
            ? warningColor.withOpacity(0.2)
            : secondaryColor.withOpacity(0.2),
        dayForegroundColor:
            WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.pressed)) {
            return isDarkMode
                ? Colors.white.withOpacity(0.8)
                : Colors.black.withOpacity(0.8);
          }
          return isDarkMode ? Colors.white : Colors.black;
        }),
        dayOverlayColor:
            WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          return states.contains(WidgetState.pressed)
              ? (isDarkMode
                  ? Colors.white.withOpacity(0.8)
                  : Colors.black.withOpacity(0.8))
              : null;
        }),
        surfaceTintColor: secondaryColor,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
            foregroundColor: Colors.black.withOpacity(0.7), // Text color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(35),
            ),
            side: const BorderSide(color: primaryColor),
            overlayColor: primaryColor,
            backgroundColor: secondaryColor,
            textStyle: const TextStyle(
                fontSize: 15, letterSpacing: 1, wordSpacing: 2)),
      ),
    );
  }
}
