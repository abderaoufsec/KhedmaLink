import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

/// Standard loading indicator widget
///
/// Provides a consistent loading state across the application
/// with customizable size, color, and message.
class LoadingIndicator extends StatelessWidget {
  final double? size;
  final Color? color;
  final String? message;
  final bool center;

  const LoadingIndicator({
    super.key,
    this.size,
    this.color,
    this.message,
    this.center = true,
  });

  @override
  Widget build(BuildContext context) {
    final loadingWidget = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size ?? AppConstants.iconSizeLg,
          height: size ?? AppConstants.iconSizeLg,
          child: CircularProgressIndicator(
            color: color ?? Theme.of(context).colorScheme.primary,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: AppConstants.spacingMd),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ],
    );

    if (center) {
      return Center(child: loadingWidget);
    }

    return loadingWidget;
  }
}

/// Full-screen loading overlay
///
/// Shows a loading indicator that covers the entire screen
/// with an optional backdrop.
class LoadingOverlay extends StatelessWidget {
  final String? message;
  final bool showBackdrop;

  const LoadingOverlay({super.key, this.message, this.showBackdrop = true});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (showBackdrop) Container(color: Colors.black.withValues(alpha: 0.3)),
        Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingLg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: AppConstants.iconSizeLg,
                    height: AppConstants.iconSizeLg,
                    child: CircularProgressIndicator(),
                  ),
                  if (message != null) ...[
                    const SizedBox(height: AppConstants.spacingMd),
                    Text(
                      message!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Button loading state wrapper
///
/// Wraps a button and shows loading state when disabled
class LoadingButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;

  const LoadingButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    required this.child,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: style,
      child: isLoading
          ? const SizedBox(
              width: AppConstants.iconSizeSm,
              height: AppConstants.iconSizeSm,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : child,
    );
  }
}

/// Skeleton loading placeholder
///
/// Shows a shimmering placeholder while content is loading
class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius:
            borderRadius ?? BorderRadius.circular(AppConstants.radiusSm),
      ),
    );
  }
}

/// List skeleton loader
///
/// Shows multiple skeleton items to represent a loading list
class ListSkeletonLoader extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final EdgeInsets padding;

  const ListSkeletonLoader({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80.0,
    this.padding = const EdgeInsets.all(AppConstants.spacingMd),
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.spacingMd),
          child: Row(
            children: [
              const SkeletonLoader(width: 60, height: 60),
              const SizedBox(width: AppConstants.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader(width: double.infinity, height: 16),
                    const SizedBox(height: AppConstants.spacingXs),
                    SkeletonLoader(
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: 12,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Card skeleton loader
///
/// Shows a skeleton representation of a card
class CardSkeletonLoader extends StatelessWidget {
  final double? width;
  final double? height;

  const CardSkeletonLoader({super.key, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SkeletonLoader(
              width: width ?? double.infinity,
              height: height ?? 150,
            ),
            const SizedBox(height: AppConstants.spacingMd),
            SkeletonLoader(width: double.infinity, height: 16),
            const SizedBox(height: AppConstants.spacingXs),
            SkeletonLoader(
              width: MediaQuery.of(context).size.width * 0.6,
              height: 12,
            ),
          ],
        ),
      ),
    );
  }
}

/// Progress indicator with percentage
///
/// Shows a linear progress bar with percentage display
class ProgressIndicatorWithPercentage extends StatelessWidget {
  final double progress;
  final String? label;
  final Color? color;
  final Color? backgroundColor;

  const ProgressIndicatorWithPercentage({
    super.key,
    required this.progress,
    this.label,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).toInt();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label!, style: Theme.of(context).textTheme.bodySmall),
              Text(
                '$percentage%',
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingXs),
        ],
        LinearProgressIndicator(
          value: progress,
          color: color ?? Theme.of(context).colorScheme.primary,
          backgroundColor: backgroundColor ?? Colors.grey[300],
          minHeight: 8,
        ),
      ],
    );
  }
}
