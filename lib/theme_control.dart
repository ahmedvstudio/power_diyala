import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeControl with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // Default to system theme mode

  // Define your color palette
  static const Color primaryColor = Color(0xffC95A3D);
  static const Color secondaryColor = Color(0xffD9C3B2);
  static const Color accentColor = Color(0xff8E4B4A); // New accent color
  static const Color warningColor = Color(0xFFFF7D00);
  static const Color errorColor = Color(0xFFFF3D00);
  static const Color lightBackgroundColor =
      Color(0xFFF5F5F5); // Light background
  static const Color lightSurfaceColor = Colors.white; // Light surface
  static const Color darkBackgroundColor = Color(0xFF2F2F2F); // Dark background
  static const Color darkSurfaceColor = Color(0xFF1E1E1E); // Dark surface
  static const Color lightShadowColor =
      Color(0x1F000000); // Light shadow color for light theme
  static const Color darkShadowColor =
      Color(0x37FFFFFF); // Light shadow color for dark theme

  ThemeMode get themeMode => _themeMode;

  ThemeControl() {
    _loadThemePreference(); // Load theme preference on initialization
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
    notifyListeners(); // Notify listeners after loading preference
  }

  Future<void> toggleTheme(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners(); // Notify listeners to rebuild with new theme

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
        backgroundColor: isDarkMode ? secondaryColor : primaryColor,
        foregroundColor:
            isDarkMode ? darkBackgroundColor : lightBackgroundColor,
      ),
      shadowColor: isDarkMode
          ? darkShadowColor
          : lightShadowColor, // Apply shadow color based on theme

      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          backgroundColor:
              WidgetStateProperty.all(Colors.transparent), // Background color
          foregroundColor: WidgetStateProperty.all(
            isDarkMode ? Colors.white : primaryColor,
          ), // Icon color
          padding: WidgetStateProperty.all(
              const EdgeInsets.all(16)), // Padding around the icon
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
          textColor: isDarkMode ? Colors.white : Colors.black,
          iconColor: isDarkMode ? accentColor : Colors.blue),
      textTheme: TextTheme(
        labelMedium: TextStyle(
            fontSize: 14.0,
            color: isDarkMode ? Colors.blueGrey : Colors.blueGrey),
        labelSmall: const TextStyle(color: secondaryColor),
        headlineLarge: const TextStyle(
            fontSize: 20.0, fontWeight: FontWeight.bold, color: warningColor),
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
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : primaryColor),
        titleMedium: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? secondaryColor : Colors.black),
        titleSmall: TextStyle(
            fontSize: 16.0, color: isDarkMode ? Colors.white70 : Colors.grey),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: accentColor, // Background color on button
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0), // Rounded corners
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        iconColor: isDarkMode ? Colors.white : Colors.black,
        surfaceTintColor: primaryColor,
        color: isDarkMode
            ? darkSurfaceColor
            : lightSurfaceColor, // Background color of the popup menu
        textStyle: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black, // Text color
          fontSize: 16.0, // Font size
        ),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(12.0), // Rounded corners for the popup menu
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: isDarkMode
            ? darkSurfaceColor
            : lightSurfaceColor, // Background color of the date picker
        headerBackgroundColor: isDarkMode
            ? darkBackgroundColor
            : lightBackgroundColor, // Header background
        headerForegroundColor: isDarkMode ? Colors.white : Colors.black,

        // Text styles for days, year, and weekdays
        dayStyle: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black), // Day text color
        yearStyle: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black), // Year text color
        weekdayStyle: TextStyle(
            color:
                isDarkMode ? Colors.white : Colors.black), // Weekday text color

        // Background colors
        rangePickerBackgroundColor:
            isDarkMode ? darkSurfaceColor : lightSurfaceColor,
        dividerColor: isDarkMode ? Colors.white : Colors.black,
        rangeSelectionBackgroundColor: isDarkMode
            ? warningColor.withOpacity(0.2)
            : secondaryColor.withOpacity(0.2),

        // Day foreground color based on state
        dayForegroundColor:
            WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.pressed)) {
            return isDarkMode
                ? Colors.white.withOpacity(0.8)
                : Colors.black.withOpacity(0.8);
          }
          return isDarkMode ? Colors.white : Colors.black;
        }),

        // Day overlay color based on state
        dayOverlayColor:
            WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          return states.contains(WidgetState.pressed)
              ? (isDarkMode
                  ? Colors.white.withOpacity(0.8)
                  : Colors.black.withOpacity(0.8))
              : null; // No overlay color when not pressed
        }),
        surfaceTintColor: secondaryColor,
      ),
    );
  }
}
