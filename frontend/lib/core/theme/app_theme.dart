import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

/// Application theme configuration
///
/// Defines light and dark themes with consistent colors, typography,
/// and component styling for the KhedmaLink app.
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // =============================================================================
  // COLOR PALETTE
  // =============================================================================

  /// Primary brand color (Blue for trust and professionalism)
  static const Color primaryColor = Color(0xFF1976D2);

  /// Primary color variant (lighter shade)
  static const Color primaryLight = Color(0xFF42A5F5);

  /// Primary color variant (darker shade)
  static const Color primaryDark = Color(0xFF1565C0);

  /// Secondary brand color (Orange for action and warmth)
  static const Color secondaryColor = Color(0xFFFF9800);

  /// Secondary color variant (lighter shade)
  static const Color secondaryLight = Color(0xFFFFB74D);

  /// Secondary color variant (darker shade)
  static const Color secondaryDark = Color(0xFFF57C00);

  // Semantic colors
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color errorColor = Color(0xFFF44336);
  static const Color infoColor = Color(0xFF2196F3);

  // Neutral colors
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // =============================================================================
  // LIGHT THEME
  // =============================================================================

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Color scheme
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      primaryContainer: primaryLight,
      secondary: secondaryColor,
      secondaryContainer: secondaryLight,
      error: errorColor,
      surface: grey50,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onError: Colors.white,
      onSurface: grey900,
    ),

    // App bar theme
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.white),
    ),

    // Card theme
    cardTheme: const CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppConstants.radiusMd)),
      ),
      color: Colors.white,
    ),

    // Elevated button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingLg,
          vertical: AppConstants.spacingMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        ),
      ),
    ),

    // Text button theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingLg,
          vertical: AppConstants.spacingMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        ),
      ),
    ),

    // Outlined button theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingLg,
          vertical: AppConstants.spacingMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        ),
        side: const BorderSide(color: primaryColor),
      ),
    ),

    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: grey50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        borderSide: const BorderSide(color: grey300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        borderSide: const BorderSide(color: grey300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        borderSide: const BorderSide(color: errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: AppConstants.spacingMd,
      ),
    ),

    // Text theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: AppConstants.fontSizeH1,
        fontWeight: FontWeight.bold,
        color: grey900,
      ),
      displayMedium: TextStyle(
        fontSize: AppConstants.fontSizeH2,
        fontWeight: FontWeight.bold,
        color: grey900,
      ),
      displaySmall: TextStyle(
        fontSize: AppConstants.fontSizeH3,
        fontWeight: FontWeight.bold,
        color: grey900,
      ),
      headlineLarge: TextStyle(
        fontSize: AppConstants.fontSizeXxl,
        fontWeight: FontWeight.bold,
        color: grey900,
      ),
      headlineMedium: TextStyle(
        fontSize: AppConstants.fontSizeXl,
        fontWeight: FontWeight.w600,
        color: grey900,
      ),
      headlineSmall: TextStyle(
        fontSize: AppConstants.fontSizeLg,
        fontWeight: FontWeight.w600,
        color: grey900,
      ),
      titleLarge: TextStyle(
        fontSize: AppConstants.fontSizeMd,
        fontWeight: FontWeight.w600,
        color: grey900,
      ),
      titleMedium: TextStyle(
        fontSize: AppConstants.fontSizeSm,
        fontWeight: FontWeight.w500,
        color: grey900,
      ),
      titleSmall: TextStyle(
        fontSize: AppConstants.fontSizeXs,
        fontWeight: FontWeight.w500,
        color: grey900,
      ),
      bodyLarge: TextStyle(
        fontSize: AppConstants.fontSizeMd,
        fontWeight: FontWeight.normal,
        color: grey800,
      ),
      bodyMedium: TextStyle(
        fontSize: AppConstants.fontSizeSm,
        fontWeight: FontWeight.normal,
        color: grey800,
      ),
      bodySmall: TextStyle(
        fontSize: AppConstants.fontSizeXs,
        fontWeight: FontWeight.normal,
        color: grey600,
      ),
      labelLarge: TextStyle(
        fontSize: AppConstants.fontSizeSm,
        fontWeight: FontWeight.w500,
        color: grey700,
      ),
      labelMedium: TextStyle(
        fontSize: AppConstants.fontSizeXs,
        fontWeight: FontWeight.w500,
        color: grey700,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: grey600,
      ),
    ),

    // Scaffold background color
    scaffoldBackgroundColor: grey50,
  );

  // =============================================================================
  // DARK THEME
  // =============================================================================

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // Color scheme
    colorScheme: const ColorScheme.dark(
      primary: primaryLight,
      primaryContainer: primaryColor,
      secondary: secondaryLight,
      secondaryContainer: secondaryColor,
      error: errorColor,
      surface: grey900,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onError: Colors.white,
      onSurface: grey100,
    ),

    // App bar theme
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: grey900,
      foregroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.white),
    ),

    // Card theme
    cardTheme: const CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppConstants.radiusMd)),
      ),
      color: grey800,
    ),

    // Elevated button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingLg,
          vertical: AppConstants.spacingMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        ),
      ),
    ),

    // Text button theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingLg,
          vertical: AppConstants.spacingMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        ),
      ),
    ),

    // Outlined button theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingLg,
          vertical: AppConstants.spacingMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        ),
        side: const BorderSide(color: primaryLight),
      ),
    ),

    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: grey800,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        borderSide: const BorderSide(color: grey600),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        borderSide: const BorderSide(color: grey600),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        borderSide: const BorderSide(color: primaryLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        borderSide: const BorderSide(color: errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: AppConstants.spacingMd,
      ),
    ),

    // Text theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: AppConstants.fontSizeH1,
        fontWeight: FontWeight.bold,
        color: grey100,
      ),
      displayMedium: TextStyle(
        fontSize: AppConstants.fontSizeH2,
        fontWeight: FontWeight.bold,
        color: grey100,
      ),
      displaySmall: TextStyle(
        fontSize: AppConstants.fontSizeH3,
        fontWeight: FontWeight.bold,
        color: grey100,
      ),
      headlineLarge: TextStyle(
        fontSize: AppConstants.fontSizeXxl,
        fontWeight: FontWeight.bold,
        color: grey100,
      ),
      headlineMedium: TextStyle(
        fontSize: AppConstants.fontSizeXl,
        fontWeight: FontWeight.w600,
        color: grey100,
      ),
      headlineSmall: TextStyle(
        fontSize: AppConstants.fontSizeLg,
        fontWeight: FontWeight.w600,
        color: grey100,
      ),
      titleLarge: TextStyle(
        fontSize: AppConstants.fontSizeMd,
        fontWeight: FontWeight.w600,
        color: grey100,
      ),
      titleMedium: TextStyle(
        fontSize: AppConstants.fontSizeSm,
        fontWeight: FontWeight.w500,
        color: grey100,
      ),
      titleSmall: TextStyle(
        fontSize: AppConstants.fontSizeXs,
        fontWeight: FontWeight.w500,
        color: grey100,
      ),
      bodyLarge: TextStyle(
        fontSize: AppConstants.fontSizeMd,
        fontWeight: FontWeight.normal,
        color: grey200,
      ),
      bodyMedium: TextStyle(
        fontSize: AppConstants.fontSizeSm,
        fontWeight: FontWeight.normal,
        color: grey200,
      ),
      bodySmall: TextStyle(
        fontSize: AppConstants.fontSizeXs,
        fontWeight: FontWeight.normal,
        color: grey400,
      ),
      labelLarge: TextStyle(
        fontSize: AppConstants.fontSizeSm,
        fontWeight: FontWeight.w500,
        color: grey300,
      ),
      labelMedium: TextStyle(
        fontSize: AppConstants.fontSizeXs,
        fontWeight: FontWeight.w500,
        color: grey300,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: grey400,
      ),
    ),

    // Scaffold background color
    scaffoldBackgroundColor: grey900,
  );
}
