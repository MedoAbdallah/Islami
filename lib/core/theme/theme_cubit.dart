import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:islami/core/theme/app_palette.dart';
import 'package:shared_preferences/shared_preferences.dart';

@immutable
class ThemeSettings {
  const ThemeSettings({
    this.mode = ThemeMode.dark,
    this.accent = AppAccentColor.gold,
  });

  final ThemeMode mode;
  final AppAccentColor accent;

  bool get isDark => mode == ThemeMode.dark;

  ThemeSettings copyWith({ThemeMode? mode, AppAccentColor? accent}) =>
      ThemeSettings(mode: mode ?? this.mode, accent: accent ?? this.accent);
}

class ThemeCubit extends Cubit<ThemeSettings> {
  static const _modeKey = 'theme_mode';
  static const _accentKey = 'theme_accent';

  ThemeCubit() : super(const ThemeSettings());

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString(_modeKey);
    final savedAccent = prefs.getString(_accentKey);
    emit(ThemeSettings(
      mode: savedMode == ThemeMode.light.name ? ThemeMode.light : ThemeMode.dark,
      accent: AppAccentColor.values.firstWhere(
        (color) => color.name == savedAccent,
        orElse: () => AppAccentColor.gold,
      ),
    ));
  }

  Future<void> setMode(ThemeMode mode) async {
    final nextMode = mode == ThemeMode.light ? ThemeMode.light : ThemeMode.dark;
    emit(state.copyWith(mode: nextMode));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modeKey, nextMode.name);
  }

  Future<void> setAccent(AppAccentColor accent) async {
    emit(state.copyWith(accent: accent));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accentKey, accent.name);
  }

  Future<void> toggle() => setMode(
    state.isDark ? ThemeMode.light : ThemeMode.dark,
  );
}
