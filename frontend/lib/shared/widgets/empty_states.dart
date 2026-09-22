import 'package:flutter/material.dart';

import '../../core/localization/app_localization.dart';
import '../../core/constants/app_constants.dart';

/// Standard empty state widget
///
/// Provides a consistent empty state across the application
/// with customizable icon, message, and action button.
class EmptyState extends StatelessWidget {
  final String? message;
  final String? subMessage;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionText;

  const EmptyState({
    super.key,
    this.message,
    this.subMessage,
    this.icon,
    this.onAction,
    this.actionText,
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
              icon ?? Icons.inbox_outlined,
              size: AppConstants.iconSizeXl,
              color: Colors.grey[400],
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Text(
              message ?? localizations.noData,
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            if (subMessage != null) ...[
              const SizedBox(height: AppConstants.spacingSm),
              Text(
                subMessage!,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null) ...[
              const SizedBox(height: AppConstants.spacingLg),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionText ?? 'Add New'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// No search results empty state
///
/// Specialized empty state for search results
class NoSearchResults extends StatelessWidget {
  final String? searchQuery;
  final VoidCallback? onClearSearch;

  const NoSearchResults({super.key, this.searchQuery, this.onClearSearch});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return EmptyState(
      icon: Icons.search_off,
      message: localizations.noResults,
      subMessage: searchQuery != null
          ? 'No results found for "$searchQuery"'
          : 'Try different search terms',
      onAction: onClearSearch,
      actionText: 'Clear Search',
    );
  }
}

/// No items empty state
///
/// Specialized empty state for lists with no items
class NoItems extends StatelessWidget {
  final String? itemType;
  final VoidCallback? onAdd;

  const NoItems({super.key, this.itemType, this.onAdd});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return EmptyState(
      icon: Icons.inventory_2_outlined,
      message: localizations.noItems,
      subMessage: itemType != null
          ? 'No $itemType found. Add your first item to get started.'
          : 'No items found. Add your first item to get started.',
      onAction: onAdd,
      actionText: 'Add First Item',
    );
  }
}

/// No notifications empty state
///
/// Specialized empty state for notifications
class NoNotifications extends StatelessWidget {
  const NoNotifications({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.notifications_none,
      message: 'No Notifications',
      subMessage: 'You\'re all caught up! We\'ll let you know when something important happens.',
    );
  }
}

/// No messages empty state
///
/// Specialized empty state for messages/conversations
class NoMessages extends StatelessWidget {
  final VoidCallback? onStartConversation;

  const NoMessages({super.key, this.onStartConversation});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.message_outlined,
      message: 'No Messages',
      subMessage:
          'Start a conversation with a provider to discuss your service needs.',
      onAction: onStartConversation,
      actionText: 'Start Conversation',
    );
  }
}

/// No bookings empty state
///
/// Specialized empty state for bookings
class NoBookings extends StatelessWidget {
  final VoidCallback? onBookService;

  const NoBookings({super.key, this.onBookService});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.event_busy,
      message: 'No Bookings',
      subMessage: 'You don\'t have any bookings yet. Find a service and book your first appointment.',
      onAction: onBookService,
      actionText: 'Book a Service',
    );
  }
}

/// No favorites empty state
///
/// Specialized empty state for favorites/saved items
class NoFavorites extends StatelessWidget {
  final VoidCallback? onBrowse;

  const NoFavorites({super.key, this.onBrowse});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.favorite_border,
      message: 'No Favorites',
      subMessage: 'Save providers you like to easily find them later.',
      onAction: onBrowse,
      actionText: 'Browse Providers',
    );
  }
}

/// Mini empty state for compact spaces
///
/// Smaller version of empty state for use in cards or tight spaces
class MiniEmptyState extends StatelessWidget {
  final String message;
  final IconData? icon;

  const MiniEmptyState({super.key, required this.message, this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon ?? Icons.inbox_outlined,
            size: AppConstants.iconSizeMd,
            color: Colors.grey[400],
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Text(
            message,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Empty state with illustration placeholder
///
/// Empty state that can include custom illustration/image
class IllustratedEmptyState extends StatelessWidget {
  final String message;
  final String? subMessage;
  final Widget? illustration;
  final VoidCallback? onAction;
  final String? actionText;

  const IllustratedEmptyState({
    super.key,
    required this.message,
    this.subMessage,
    this.illustration,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (illustration != null) ...[
              illustration!,
              const SizedBox(height: AppConstants.spacingLg),
            ],
            Text(
              message,
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            if (subMessage != null) ...[
              const SizedBox(height: AppConstants.spacingSm),
              Text(
                subMessage!,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null) ...[
              const SizedBox(height: AppConstants.spacingLg),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionText ?? 'Get Started'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
