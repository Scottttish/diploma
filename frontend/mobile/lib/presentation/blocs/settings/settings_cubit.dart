import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_state.dart';

const _keyLocale = 'pref_locale';
const _keyTheme = 'pref_theme';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit()
      : super(
          const SettingsState(
            locale: Locale('en'),
            themeMode: ThemeMode.light,
          ),
        ) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(_keyLocale) ?? 'en';
    final themeStr = prefs.getString(_keyTheme) ?? 'light';
    emit(
      SettingsState(
        locale: Locale(localeCode),
        themeMode: themeStr == 'dark' ? ThemeMode.dark : ThemeMode.light,
      ),
    );
  }

  Future<void> setLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLocale, languageCode);
    emit(state.copyWith(locale: Locale(languageCode)));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTheme, mode == ThemeMode.dark ? 'dark' : 'light');
    emit(state.copyWith(themeMode: mode));
  }
}
