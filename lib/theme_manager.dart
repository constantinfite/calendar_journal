import 'package:flutter/material.dart';
import 'package:calendar_journal/storage_manager.dart';

class ThemeNotifier with ChangeNotifier {
  final darkTheme = ThemeData(
    primarySwatch: Colors.grey,
    primaryColor: Color.fromARGB(255, 105, 105, 105),
    scaffoldBackgroundColor: Color.fromARGB(255, 33,33,49),
    brightness: Brightness.dark,
    backgroundColor: Color.fromARGB(255, 0, 0, 0),
    primaryColorDark: Color.fromARGB(255, 46, 54, 59),
    dividerColor: Color.fromARGB(31, 7, 7, 7),
    primaryColorLight: Colors.white,
  );

  final lightTheme = ThemeData(
      primarySwatch: Colors.grey,
      primaryColor: Colors.white,
      brightness: Brightness.light,
      backgroundColor: const Color(0xFFE5E5E5),
      dividerColor: Color.fromARGB(255, 60, 60, 60),
      primaryColorDark: Colors.white,
      primaryColorLight: Color.fromARGB(255, 60, 60, 60),
      scaffoldBackgroundColor: Color.fromARGB(255, 8, 10, 11));

  ThemeData _themeData = ThemeData(primaryColor: Colors.white);
  ThemeData getTheme() => _themeData;

  ThemeNotifier() {
    StorageManager.readData('themeMode').then((value) {
      var themeMode = value ?? 'light';
      if (themeMode == 'light') {
        _themeData = lightTheme;
      } else {
        _themeData = darkTheme;
      }
      notifyListeners();
    });
  }

  void setDarkMode() async {
    _themeData = darkTheme;
    StorageManager.saveData('themeMode', 'dark');
    notifyListeners();
  }

  void setLightMode() async {
    _themeData = lightTheme;
    StorageManager.saveData('themeMode', 'light');
    notifyListeners();
  }
}
