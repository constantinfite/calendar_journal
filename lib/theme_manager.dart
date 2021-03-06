import 'package:flutter/material.dart';
import 'package:calendar_journal/storage_manager.dart';

class ThemeNotifier with ChangeNotifier {
  final darkTheme = ThemeData(
    primarySwatch: Colors.grey,
    primaryColor: Color.fromARGB(255, 105, 105, 105),
    scaffoldBackgroundColor: Color.fromARGB(255, 60, 60, 60),
    brightness: Brightness.dark,
    backgroundColor: Color.fromARGB(255, 0, 0, 0),
    primaryColorDark: Color.fromARGB(255, 39, 39, 39),
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
      scaffoldBackgroundColor: Color.fromARGB(255, 241, 241, 241));

  ThemeData _themeData = ThemeData(primaryColor: Colors.white);
  ThemeData getTheme() => _themeData;

  ThemeNotifier() {
    StorageManager.readData('themeMode').then((value) {
      print('value read from storage: ' + value.toString());
      var themeMode = value ?? 'light';
      if (themeMode == 'light') {
        _themeData = lightTheme;
      } else {
        print('setting dark theme');
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
