import 'package:flutter/material.dart';

import '../../core/localization/app_localization.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

/// Standard error display widget
///
/// Provides a consistent error state across the application
/// with customizable icon, message, and action button.
class ErrorDisplay extends StatelessWidget {
  final String? message;
  final String? subMessage;
  final IconData? icon;
  final VoidCallback? onRetry;
  final String? retryText;

  const ErrorDisplay({
    super.key,
    this.message,
    this.subMessage,
    this.icon,
    this.onRetry,
    this.retryText,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: AppConstants.iconSizeXl,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Text(
              message ?? localizations.error,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            if (subMessage != null) ...[
              const SizedBox(height: AppConstants.spacingSm),
              Text(
                subMessage!,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: AppConstants.spacingLg),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryText ?? localizations.refresh),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Network error display
///
/// Specialized error display for network-related errors
class NetworkErrorDisplay extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorDisplay({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return ErrorDisplay(
      icon: Icons.wifi_off,
      message: localizations.errorNetwork,
      subMessage: 'Please check your internet connection and try again.',
      onRetry: onRetry,
      retryText: localizations.tryAgain,
    );
  }
}

/// Server error display
///
/// Specialized error display for server-related errors
class ServerErrorDisplay extends StatelessWidget {
  final VoidCallback? onRetry;

  const ServerErrorDisplay({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return ErrorDisplay(
      icon: Icons.cloud_off,
      message: localizations.errorServer,
      subMessage:
          'Our servers are experiencing issues. Please try again later.',
      onRetry: onRetry,
      retryText: localizations.tryAgain,
    );
  }
}

/// Not found error display
///
/// Specialized error display for 404/not found errors
class NotFoundErrorDisplay extends StatelessWidget {
  final String? resourceName;
  final VoidCallback? onBack;

  const NotFoundErrorDisplay({super.key, this.resourceName, this.onBack});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return ErrorDisplay(
      icon: Icons.search_off,
      message: localizations.errorNotFound,
      subMessage: resourceName != null
          ? '$resourceName could not be found.'
          : 'The requested resource could not be found.',
      onRetry: onBack,
      retryText: localizations.back,
    );
  }
}

/// Validation error display
///
/// Specialized error display for form validation errors
class ValidationErrorDisplay extends StatelessWidget {
  final String fieldName;
  final String? customMessage;

  const ValidationErrorDisplay({
    super.key,
    required this.fieldName,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorDisplay(
      icon: Icons.warning_amber_rounded,
      message: 'Invalid $fieldName',
      subMessage: customMessage ?? 'Please check your input and try again.',
    );
  }
}

/// Error banner for snack bars
///
/// Compact error display for use in snack bars or banners
class ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;

  const ErrorBanner({super.key, required this.message, this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppTheme.errorColor),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppTheme.errorColor,
            size: AppConstants.iconSizeMd,
          ),
          const SizedBox(width: AppConstants.spacingSm),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: AppTheme.errorColor),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: onDismiss,
              color: AppTheme.errorColor,
              iconSize: AppConstants.iconSizeSm,
            ),
        ],
      ),
    );
  }
}

/// Inline error text for form fields
///
/// Compact error message for form field validation
class InlineError extends StatelessWidget {
  final String message;

  const InlineError({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppConstants.spacingXs),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            size: AppConstants.iconSizeXs,
            color: AppTheme.errorColor,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}
