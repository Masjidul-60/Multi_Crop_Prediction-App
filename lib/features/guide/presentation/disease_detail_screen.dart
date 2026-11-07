import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_state_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/crop_disease_info.dart';
import '../../../../l10n/app_localizations.dart';

class DiseaseDetailScreen extends ConsumerWidget {
  final CropDiseaseInfo info;

  const DiseaseDetailScreen({
    super.key,
    required this.info,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final locale = ref.watch(localeProvider) ?? Localizations.localeOf(context);
    final isBangla = locale.languageCode == 'bn';

    final cropName = info.getCropName(isBangla);
    final diseaseName = info.getDiseaseName(isBangla);
    final description = info.getDescription(isBangla);
    final symptoms = info.getSymptoms(isBangla);
    final whatToDo = info.getWhatToDo(isBangla);

    return Scaffold(
      appBar: AppBar(
        title: Text(diseaseName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Crop Badge & Title
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.primaryGreenDark : AppColors.statusConfidentBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${l10n?.cropLabel ?? 'Crop'}: $cropName',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              diseaseName,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 24),

            // Symptoms section
            Text(
              l10n?.symptomsTitle ?? 'Symptoms & Indicators',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Column(
                children: symptoms
                    .map((s) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 5),
                                child: Icon(Icons.circle, size: 6, color: AppColors.primaryGreen),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(s, style: const TextStyle(fontSize: 13, height: 1.4)),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),

            const SizedBox(height: 24),

            // What to do next section (from knowledge JSON)
            Text(
              l10n?.whatToDoTitle ?? 'What To Do Next',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Column(
                children: [
                  ...whatToDo.map((step) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 3),
                              child: Icon(Icons.arrow_right_rounded,
                                  size: 18, color: AppColors.primaryGreen),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                step,
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.4,
                                  fontWeight: step.contains('TODO')
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: step.contains('TODO')
                                      ? AppColors.statusUncertain
                                      : (isDark ? Colors.white : AppColors.textPrimaryLight),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 12),
                  // Fixed extension officer notice
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.primaryGreenDark : AppColors.statusConfidentBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.shield_outlined, size: 18, color: AppColors.primaryGreen),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n?.extensionOfficerNotice ??
                                'Confirm with a local agricultural extension officer before spraying anything.',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
