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
        surfaceContainer: p.surface,
        surfaceContainerHigh: p.surfaceVariant,
        surfaceContainerLow: p.mantle,
        outline: p.surfaceVariant,
        outlineVariant: p.mantle,
        shadow: p.crust,
        scrim: p.crust,
        onSurfaceVariant: p.subtext,
        inverseSurface: p.text,
        onInverseSurface: p.base,
        inversePrimary: p.primary,
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
        bodySmall: TextStyle(color: p.subtext),
        titleMedium: TextStyle(
          color: p.text,
          fontWeight: FontWeight.w600,
        ),
        labelLarge: TextStyle(
          color: p.subtext,
          letterSpacing: 1.2,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: p.primary,
        inactiveTrackColor: p.surfaceVariant,
        thumbColor: p.primary,
      ),
      dividerColor: p.surfaceVariant,
      cardTheme: CardThemeData(
        color: p.surface,
        shadowColor: p.crust,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      iconTheme: IconThemeData(
        color: p.text,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: p.base,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.primary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: p.surfaceVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: p.surfaceVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: p.primary),
        ),
        hintStyle: TextStyle(color: p.subtext),
      ),
    );
  }
}
