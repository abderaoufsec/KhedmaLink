import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

/// Utility class for responsive design calculations
///
/// Provides helper methods for determining screen sizes,
/// calculating responsive values, and adapting layouts.
class ResponsiveUtils {
  // Private constructor to prevent instantiation
  ResponsiveUtils._();

  // =============================================================================
  // SCREEN SIZE DETECTION
  // =============================================================================

  /// Get screen size category based on width
  static ScreenSize getScreenSize(double width) {
    if (width < AppConstants.breakpointMobile) {
      return ScreenSize.mobile;
    } else if (width < AppConstants.breakpointTablet) {
      return ScreenSize.tablet;
    } else {
      return ScreenSize.desktop;
    }
  }

  /// Check if current screen is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < AppConstants.breakpointMobile;
  }

  /// Check if current screen is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= AppConstants.breakpointMobile &&
        width < AppConstants.breakpointTablet;
  }

  /// Check if current screen is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= AppConstants.breakpointTablet;
  }

  /// Check if current orientation is landscape
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Check if current orientation is portrait
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  // =============================================================================
  // RESPONSIVE VALUE CALCULATIONS
  // =============================================================================

  /// Calculate responsive value based on screen width
  ///
  /// Scales value linearly between mobile and desktop breakpoints
  static double responsiveValue(
    BuildContext context,
    double mobileValue,
    double tabletValue,
    double desktopValue,
  ) {
    final width = MediaQuery.of(context).size.width;
    final screenSize = getScreenSize(width);

    switch (screenSize) {
      case ScreenSize.mobile:
        return mobileValue;
      case ScreenSize.tablet:
        return tabletValue;
      case ScreenSize.desktop:
        return desktopValue;
    }
  }

  /// Calculate responsive font size
  static double responsiveFontSize(
    BuildContext context,
    double baseSize, {
    double? tabletSize,
    double? desktopSize,
  }) {
    return responsiveValue(
      context,
      baseSize,
      tabletSize ?? baseSize * 1.1,
      desktopSize ?? baseSize * 1.2,
    );
  }

  /// Calculate responsive spacing
  static double responsiveSpacing(
    BuildContext context,
    double baseSpacing, {
    double? tabletSpacing,
    double? desktopSpacing,
  }) {
    return responsiveValue(
      context,
      baseSpacing,
      tabletSpacing ?? baseSpacing * 1.25,
      desktopSpacing ?? baseSpacing * 1.5,
    );
  }

  /// Calculate responsive border radius
  static double responsiveBorderRadius(
    BuildContext context,
    double baseRadius, {
    double? tabletRadius,
    double? desktopRadius,
  }) {
    return responsiveValue(
      context,
      baseRadius,
      tabletRadius ?? baseRadius * 1.2,
      desktopRadius ?? baseRadius * 1.4,
    );
  }

  /// Calculate responsive icon size
  static double responsiveIconSize(
    BuildContext context,
    double baseSize, {
    double? tabletSize,
    double? desktopSize,
  }) {
    return responsiveValue(
      context,
      baseSize,
      tabletSize ?? baseSize * 1.2,
      desktopSize ?? baseSize * 1.4,
    );
  }

  // =============================================================================
  // SCREEN DIMENSIONS
  // =============================================================================

  /// Get screen width
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Get safe area padding
  static EdgeInsets safePadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get screen width minus safe area
  static double safeWidth(BuildContext context) {
    return screenWidth(context) - safePadding(context).horizontal;
  }

  /// Get screen height minus safe area
  static double safeHeight(BuildContext context) {
    return screenHeight(context) - safePadding(context).vertical;
  }

  // =============================================================================
  // LAYOUT HELPERS
  // =============================================================================

  /// Calculate number of columns for grid layout
  static int gridColumns(
    BuildContext context, {
    int mobileColumns = 1,
    int tabletColumns = 2,
    int desktopColumns = 3,
  }) {
    final screenSize = getScreenSize(screenWidth(context));

    switch (screenSize) {
      case ScreenSize.mobile:
        return mobileColumns;
      case ScreenSize.tablet:
        return tabletColumns;
      case ScreenSize.desktop:
        return desktopColumns;
    }
  }

  /// Calculate aspect ratio for images/cards
  static double aspectRatio(
    BuildContext context, {
    double mobileRatio = 1.0,
    double tabletRatio = 1.3,
    double desktopRatio = 1.5,
  }) {
    return responsiveValue(context, mobileRatio, tabletRatio, desktopRatio);
  }

  /// Calculate max width for content containers
  static double maxContentWidth(BuildContext context) {
    final screenSize = getScreenSize(screenWidth(context));

    switch (screenSize) {
      case ScreenSize.mobile:
        return double.infinity;
      case ScreenSize.tablet:
        return 800.0;
      case ScreenSize.desktop:
        return 1200.0;
    }
  }

  // =============================================================================
  // TEXT SCALING
  // =============================================================================

  /// Get text scale factor from MediaQuery
  static double textScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaler.scale(1.0);
  }

  /// Check if text scaling is enabled
  static bool isTextScaled(BuildContext context) {
    return textScaleFactor(context) != 1.0;
  }

  /// Apply text scale factor to value
  static double scaleText(BuildContext context, double value) {
    return value * textScaleFactor(context);
  }

  // =============================================================================
  // PLATFORM SPECIFIC
  // =============================================================================

  /// Check if running on web
  static bool isWeb() {
    // This will be properly implemented when platform detection is added
    return false;
  }

  /// Check if running on Android
  static bool isAndroid() {
    // This will be properly implemented when platform detection is added
    return false;
  }

  /// Check if running on iOS
  static bool isIOS() {
    // This will be properly implemented when platform detection is added
    return false;
  }

  // =============================================================================
  // BREAKPOINT HELPERS
  // =============================================================================

  /// Get current breakpoint
  static double getCurrentBreakpoint(BuildContext context) {
    final width = screenWidth(context);
    final screenSize = getScreenSize(width);

    switch (screenSize) {
      case ScreenSize.mobile:
        return AppConstants.breakpointMobile;
      case ScreenSize.tablet:
        return AppConstants.breakpointTablet;
      case ScreenSize.desktop:
        return AppConstants.breakpointDesktop;
    }
  }

  /// Get percentage of screen width
  static double percentageOfWidth(BuildContext context, double percentage) {
    return screenWidth(context) * (percentage / 100);
  }

  /// Get percentage of screen height
  static double percentageOfHeight(BuildContext context, double percentage) {
    return screenHeight(context) * (percentage / 100);
  }
}

/// Screen size enum for responsive design
enum ScreenSize { mobile, tablet, desktop }
