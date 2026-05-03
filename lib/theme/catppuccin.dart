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
  final Color border;
  final Color accentMuted;

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
    required this.border,
    required this.accentMuted,
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
    border: Color(0xFF45475A),
    accentMuted: Color(0xFF6C7086),
  );
}
