import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/core/constants/storage_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._prefs) : super(ThemeMode.system) {
    _loadTheme();
  }

  final SharedPreferences _prefs;

  void _loadTheme() {
    final themeString = _prefs.getString(StorageKeys.themeMode);
    
    if (themeString == 'light') {
      emit(ThemeMode.light);
    } else if (themeString == 'dark') {
      emit(ThemeMode.dark);
    } else {
      emit(ThemeMode.system); 
    }
  }

  Future<void> changeTheme(ThemeMode mode) async {
    emit(mode);
    
    String themeString = 'system';
    if (mode == ThemeMode.light) themeString = 'light';
    if (mode == ThemeMode.dark) themeString = 'dark';
    
    await _prefs.setString(StorageKeys.themeMode, themeString);
  }
}