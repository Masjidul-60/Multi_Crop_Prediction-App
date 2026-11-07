import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConfig.keyOnboardingComplete, true);
    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final slides = [
      _OnboardingSlideData(
        icon: Icons.eco_rounded,
        title: l10n?.onboardingTitle1 ?? 'Identify Crop Diseases Fast',
        description: l10n?.onboardingDesc1 ??
            'Photograph any crop leaf to detect diseases early, safeguard crops, and avoid yield loss.',
        badgeColor: AppColors.primaryGreen,
      ),
      _OnboardingSlideData(
        icon: Icons.camera_enhance_rounded,
        title: l10n?.onboardingTitle2 ?? 'Take Clear Leaf Photos',
        description: l10n?.onboardingDesc2 ??
            'Capture a single leaf in bright natural light. Fill the frame and avoid casting dark shadows.',
        badgeColor: const Color(0xFF2E8F59),
      ),
      _OnboardingSlideData(
        icon: Icons.verified_user_rounded,
        title: l10n?.onboardingTitle3 ?? 'Important Advisory Notice',
        description: l10n?.onboardingDesc3 ??
            'AI estimates can be wrong. Always confirm with an agricultural expert before spraying or taking critical steps.',
        badgeColor: AppColors.statusUncertain,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (_currentIndex < slides.length - 1)
            TextButton(
              onPressed: _completeOnboarding,
              child: Text(
                l10n?.btnSkip ?? 'Skip',
                style: TextStyle(
                  color: isDark ? AppColors.accentLime : AppColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: slides.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final slide = slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: slide.badgeColor.withValues(alpha: 0.12),
                            border: Border.all(
                              color: slide.badgeColor.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            slide.icon,
                            size: 72,
                            color: slide.badgeColor,
                          ),
                        )
                            .animate(key: ValueKey(index))
                            .scale(duration: 400.ms, curve: Curves.easeOutBack)
                            .fadeIn(duration: 300.ms),
                        const SizedBox(height: 36),
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        )
                            .animate(key: ValueKey('title_$index'))
                            .fadeIn(duration: 350.ms)
                            .slideY(begin: 0.15, end: 0),
                        const SizedBox(height: 16),
                        Text(
                          slide.description,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                            height: 1.5,
                          ),
                        )
                            .animate(key: ValueKey('desc_$index'))
                            .fadeIn(duration: 400.ms)
                            .slideY(begin: 0.1, end: 0),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Page indicators and action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(slides.length, (index) {
                      final isActive = index == _currentIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: isActive
                              ? (isDark
                                  ? AppColors.accentLime
                                  : AppColors.primaryGreen)
                              : (isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: () {
                      if (_currentIndex < slides.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _completeOnboarding();
                      }
                    },
                    child: Text(
                      _currentIndex == slides.length - 1
                          ? (l10n?.btnGetStarted ?? 'Get Started')
                          : (l10n?.btnNext ?? 'Next'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlideData {
  final IconData icon;
  final String title;
  final String description;
  final Color badgeColor;

  const _OnboardingSlideData({
    required this.icon,
    required this.title,
    required this.description,
    required this.badgeColor,
  });
}
