import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeControl with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  Color _primaryColor = const Color(0xffC95A3D);
  Color _secondaryColor = const Color(0xffD9C3B2);
  Color _accentColor = const Color(0xff8E4B4A);

  static const Color _defaultPrimaryColor = Color(0xffC95A3D);
  static const Color _defaultSecondaryColor = Color(0xffD9C3B2);
  static const Color _defaultAccentColor = Color(0xff8E4B4A);

  static const Color warningColor = Color(0xFFFF7D00);
  static const Color errorColor = Color(0xFFFF3D00);
  static const Color lightBackgroundColor = Color(0xFFF5F5F5);
  static const Color lightSurfaceColor = Colors.white;
  static const Color darkBackgroundColor = Color(0xFF2F2F2F);
  static const Color darkSurfaceColor = Color(0xFF1E1E1E);
  static const Color lightShadowColor = Color(0x1F000000);
  static const Color darkShadowColor = Color(0x37FFFFFF);

  ThemeMode get themeMode => _themeMode;

  ThemeControl() {
    _loadThemePreference();
    _loadColorPreferences();
  }
  Color _fromHexString(String hex) {
    return Color(int.parse(hex, radix: 16));
  }

  Future<void> _loadColorPreferences() async {
    final SharedPreferencesAsync prefs = SharedPreferencesAsync();

    final primaryColorHex = await prefs.getString('primary_color') ??
        _defaultPrimaryColor.toHexString(includeHashSign: false);
    final secondaryColorHex = await prefs.getString('secondary_color') ??
        _defaultSecondaryColor.toHexString(includeHashSign: false);
    final accentColorHex = await prefs.getString('accent_color') ??
        _defaultAccentColor.toHexString(includeHashSign: false);

    _primaryColor = _fromHexString(primaryColorHex);
    _secondaryColor = _fromHexString(secondaryColorHex);
    _accentColor = _fromHexString(accentColorHex);

    notifyListeners();
  }

  // Getter methods for the colors
  Color get primaryColor => _primaryColor;
  Color get secondaryColor => _secondaryColor;
  Color get accentColor => _accentColor;

  Future<void> saveColors(Color primary, Color secondary, Color accent) async {
    final SharedPreferencesAsync prefs = SharedPreferencesAsync();
    await prefs.setString(
        'primary_color', primary.toHexString(includeHashSign: false));
    await prefs.setString(
        'secondary_color', secondary.toHexString(includeHashSign: false));
    await prefs.setString(
        'accent_color', accent.toHexString(includeHashSign: false));

    _primaryColor = primary;
    _secondaryColor = secondary;
    _accentColor = accent;

    notifyListeners();
  }

  Future<void> _loadThemePreference() async {
    final SharedPreferencesAsync prefs = SharedPreferencesAsync();
    String? savedTheme = await prefs.getString('theme_mode');

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
    final SharedPreferencesAsync prefs = SharedPreferencesAsync();
    await prefs.setString('theme_mode', mode.toString());
  }

  ThemeData appTheme({required bool isDarkMode}) {
    return ThemeData(
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      primaryColor: _primaryColor,
      scaffoldBackgroundColor:
          isDarkMode ? darkBackgroundColor : lightBackgroundColor,
      secondaryHeaderColor: _secondaryColor,
      cardColor: isDarkMode ? darkSurfaceColor : lightSurfaceColor,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: isDarkMode ? _secondaryColor : _accentColor,
        foregroundColor:
            isDarkMode ? darkBackgroundColor : lightBackgroundColor,
      ),
      shadowColor: isDarkMode ? darkShadowColor : lightShadowColor,
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
          foregroundColor: WidgetStateProperty.all(
            isDarkMode ? secondaryColor : _primaryColor,
          ), // Icon color
          padding: WidgetStateProperty.all(const EdgeInsets.all(16)),
        ),
      ),
      dividerColor: isDarkMode ? Colors.white70 : _primaryColor,
      snackBarTheme: SnackBarThemeData(
        dismissDirection: DismissDirection.horizontal,
        actionTextColor: Colors.blueGrey,
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            isDarkMode ? lightBackgroundColor : darkBackgroundColor,
        contentTextStyle:
            TextStyle(color: isDarkMode ? Colors.black : Colors.white),
      ),
      colorScheme: ColorScheme(
          primary: _primaryColor,
          secondary: _secondaryColor,
          surface: isDarkMode ? darkSurfaceColor : lightSurfaceColor,
          error: errorColor,
          onPrimary: Colors.white,
          onSecondary: isDarkMode ? lightBackgroundColor : darkSurfaceColor,
          onSurface: Colors.black,
          onError: Colors.white,
          brightness: isDarkMode ? Brightness.dark : Brightness.light,
          tertiary: _accentColor),
      listTileTheme: ListTileThemeData(
          titleTextStyle: TextStyle(
              color: isDarkMode ? lightBackgroundColor : Colors.black,
              fontSize: 17),
          iconColor: isDarkMode
              ? lightBackgroundColor.withValues(alpha: 0.8)
              : darkBackgroundColor.withValues(alpha: 0.8),
          leadingAndTrailingTextStyle: TextStyle(
              color: isDarkMode ? Colors.amber : _accentColor, fontSize: 14),
          subtitleTextStyle: TextStyle(
              color: isDarkMode
                  ? Colors.amber.withValues(alpha: 0.8)
                  : _accentColor,
              fontSize: 14)),
      expansionTileTheme: ExpansionTileThemeData(
          textColor: isDarkMode ? warningColor : _primaryColor,
          collapsedIconColor: isDarkMode ? _secondaryColor : _accentColor,
          collapsedTextColor: isDarkMode ? Colors.white : Colors.black),
      textTheme: TextTheme(
        labelSmall: TextStyle(color: _secondaryColor),
        labelMedium: TextStyle(
            fontSize: 14.0,
            color: isDarkMode ? Colors.blueGrey : Colors.blueGrey),
        headlineSmall: TextStyle(
            fontSize: 15.0, fontWeight: FontWeight.bold, color: _accentColor),
        headlineMedium: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? warningColor : _primaryColor),
        headlineLarge: const TextStyle(
            fontSize: 20.0, color: warningColor, fontStyle: FontStyle.italic),
        bodySmall:
            TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87),
        bodyMedium: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        bodyLarge: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
        titleLarge: TextStyle(
            fontSize: 20.0,
            fontStyle: FontStyle.italic,
            color: isDarkMode ? _secondaryColor : _primaryColor),
        titleSmall: TextStyle(
            fontSize: 16.0, color: isDarkMode ? Colors.white70 : Colors.grey),
        titleMedium: TextStyle(
            fontSize: 18.0, color: isDarkMode ? _secondaryColor : Colors.black),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          iconColor: Colors.white,
          backgroundColor: _accentColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        iconColor: isDarkMode ? Colors.white : Colors.black,
        surfaceTintColor: _accentColor,
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
            ? warningColor.withValues(alpha: 0.2)
            : _secondaryColor.withValues(alpha: 0.2),
        dayForegroundColor:
            WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.pressed)) {
            return isDarkMode
                ? Colors.white.withValues(alpha: 0.8)
                : Colors.black.withValues(alpha: 0.8);
          }
          return isDarkMode ? Colors.white : Colors.black;
        }),
        dayOverlayColor:
            WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          return states.contains(WidgetState.pressed)
              ? (isDarkMode
                  ? Colors.white.withValues(alpha: 0.8)
                  : Colors.black.withValues(alpha: 0.8))
              : null;
        }),
        surfaceTintColor: _secondaryColor,
      ),
      timePickerTheme: TimePickerThemeData(
        dayPeriodColor: _secondaryColor,
        dayPeriodTextColor: isDarkMode ? _primaryColor : darkSurfaceColor,
        entryModeIconColor: _primaryColor,
        backgroundColor: isDarkMode ? darkSurfaceColor : lightSurfaceColor,
        hourMinuteShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        hourMinuteTextColor: isDarkMode ? Colors.white : Colors.black,
        dialBackgroundColor: isDarkMode ? _secondaryColor : lightSurfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
          foregroundColor: isDarkMode ? _secondaryColor : _primaryColor,
          overlayColor: _primaryColor,
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        surfaceTintColor: secondaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide(
            color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
            width: 1.0,
          ),
        ),
        elevation: 8.0,
        titleTextStyle: TextStyle(
            fontSize: 20.0,
            fontStyle: FontStyle.italic,
            color: isDarkMode ? _primaryColor : _accentColor,
            fontWeight: FontWeight.bold),
        contentTextStyle: TextStyle(
          color: isDarkMode ? Colors.white70 : Colors.black87,
          fontSize: 16.0,
        ),
        insetPadding: const EdgeInsets.all(16.0),
        actionsPadding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
          foregroundColor:
              isDarkMode ? lightBackgroundColor : darkBackgroundColor,
          backgroundColor: isDarkMode
              ? darkBackgroundColor
              : lightBackgroundColor, // Background color
          overlayColor: _primaryColor, // Overlay color on press
          side: BorderSide(color: _primaryColor),
          textStyle: const TextStyle(
            fontSize: 15,
            letterSpacing: 1,
            wordSpacing: 2,
          ),
        ),
      ),
      toggleButtonsTheme: ToggleButtonsThemeData(
        borderWidth: 2.0,
        borderColor: isDarkMode ? Colors.grey.shade700 : _primaryColor,
        selectedBorderColor: isDarkMode ? _accentColor : _secondaryColor,
        fillColor: isDarkMode
            ? _primaryColor.withValues(alpha: 0.2)
            : _secondaryColor.withValues(alpha: 0.2),
        color: isDarkMode ? lightBackgroundColor : darkBackgroundColor,
        selectedColor: isDarkMode ? warningColor : _accentColor,
        borderRadius: BorderRadius.circular(12.0),
        textStyle: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        splashColor: isDarkMode
            ? _primaryColor.withValues(alpha: 0.3)
            : _accentColor.withValues(alpha: 0.3),
        hoverColor: isDarkMode
            ? _accentColor.withValues(alpha: 0.2)
            : _secondaryColor.withValues(alpha: 0.2),
      ),
    );
  }
}
