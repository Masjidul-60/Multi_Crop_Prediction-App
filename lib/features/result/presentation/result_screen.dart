import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/providers/app_state_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/widgets/local_image.dart';
import '../../../core/utils/string_extensions.dart';
import '../../../data/api/prediction_service.dart';
import '../../../data/models/crop_disease_info.dart';
import '../../../data/models/prediction_response.dart';
import '../../../data/repositories/disease_knowledge_repository.dart';
import '../../../data/repositories/history_repository.dart';
import '../../../../l10n/app_localizations.dart';
import 'confidence_ring.dart';

class ResultScreen extends ConsumerStatefulWidget {
  final PredictionResponse response;
  final String? imagePath;
  final String? scanId;

  const ResultScreen({
    super.key,
    required this.response,
    this.imagePath,
    this.scanId,
  });

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  CropDiseaseInfo? _knowledgeInfo;
  bool _isReported = false;

  @override
  void initState() {
    super.initState();
    _loadKnowledge();
  }

  Future<void> _loadKnowledge() async {
    final topPred = widget.response.topPrediction;
    if (topPred != null) {
      final repo = ref.read(diseaseKnowledgeRepositoryProvider);
      final info = await repo.getInfo(topPred.label);
      if (mounted) {
        setState(() {
          _knowledgeInfo = info;
        });
      }
    }
  }

  Future<void> _shareResult(bool isBangla) async {
    AppHaptics.selectionClick();
    final topPred = widget.response.topPrediction;
    final status = widget.response.status;

    final String text;
    if (status == PredictionStatus.confident && _knowledgeInfo != null) {
      final crop = _knowledgeInfo!.getCropName(isBangla);
      final disease = _knowledgeInfo!.getDiseaseName(isBangla);
      final conf = ((topPred?.confidence ?? 0) * 100).toInt();
      text =
          'CropDoc Diagnosis:\nCrop: $crop\nCondition: $disease ($conf% match)\n\nDisclaimer: AI estimate, not an official agricultural diagnosis.';
    } else if (status == PredictionStatus.uncertain) {
      text = 'CropDoc Scan: Uncertain Diagnosis.\nPossible matches detected with low confidence.\n\nDisclaimer: AI estimate, not an official agricultural diagnosis.';
    } else {
      text = 'CropDoc Scan: Leaf Not Recognised.\nCould not match to supported crop diseases.\n\nDisclaimer: AI estimate, not an official agricultural diagnosis.';
    }

    if (!kIsWeb &&
        widget.imagePath != null &&
        File(widget.imagePath!).existsSync()) {
      await Share.shareXFiles(
        [XFile(widget.imagePath!)],
        text: text,
        subject: 'CropDoc Leaf Diagnosis',
      );
    } else {
      await Share.share(text, subject: 'CropDoc Leaf Diagnosis');
    }
  }

