import 'package:flutter/services.dart';

class AppHaptics {
  AppHaptics._();

  static void lightImpact() {
    HapticFeedback.lightImpact();
  }

  static void mediumImpact() {
    HapticFeedback.mediumImpact();
  }

  static void selectionClick() {
    HapticFeedback.selectionClick();
  }

  static void success() {
    HapticFeedback.mediumImpact();
  }

  static void warning() {
    HapticFeedback.heavyImpact();
  }
}
