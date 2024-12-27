import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  final String key = "theme";
  late SharedPreferences pref;
  late bool isDarkMode;

  ThemeProvider() {
    isDarkMode = false;
    loadFromPrefs();
  }

  toggleTheme() {
    isDarkMode = !isDarkMode;
    saveToPrefs();
    notifyListeners();
  }

  Future<void> initPrefs() async {
    pref = await SharedPreferences.getInstance();
  }

  Future<void> loadFromPrefs() async {
    await initPrefs();
    isDarkMode = pref.getBool(key) ?? false;
    notifyListeners();
  }

  Future<void> saveToPrefs() async {
    await initPrefs();
    pref.setBool(key, isDarkMode);
  }
}
