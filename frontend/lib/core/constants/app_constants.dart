/// Application-wide constants
///
/// Contains static constants used throughout the application
/// for consistency and maintainability.
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // =============================================================================
  // STORAGE KEYS
  // =============================================================================

  /// Storage keys for shared preferences
  static const String keyAuthToken = 'auth_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyUserRole = 'user_role';
  static const String keyLanguage = 'language';
  static const String keyTheme = 'theme';
  static const String keyOnboardingCompleted = 'onboarding_completed';

  // =============================================================================
  // REGEX PATTERNS
  // =============================================================================

  /// Email validation regex pattern
  static const String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

  /// Phone number validation regex pattern (Algeria)
  static const String phonePattern = r'^(\+213|0)[5-7][0-9]{8}$';

  /// Password validation regex pattern
  /// At least 8 characters, 1 uppercase, 1 lowercase, 1 number
  static const String passwordPattern =
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$';

  // =============================================================================
  // ANIMATION DURATIONS
  // =============================================================================

  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);

  // =============================================================================
  // SPACING
  // =============================================================================

  static const double spacingXxs = 4.0;
  static const double spacingXs = 8.0;
  static const double spacingSm = 12.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // =============================================================================
  // BORDER RADIUS
  // =============================================================================

  static const double radiusSm = 4.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radiusXxl = 24.0;
  static const double radiusFull = 999.0;

  // =============================================================================
  // FONT SIZES
  // =============================================================================

  static const double fontSizeXs = 12.0;
  static const double fontSizeSm = 14.0;
  static const double fontSizeMd = 16.0;
  static const double fontSizeLg = 18.0;
  static const double fontSizeXl = 20.0;
  static const double fontSizeXxl = 24.0;
  static const double fontSizeH1 = 32.0;
  static const double fontSizeH2 = 28.0;
  static const double fontSizeH3 = 24.0;

  // =============================================================================
  // ICON SIZES
  // =============================================================================

  static const double iconSizeXs = 16.0;
  static const double iconSizeSm = 20.0;
  static const double iconSizeMd = 24.0;
  static const double iconSizeLg = 32.0;
  static const double iconSizeXl = 48.0;

  // =============================================================================
  // SCREEN BREAKPOINTS
  // =============================================================================

  static const double breakpointMobile = 600.0;
  static const double breakpointTablet = 900.0;
  static const double breakpointDesktop = 1200.0;

  // =============================================================================
  // IMAGE SIZES
  // =============================================================================

  static const double avatarSizeSm = 32.0;
  static const double avatarSizeMd = 48.0;
  static const double avatarSizeLg = 64.0;
  static const double avatarSizeXl = 96.0;

  // =============================================================================
  // FILE SIZE LIMITS
  // =============================================================================

  static const int maxFileSizeBytes = 10 * 1024 * 1024; // 10MB
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB

  // =============================================================================
  // SUPPORTED IMAGE FORMATS
  // =============================================================================

  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png'];
  static const List<String> supportedDocumentFormats = ['pdf', 'doc', 'docx'];

  // =============================================================================
  // ERROR MESSAGES
  // =============================================================================

  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork =
      'Network error. Please check your connection.';
  static const String errorTimeout = 'Request timed out. Please try again.';
  static const String errorUnauthorized = 'Unauthorized access. Please login.';
  static const String errorNotFound = 'Resource not found.';
  static const String errorValidation =
      'Invalid input. Please check your data.';
  static const String errorServer = 'Server error. Please try again later.';
}
