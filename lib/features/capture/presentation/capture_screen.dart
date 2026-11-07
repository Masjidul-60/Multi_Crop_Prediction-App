import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/utils/image_utils.dart';
import '../../../core/widgets/local_image.dart';
import '../../../../l10n/app_localizations.dart';
import 'leaf_overlay_painter.dart';

class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen> {
  CameraController? _cameraController;
  List<CameraDescription> _availableCameras = [];
  bool _isCameraInitialized = false;
  bool _isInitializing = true;
  String? _errorMessage;

  // Captured state
  String? _capturedImagePath;
  int _rotateDegrees = 0;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      _availableCameras = await availableCameras();
      if (_availableCameras.isEmpty) {
        setState(() {
          _errorMessage = 'No hardware camera detected.';
          _isInitializing = false;
        });
        return;
      }

      // Pick rear camera
      final rearCamera = _availableCameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => _availableCameras.first,
      );

      final controller = CameraController(
        rearCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();

      if (mounted) {
        setState(() {
          _cameraController = controller;
          _isCameraInitialized = true;
          _isInitializing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isInitializing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    AppHaptics.selectionClick();
    final newMode = _isFlashOn ? FlashMode.off : FlashMode.torch;
    try {
      await _cameraController!.setFlashMode(newMode);
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (_) {}
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    AppHaptics.mediumImpact();
    try {
      final xfile = await _cameraController!.takePicture();
      setState(() {
        _capturedImagePath = xfile.path;
        _rotateDegrees = 0;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to take photo: $e')));
      }
    }
  }

  Future<void> _pickFromGallery() async {
    AppHaptics.selectionClick();
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _capturedImagePath = picked.path;
        _rotateDegrees = 0;
      });
    }
  }

  Future<void> _fallbackTakePhoto() async {
    AppHaptics.selectionClick();
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        _capturedImagePath = picked.path;
        _rotateDegrees = 0;
      });
    }
  }

  void _rotateImage() {
    AppHaptics.selectionClick();
    setState(() {
      _rotateDegrees = (_rotateDegrees + 90) % 360;
    });
  }

  void _retake() {
    AppHaptics.selectionClick();
    setState(() {
      _capturedImagePath = null;
      _rotateDegrees = 0;
    });
  }

  Future<void> _analyzeCapturedImage() async {
    if (_capturedImagePath == null) return;
    AppHaptics.lightImpact();

    // Browser-picked images are Blob URLs; keep the XFile bytes intact instead
    // of passing them through dart:io image preparation.
    if (kIsWeb) {
      context.pushReplacement('/analyzing', extra: XFile(_capturedImagePath!));
      return;
    }

    final config = ref.read(configProvider);
    final l10n = AppLocalizations.of(context);

    // Prepare image and run client-side quality checks (Laplacian variance & brightness)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.accentLime),
      ),
    );

    try {
      final prepared = await ImageUtils.prepareImageForPrediction(
        sourcePath: _capturedImagePath!,
        isDataSaver: config.dataSaver,
        rotateDegrees: _rotateDegrees,
      );

      if (mounted) Navigator.pop(context); // pop progress

      if (prepared.qualityAssessment.hasWarning) {
        final isBlurry = prepared.qualityAssessment.isTooBlurry;
        final warningMsg = isBlurry
            ? (l10n?.blurWarningMsg ??
                  'The photo appears blurry or out of focus.')
            : (l10n?.darkWarningMsg ?? 'The photo is too dark.');

        if (!mounted) return;
        final shouldContinue = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.statusUncertain,
                ),
                const SizedBox(width: 8),
                Text(l10n?.qualityWarningTitle ?? 'Photo Quality Advisory'),
              ],
            ),
            content: Text(warningMsg),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n?.retake ?? 'Retake'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l10n?.continueAnyway ?? 'Continue Anyway'),
              ),
            ],
          ),
        );

        if (shouldContinue == true && mounted) {
          context.pushReplacement('/analyzing', extra: prepared.file.path);
        }
      } else {
        if (mounted) {
          context.pushReplacement('/analyzing', extra: prepared.file.path);
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error preparing image: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // If an image has already been captured, show preview & edit mode
    if (_capturedImagePath != null) {
      return _buildPreviewView(context, l10n, theme);
    }

    // Camera view or Fallback view
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview or fallback
          if (_isCameraInitialized && _cameraController != null)
            CameraPreview(_cameraController!)
          else
            _buildCameraFallbackView(l10n, theme),

          // Leaf shape guide overlay
          if (_isCameraInitialized)
            CustomPaint(
              size: MediaQuery.of(context).size,
              painter: LeafOverlayPainter(
                overlayColor: Colors.black.withValues(alpha: 0.45),
                guideColor: AppColors.accentLime,
              ),
            ),

          // Top action bar (Back, Flash toggle)
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () => context.pop(),
                    ),
                    if (_isCameraInitialized)
                      IconButton(
                        icon: Icon(
                          _isFlashOn
                              ? Icons.flash_on_rounded
                              : Icons.flash_off_rounded,
                          color: _isFlashOn
                              ? AppColors.accentLime
                              : Colors.white,
                        ),
                        onPressed: _toggleFlash,
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Live Photography Tips banner
          Positioned(
            top: 90,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.accentLime,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      l10n?.captureLiveTip ??
                          'One leaf • Fill frame • Bright light • No shadows',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: -0.2, end: 0),
          ),

          // Bottom capture controls (Gallery, Shutter Button, Switch)
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.only(bottom: 24, left: 32, right: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Gallery button
                    IconButton(
                      iconSize: 32,
                      icon: const Icon(
                        Icons.photo_library_outlined,
                        color: Colors.white,
                      ),
                      onPressed: _pickFromGallery,
                    ),

                    // Shutter button
                    GestureDetector(
                      onTap: _isCameraInitialized
                          ? _takePicture
                          : _fallbackTakePhoto,
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        child: Center(
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.accentLime,
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Color(0xFF13502E),
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Fallback camera pick or switch
                    IconButton(
                      iconSize: 32,
                      icon: const Icon(
                        Icons.cameraswitch_outlined,
                        color: Colors.white,
                      ),
                      onPressed: _fallbackTakePhoto,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewView(
    BuildContext context,
    AppLocalizations? l10n,
    ThemeData theme,
  ) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(l10n?.captureInstruction ?? 'Review Leaf Image'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: _retake,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.rotate_right_rounded),
            tooltip: l10n?.rotate ?? 'Rotate',
            onPressed: _rotateImage,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: RotatedBox(
                quarterTurns: (_rotateDegrees ~/ 90),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: LocalImage(
                    path: _capturedImagePath!,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white60),
                        minimumSize: const Size.fromHeight(52),
                      ),
                      onPressed: _retake,
                      child: Text(l10n?.retake ?? 'Retake'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentLime,
                        foregroundColor: const Color(0xFF0F321C),
                        minimumSize: const Size.fromHeight(52),
                      ),
                      onPressed: _analyzeCapturedImage,
                      icon: const Icon(Icons.search_rounded, size: 20),
                      label: Text(
                        l10n?.analyze ?? 'Analyze Leaf',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
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

  Widget _buildCameraFallbackView(AppLocalizations? l10n, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isInitializing)
              const CircularProgressIndicator(color: AppColors.accentLime)
            else ...[
              const Icon(
                Icons.camera_alt_outlined,
                color: Colors.white70,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                l10n?.permissionCameraTitle ?? 'Camera Preview Unavailable',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ??
                    (l10n?.permissionCameraMsg ??
                        'Take a photo directly with device camera or pick from gallery.'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentLime,
                  foregroundColor: const Color(0xFF13502E),
                ),
                onPressed: _fallbackTakePhoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Capture with System Camera'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
