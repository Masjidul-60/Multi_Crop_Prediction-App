import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

// Locale Provider (Bangla default!)
class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier() : super(const Locale('bn')) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString(AppConfig.keyLanguage);
    if (lang != null && lang.isNotEmpty) {
      if (lang == 'system') {
        state = null;
      } else {
        state = Locale(lang);
      }
    } else {
      state = const Locale('bn'); // Bangla default
    }
  }

  Future<void> setLocale(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.keyLanguage, langCode);
    if (langCode == 'system') {
      state = null;
    } else {
      state = Locale(langCode);
    }
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  return LocaleNotifier();
});

// Theme Mode Provider
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString(AppConfig.keyThemeMode);
    if (mode == 'light') {
      state = ThemeMode.light;
    } else if (mode == 'dark') {
      state = ThemeMode.dark;
    } else {
      state = ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    final String modeStr = mode == ThemeMode.light
        ? 'light'
        : mode == ThemeMode.dark
            ? 'dark'
            : 'system';
    await prefs.setString(AppConfig.keyThemeMode, modeStr);
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

// Connectivity Provider
final connectivityStreamProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map((results) {
    return results.any((r) => r != ConnectivityResult.none);
  });
});

// Offline Queue Model & Provider
class QueuedScan {
  final String id;
  final String imagePath;
  final DateTime timestamp;

  const QueuedScan({
    required this.id,
    required this.imagePath,
    required this.timestamp,
  });
}

class OfflineQueueNotifier extends StateNotifier<List<QueuedScan>> {
  OfflineQueueNotifier() : super([]);

  void add(String imagePath) {
    final scan = QueuedScan(
      id: 'queue_${DateTime.now().millisecondsSinceEpoch}',
      imagePath: imagePath,
      timestamp: DateTime.now(),
    );
    state = [...state, scan];
  }

  void remove(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  void clear() {
    state = [];
  }
}

final offlineQueueProvider =
    StateNotifierProvider<OfflineQueueNotifier, List<QueuedScan>>((ref) {
  return OfflineQueueNotifier();
});
