import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode =
      ThemeMode.light; // Artık standart olarak Açık Renk açılsın

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    notifyListeners(); // Tema değiştiği an uygulamaya "kendini güncelle" haberini gönderir
  }
}
