import 'dart:ui';
import 'package:flutter/material.dart';

class ThemeHelper {
  static String appTheme = "primary";

  final Map<String, PrimaryColors> _supportedCustomColor = {
    'primary': PrimaryColors(),
  };

  final Map<String, ColorScheme> _supportedColorScheme = {
    'primary': ColorSchemes.primaryColorScheme,
  };

  get gray50 => null;

  void changeTheme(String newTheme) {
    appTheme = newTheme;
  }

  PrimaryColors getThemeColors() {
    return _supportedCustomColor[appTheme] ?? PrimaryColors();
  }

  ThemeData getThemeData() {
    var colorScheme = _supportedColorScheme[appTheme] ?? ColorSchemes.primaryColorScheme;
    return ThemeData(
      visualDensity: VisualDensity.standard,
      colorScheme: colorScheme,
      textTheme: TextThemes.textTheme(colorScheme),
      scaffoldBackgroundColor: _supportedCustomColor[appTheme]?.gray50 ?? Colors.white,
    );
  }
}

class TextThemes {
  static TextTheme textTheme(ColorScheme colorScheme) => TextTheme(
        displayLarge: TextStyle(
          color: ThemeHelper.appTheme == "primary" ? PrimaryColors().blueGray900 : Colors.black, // Example usage
          fontSize: 32.0, // Change this to a double value
          fontFamily: 'Lato',
          fontWeight: FontWeight.w700,
        ),
        // Add more text styles as needed
      );
}

class ColorSchemes {
  static const primaryColorScheme = ColorScheme.light();

  // You can add more color schemes here
}

class PrimaryColors {
  Color get blueGray900 => Color(0xFF192242);
  Color get gray50 => Color(0xFFF3F6FF);
}

final ThemeHelper appTheme = ThemeHelper();
final ThemeData theme = appTheme.getThemeData();
