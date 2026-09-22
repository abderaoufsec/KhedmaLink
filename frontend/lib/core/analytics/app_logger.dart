import 'package:flutter/foundation.dart';

import '../config/app_config.dart';

/// Application logger utility
///
/// Provides structured logging with different severity levels
/// and automatic disabling in production builds.
class AppLogger {
  // Private constructor to prevent instantiation
  AppLogger._();

  // Log levels
  static const String _levelDebug = 'DEBUG';
  static const String _levelInfo = 'INFO';
  static const String _levelWarning = 'WARNING';
  static const String _levelError = 'ERROR';
  static const String _levelFatal = 'FATAL';

  // =============================================================================
  // PUBLIC LOGGING METHODS
  // =============================================================================

  /// Log debug message
  ///
  /// Only logs in debug mode. Used for detailed debugging information.
  static void debug(String message, {Object? error, StackTrace? stackTrace}) {
    if (AppConfig.enableDebugLogging) {
      _log(_levelDebug, message, error: error, stackTrace: stackTrace);
    }
  }

  /// Log info message
  ///
  /// General informational messages about app state and events.
  static void info(String message, {Object? error, StackTrace? stackTrace}) {
    if (AppConfig.enableDebugLogging) {
      _log(_levelInfo, message, error: error, stackTrace: stackTrace);
    }
  }

  /// Log warning message
  ///
  /// Warning messages for potential issues that don't prevent app operation.
  static void warning(String message, {Object? error, StackTrace? stackTrace}) {
    if (AppConfig.enableDebugLogging) {
      _log(_levelWarning, message, error: error, stackTrace: stackTrace);
    }
  }

  /// Log error message
  ///
  /// Error messages for issues that affect app functionality.
  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    _log(_levelError, message, error: error, stackTrace: stackTrace);
  }

  /// Log fatal error message
  ///
  /// Critical errors that may cause app crashes or data loss.
  static void fatal(String message, {Object? error, StackTrace? stackTrace}) {
    _log(_levelFatal, message, error: error, stackTrace: stackTrace);
  }

  // =============================================================================
  // CATEGORY-SPECIFIC LOGGING
  // =============================================================================

  /// Log network-related messages
  static void network(String message, {Object? error, StackTrace? stackTrace}) {
    debug('[NETWORK] $message', error: error, stackTrace: stackTrace);
  }

  /// Log authentication-related messages
  static void auth(String message, {Object? error, StackTrace? stackTrace}) {
    info('[AUTH] $message', error: error, stackTrace: stackTrace);
  }

  /// Log database/storage-related messages
  static void database(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    debug('[DATABASE] $message', error: error, stackTrace: stackTrace);
  }

  /// Log UI-related messages
  static void ui(String message, {Object? error, StackTrace? stackTrace}) {
    debug('[UI] $message', error: error, stackTrace: stackTrace);
  }

  /// Log performance-related messages
  static void performance(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    info('[PERFORMANCE] $message', error: error, stackTrace: stackTrace);
  }

  // =============================================================================
  // INTERNAL LOGGING METHOD
  // =============================================================================

  static void _log(
    String level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] [$level] $message';

    // Use Flutter's debugPrint for better performance in debug mode
    debugPrint(logMessage);

    // Print error and stack trace if provided
    if (error != null) {
      debugPrint('Error: $error');
    }
    if (stackTrace != null) {
      debugPrint('StackTrace: $stackTrace');
    }
  }

  // =============================================================================
  // PERFORMANCE TRACKING
  // =============================================================================

  /// Track the start of a performance operation
  static String startPerformanceTracking(String operationName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    debug('[PERF] Started: $operationName');
    return '$operationName:$timestamp';
  }

  /// Track the end of a performance operation
  static void endPerformanceTracking(String trackingId) {
    final parts = trackingId.split(':');
    if (parts.length != 2) return;

    final operationName = parts[0];
    final startTime = int.tryParse(parts[1]);
    if (startTime == null) return;

    final endTime = DateTime.now().millisecondsSinceEpoch;
    final duration = endTime - startTime;

    info('[PERF] Completed: $operationName in ${duration}ms');
  }

  // =============================================================================
  // ERROR TRACKING
  // =============================================================================

  /// Log exception with context
  static void exception(
    String context,
    dynamic exception, {
    StackTrace? stackTrace,
  }) {
    error('Exception in $context', error: exception, stackTrace: stackTrace);
  }

  /// Log API error
  static void apiError(
    String endpoint,
    int statusCode,
    String? errorMessage, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    AppLogger.error(
      'API Error: $endpoint returned $statusCode',
      error: error ?? errorMessage,
      stackTrace: stackTrace,
    );
  }

  // =============================================================================
  // USER ACTION TRACKING
  // =============================================================================

  /// Log user action for analytics
  static void userAction(String action, {Map<String, dynamic>? parameters}) {
    info('[USER ACTION] $action${parameters != null ? ' - $parameters' : ''}');
  }

  /// Log screen view for analytics
  static void screenView(String screenName) {
    info('[SCREEN VIEW] $screenName');
  }

  /// Log button click for analytics
  static void buttonClick(String buttonName, {String? context}) {
    info('[BUTTON CLICK] $buttonName${context != null ? ' in $context' : ''}');
  }
}

/// Simple performance tracker class
///
/// Use this to track the duration of operations automatically.
class PerformanceTracker {
  final String operationName;
  final String _trackingId;

  PerformanceTracker(this.operationName)
    : _trackingId = AppLogger.startPerformanceTracking(operationName);

  /// Stop tracking and log the duration
  void stop() {
    AppLogger.endPerformanceTracking(_trackingId);
  }

  /// Stop tracking with custom message
  void stopWithMessage(String message) {
    AppLogger.endPerformanceTracking(_trackingId);
    AppLogger.performance('$operationName: $message');
  }
}
