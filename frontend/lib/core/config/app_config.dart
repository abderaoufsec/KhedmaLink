import 'package:flutter/material.dart';

/// Application configuration constants and settings
///
/// This class contains all static configuration values for the KhedmaLink app,
/// including API endpoints, feature flags, and app settings.
class AppConfig {
  // =============================================================================
  // APP INFORMATION
  // =============================================================================

  /// Application name
  static const String appName = 'KhedmaLink';

  /// Application version
  static const String appVersion = '0.1.0';

  /// Build number
  static const String buildNumber = '1';

  // =============================================================================
  // ENVIRONMENT CONFIGURATION
  // =============================================================================

  /// Current environment (development, staging, production)
  static const String environment = String.fromEnvironment(
    'FLUTTER_ENV',
    defaultValue: 'development',
  );

  /// Whether to show debug banner
  static bool get showDebugBanner => environment != 'production';

  /// Whether to enable debug logging
  static bool get enableDebugLogging => environment != 'production';

  // =============================================================================
  // API CONFIGURATION
  // =============================================================================

  /// Base API URL
  ///
  /// Uses different URLs based on environment:
  /// - Development: Localhost (10.0.2.2 for Android emulator, or network IP)
  /// - Staging: Staging server
  /// - Production: Production server
  static String get apiBaseUrl {
    switch (environment) {
      case 'production':
        return 'https://api.khedmalink.com';
      case 'staging':
        return 'https://staging-api.khedmalink.com';
      default:
        // Development mode - use network IP for actual device testing
        // Comment out the emulator IP and use network IP for real device testing
        return 'http://192.168.1.6:8000'; // Your network IP address
        // return 'http://10.0.2.2:8000'; // Android emulator localhost
    }
  }

  /// API version
  static const String apiVersion = 'v1';

  /// Full API endpoint base URL
  static String get apiEndpoint => '$apiBaseUrl/api/$apiVersion';

  /// API base URL for direct use (without version prefix)
  static String get apiBaseUrlDirect => apiBaseUrl;

  /// WebSocket endpoint for real-time features
  static String get wsEndpoint => apiBaseUrl.replaceFirst('http', 'ws');

  // =============================================================================
  // TIMEOUT CONFIGURATION
  // =============================================================================

  /// Connection timeout in seconds
  static const int connectionTimeout = 30;

  /// Receive timeout in seconds
  static const int receiveTimeout = 30;

  /// Send timeout in seconds
  static const int sendTimeout = 30;

  // =============================================================================
  // FEATURE FLAGS
  // =============================================================================

  /// Enable analytics tracking
  static const bool enableAnalytics = false;

  /// Enable crash reporting
  static const bool enableCrashReporting = false;

  /// Enable push notifications
  static const bool enablePushNotifications = true;

  /// Enable debug tools
  static bool get enableDebugTools => environment != 'production';

  // =============================================================================
  // LOCALIZATION CONFIGURATION
  // =============================================================================

  /// Default language code
  static const String defaultLanguage = 'ar';

  /// Supported language codes
  static const List<String> supportedLanguages = ['ar', 'fr'];

  /// Default locale (Arabic for Algeria launch)
  static Locale get defaultLocale => const Locale('ar');

  // =============================================================================
  // STORAGE CONFIGURATION
  // =============================================================================

  /// Maximum cache size in MB
  static const int maxCacheSize = 50;

  /// Image cache duration in days
  static const int imageCacheDuration = 7;

  // =============================================================================
  // UI CONFIGURATION
  // =============================================================================

  /// Default animation duration
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);

  /// Default animation curve
  static Curve get defaultAnimationCurve => Curves.easeInOut;

  /// Image quality (0-100)
  static const int imageQuality = 85;

  // =============================================================================
  // PLATFORM SPECIFIC
  // =============================================================================

  /// Whether running on web platform
  static bool get isWeb =>
      identical(0, 0.0); // Will be replaced by platform check

  /// Whether running on Android
  static bool get isAndroid => false; // Will be replaced by platform check

  /// Whether running on iOS
  static bool get isIOS => false; // Will be replaced by platform check

  // =============================================================================
  // VALIDATION RULES
  // =============================================================================

  /// Minimum password length
  static const int minPasswordLength = 8;

  /// Maximum password length
  static const int maxPasswordLength = 128;

  /// Minimum phone number length
  static const int minPhoneLength = 10;

  /// Maximum phone number length
  static const int maxPhoneLength = 15;

  // =============================================================================
  // PAGINATION
  // =============================================================================

  /// Default page size
  static const int defaultPageSize = 20;

  /// Maximum page size
  static const int maxPageSize = 100;
}
