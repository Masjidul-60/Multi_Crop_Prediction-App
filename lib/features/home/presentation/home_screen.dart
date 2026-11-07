import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/config.dart';
import '../../../core/widgets/local_image.dart';
import '../../../core/providers/app_state_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/haptics.dart';
import '../../../data/models/history_scan.dart';
import '../../../data/models/prediction_response.dart';
import '../../../data/repositories/history_repository.dart';
import '../../../../l10n/app_localizations.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _pickFromGallery(BuildContext context) async {
    AppHaptics.selectionClick();
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null && context.mounted) {
      context.push('/analyzing', extra: picked);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final locale = ref.watch(localeProvider) ?? Localizations.localeOf(context);
    final isBangla = locale.languageCode == 'bn';

    final recentScans = ref.watch(historyListProvider);
    final confirmedScans = recentScans
        .where((scan) => scan.status == PredictionStatus.confident)
        .length;
    final cropsScanned = recentScans
        .map((scan) => scan.crop.toLowerCase())
        .toSet()
        .length;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(historyListProvider.notifier).load();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.primaryGreenDark
                                      : AppColors.statusConfidentBg,
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                child: const Icon(
                                  Icons.eco_rounded,
                                  color: AppColors.primaryGreen,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 9),
                              Text(
                                l10n?.appTitle ?? 'CropDoc',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? AppColors.accentLime
                                      : AppColors.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n?.homeGreeting ?? 'Hello, Farmer',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n?.homeSubtitle ??
                                'Check your crop\'s health today',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Material(
                      color: isDark
                          ? AppColors.surfaceVariantDark
                          : AppColors.surfaceLight,
                      shape: const CircleBorder(),
                      child: IconButton(
                        icon: const Icon(Icons.settings_outlined),
                        tooltip: l10n?.navSettings ?? 'Settings',
                        onPressed: () => context.go('/settings'),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 300.ms),

                const SizedBox(height: 24),

                // Primary "Scan a Leaf" & Secondary "Choose from gallery" Action Card
                Container(
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=1200&q=85',
                          ),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGreen.withValues(
                              alpha: 0.25,
                            ),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [
                                    const Color(0xED10281A),
                                    const Color(0xD9163E26),
                                  ]
                                : [
                                    const Color(0xE61F6F43),
                                    const Color(0xCC13502E),
                                  ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.auto_awesome_rounded,
                                      color: AppColors.accentLime,
                                      size: 15,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      isBangla
                                          ? 'স্মার্ট ফসল পরিচর্যা'
                                          : 'SMART CROP CARE',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.6,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentLime.withValues(
                                      alpha: 0.2,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    color: AppColors.accentLime,
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    isBangla
                                        ? 'মুহূর্তের মধ্যে পাতার রোগ নির্ণয় করুন'
                                        : 'Diagnose leaf diseases instantly with AI',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentLime,
                                foregroundColor: const Color(0xFF0F321C),
                                elevation: 0,
                                minimumSize: const Size.fromHeight(54),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () {
                                AppHaptics.lightImpact();
                                context.push('/capture');
                              },
                              icon: const Icon(
                                Icons.center_focus_strong_rounded,
                                size: 22,
                              ),
                              label: Text(
                                l10n?.btnScanLeaf ?? 'Scan a Leaf',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(
                                  color: Colors.white70,
                                  width: 1.2,
                                ),
                                minimumSize: const Size.fromHeight(48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () => _pickFromGallery(context),
                              icon: const Icon(
                                Icons.photo_library_outlined,
                                size: 20,
                              ),
                              label: Text(
                                l10n?.btnChooseGallery ?? 'Choose from Gallery',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .animate()
                    .slideY(begin: 0.08, end: 0, duration: 350.ms)
                    .fadeIn(),

                const SizedBox(height: 26),

                _SectionHeading(
                  title: isBangla
                      ? 'আপনার ফসলের সারাংশ'
                      : 'Your field snapshot',
                  subtitle: isBangla
                      ? 'আপনার সংরক্ষিত স্ক্যান থেকে'
                      : 'Based on your saved scans',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _DashboardStatCard(
                        icon: Icons.document_scanner_outlined,
                        value: '${recentScans.length}',
                        label: isBangla ? 'মোট স্ক্যান' : 'Total scans',
                        color: AppColors.primaryGreen,
                        background: isDark
                            ? AppColors.statusConfidentBgDark
                            : AppColors.statusConfidentBg,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _DashboardStatCard(
                        icon: Icons.verified_outlined,
                        value: '$confirmedScans',
                        label: isBangla ? 'নিশ্চিত ফল' : 'Clear matches',
                        color: isDark
                            ? AppColors.accentLime
                            : AppColors.primaryGreen,
                        background: isDark
                            ? const Color(0xFF293728)
                            : const Color(0xFFF0F5DE),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _DashboardStatCard(
                        icon: Icons.grass_rounded,
                        value: '$cropsScanned',
                        label: isBangla ? 'পরীক্ষিত ফসল' : 'Crops checked',
                        color: const Color(0xFFB36B24),
                        background: isDark
                            ? const Color(0xFF3A2D20)
                            : const Color(0xFFFFF1DF),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                _SectionHeading(
                  title: l10n?.supportedCropsTitle ?? 'Supported Crops',
                  subtitle: isBangla
                      ? 'আপনার ফসলের জন্য অফলাইন নির্দেশিকা'
                      : 'Explore the offline crop library',
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: AppConfig.supportedCrops.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cropKey = AppConfig.supportedCrops[index];
                      final localizedCrop = _localizeCropName(
                        cropKey,
                        isBangla,
                      );
                      return ActionChip(
                        avatar: const Icon(
                          Icons.spa_rounded,
                          size: 16,
                          color: AppColors.primaryGreen,
                        ),
                        label: Text(localizedCrop),
                        onPressed: () {
                          AppHaptics.selectionClick();
                          context.go('/guide');
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 28),

                _SectionHeading(
                  title: isBangla ? 'দ্রুত প্রবেশ' : 'Quick access',
                  subtitle: isBangla
                      ? 'আপনার প্রয়োজনীয় টুলগুলো এক জায়গায়'
                      : 'Your most-used tools, all in one place',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _QuickAccessCard(
                        icon: Icons.menu_book_rounded,
                        title: isBangla ? 'ফসল নির্দেশিকা' : 'Crop library',
                        subtitle: isBangla
                            ? 'ফসল ও রোগ সম্পর্কে জানুন'
                            : 'Browse crops and diseases',
                        color: const Color(0xFF5C65B8),
                        background: isDark
                            ? const Color(0xFF292A43)
                            : const Color(0xFFEEEEFF),
                        onTap: () => context.go('/guide'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickAccessCard(
                        icon: Icons.history_rounded,
                        title: isBangla ? 'স্ক্যান ইতিহাস' : 'Scan history',
                        subtitle: isBangla
                            ? 'আগের ফলাফল দেখুন'
                            : 'Review your past results',
                        color: const Color(0xFFB36B24),
                        background: isDark
                            ? const Color(0xFF3A2D20)
                            : const Color(0xFFFFF1DF),
                        onTap: () => context.go('/history'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Photography Tips Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceVariantDark
                        : const Color(0xFFF0EFE6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.statusUncertain.withValues(
                            alpha: 0.15,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lightbulb_outline_rounded,
                          color: AppColors.statusUncertain,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n?.tipCardTitle ?? 'Photography Tip',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n?.tipCardContent ?? 'Focus on a single leaf with good daylight. Wipe dirty lenses and avoid blurry movement.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Recent Scans Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n?.recentScansTitle ?? 'Recent Scans',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (recentScans.isNotEmpty)
                      TextButton(
                        onPressed: () => context.go('/history'),
                        child: Text(l10n?.viewAll ?? 'View All'),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                if (recentScans.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 36,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.history_toggle_off_rounded,
                          size: 44,
                          color: isDark
                              ? AppColors.textDisabledDark
                              : AppColors.textDisabledLight,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n?.noRecentScans ?? 'No recent scans yet. Tap "Scan a Leaf" to begin.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  SizedBox(
                    height: 160,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: recentScans.length > 5
                          ? 5
                          : recentScans.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final scan = recentScans[index];
                        return _RecentScanCard(
                          scan: scan,
                          isBangla: isBangla,
                          onTap: () {
                            AppHaptics.selectionClick();
                            context.push(
                              '/result',
                              extra: {
                                'response': scan.predictionResponse,
                                'imagePath': scan.imagePath,
                                'scanId': scan.id,
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _localizeCropName(String cropKey, bool isBangla) {
    if (!isBangla) {
      return cropKey[0].toUpperCase() + cropKey.substring(1);
    }
    switch (cropKey.toLowerCase()) {
      case 'rice':
        return 'ধান';
      case 'potato':
        return 'আলু';
      case 'tomato':
        return 'টমেটো';
      case 'maize':
        return 'ভুট্টা';
      case 'wheat':
        return 'গম';
      case 'chili':
        return 'মরিচ';
      default:
        return cropKey;
    }
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeading({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}

class _DashboardStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color background;

  const _DashboardStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(minHeight: 112),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? AppColors.borderDark
              : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.brightness == Brightness.dark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.background,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          constraints: const BoxConstraints(minHeight: 132),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentScanCard extends StatelessWidget {
  final HistoryScan scan;
  final bool isBangla;
  final VoidCallback onTap;

  const _RecentScanCard({
    required this.scan,
    required this.isBangla,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext =
        theme.extension<CropDocThemeExtension>() ?? CropDocThemeExtension.light;
    final isDark = theme.brightness == Brightness.dark;

    final Color statusColor;
    final Color statusBg;
    final String statusText;

    switch (scan.status) {
      case PredictionStatus.confident:
        statusColor = ext.confidentColor;
        statusBg = ext.confidentBg;
        statusText = isBangla ? 'শনাক্তকৃত' : 'Confirmed';
        break;
      case PredictionStatus.uncertain:
        statusColor = ext.uncertainColor;
        statusBg = ext.uncertainBg;
        statusText = isBangla ? 'অনিশ্চিত' : 'Uncertain';
        break;
      case PredictionStatus.unknown:
        statusColor = ext.unknownColor;
        statusBg = ext.unknownBg;
        statusText = isBangla ? 'অচেনা' : 'Unknown';
        break;
    }

    final dateFormatted = DateFormat('dd MMM, hh:mm a').format(scan.timestamp);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with status badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 72,
                    width: double.infinity,
                    color: isDark
                        ? AppColors.surfaceVariantDark
                        : Colors.grey.shade200,
                    child: LocalImage(
                      path: scan.imagePath,
                      fallback: const Icon(
                        Icons.spa_rounded,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              scan.disease.replaceAll('_', ' '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const Spacer(),
            Text(
              dateFormatted,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10,
                color: isDark
                    ? AppColors.textDisabledDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
