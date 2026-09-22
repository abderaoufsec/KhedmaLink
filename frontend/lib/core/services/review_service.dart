// Review API service for KhedmaLink Flutter app
// Handles API communication for review operations

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:khedmalink/core/config/app_config.dart';
import 'package:khedmalink/core/analytics/app_logger.dart';
import 'package:khedmalink/core/models/review_models.dart';
import 'package:khedmalink/core/services/auth_service.dart';

/// Review API service for handling review API operations
class ReviewApiService {
  final http.Client _client;
  final AuthService _authService;

  /// Constructor
  ReviewApiService({http.Client? client, AuthService? authService})
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
  // REVIEW METHODS
  // =============================================================================

  /// Get review for a booking
  Future<Review?> getBookingReview(String bookingId) async {
    try {
      AppLogger.info('Fetching review for booking: $bookingId');

      final response = await _client.get(
        Uri.parse('$_baseUrl/api/v1/reviews/me/bookings/$bookingId/review'),
        headers: await _getAuthHeaders(),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final review = Review.fromJson(data);

        AppLogger.info('Review fetched successfully: ${review.id}');
        return review;
      } else if (response.statusCode == 401) {
        AppLogger.error('Unauthorized access to review');
        throw Exception('Unauthorized');
      } else if (response.statusCode == 403) {
        AppLogger.error('Forbidden access to review');
        throw Exception('You do not have permission to access this review');
      } else if (response.statusCode == 404) {
        AppLogger.info('No review found for booking');
        return null;
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to fetch review: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to fetch review');
      }
    } catch (e) {
      AppLogger.error('Fetch review error: $e');
      rethrow;
    }
  }

  /// Create a review for a booking
  Future<Review> createReview(
    String bookingId,
    int rating, {
    String? title,
    String? comment,
    int? professionalism,
    int? quality,
    int? timeliness,
    int? communication,
    int? value,
  }) async {
    try {
      AppLogger.info('Creating review for booking: $bookingId');

      final response = await _client.post(
        Uri.parse('$_baseUrl/api/v1/reviews/me/bookings/$bookingId/review'),
        headers: await _getAuthHeaders(),
        body: jsonEncode({
          'booking_id': bookingId,
          'rating': rating,
          if (title != null) 'title': title,
          if (comment != null) 'comment': comment,
          if (professionalism != null) 'professionalism': professionalism,
          if (quality != null) 'quality': quality,
          if (timeliness != null) 'timeliness': timeliness,
          if (communication != null) 'communication': communication,
          if (value != null) 'value': value,
        }),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final review = Review.fromJson(data);

        AppLogger.info('Review created successfully: ${review.id}');
        return review;
      } else if (response.statusCode == 401) {
        AppLogger.error('Unauthorized to create review');
        throw Exception('Unauthorized');
      } else if (response.statusCode == 403) {
        AppLogger.error('Forbidden to create review');
        throw Exception('Only the customer can create a review');
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to create review: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to create review');
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to create review: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to create review');
      }
    } catch (e) {
      AppLogger.error('Create review error: $e');
      rethrow;
    }
  }

  /// List reviews for a provider
  Future<List<Review>> listProviderReviews(
    String providerId, {
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      AppLogger.info('Fetching reviews for provider: $providerId');

      final queryParams = <String, String>{
        'skip': skip.toString(),
        'limit': limit.toString(),
      };

      final uri = Uri.parse('$_baseUrl/api/v1/reviews/providers/$providerId/reviews')
          .replace(queryParameters: queryParams);

      final response = await _client.get(
        uri,
        headers: await _getAuthHeaders(),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        final reviews =
            data.map((item) => Review.fromJson(item as Map<String, dynamic>))
                .toList();

        AppLogger.info('Reviews fetched successfully: ${reviews.length}');
        return reviews;
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to fetch reviews: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to fetch reviews');
      }
    } catch (e) {
      AppLogger.error('Fetch reviews error: $e');
      rethrow;
    }
  }

  /// Get provider reputation
  Future<ProviderReputation> getProviderReputation(String providerId) async {
    try {
      AppLogger.info('Fetching reputation for provider: $providerId');

      final response = await _client.get(
        Uri.parse('$_baseUrl/api/v1/reviews/providers/$providerId/reputation'),
        headers: await _getAuthHeaders(),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final reputation = ProviderReputation.fromJson(data);

        AppLogger.info('Reputation fetched successfully');
        return reputation;
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to fetch reputation: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to fetch reputation');
      }
    } catch (e) {
      AppLogger.error('Fetch reputation error: $e');
      rethrow;
    }
  }

  /// Update a review
  Future<Review> updateReview(
    String reviewId, {
    String? title,
    String? comment,
    String? providerResponse,
  }) async {
    try {
      AppLogger.info('Updating review: $reviewId');

      final response = await _client.patch(
        Uri.parse('$_baseUrl/api/v1/reviews/me/reviews/$reviewId'),
        headers: await _getAuthHeaders(),
        body: jsonEncode({
          if (title != null) 'title': title,
          if (comment != null) 'comment': comment,
          if (providerResponse != null) 'provider_response': providerResponse,
        }),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final review = Review.fromJson(data);

        AppLogger.info('Review updated successfully: ${review.id}');
        return review;
      } else if (response.statusCode == 401) {
        AppLogger.error('Unauthorized to update review');
        throw Exception('Unauthorized');
      } else if (response.statusCode == 403) {
        AppLogger.error('Forbidden to update review');
        throw Exception('You do not have permission to update this review');
      } else if (response.statusCode == 404) {
        AppLogger.error('Review not found');
        throw Exception('Review not found');
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to update review: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to update review');
      }
    } catch (e) {
      AppLogger.error('Update review error: $e');
      rethrow;
    }
  }
}
