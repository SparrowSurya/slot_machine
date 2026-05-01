import 'package:flutter/material.dart' show Color;


/// Catppuccin color palette.
class CatppuccinPalette {
  final Color base;
  final Color mantle;
  final Color crust;
  final Color surface;
  final Color surfaceVariant;
  final Color text;
  final Color subtext;
  final Color primary;
  final Color secondary;
  final Color error;

  const CatppuccinPalette({
    required this.base,
    required this.mantle,
    required this.crust,
    required this.surface,
    required this.surfaceVariant,
    required this.text,
    required this.subtext,
    required this.primary,
    required this.secondary,
    required this.error,
  });
}


/// Predefined Catppuccin color palettes.
class Catppuccin {
  static const mocha = CatppuccinPalette(
    base: Color(0xFF1E1E2E),
    mantle: Color(0xFF181825),
    crust: Color(0xFF11111B),
    surface: Color(0xFF313244),
    surfaceVariant: Color(0xFF45475A),
    text: Color(0xFFCDD6F4),
    subtext: Color(0xFFA6ADC8),
    primary: Color(0xFFCBA6F7),
    secondary: Color(0xFFF9E2AF),
    error: Color(0xFFF38BA8),
  );

  static const macchiato = CatppuccinPalette(
    base: Color(0xFF24273A),
    mantle: Color(0xFF1E2030),
    crust: Color(0xFF181926),
    surface: Color(0xFF363A4F),
    surfaceVariant: Color(0xFF494D64),
    text: Color(0xFFCAD3F5),
    subtext: Color(0xFFA5ADCB),
    primary: Color(0xFFC6A0F6),
    secondary: Color(0xFFEED49F),
    error: Color(0xFFED8796),
  );

  static const frappe = CatppuccinPalette(
    base: Color(0xFF303446),
    mantle: Color(0xFF292C3C),
    crust: Color(0xFF232634),
    surface: Color(0xFF414559),
    surfaceVariant: Color(0xFF51576D),
    text: Color(0xFFC6D0F5),
    subtext: Color(0xFFA5ADCE),
    primary: Color(0xFFCA9EE6),
    secondary: Color(0xFFE5C890),
    error: Color(0xFFE78284),
  );

  static const latte = CatppuccinPalette(
    base: Color(0xFFEFF1F5),
    mantle: Color(0xFFE6E9EF),
    crust: Color(0xFFDCE0E8),
    surface: Color(0xFFCCD0DA),
    surfaceVariant: Color(0xFFBCC0CC),
    text: Color(0xFF4C4F69),
    subtext: Color(0xFF6C6F85),
    primary: Color(0xFF8839EF),
    secondary: Color(0xFFDF8E1D),
    error: Color(0xFFD20F39),
  );
}
