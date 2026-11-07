import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static const String appVersion = '1.0.0+1';
  // The Python inference server runs on the development PC. Physical phones
  // must use that PC's Wi-Fi address, not their own localhost address.
  static const String defaultBaseUrl = 'http://192.168.10.242:8000';
  static const bool defaultUseMock = false;
  static const int requestTimeoutSeconds = 20;
  static const int maxImageSidePixels = 1024;
  static const int maxImageSideDataSaver = 800;

  static const List<String> supportedCrops = [
    'rice',
    'potato',
    'tomato',
    'maize',
    'wheat',
    'chili',
  ];

  static const String keyUseMock = 'config_use_mock';
  static const String keyBaseUrl = 'config_base_url';
  static const String keyDataSaver = 'config_data_saver';
  static const String keyThemeMode = 'config_theme_mode';
  static const String keyLanguage = 'config_language';
  static const String keyOnboardingComplete = 'config_onboarding_done';
}

/// State holder for developer and runtime configuration
class RuntimeConfigState {
  final bool useMock;
  final String baseUrl;
  final bool dataSaver;
  final bool isDevModeUnlocked;

  const RuntimeConfigState({
    required this.useMock,
    required this.baseUrl,
    required this.dataSaver,
    required this.isDevModeUnlocked,
  });

  RuntimeConfigState copyWith({
    bool? useMock,
    String? baseUrl,
    bool? dataSaver,
    bool? isDevModeUnlocked,
  }) {
    return RuntimeConfigState(
      useMock: useMock ?? this.useMock,
      baseUrl: baseUrl ?? this.baseUrl,
      dataSaver: dataSaver ?? this.dataSaver,
      isDevModeUnlocked: isDevModeUnlocked ?? this.isDevModeUnlocked,
    );
  }
}

class RuntimeConfigNotifier extends StateNotifier<RuntimeConfigState> {
  RuntimeConfigNotifier()
      : super(const RuntimeConfigState(
          useMock: AppConfig.defaultUseMock,
          baseUrl: AppConfig.defaultBaseUrl,
          dataSaver: false,
          isDevModeUnlocked: false,
        )) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final useMock = prefs.getBool(AppConfig.keyUseMock) ?? AppConfig.defaultUseMock;
    final savedBaseUrl = prefs.getString(AppConfig.keyBaseUrl);
    const legacyBaseUrls = {
      'http://127.0.0.1:8000',
      'http://localhost:8000',
      'https://api.cropdoc.app',
    };
    final shouldMigrateBaseUrl =
        savedBaseUrl != null && legacyBaseUrls.contains(savedBaseUrl);
    final baseUrl = shouldMigrateBaseUrl
        ? AppConfig.defaultBaseUrl
        : savedBaseUrl ?? AppConfig.defaultBaseUrl;
    if (shouldMigrateBaseUrl) {
      await prefs.setString(AppConfig.keyBaseUrl, baseUrl);
    }
    final dataSaver = prefs.getBool(AppConfig.keyDataSaver) ?? false;
    final devUnlocked = prefs.getBool('config_dev_unlocked') ?? false;

    state = RuntimeConfigState(
      useMock: useMock,
      baseUrl: baseUrl,
      dataSaver: dataSaver,
      isDevModeUnlocked: devUnlocked,
    );
  }

  Future<void> setUseMock(bool value) async {
    state = state.copyWith(useMock: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConfig.keyUseMock, value);
  }

  Future<void> setBaseUrl(String url) async {
    state = state.copyWith(baseUrl: url);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.keyBaseUrl, url);
  }

  Future<void> setDataSaver(bool enabled) async {
    state = state.copyWith(dataSaver: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConfig.keyDataSaver, enabled);
  }

  Future<void> unlockDevMode() async {
    state = state.copyWith(isDevModeUnlocked: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('config_dev_unlocked', true);
  }
}

final configProvider =
    StateNotifierProvider<RuntimeConfigNotifier, RuntimeConfigState>((ref) {
  return RuntimeConfigNotifier();
});
