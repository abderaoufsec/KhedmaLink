// Booking API service for KhedmaLink Flutter app
// Handles API communication for booking operations

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:khedmalink/core/config/app_config.dart';
import 'package:khedmalink/core/analytics/app_logger.dart';
import 'package:khedmalink/core/models/booking_models.dart';
import 'package:khedmalink/core/services/auth_service.dart';

/// Booking API service for handling booking API operations
class BookingApiService {
  final http.Client _client;
  final AuthService _authService;

  /// Constructor
  BookingApiService({http.Client? client, AuthService? authService})
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
  // BOOKING MANAGEMENT METHODS
  // =============================================================================

  /// List current user's bookings (as customer or provider)
  Future<List<Booking>> listMyBookings({
    int skip = 0,
    int limit = 100,
    String? statusFilter,
  }) async {
    try {
      AppLogger.info('Fetching my bookings');

      // Build query parameters
      final queryParams = <String, String>{
        'skip': skip.toString(),
        'limit': limit.toString(),
      };

      if (statusFilter != null) {
        queryParams['status_filter'] = statusFilter;
      }

      final uri = Uri.parse('$_baseUrl/api/v1/bookings/me/bookings')
          .replace(queryParameters: queryParams);

      final response = await _client.get(
        uri,
        headers: await _getAuthHeaders(),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        final bookings =
            data.map((item) => Booking.fromJson(item as Map<String, dynamic>))
                .toList();

        AppLogger.info('My bookings fetched successfully: ${bookings.length}');
        return bookings;
      } else if (response.statusCode == 401) {
        AppLogger.error('Unauthorized access to bookings');
        throw Exception('Unauthorized');
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to fetch bookings: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to fetch bookings');
      }
    } catch (e) {
      AppLogger.error('Fetch my bookings error: $e');
      rethrow;
    }
  }

  /// Get a specific booking
  Future<Booking> getMyBooking(String bookingId) async {
    try {
      AppLogger.info('Fetching booking: $bookingId');

      final response = await _client.get(
        Uri.parse('$_baseUrl/api/v1/bookings/me/bookings/$bookingId'),
        headers: await _getAuthHeaders(),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final booking = Booking.fromJson(data);

        AppLogger.info('Booking fetched successfully: ${booking.id}');
        return booking;
      } else if (response.statusCode == 401) {
        AppLogger.error('Unauthorized access to booking');
        throw Exception('Unauthorized');
      } else if (response.statusCode == 404) {
        AppLogger.error('Booking not found');
        throw Exception('Booking not found');
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to fetch booking: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to fetch booking');
      }
    } catch (e) {
      AppLogger.error('Fetch booking error: $e');
      rethrow;
    }
  }

  /// Cancel a booking
  Future<Booking> cancelBooking(String bookingId, String reason) async {
    try {
      AppLogger.info('Cancelling booking: $bookingId');

      final response = await _client.post(
        Uri.parse('$_baseUrl/api/v1/bookings/me/bookings/$bookingId/cancel'),
        headers: await _getAuthHeaders(),
        body: jsonEncode({
          'cancellation_reason': reason,
        }),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final booking = Booking.fromJson(data);

        AppLogger.info('Booking cancelled successfully: ${booking.id}');
        return booking;
      } else if (response.statusCode == 401) {
        AppLogger.error('Unauthorized to cancel booking');
        throw Exception('Unauthorized');
      } else if (response.statusCode == 404) {
        AppLogger.error('Booking not found');
        throw Exception('Booking not found');
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to cancel booking: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to cancel booking');
      }
    } catch (e) {
      AppLogger.error('Cancel booking error: $e');
      rethrow;
    }
  }

  /// Start a booking (provider only)
  Future<Booking> startBooking(String bookingId) async {
    try {
      AppLogger.info('Starting booking: $bookingId');

      final response = await _client.post(
        Uri.parse('$_baseUrl/api/v1/bookings/me/bookings/$bookingId/start'),
        headers: await _getAuthHeaders(),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final booking = Booking.fromJson(data);

        AppLogger.info('Booking started successfully: ${booking.id}');
        return booking;
      } else if (response.statusCode == 401) {
        AppLogger.error('Unauthorized to start booking');
        throw Exception('Unauthorized');
      } else if (response.statusCode == 403) {
        AppLogger.error('Only provider can start booking');
        throw Exception('Only the provider can start this booking');
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to start booking: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to start booking');
      }
    } catch (e) {
      AppLogger.error('Start booking error: $e');
      rethrow;
    }
  }

  /// Complete a booking (provider only)
  Future<Booking> completeBooking(String bookingId, {String? notes}) async {
    try {
      AppLogger.info('Completing booking: $bookingId');

      final response = await _client.post(
        Uri.parse('$_baseUrl/api/v1/bookings/me/bookings/$bookingId/complete'),
        headers: await _getAuthHeaders(),
        body: jsonEncode({
          if (notes != null) 'completion_notes': notes,
        }),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final booking = Booking.fromJson(data);

        AppLogger.info('Booking completed successfully: ${booking.id}');
        return booking;
      } else if (response.statusCode == 401) {
        AppLogger.error('Unauthorized to complete booking');
        throw Exception('Unauthorized');
      } else if (response.statusCode == 403) {
        AppLogger.error('Only provider can complete booking');
        throw Exception('Only the provider can complete this booking');
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to complete booking: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to complete booking');
      }
    } catch (e) {
      AppLogger.error('Complete booking error: $e');
      rethrow;
    }
  }

  // =============================================================================
  // BOOKING EVENTS METHODS
  // =============================================================================

  /// List events for a booking
  Future<List<BookingEvent>> listBookingEvents(String bookingId) async {
    try {
      AppLogger.info('Fetching events for booking: $bookingId');

      final response = await _client.get(
        Uri.parse('$_baseUrl/api/v1/bookings/me/bookings/$bookingId/events'),
        headers: await _getAuthHeaders(),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        final events =
            data.map((item) => BookingEvent.fromJson(item as Map<String, dynamic>))
                .toList();

        AppLogger.info('Booking events fetched successfully: ${events.length}');
        return events;
      } else if (response.statusCode == 401) {
        AppLogger.error('Unauthorized access to booking events');
        throw Exception('Unauthorized');
      } else if (response.statusCode == 404) {
        AppLogger.error('Booking not found');
        throw Exception('Booking not found');
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to fetch booking events: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to fetch booking events');
      }
    } catch (e) {
      AppLogger.error('Fetch booking events error: $e');
      rethrow;
    }
  }
}
