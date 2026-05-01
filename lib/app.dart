import 'package:flutter/material.dart';
import 'theme/theme.dart';
import 'theme/catppuccin.dart';
import 'screens/slot_machine.dart';


/// The main application widget.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.fromCatppuccin(Catppuccin.mocha),
      home: const MySlotMachine(),
    );
  }
}