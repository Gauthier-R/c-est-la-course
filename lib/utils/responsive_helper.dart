import 'package:flutter/material.dart';

/// Helper class to provide responsive height and width based on screen size.
class ResponsiveHelper {
  /// Returns a height value that corresponds to [percent] of the screen height.
  static double heightPercent(BuildContext context, double percent) {
    assert(percent >= 0 && percent <= 1,
        'Percent must be between 0 and 1. Received: $percent');
    return MediaQuery.of(context).size.height * percent;
  }

  /// Returns a width value that corresponds to [percent] of the screen width.
  static double widthPercent(BuildContext context, double percent) {
    assert(percent >= 0 && percent <= 1,
        'Percent must be between 0 and 1. Received: $percent');
    return MediaQuery.of(context).size.width * percent;
  }

  /// Returns a font size that adapts to the screen width.
  static double scalableFont(BuildContext context, double baseSize) {
    double screenWidth = MediaQuery.of(context).size.width;
    return baseSize * (screenWidth / 375.0); // 375 is iPhone 11 reference
  }
}
