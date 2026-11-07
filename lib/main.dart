import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/config.dart';
import 'core/providers/app_state_providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/disease_knowledge_repository.dart';
import 'data/repositories/history_repository.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local Hive storage
  await Hive.initFlutter();

  // Initialize SharedPreferences and knowledge repository
  final prefs = await SharedPreferences.getInstance();
  final isOnboardingDone = prefs.getBool(AppConfig.keyOnboardingComplete) ?? false;

  final knowledgeRepo = DiseaseKnowledgeRepository();
  await knowledgeRepo.init();

  final historyRepo = HistoryRepository();
  await historyRepo.init();

  runApp(
    ProviderScope(
      overrides: [
        diseaseKnowledgeRepositoryProvider.overrideWithValue(knowledgeRepo),
        historyRepositoryProvider.overrideWithValue(historyRepo),
      ],
      child: CropDocApp(showOnboardingFirst: !isOnboardingDone),
    ),
  );
}

class CropDocApp extends ConsumerWidget {
  final bool showOnboardingFirst;

  const CropDocApp({
    super.key,
    required this.showOnboardingFirst,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final activeLocale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'CropDoc',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      themeMode: themeMode,
      theme: AppTheme.lightTheme(activeLocale),
      darkTheme: AppTheme.darkTheme(activeLocale),
      locale: activeLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        // Enforce accessible text scaling clamped between 1.0x and 1.5x
        final mediaQueryData = MediaQuery.of(context);
        final clampedScale = mediaQueryData.textScaler.clamp(
          minScaleFactor: 1.0,
          maxScaleFactor: 1.5,
        );

        return MediaQuery(
          data: mediaQueryData.copyWith(textScaler: clampedScale),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
