import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._prefs)
    : super(
        _prefs.getBool(_darkKey) == true ? ThemeMode.dark : ThemeMode.light,
      );

  final SharedPreferences _prefs;

  static const _darkKey = 'dark_theme';

  bool get isDark => state == ThemeMode.dark;

  Future<void> setDark(bool value) async {
    emit(value ? ThemeMode.dark : ThemeMode.light);
    await _prefs.setBool(_darkKey, value);
  }
}