  Future<void> _showReportWrongDialog(AppLocalizations? l10n) async {
    AppHaptics.selectionClick();
    final textController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(
              Icons.report_problem_rounded,
              color: AppColors.statusUncertain,
            ),
            const SizedBox(width: 8),
            Text(l10n?.reportDialogTitle ?? 'Report Incorrect Diagnosis'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.reportDialogNote ?? 'Tell us what you believe the correct diagnosis is (optional):',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'e.g. Zinc deficiency, water stress...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n?.btnSubmit ?? 'Submit'),
          ),
        ],
      ),
    );

    if (result == true) {
      final comment = textController.text.trim();
      if (widget.scanId != null) {
        await ref
            .read(historyListProvider.notifier)
            .markScanWrong(widget.scanId!, comment);
      }

      // Call API stub
      final service = ref.read(predictionServiceProvider);
      await service.submitFeedback(
        requestId: widget.response.requestId,
        isCorrect: false,
        note: comment.isNotEmpty ? comment : null,
      );

      if (!mounted) return;

      setState(() {
        _isReported = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n?.feedbackSubmitted ?? 'Feedback recorded locally. Thank you!',
          ),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    }
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

    final status = widget.response.status;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.appTitle ?? 'CropDoc Result'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: l10n?.btnShare ?? 'Share',
            onPressed: () => _shareResult(isBangla),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner according to status
            _buildStatusHeader(status, ext, isDark, l10n, isBangla),

            const SizedBox(height: 20),

            // Captured Leaf Image Thumbnail (if available)
            if (widget.imagePath != null &&
                (kIsWeb || File(widget.imagePath!).existsSync()))
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    color: Colors.black12,
                    child: LocalImage(
                      path: widget.imagePath!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms),

            const SizedBox(height: 20),

            // Top predictions bar chart
            if (status != PredictionStatus.unknown &&
                widget.response.predictions.isNotEmpty)
              _buildTopPredictionsSection(
                theme,
                ext,
                isDark,
                l10n,
                isBangla,
              ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05, end: 0),

            const SizedBox(height: 24),

            // Symptoms & Indicators (from diseases.json)
            if (status == PredictionStatus.confident &&
                _knowledgeInfo != null) ...[
              _buildSymptomsSection(theme, isDark, l10n, isBangla),
              const SizedBox(height: 24),
              _buildWhatToDoNextSection(theme, isDark, l10n, isBangla),
              const SizedBox(height: 24),
            ],

            // Advice / Retake Tips for Uncertain or Unknown
            if (status == PredictionStatus.uncertain)
              _buildUncertainTipsCard(theme, isDark, l10n, isBangla)
            else if (status == PredictionStatus.unknown)
              _buildUnknownTipsCard(theme, isDark, l10n, isBangla),

            const SizedBox(height: 24),

            // Technical metadata (Model version, inference ms, disclaimer)
            _buildMetadataAndDisclaimer(theme, isDark, l10n),

            const SizedBox(height: 24),

            // Bottom actions (Retake, Report wrong result)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      AppHaptics.lightImpact();
                      context.push('/capture');
                    },
                    icon: const Icon(Icons.camera_alt_outlined, size: 18),
                    label: Text(l10n?.retake ?? 'Scan Another'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: _isReported
                          ? AppColors.primaryGreen
                          : AppColors.statusUncertain,
                    ),
                    onPressed: _isReported
                        ? null
                        : () => _showReportWrongDialog(l10n),
                    icon: Icon(
                      _isReported
                          ? Icons.check_circle_outline
                          : Icons.flag_outlined,
                      size: 18,
                    ),
                    label: Text(
                      _isReported
                          ? (isBangla ? 'রিপোর্ট করা হয়েছে' : 'Reported')
                          : (l10n?.btnReportWrong ?? 'Report Wrong'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(
    PredictionStatus status,
    CropDocThemeExtension ext,
    bool isDark,
    AppLocalizations? l10n,
    bool isBangla,
  ) {
    switch (status) {
      case PredictionStatus.confident:
        final cropName =
            _knowledgeInfo?.getCropName(isBangla) ??
            widget.response.crop.name.capitalizeWords();
        final diseaseName =
            _knowledgeInfo?.getDiseaseName(isBangla) ??
            (widget.response.topPrediction?.disease ?? 'Healthy')
                .capitalizeWords();
        final conf = widget.response.topPrediction?.confidence ?? 0.0;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ext.confidentBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: ext.confidentColor.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          color: ext.confidentColor,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n?.statusConfident ?? 'Confirmed Match',
                          style: TextStyle(
                            color: ext.confidentColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      diseaseName,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? Colors.white
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${l10n?.cropLabel ?? 'Crop'}: $cropName',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ConfidenceRing(
                confidence: conf,
                ringColor: ext.confidentColor,
                size: 96,
              ),
            ],
          ),
        ).animate().fadeIn().slideY(begin: -0.05, end: 0);

      case PredictionStatus.uncertain:
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: ext.uncertainBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: ext.uncertainColor.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.help_outline_rounded,
                    color: ext.uncertainColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n?.uncertainBanner ?? 'Potential Match - Low Confidence',
                    style: TextStyle(
                      color: ext.uncertainColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l10n?.uncertainSubtitle ?? 'The AI detected possible diseases but confidence is low. Compare options below or retake the photo.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : const Color(0xFF5A3E00),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ).animate().fadeIn().slideY(begin: -0.05, end: 0);

      case PredictionStatus.unknown:
        final crop = widget.response.crop;
        final hasCropEstimate =
            crop.name != 'unknown' && crop.confidence >= 0.6;
        const cropNamesBn = {
          'apple': 'আপেল',
          'blueberry': 'ব্লুবেরি',
          'cherry': 'চেরি',
          'corn': 'ভুট্টা',
          'grape': 'আঙুর',
          'mango': 'আম',
          'orange': 'কমলা',
          'peach': 'পিচ',
          'pepper': 'মরিচ',
          'potato': 'আলু',
          'raspberry': 'রাস্পবেরি',
          'rice': 'ধান',
          'soybean': 'সয়াবিন',
          'squash': 'স্কোয়াশ',
          'strawberry': 'স্ট্রবেরি',
          'tomato': 'টমেটো',
          'wheat': 'গম',
        };
        final displayCrop = isBangla
            ? cropNamesBn[crop.name] ?? crop.name
            : crop.name.capitalizeWords();
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: ext.unknownBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ext.unknownColor.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: ext.unknownColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hasCropEstimate
                          ? (isBangla
                                ? 'পাতার ধরন: $displayCrop (${(crop.confidence * 100).round()}%)'
                                : 'Crop estimate: $displayCrop (${(crop.confidence * 100).round()}%) — disease unconfirmed')
                          : (l10n?.unknownBanner ??
                                'This leaf is not recognised'),
                      style: TextStyle(
                        color: ext.unknownColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                hasCropEstimate
                    ? (isBangla
                          ? 'রোগের ধরন নির্ভরযোগ্যভাবে মেলেনি। অন্য আলো ও কোণে পরিষ্কার ছবি তুলুন।'
                          : 'The crop looks like $displayCrop (${(crop.confidence * 100).round()}%), but the disease could not be confirmed. Try a clear, close photo in daylight.')
                    : (l10n?.unknownSubtitle ??
                          'The system could not identify this as a known crop disease. Please take another photo in clear daylight.'),
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : const Color(0xFF5F1414),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ).animate().fadeIn().slideY(begin: -0.05, end: 0);
    }
  }

  Widget _buildTopPredictionsSection(
    ThemeData theme,
    CropDocThemeExtension ext,
    bool isDark,
    AppLocalizations? l10n,
    bool isBangla,
  ) {
    final predictions = widget.response.predictions;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.topPredictionsTitle ?? 'Top Predictions',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          ...predictions.take(3).map((pred) {
            final percent = (pred.confidence * 100).toInt();
            final labelDisplay =
                '${pred.crop} • ${pred.disease.replaceAll('_', ' ')}'
                    .capitalizeWords();

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          labelDisplay,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '$percent%',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: ext.confidentColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pred.confidence.clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: isDark
                          ? AppColors.surfaceVariantDark
                          : Colors.grey.shade200,
                      color: ext.confidentColor,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSymptomsSection(
    ThemeData theme,
    bool isDark,
    AppLocalizations? l10n,
    bool isBangla,
  ) {
    final symptoms = _knowledgeInfo!.getSymptoms(isBangla);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.biotech_rounded,
                size: 20,
                color: AppColors.primaryGreen,
              ),
              const SizedBox(width: 8),
              Text(
                l10n?.symptomsTitle ?? 'Symptoms & Indicators',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _knowledgeInfo!.getDescription(isBangla),
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 12),
          ...symptoms.map(
            (symptom) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Icon(
                      Icons.circle,
                      size: 6,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      symptom,
                      style: const TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatToDoNextSection(
    ThemeData theme,
    bool isDark,
    AppLocalizations? l10n,
    bool isBangla,
  ) {
    // ONLY shows text found in the knowledge JSON, plus the fixed extension officer line!
    final whatToDoList = _knowledgeInfo!.getWhatToDo(isBangla);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.checklist_rtl_rounded,
                size: 20,
                color: AppColors.primaryGreen,
              ),
              const SizedBox(width: 8),
              Text(
                l10n?.whatToDoTitle ?? 'What To Do Next',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Items from diseases.json
          ...whatToDoList.map(
            (step) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: Icon(
                      Icons.arrow_right_rounded,
                      size: 18,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 6),
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
                            : (isDark
                                  ? Colors.white
                                  : AppColors.textPrimaryLight),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Fixed advisory line
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.primaryGreenDark
                  : AppColors.statusConfidentBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.shield_outlined,
                  size: 18,
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n?.extensionOfficerNotice ?? 'Confirm with a local agricultural extension officer before spraying anything.',
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
    );
  }

  Widget _buildUncertainTipsCard(
    ThemeData theme,
    bool isDark,
    AppLocalizations? l10n,
    bool isBangla,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.statusUncertain.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.tips_and_updates_rounded,
                color: AppColors.statusUncertain,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isBangla
                    ? 'পুনরায় ছবি তোলার পরামর্শ'
                    : 'Tips for a Clearer Photo',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _bulletPoint(
            isBangla
                ? 'একটি নির্দিষ্ট পাতায় ক্যামেরা স্থির রাখুন এবং ঝাপসা না হওয়া নিশ্চিত করুন।'
                : 'Hold camera steady on a single diseased leaf without movement blur.',
          ),
          _bulletPoint(
            isBangla
                ? 'সরাসরি প্রখর রোদ বা গভীর ছায়া এড়িয়ে স্বাভাবিক আলোয় ছবি তুলুন।'
                : 'Avoid harsh direct glare or dark shadows; shoot under natural daylight.',
          ),
          _bulletPoint(
            isBangla
                ? 'রোগের দাগ ফ্রেমের কেন্দ্রে স্পষ্টভাবে রাখুন।'
                : 'Center key lesion spots within the camera frame.',
          ),
        ],
      ),
    );
  }

  Widget _buildUnknownTipsCard(
    ThemeData theme,
    bool isDark,
    AppLocalizations? l10n,
    bool isBangla,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.statusUnknown.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.help_center_outlined,
                color: AppColors.statusUnknown,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isBangla ? 'পরামর্শ ও সহায়তা' : 'Recommendations',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _bulletPoint(
            isBangla ? 'ছবিতে স্পষ্ট কোনো ফসলের পাতা আছে কি না যাচাই করুন।' : 'Ensure the image clearly captures a crop leaf rather than background clutter.',
          ),
          _bulletPoint(
            isBangla
                ? 'যদি সমস্যা অব্যাহত থাকে, আপনার নিকটস্থ কৃষি কর্মকর্তার সাথে যোগাযোগ করুন।'
                : 'If symptoms persist, consult your local agricultural extension service.',
          ),
        ],
      ),
    );
  }

  Widget _bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataAndDisclaimer(
    ThemeData theme,
    bool isDark,
    AppLocalizations? l10n,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${l10n?.modelVersionLabel ?? 'Model'}: ${widget.response.modelVersion}',
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? AppColors.textDisabledDark
                    : AppColors.textDisabledLight,
              ),
            ),
            if (widget.response.inferenceMs > 0)
              Text(
                '${l10n?.inferenceTimeLabel ?? 'Time'}: ${widget.response.inferenceMs} ms',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? AppColors.textDisabledDark
                      : AppColors.textDisabledLight,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          l10n?.aiDisclaimer ?? 'AI estimate, not an official agricultural diagnosis. Validate with certified experts.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontStyle: FontStyle.italic,
            color: isDark
                ? AppColors.textDisabledDark
                : AppColors.textDisabledLight,
          ),
        ),
      ],
    );
  }
}
