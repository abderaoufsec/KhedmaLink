// Notifications screen for KhedmaLink Flutter app
// Displays user notifications with mark as read functionality

import 'package:flutter/material.dart';
import 'package:khedmalink/core/models/message_models.dart' as models;
import 'package:khedmalink/core/services/messaging_service.dart' as api;
import 'package:khedmalink/core/analytics/app_logger.dart';

/// Notifications screen
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final api.MessagingApiService _messagingService = api.MessagingApiService();
  List<models.AppNotification> _notifications = [];
  bool _isLoading = true;
  bool _showUnreadOnly = false;
  String? _errorMessage;

  String get language => 'ar'; // Will be from localization provider

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final notifications = await _messagingService.listMyNotifications(
        unreadOnly: _showUnreadOnly,
      );
      if (mounted) {
        setState(() {
          _notifications = notifications;
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('Load notifications error: $e');
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      await _messagingService.updateNotification(notificationId, true);
      if (mounted) {
        setState(() {
          _notifications.removeWhere((n) => n.id == notificationId);
        });
      }
    } catch (e) {
      AppLogger.error('Mark notification as read error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              language == 'ar' ? 'فشل تحديث الإشعار' : 'Failed to update notification',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          language == 'ar' ? 'الإشعارات' : 'Notifications',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotifications,
          ),
          PopupMenuButton<bool>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _showUnreadOnly = value;
              });
              _loadNotifications();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: false,
                child: Text(language == 'ar' ? 'الكل' : 'All'),
              ),
              PopupMenuItem(
                value: true,
                child: Text(language == 'ar' ? 'غير المقروءة' : 'Unread'),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(context, language),
    );
  }

  Widget _buildBody(BuildContext context, String language) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error: $_errorMessage',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadNotifications,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              language == 'ar' ? 'لا توجد إشعارات' : 'No notifications',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              language == 'ar'
                  ? 'ستظهر الإشعارات هنا عند حدوث أحداث مهمة'
                  : 'Notifications will appear here for important events',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return _NotificationTile(
            notification: notification,
            language: language,
            onTap: () => _markAsRead(notification.id),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final models.AppNotification notification;
  final String language;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.language,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: notification.isUnread ? 2 : 1,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon based on type
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification.notificationType).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  _getNotificationIcon(notification.notificationType),
                  color: _getNotificationColor(notification.notificationType),
                ),
              ),
              const SizedBox(width: 16),
              // Notification content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.getLocalizedTitle(language),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: notification.isUnread ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    if (notification.getLocalizedBody(language) != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        notification.getLocalizedBody(language)!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(notification.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              // Unread indicator
              if (notification.isUnread)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'quote_received':
      case 'quote_accepted':
        return Colors.blue;
      case 'booking_created':
      case 'booking_scheduled':
        return Colors.purple;
      case 'booking_started':
        return Colors.orange;
      case 'booking_completed':
        return Colors.green;
      case 'booking_cancelled':
        return Colors.red;
      case 'message_received':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'quote_received':
      case 'quote_accepted':
        return Icons.description;
      case 'booking_created':
      case 'booking_scheduled':
        return Icons.event;
      case 'booking_started':
        return Icons.play_circle_outline;
      case 'booking_completed':
        return Icons.check_circle_outline;
      case 'booking_cancelled':
        return Icons.cancel;
      case 'message_received':
        return Icons.chat_bubble_outline;
      default:
        return Icons.notifications;
    }
  }

  String _formatTime(String dateTime) {
    final date = DateTime.parse(dateTime);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return language == 'ar' ? 'الآن' : 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} ${language == 'ar' ? 'دقيقة' : 'min'}';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} ${language == 'ar' ? 'ساعة' : 'hr'}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${language == 'ar' ? 'يوم' : 'days'}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
