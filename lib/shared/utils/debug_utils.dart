import 'package:flutter/foundation.dart';

class DebugUtils {
  // Check if we're running in debug or release mode
  static bool get isDebugMode => kDebugMode;
  static bool get isReleaseMode => kReleaseMode;
  static bool get isProfileMode => kProfileMode;

  // Get safety limits for sliders based on mode
  static double get sliderSafetyBuffer => isDebugMode ? 10.0 : 0.0;

  // Safely clamp a value to be used in a slider
  static double safeSliderValue(double value, double min, double max) {
    // Handle edge cases
    if (value.isNaN || value.isInfinite) return min;
    if (max <= min) return min; // Prevent invalid range

    // Add extra buffer in debug mode to prevent assertion errors
    if (isDebugMode) {
      // Ensure max is at least min + 1 to prevent slider errors
      final safeMax = max > min + 1.0 ? max - sliderSafetyBuffer : min + 1.0;
      return value.clamp(min, safeMax);
    }
    return value.clamp(min, max);
  }

  // Get safe slider max value
  static double safeSliderMaxValue(double min, double max) {
    if (max <= min) return min + 1.0; // Ensure at least 1.0 difference

    if (isDebugMode) {
      return max > min + 1.0 ? max - sliderSafetyBuffer : min + 1.0;
    }
    return max;
  }
}
