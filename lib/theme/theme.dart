import 'package:flutter/material.dart';
import 'package:slot_machine/assets.dart';
import 'catppuccin.dart';


/// Appliocation themes.
class AppTheme {

  /// Converts a Catppuccin palette to a Flutter ThemeData.
  static ThemeData fromCatppuccin(CatppuccinPalette p, {bool isDark = true}) {
    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      fontFamily: AppFonts.roboto,
      scaffoldBackgroundColor: p.base,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: p.primary,
        onPrimary: p.base,
        secondary: p.secondary,
        onSecondary: p.base,
        surface: p.surface,
        onSurface: p.text,
        error: p.error,
        onError: p.text,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: p.base,
        elevation: 0,
        centerTitle: true,
        foregroundColor: p.text,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: p.text,
        ),
      ),
      textTheme: TextTheme(
        bodyMedium: TextStyle(color: p.text),
        titleMedium: TextStyle(
          color: p.text,
          fontWeight: FontWeight.w600,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: p.primary,
        inactiveTrackColor: p.surfaceVariant,
        thumbColor: p.primary,
      ),
    );
  }
}
