import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sorun_takip_sistemi/core/enums/enums.dart';

final themeNotifierProvider = StateNotifierProvider((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier {
  ThemeModeEnum _mode;
  ThemeNotifier({ThemeModeEnum mode = ThemeModeEnum.dark})
      : _mode = mode,
        super(
          FlexThemeData.dark(
            scheme: FlexScheme.amber,
            appBarElevation: 2,
          ),
        ) {
    getTheme();
  }

  ThemeModeEnum get mode => _mode;

  void getTheme() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final theme = preferences.get("theme");

    if (theme == "light") {
      _mode = ThemeModeEnum.light;
      state = FlexThemeData.light(
        scheme: FlexScheme.amber,
        appBarElevation: 2,
      );
    } else {
      _mode = ThemeModeEnum.dark;
      state = FlexThemeData.dark(
        scheme: FlexScheme.amber,
        appBarElevation: 2,
      );
    }
  }

  void toggleTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (_mode == ThemeModeEnum.dark) {
      _mode = ThemeModeEnum.light;
      state = FlexThemeData.light(
        scheme: FlexScheme.amber,
        appBarElevation: 2,
      );
      prefs.setString('theme', 'light');
    } else {
      _mode = ThemeModeEnum.dark;
      state = FlexThemeData.dark(
        scheme: FlexScheme.amber,
        appBarElevation: 2,
      );
      prefs.setString('theme', 'dark');
    }
  }
}
