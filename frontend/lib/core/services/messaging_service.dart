// Messaging API service for KhedmaLink Flutter app
// Handles API communication for messaging and notifications

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:khedmalink/core/config/app_config.dart';
import 'package:khedmalink/core/analytics/app_logger.dart';
import 'package:khedmalink/core/models/message_models.dart' as models;
import 'package:khedmalink/core/services/auth_service.dart';

/// Messaging API service for handling messaging and notification API operations
class MessagingApiService {
  final http.Client _client;
  final AuthService _authService;

  /// Constructor
  MessagingApiService({http.Client? client, AuthService? authService})
      : _client = client ?? http.Client(),
        _authService = authService ?? AuthService();

  /// Get base URL from config
  String get _baseUrl => AppConfig.apiBaseUrlDirect;

  /// Get authorization headers
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      return {'Content-Type': 'application/json'};
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // =============================================================================
  // MESSAGE METHODS
  // =============================================================================

  /// List messages for a booking
  Future<List<models.Message>> listBookingMessages(
    String bookingId, {
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      AppLogger.info('Fetching messages for booking: $bookingId');

      // Build query parameters
      final queryParams = <String, String>{
        'skip': skip.toString(),
        'limit': limit.toString(),
      };

      final uri = Uri.parse('$_baseUrl/api/v1/messages/me/bookings/$bookingId/messages')
          .replace(queryParameters: queryParams);

      final response = await _client.get(
        uri,
        headers: await _getAuthHeaders(),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        final messages =
            data.map((item) => models.Message.fromJson(item as Map<String, dynamic>))
                .toList();

        AppLogger.info('Messages fetched successfully: ${messages.length}');
        return messages;
      } else if (response.statusCode == 401) {
        AppLogger.error('Unauthorized access to messages');
        throw Exception('Unauthorized');
      } else if (response.statusCode == 403) {
        AppLogger.error('Forbidden access to messages');
        throw Exception('You do not have permission to access these messages');
      } else if (response.statusCode == 404) {
        AppLogger.error('Booking not found');
        throw Exception('Booking not found');
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to fetch messages: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to fetch messages');
      }
    } catch (e) {
      AppLogger.error('Fetch messages error: $e');
      rethrow;
    }
  }

  /// Create a new message for a booking
  Future<models.Message> createMessage(String bookingId, String content) async {
    try {
      AppLogger.info('Creating message for booking: $bookingId');

      final response = await _client.post(
        Uri.parse('$_baseUrl/api/v1/messages/me/bookings/$bookingId/messages'),
        headers: await _getAuthHeaders(),
        body: jsonEncode({
          'booking_id': bookingId,
          'content': content,
          'message_type': 'text',
        }),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final message = models.Message.fromJson(data);

        AppLogger.info('Message created successfully: ${message.id}');
        return message;
      } else if (response.statusCode == 401) {
        AppLogger.error('Unauthorized to create message');
        throw Exception('Unauthorized');
      } else if (response.statusCode == 403) {
        AppLogger.error('Forbidden to create message');
        throw Exception('You do not have permission to send messages to this booking');
      } else if (response.statusCode == 404) {
        AppLogger.error('Booking not found');
        throw Exception('Booking not found');
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to create message: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to create message');
      }
    } catch (e) {
      AppLogger.error('Create message error: $e');
      rethrow;
    }
  }

  /// Update a message (mark as read)
  Future<models.Message> updateMessage(String messageId, bool isRead) async {
    try {
      AppLogger.info('Updating message: $messageId');

      final response = await _client.patch(
        Uri.parse('$_baseUrl/api/v1/messages/me/messages/$messageId'),
        headers: await _getAuthHeaders(),
        body: jsonEncode({
          'is_read': isRead,
        }),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final message = models.Message.fromJson(data);

        AppLogger.info('Message updated successfully: ${message.id}');
        return message;
      } else if (response.statusCode == 401) {
        AppLogger.error('Unauthorized to update message');
        throw Exception('Unauthorized');
      } else if (response.statusCode == 403) {
        AppLogger.error('Forbidden to update message');
        throw Exception('You do not have permission to update this message');
      } else if (response.statusCode == 404) {
        AppLogger.error('Message not found');
        throw Exception('Message not found');
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to update message: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to update message');
      }
    } catch (e) {
      AppLogger.error('Update message error: $e');
      rethrow;
    }
  }

  // =============================================================================
  // NOTIFICATION METHODS
  // =============================================================================

  /// List current user's notifications
  Future<List<models.AppNotification>> listMyNotifications({
    int skip = 0,
    int limit = 100,
    bool unreadOnly = false,
  }) async {
    try {
      AppLogger.info('Fetching my notifications');

      // Build query parameters
      final queryParams = <String, String>{
        'skip': skip.toString(),
        'limit': limit.toString(),
      };

      if (unreadOnly) {
        queryParams['unread_only'] = 'true';
      }

      final uri = Uri.parse('$_baseUrl/api/v1/messages/me/notifications')
          .replace(queryParameters: queryParams);

      final response = await _client.get(
        uri,
        headers: await _getAuthHeaders(),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        final notifications =
            data.map((item) => models.AppNotification.fromJson(item as Map<String, dynamic>))
                .toList();

        AppLogger.info('Notifications fetched successfully: ${notifications.length}');
        return notifications;
      } else if (response.statusCode == 401) {
        AppLogger.error('Unauthorized access to notifications');
        throw Exception('Unauthorized');
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to fetch notifications: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to fetch notifications');
      }
    } catch (e) {
      AppLogger.error('Fetch notifications error: $e');
      rethrow;
    }
  }

  /// Update a notification (mark as read)
  Future<models.AppNotification> updateNotification(String notificationId, bool isRead) async {
    try {
      AppLogger.info('Updating notification: $notificationId');

      final response = await _client.patch(
        Uri.parse('$_baseUrl/api/v1/messages/me/notifications/$notificationId'),
        headers: await _getAuthHeaders(),
        body: jsonEncode({
          'is_read': isRead,
        }),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final notification = models.AppNotification.fromJson(data);

        AppLogger.info('Notification updated successfully: ${notification.id}');
        return notification;
      } else if (response.statusCode == 401) {
        AppLogger.error('Unauthorized to update notification');
        throw Exception('Unauthorized');
      } else if (response.statusCode == 403) {
        AppLogger.error('Forbidden to update notification');
        throw Exception('You do not have permission to update this notification');
      } else if (response.statusCode == 404) {
        AppLogger.error('Notification not found');
        throw Exception('Notification not found');
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to update notification: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to update notification');
      }
    } catch (e) {
      AppLogger.error('Update notification error: $e');
      rethrow;
    }
  }
}
