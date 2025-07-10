import 'package:flutter/material.dart';

/// Color palette for ArLoop application
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  /// Primary color - Used for buttons, highlights, accents
  static const Color primary = Color(0xFF028A8D);

  /// Primary color variants
  static const Color primaryLight = Color(0xFF4FB3B5);
  static const Color primaryDark = Color(0xFF016163);

  /// Secondary color - Used for backgrounds, cards
  static const Color secondary = Color(0xFFE6F4F1);

  /// Secondary color variants
  static const Color secondaryLight = Color(0xFFF2F9F7);
  static const Color secondaryDark = Color(0xFFD1EDE7);

  /// Neutral colors
  static const Color neutral = Color(0xFFFFFFFF);
  static const Color neutralGrey = Color(0xFFF5F5F5);
  static const Color neutralLight = Color(0xFFFAFAFA);

  /// Text colors
  static const Color darkText = Color(0xFF333333);
  static const Color lightText = Color(0xFF666666);
  static const Color mutedText = Color(0xFF999999);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  /// CTA (Call to Action) Accent - For emergency buttons
  static const Color ctaAccent = Color(0xFFFF6B35);
  static const Color ctaAccentLight = Color(0xFFFF8F65);
  static const Color ctaAccentDark = Color(0xFFE55A2B);

  /// Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  /// Background colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF8F9FA);
  static const Color cardBackground = Color(0xFFE6F4F1);

  /// Border and divider colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);

  /// Shadow colors
  static const Color shadow = Color(0x1F000000);
  static const Color lightShadow = Color(0x0F000000);

  /// Disabled states
  static const Color disabled = Color(0xFFBDBDBD);
  static const Color disabledText = Color(0xFF9E9E9E);

  /// Overlay colors
  static const Color overlay = Color(0x80000000);
  static const Color lightOverlay = Color(0x40000000);
}

/// Material color swatch for the primary color
class AppColorSwatch {
  static const MaterialColor primarySwatch =
      MaterialColor(0xFF028A8D, <int, Color>{
        50: Color(0xFFE0F2F3),
        100: Color(0xFFB3DEE0),
        200: Color(0xFF80C8CC),
        300: Color(0xFF4DB2B7),
        400: Color(0xFF26A1A7),
        500: Color(0xFF028A8D),
        600: Color(0xFF027F85),
        700: Color(0xFF01727A),
        800: Color(0xFF016570),
        900: Color(0xFF014F5D),
      });
}

/// Extension to add convenience methods to Color class
extension AppColorExtensions on Color {
  /// Returns a lighter version of the color
  Color lighten([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness(
      (hsl.lightness + amount).clamp(0.0, 1.0),
    );
    return hslLight.toColor();
  }

  /// Returns a darker version of the color
  Color darken([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  /// Returns a more saturated version of the color
  Color saturate([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    final hslSaturated = hsl.withSaturation(
      (hsl.saturation + amount).clamp(0.0, 1.0),
    );
    return hslSaturated.toColor();
  }

  /// Returns a less saturated version of the color
  Color desaturate([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    final hslDesaturated = hsl.withSaturation(
      (hsl.saturation - amount).clamp(0.0, 1.0),
    );
    return hslDesaturated.toColor();
  }
}
