import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

/// Application theme configuration
///
/// Defines light and dark themes with modern, professional design
/// featuring gradients, shadows, glassmorphism, and sophisticated typography
/// for the KhedmaLink app.
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // =============================================================================
  // MODERN COLOR PALETTE
  // =============================================================================

  /// Primary brand color (Modern Indigo for trust and professionalism)
  static const Color primaryColor = Color(0xFF6366F1); // Modern Indigo
  
  /// Primary color variant (lighter shade)
  static const Color primaryLight = Color(0xFF818CF8);
  
  /// Primary color variant (darker shade)
  static const Color primaryDark = Color(0xFF4F46E5);

  /// Secondary brand color (Modern Coral for action and warmth)
  static const Color secondaryColor = Color(0xFFF43F5E); // Modern Coral
  
  /// Secondary color variant (lighter shade)
  static const Color secondaryLight = Color(0xFFFB7185);
  
  /// Secondary color variant (darker shade)
  static const Color secondaryDark = Color(0xFFE11D48);

  /// Accent color (Teal for freshness and growth)
  static const Color accentColor = Color(0xFF14B8A6);
  
  /// Accent light variant
  static const Color accentLight = Color(0xFF2DD4BF);
  
  /// Accent dark variant
  static const Color accentDark = Color(0xFF0D9488);

  // Semantic colors with modern shades
  static const Color successColor = Color(0xFF10B981); // Emerald
  static const Color successLight = Color(0xFF34D399);
  static const Color successDark = Color(0xFF059669);
  
  static const Color warningColor = Color(0xFFF59E0B); // Amber
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFD97706);
  
  static const Color errorColor = Color(0xFFEF4444); // Red
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFDC2626);
  
  static const Color infoColor = Color(0xFF3B82F6); // Blue
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color infoDark = Color(0xFF2563EB);

  // Modern neutral colors (warm gray tones)
  static const Color grey50 = Color(0xFFFAFAF9); // Stone 50
  static const Color grey100 = Color(0xFFF5F5F4); // Stone 100
  static const Color grey200 = Color(0xFFE7E5E4); // Stone 200
  static const Color grey300 = Color(0xFFD6D3D1); // Stone 300
  static const Color grey400 = Color(0xFFA8A29E); // Stone 400
  static const Color grey500 = Color(0xFF78716C); // Stone 500
  static const Color grey600 = Color(0xFF57534E); // Stone 600
  static const Color grey700 = Color(0xFF44403C); // Stone 700
  static const Color grey800 = Color(0xFF292524); // Stone 800
  static const Color grey900 = Color(0xFF1C1917); // Stone 900

  // Gradient definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondaryColor, secondaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentColor, accentDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [successColor, successDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadow definitions for depth
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: primaryColor.withValues(alpha: 0.3),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get floatingShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 32,
      offset: const Offset(0, 12),
    ),
  ];

  // =============================================================================
  // MODERN LIGHT THEME
  // =============================================================================

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Modern color scheme with sophisticated palette
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      primaryContainer: primaryLight,
      secondary: secondaryColor,
      secondaryContainer: secondaryLight,
      tertiary: accentColor,
      error: errorColor,
      surface: grey50,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onTertiary: Colors.white,
      onError: Colors.white,
      onSurface: grey900,
      outline: grey300,
      outlineVariant: grey200,
    ),

    // Modern app bar with gradient and elevation
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.white,
      foregroundColor: grey900,
      iconTheme: const IconThemeData(color: grey900),
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: grey900,
        letterSpacing: -0.5,
      ),
      shadowColor: Colors.black.withValues(alpha: 0.05),
    ),

    // Modern card with elegant shadows and rounded corners
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      color: Colors.white,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      margin: const EdgeInsets.all(AppConstants.spacingSm),
    ),

    // Modern elevated button with gradient and shadows
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingXl,
          vertical: AppConstants.spacingLg,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ).copyWith(
        overlayColor: WidgetStateProperty.all(primaryLight.withValues(alpha: 0.2)),
      ),
    ),

    // Modern text button with refined styling
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingLg,
          vertical: AppConstants.spacingMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        ),
        foregroundColor: primaryColor,
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    ),

    // Modern outlined button with elegant border
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingLg,
          vertical: AppConstants.spacingMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        ),
        side: const BorderSide(color: primaryColor, width: 1.5),
        foregroundColor: primaryColor,
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    ),

    // Modern input decoration with elegant borders
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: grey50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        borderSide: const BorderSide(color: errorColor, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingLg,
        vertical: AppConstants.spacingLg,
      ),
      hintStyle: TextStyle(
        color: grey400,
        fontSize: 15,
      ),
    ),

    // Modern text theme with refined typography
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: grey900,
        letterSpacing: -1.0,
        height: 1.2,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: grey900,
        letterSpacing: -0.8,
        height: 1.2,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: grey900,
        letterSpacing: -0.5,
        height: 1.3,
      ),
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: grey900,
        letterSpacing: -0.5,
        height: 1.3,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: grey900,
        letterSpacing: -0.3,
        height: 1.4,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: grey900,
        letterSpacing: -0.2,
        height: 1.4,
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: grey900,
        letterSpacing: -0.1,
        height: 1.5,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: grey900,
        height: 1.5,
      ),
      titleSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: grey900,
        height: 1.5,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: grey800,
        height: 1.6,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: grey800,
        height: 1.6,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: grey600,
        height: 1.5,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: grey700,
        height: 1.4,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: grey700,
        height: 1.4,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: grey600,
        height: 1.4,
      ),
    ),

    // Modern scaffold with subtle gradient
    scaffoldBackgroundColor: grey100,

    // Modern chip theme
    chipTheme: ChipThemeData(
      backgroundColor: grey100,
      selectedColor: primaryLight.withValues(alpha: 0.2),
      labelStyle: const TextStyle(
        color: grey700,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: AppConstants.spacingSm,
      ),
    ),

    // Modern divider
    dividerTheme: const DividerThemeData(
      color: grey200,
      thickness: 1,
      space: 1,
    ),
  );

  // =============================================================================
  // MODERN DARK THEME
  // =============================================================================

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // Modern dark color scheme with sophisticated palette
    colorScheme: const ColorScheme.dark(
      primary: primaryLight,
      primaryContainer: primaryColor,
      secondary: secondaryLight,
      secondaryContainer: secondaryColor,
      tertiary: accentLight,
      error: errorColor,
      surface: grey900,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onTertiary: Colors.white,
      onError: Colors.white,
      onSurface: grey100,
      outline: grey600,
      outlineVariant: grey700,
    ),

    // Modern dark app bar
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: grey900,
      foregroundColor: grey100,
      iconTheme: const IconThemeData(color: grey100),
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: grey100,
        letterSpacing: -0.5,
      ),
      shadowColor: Colors.black.withValues(alpha: 0.3),
    ),

    // Modern dark card with elegant shadows
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      color: grey800,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      margin: const EdgeInsets.all(AppConstants.spacingSm),
    ),

    // Modern dark elevated button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingXl,
          vertical: AppConstants.spacingLg,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        ),
        backgroundColor: primaryLight,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ).copyWith(
        overlayColor: WidgetStateProperty.all(primaryColor.withValues(alpha: 0.2)),
      ),
    ),

    // Modern dark text button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingLg,
          vertical: AppConstants.spacingMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        ),
        foregroundColor: primaryLight,
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    ),

    // Modern dark outlined button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingLg,
          vertical: AppConstants.spacingMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        ),
        side: const BorderSide(color: primaryLight, width: 1.5),
        foregroundColor: primaryLight,
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    ),

    // Modern dark input decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: grey800,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        borderSide: const BorderSide(color: primaryLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        borderSide: const BorderSide(color: errorColor, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingLg,
        vertical: AppConstants.spacingLg,
      ),
      hintStyle: TextStyle(
        color: grey500,
        fontSize: 15,
      ),
    ),

    // Modern dark text theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: grey100,
        letterSpacing: -1.0,
        height: 1.2,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: grey100,
        letterSpacing: -0.8,
        height: 1.2,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: grey100,
        letterSpacing: -0.5,
        height: 1.3,
      ),
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: grey100,
        letterSpacing: -0.5,
        height: 1.3,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: grey100,
        letterSpacing: -0.3,
        height: 1.4,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: grey100,
        letterSpacing: -0.2,
        height: 1.4,
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: grey100,
        letterSpacing: -0.1,
        height: 1.5,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: grey100,
        height: 1.5,
      ),
      titleSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: grey100,
        height: 1.5,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: grey200,
        height: 1.6,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: grey200,
        height: 1.6,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: grey400,
        height: 1.5,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: grey300,
        height: 1.4,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: grey300,
        height: 1.4,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: grey400,
        height: 1.4,
      ),
    ),

    // Modern dark scaffold
    scaffoldBackgroundColor: grey900,

    // Modern dark chip theme
    chipTheme: ChipThemeData(
      backgroundColor: grey800,
      selectedColor: primaryColor.withValues(alpha: 0.3),
      labelStyle: const TextStyle(
        color: grey200,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: AppConstants.spacingSm,
      ),
    ),

    // Modern dark divider
    dividerTheme: const DividerThemeData(
      color: grey700,
      thickness: 1,
      space: 1,
    ),
  );
}
