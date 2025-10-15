import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants.dart';

/// Provider pour le thème de l'application
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

/// Notifier pour gérer le thème
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  /// Chargement du thème depuis SharedPreferences
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(AppConstants.themeKey) ?? 0;
    state = ThemeMode.values[themeIndex];
  }

  /// Sauvegarde du thème dans SharedPreferences
  Future<void> _saveThemeMode(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.themeKey, themeMode.index);
  }

  /// Changement du thème
  Future<void> setThemeMode(ThemeMode themeMode) async {
    state = themeMode;
    await _saveThemeMode(themeMode);
  }

  /// Basculement entre thème clair et sombre
  Future<void> toggleTheme() async {
    final newTheme = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newTheme);
  }

  /// Vérification si le thème est sombre
  bool get isDarkMode => state == ThemeMode.dark;

  /// Vérification si le thème est clair
  bool get isLightMode => state == ThemeMode.light;

  /// Vérification si le thème suit le système
  bool get isSystemMode => state == ThemeMode.system;
}

