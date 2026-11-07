import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Displays a picked image on Flutter Web (where `Image.file` is unsupported)
/// and a local file on Android/iOS/desktop.
class LocalImage extends StatelessWidget {
  final String path;
  final BoxFit fit;
  final Widget? fallback;

  const LocalImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final errorFallback =
        fallback ?? const Center(child: Icon(Icons.eco_outlined));
    if (path.isEmpty) return errorFallback;

    if (kIsWeb) {
      return Image.network(
        path,
        fit: fit,
        errorBuilder: (_, _, _) => errorFallback,
      );
    }

    return Image.file(
      File(path),
      fit: fit,
      errorBuilder: (_, _, _) => errorFallback,
    );
  }
}
