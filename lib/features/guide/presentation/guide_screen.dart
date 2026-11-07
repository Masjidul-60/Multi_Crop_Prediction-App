import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config.dart';
import '../../../core/providers/app_state_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/utils/string_extensions.dart';
import '../../../data/models/crop_disease_info.dart';
import '../../../data/repositories/disease_knowledge_repository.dart';
import '../../../../l10n/app_localizations.dart';

class GuideScreen extends ConsumerStatefulWidget {
  const GuideScreen({super.key});

  @override
  ConsumerState<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends ConsumerState<GuideScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCrop;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final locale = ref.watch(localeProvider) ?? Localizations.localeOf(context);
    final isBangla = locale.languageCode == 'bn';

    final repo = ref.watch(diseaseKnowledgeRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.guideTitle ?? 'Crop Library'),
      ),
      body: FutureBuilder<List<CropDiseaseInfo>>(
        future: _searchQuery.isNotEmpty
            ? repo.search(_searchQuery, isBangla)
            : (_selectedCrop != null
                ? repo.getByCrop(_selectedCrop!)
                : repo.getAll()),
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];
          final isLoading = snapshot.connectionState == ConnectionState.waiting;

          return Column(
            children: [
              // Search input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: l10n?.searchGuideHint ?? 'Search crops or diseases...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                  ),
                ),
              ),

              // Filter by crop chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    ChoiceChip(
                      label: Text(l10n?.filterAllCrops ?? 'All Crops'),
                      selected: _selectedCrop == null && _searchQuery.isEmpty,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedCrop = null;
                            _searchQuery = '';
                            _searchController.clear();
                          });
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    ...AppConfig.supportedCrops.map((crop) {
                      final isSelected = _selectedCrop?.toLowerCase() == crop.toLowerCase();
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(crop.capitalizeWords()),
                          selected: isSelected,
                          onSelected: (sel) {
                            setState(() {
                              _selectedCrop = sel ? crop : null;
                              _searchQuery = '';
                              _searchController.clear();
                            });
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // List of diseases
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                    : items.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                l10n?.noDiseasesFound ?? 'No entries found.',
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: items.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final info = items[index];
                              return _DiseaseLibraryCard(
                                info: info,
                                isBangla: isBangla,
                                isDark: isDark,
                                onTap: () {
                                  AppHaptics.selectionClick();
                                  context.push('/guide/detail', extra: info);
                                },
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DiseaseLibraryCard extends StatelessWidget {
  final CropDiseaseInfo info;
  final bool isBangla;
  final bool isDark;
  final VoidCallback onTap;

  const _DiseaseLibraryCard({
    required this.info,
    required this.isBangla,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cropName = info.getCropName(isBangla);
    final diseaseName = info.getDiseaseName(isBangla);
    final desc = info.getDescription(isBangla);
    final isHealthy = info.disease == 'healthy';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.primaryGreenDark : AppColors.statusConfidentBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      cropName,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                  Icon(
                    isHealthy ? Icons.check_circle_outline_rounded : Icons.spa_outlined,
                    size: 18,
                    color: isHealthy ? AppColors.primaryGreen : AppColors.accentLimeDark,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                diseaseName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
