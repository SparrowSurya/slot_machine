import 'package:shared_preferences/shared_preferences.dart';


/// Collection of app preferences.
enum Pref {
  coins,
}

/// Manages preferences storage.
class Preferences {
  static late final SharedPreferences _instance;

  static Future<void> init() async {
    _instance = await SharedPreferences.getInstance();
  }

  static String? getString(Pref key) {
    return _instance.getString(key.name);
  }

  static int? getInt(Pref key) {
    return _instance.getInt(key.name);
  }

  static double? getDouble(Pref key) {
    return _instance.getDouble(key.name);
  }

  static bool? getBool(Pref key) {
    return _instance.getBool(key.name);
  }

  static Future<bool> setString(Pref key, String? value) async {
    if (value == null) {
      return _instance.remove(key.name);
    }
    return _instance.setString(key.name, value);
  }

  static Future<bool> setDouble(Pref key, double? value) async {
    if (value == null) {
      return _instance.remove(key.name);
    }
    return _instance.setDouble(key.name, value);
  }

  static Future<bool> setInt(Pref key, int? value) async {
    if (value == null) {
      return _instance.remove(key.name);
    }
    return _instance.setInt(key.name, value);
  }

  static Future<bool> setBool(Pref key, bool? value) async {
    if (value == null) {
      return _instance.remove(key.name);
    }
    return _instance.setBool(key.name, value);
  }
}
