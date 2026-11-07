import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/crop_disease_info.dart';
import '../../data/models/prediction_response.dart';
import '../../features/analyzing/presentation/analyzing_screen.dart';
import '../../features/capture/presentation/capture_screen.dart';
import '../../features/guide/presentation/disease_detail_screen.dart';
import '../../features/guide/presentation/guide_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/result/presentation/result_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/shell/presentation/shell_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ShellScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/guide',
                builder: (context, state) => const GuideScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/capture',
        builder: (context, state) => const CaptureScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/analyzing',
        builder: (context, state) {
          final extra = state.extra;
          final imageFile = extra is XFile
              ? extra
              : XFile(extra is String ? extra : '');
          return AnalyzingScreen(imageFile: imageFile);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/result',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final response =
              extra['response'] as PredictionResponse? ??
              const PredictionResponse(
                requestId: 'empty',
                crop: CropConfidence(name: 'unknown', confidence: 0),
                predictions: [],
                status: PredictionStatus.unknown,
                reasons: [],
                modelVersion: 'v1.0.0',
                inferenceMs: 0,
              );
          final imagePath = extra['imagePath'] as String?;
          final scanId = extra['scanId'] as String?;

          return ResultScreen(
            response: response,
            imagePath: imagePath,
            scanId: scanId,
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/guide/detail',
        builder: (context, state) {
          final info = state.extra as CropDiseaseInfo;
          return DiseaseDetailScreen(info: info);
        },
      ),
    ],
  );
});
