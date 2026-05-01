import 'package:flutter/material.dart';
import 'storage/prefs.dart';
import 'app.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Preferences.init();

  runApp(const MyApp());
}
