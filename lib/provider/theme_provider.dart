import 'package:flutter/material.dart';
import 'package:twithub/themes/light_mode.dart';
import '../themes/dark_mode.dart';

/*
  Theme provider
  this helps us change the app from dark & light mode
*/

class ThemeProvider with ChangeNotifier {
  // initially,set it as light mode
  ThemeData _themeData = lightMode;

  // get the current theme
  ThemeData get themeDate => _themeData;

  // is it dark mode currently?
  bool get isDarkMode => themeDate == darkMode;

  //set the theme
  set themeData(ThemeData themeData) {
    _themeData = themeData;

    //update UI
    notifyListeners();
  }

  //toggle between dark & light mode
  void toggleTheme() {
    if (_themeData == lightMode) {
      themeData = darkMode;
    } else {
      themeData = lightMode;
    }
  }
}
