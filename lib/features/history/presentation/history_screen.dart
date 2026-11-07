import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/config.dart';
import '../../../core/providers/app_state_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/local_image.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/utils/string_extensions.dart';
import '../../../data/models/history_scan.dart';
import '../../../data/models/prediction_response.dart';
import '../../../data/repositories/history_repository.dart';
import '../../../../l10n/app_localizations.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCrop;
  PredictionStatus? _selectedStatus;

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
    final ext =
        theme.extension<CropDocThemeExtension>() ?? CropDocThemeExtension.light;
    final locale = ref.watch(localeProvider) ?? Localizations.localeOf(context);
    final isBangla = locale.languageCode == 'bn';

    final allScans = ref.watch(historyListProvider);

    // Apply filtering & searching
    final filteredScans = allScans.where((scan) {
      if (_selectedCrop != null &&
          scan.crop.toLowerCase() != _selectedCrop!.toLowerCase()) {
        return false;
      }
      if (_selectedStatus != null && scan.status != _selectedStatus) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchCrop = scan.crop.toLowerCase().contains(q);
        final matchDisease = scan.disease.toLowerCase().contains(q);
        return matchCrop || matchDisease;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.historyTitle ?? 'Diagnosis History'),
        actions: [
          if (allScans.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.file_download_outlined),
              tooltip: l10n?.exportCsv ?? 'Export to CSV',
              onPressed: () {
                AppHaptics.selectionClick();
                ref.read(historyListProvider.notifier).exportCsv();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter header
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
                hintText: l10n?.searchScansHint ?? 'Search crop or disease...',
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Horizontal filter chips (Crop & Status)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                // Filter by Crop
                ChoiceChip(
                  label: Text(l10n?.filterAllCrops ?? 'All Crops'),
                  selected: _selectedCrop == null,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedCrop = null);
                    }
                  },
                ),
                const SizedBox(width: 8),
                ...AppConfig.supportedCrops.map((crop) {
                  final isSelected =
                      _selectedCrop?.toLowerCase() == crop.toLowerCase();
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(crop.capitalizeWords()),
                      selected: isSelected,
                      onSelected: (sel) {
                        setState(() {
                          _selectedCrop = sel ? crop : null;
                        });
                      },
                    ),
                  );
                }),
                const SizedBox(width: 8),
                // Filter by Status
                ChoiceChip(
                  label: Text(l10n?.filterAllStatuses ?? 'All Statuses'),
                  selected: _selectedStatus == null,
                  onSelected: (sel) {
                    if (sel) setState(() => _selectedStatus = null);
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text(l10n?.statusConfident ?? 'Confirmed'),
                  selected: _selectedStatus == PredictionStatus.confident,
                  onSelected: (sel) {
                    setState(() {
                      _selectedStatus = sel ? PredictionStatus.confident : null;
                    });
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text(l10n?.statusUncertain ?? 'Uncertain'),
                  selected: _selectedStatus == PredictionStatus.uncertain,
                  onSelected: (sel) {
                    setState(() {
                      _selectedStatus = sel ? PredictionStatus.uncertain : null;
                    });
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text(l10n?.statusUnknown ?? 'Unknown'),
                  selected: _selectedStatus == PredictionStatus.unknown,
                  onSelected: (sel) {
                    setState(() {
                      _selectedStatus = sel ? PredictionStatus.unknown : null;
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Scan list
          Expanded(
            child: filteredScans.isEmpty
                ? _buildEmptyState(theme, isDark, l10n, allScans.isEmpty)
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: filteredScans.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final scan = filteredScans[index];
                      return Dismissible(
                        key: ValueKey(scan.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: AppColors.statusUnknown,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.white,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text(l10n?.deleteScan ?? 'Delete Scan'),
                              content: Text(
                                l10n?.deleteScanConfirm ??
                                    'Delete this diagnosis from history?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: Text(l10n?.cancel ?? 'Cancel'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.statusUnknown,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: Text(l10n?.delete ?? 'Delete'),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) {
                          ref
                              .read(historyListProvider.notifier)
                              .deleteScan(scan.id);
                        },
                        child: _HistoryCard(
                          scan: scan,
                          isBangla: isBangla,
                          ext: ext,
                          isDark: isDark,
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
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    ThemeData theme,
    bool isDark,
    AppLocalizations? l10n,
    bool isCompletelyEmpty,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCompletelyEmpty
                  ? Icons.folder_open_rounded
                  : Icons.search_off_rounded,
              size: 64,
              color: isDark
                  ? AppColors.textDisabledDark
                  : AppColors.textDisabledLight,
            ),
            const SizedBox(height: 16),
            Text(
              isCompletelyEmpty
                  ? (l10n?.noHistoryEmpty ?? 'No diagnosis history yet.')
                  : (l10n?.noHistoryFound ??
                        'No scans match your search or filter.'),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final HistoryScan scan;
  final bool isBangla;
  final CropDocThemeExtension ext;
  final bool isDark;
  final VoidCallback onTap;

  const _HistoryCard({
    required this.scan,
    required this.isBangla,
    required this.ext,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormatted = DateFormat('MMM dd, yyyy • hh:mm a')
        .format(scan.timestamp);

    final Color statusColor;
    final Color statusBg;
    final String statusLabel;

    switch (scan.status) {
      case PredictionStatus.confident:
        statusColor = ext.confidentColor;
        statusBg = ext.confidentBg;
        statusLabel = isBangla ? 'শনাক্তকৃত' : 'Confirmed';
        break;
      case PredictionStatus.uncertain:
        statusColor = ext.uncertainColor;
        statusBg = ext.uncertainBg;
        statusLabel = isBangla ? 'অনিশ্চিত' : 'Uncertain';
        break;
      case PredictionStatus.unknown:
        statusColor = ext.unknownColor;
        statusBg = ext.unknownBg;
        statusLabel = isBangla ? 'অচেনা' : 'Unknown';
        break;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 68,
                  height: 68,
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
              const SizedBox(width: 14),
              // Metadata
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          scan.crop.capitalizeWords(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.accentLime
                                : AppColors.primaryGreen,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      scan.disease.replaceAll('_', ' ').capitalizeWords(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dateFormatted,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.textDisabledDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        if (scan.status == PredictionStatus.confident)
                          Text(
                            '${(scan.confidence * 100).toInt()}% match',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
