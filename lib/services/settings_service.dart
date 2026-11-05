import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  SettingsService();

  SharedPreferences? _prefs;

  /// Idempotent: safe to call from anywhere, any number of times.
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  ThemeMode readTheme() {
    final p = _prefs;
    if (p == null) return ThemeMode.system;
    final raw = p.getString('theme');
    return switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setTheme(ThemeMode mode) async {
    await init();
    await _prefs!.setString('theme', switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'system',
    });
  }

  Future<void> setSeenIntro(bool seen) async {
    await init();
    await _prefs!.setBool('seen_intro', seen);
  }

  bool getSeenIntro() {
    final p = _prefs;
    return p?.getBool('seen_intro') ?? false;
  }
}
