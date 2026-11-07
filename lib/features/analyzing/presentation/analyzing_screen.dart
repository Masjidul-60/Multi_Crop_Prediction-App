import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/config.dart';
import '../../../core/providers/app_state_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/image_utils.dart';
import '../../../core/widgets/local_image.dart';
import '../../../data/api/api_exceptions.dart';
import '../../../data/api/prediction_service.dart';
import '../../../data/models/history_scan.dart';
import '../../../data/repositories/history_repository.dart';
import '../../../../l10n/app_localizations.dart';

class AnalyzingScreen extends ConsumerStatefulWidget {
  final XFile imageFile;

  const AnalyzingScreen({super.key, required this.imageFile});

  @override
  ConsumerState<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends ConsumerState<AnalyzingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanController;
  Timer? _timeoutTimer;
  bool _isTimedOut = false;
  String? _errorMessage;
  bool _isProcessing = true;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _startPrediction();
  }

  @override
  void dispose() {
    _scanController.dispose();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  Future<void> _startPrediction() async {
    setState(() {
      _isTimedOut = false;
      _errorMessage = null;
      _isProcessing = true;
    });

    // 20s timeout safety
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(
      const Duration(seconds: AppConfig.requestTimeoutSeconds),
      () {
        if (mounted && _isProcessing) {
          setState(() {
            _isTimedOut = true;
            _isProcessing = false;
          });
        }
      },
    );

    try {
      // Check network connectivity
      final connectivity = await Connectivity().checkConnectivity();
      final isOffline = connectivity.every((r) => r == ConnectivityResult.none);

      if (isOffline) {
        final config = ref.read(configProvider);
        if (!config.useMock) {
          // If offline and real backend mode, queue scan for offline processing
          ref.read(offlineQueueProvider.notifier).add(widget.imageFile.path);
          _timeoutTimer?.cancel();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)?.offlineQueuedNotice ?? 'Device is offline. Image queued to analyze when connection returns.',
                ),
                backgroundColor: AppColors.statusUncertain,
              ),
            );
            context.go('/history');
          }
          return;
        }
      }

      final predictionService = ref.read(predictionServiceProvider);
      final response = await predictionService.predictLeaf(widget.imageFile);

      _timeoutTimer?.cancel();

      if (!mounted) return;

      // Save to History Repository
      final scanId = 'scan_${DateTime.now().millisecondsSinceEpoch}';
      final thumbPath = await ImageUtils.saveHistoryThumbnail(
        widget.imageFile.path,
      );

      final topPred = response.topPrediction;
      final scan = HistoryScan(
        id: scanId,
        timestamp: DateTime.now(),
        imagePath: thumbPath,
        crop: response.crop.name,
        disease: topPred?.disease ?? 'unknown',
        status: response.status,
        confidence: topPred?.confidence ?? 0.0,
        predictionResponse: response,
      );

      await ref.read(historyListProvider.notifier).addScan(scan);

      if (mounted) {
        context.pushReplacement(
          '/result',
          extra: {
            'response': response,
            'imagePath': widget.imageFile.path,
            'scanId': scanId,
          },
        );
      }
    } on NetworkTimeoutException {
      if (mounted) {
        setState(() {
          _isTimedOut = true;
          _isProcessing = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _isProcessing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmOffWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Header title
              Text(
                l10n?.analyzingTitle ?? 'Analyzing Leaf...',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n?.analyzingSubtitle ??
                    'Examining leaf texture, spots, and color patterns...',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 32),

              // Leaf image with active animated scanning beam
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            LocalImage(
                              path: widget.imageFile.path,
                              fit: BoxFit.cover,
                            ),
                            // Scanning beam animation
                            if (_isProcessing)
                              AnimatedBuilder(
                                animation: _scanController,
                                builder: (context, child) {
                                  return CustomPaint(
                                    painter: _ScannerBeamPainter(
                                      progress: _scanController.value,
                                      beamColor: AppColors.accentLime,
                                    ),
                                  );
                                },
                              ),
                            // Tint overlay
                            if (_isProcessing)
                              Container(
                                color: AppColors.primaryGreen.withValues(
                                  alpha: 0.08,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Timeout or Error State
              if (_isTimedOut || _errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.statusUnknownBgDark
                        : AppColors.statusUnknownBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.statusUnknown.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.statusUnknown,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _isTimedOut
                              ? (l10n?.analyzingTimeout ??
                                    'Analysis timed out (20s). Check your connection and retry.')
                              : (_errorMessage ??
                                    'An error occurred during inference.'),
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : AppColors.statusUnknown,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        child: Text(l10n?.cancel ?? 'Cancel'),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _startPrediction,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: Text(l10n?.retry ?? 'Retry'),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Cancel button during analysis
                SizedBox(
                  width: 160,
                  child: OutlinedButton(
                    onPressed: () {
                      _timeoutTimer?.cancel();
                      context.pop();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark
                          ? Colors.white70
                          : AppColors.textSecondaryLight,
                      side: BorderSide(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                    ),
                    child: Text(l10n?.cancel ?? 'Cancel'),
                  ),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScannerBeamPainter extends CustomPainter {
  final double progress;
  final Color beamColor;

  const _ScannerBeamPainter({required this.progress, required this.beamColor});

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * progress;

    // Gradient halo behind the beam line
    final haloPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          beamColor.withValues(alpha: 0.0),
          beamColor.withValues(alpha: 0.35),
          beamColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, y - 24, size.width, 48));

    canvas.drawRect(Rect.fromLTWH(0, y - 24, size.width, 48), haloPaint);

    // Crisp laser beam line
    final linePaint = Paint()
      ..color = beamColor
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
  }

  @override
  bool shouldRepaint(covariant _ScannerBeamPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
