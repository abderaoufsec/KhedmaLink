// Quote API service for KhedmaLink Flutter app
// Handles API communication for quote operations

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:khedmalink/core/config/app_config.dart';
import 'package:khedmalink/core/analytics/app_logger.dart';
import 'package:khedmalink/core/models/quote_models.dart';
import 'package:khedmalink/core/services/auth_service.dart';

/// Quote API service for handling quote API operations
class QuoteApiService {
  final http.Client _client;
  final AuthService _authService;

  /// Constructor
  QuoteApiService({http.Client? client, AuthService? authService})
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
  // PROVIDER QUOTE MANAGEMENT METHODS
  // =============================================================================

  /// List current provider's quotes
  Future<List<Quote>> listMyQuotes({
    int skip = 0,
    int limit = 100,
    String? statusFilter,
  }) async {
    try {
      AppLogger.info('Fetching my quotes');

      // Build query parameters
      final queryParams = <String, String>{
        'skip': skip.toString(),
        'limit': limit.toString(),
      };

      if (statusFilter != null) {
        queryParams['status_filter'] = statusFilter;
      }

      final uri = Uri.parse('$_baseUrl/api/v1/quotes/me/quotes')
          .replace(queryParameters: queryParams);

      final response = await _client.get(
        uri,
        headers: await _getAuthHeaders(),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        final quotes =
            data.map((item) => Quote.fromJson(item as Map<String, dynamic>))
                .toList();

        AppLogger.info('My quotes fetched successfully: ${quotes.length}');
        return quotes;
      } else if (response.statusCode == 401) {
        AppLogger.error('Unauthorized access to quotes');
        throw Exception('Unauthorized');
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to fetch quotes: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to fetch quotes');
      }
    } catch (e) {
      AppLogger.error('Fetch my quotes error: $e');
      rethrow;
    }
  }

  /// Create a new quote
  Future<Quote> createQuote({
    required String requestId,
    String? description,
    required double estimatedPrice,
    String currency = 'DZD',
    int? estimatedDuration,
    String? estimatedDurationUnit,
    DateTime? availableDate,
    String? availableTimeStart,
    String? availableTimeEnd,
  }) async {
    try {
      AppLogger.info('Creating quote');

      final response = await _client.post(
        Uri.parse('$_baseUrl/api/v1/quotes/me/quotes'),
        headers: await _getAuthHeaders(),
        body: jsonEncode({
          'request_id': requestId,
          if (description?.isNotEmpty == true) 'description': description,
          'estimated_price': estimatedPrice,
          'currency': currency,
          if (estimatedDuration != null) 'estimated_duration': estimatedDuration,
          if (estimatedDurationUnit?.isNotEmpty == true) 'estimated_duration_unit': estimatedDurationUnit,
          if (availableDate != null) 'available_date': availableDate.toIso8601String(),
          if (availableTimeStart?.isNotEmpty == true) 'available_time_start': availableTimeStart,
          if (availableTimeEnd?.isNotEmpty == true) 'available_time_end': availableTimeEnd,
        }),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final quote = Quote.fromJson(data);

        AppLogger.info('Quote created successfully: ${quote.id}');
        return quote;
      } else if (response.statusCode == 401) {
        AppLogger.error('Unauthorized to create quote');
        throw Exception('Unauthorized');
      } else if (response.statusCode == 404) {
        AppLogger.error('Service request not found');
        throw Exception('Service request not found');
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to create quote: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to create quote');
      }
    } catch (e) {
      AppLogger.error('Create quote error: $e');
      rethrow;
    }
  }

  /// Get a specific quote
  Future<Quote> getMyQuote(String quoteId) async {
    try {
      AppLogger.info('Fetching quote: $quoteId');

      final response = await _client.get(
        Uri.parse('$_baseUrl/api/v1/quotes/me/quotes/$quoteId'),
        headers: await _getAuthHeaders(),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final quote = Quote.fromJson(data);

        AppLogger.info('Quote fetched successfully: ${quote.id}');
        return quote;
      } else if (response.statusCode == 401) {
        AppLogger.error('Unauthorized access to quote');
        throw Exception('Unauthorized');
      } else if (response.statusCode == 404) {
        AppLogger.error('Quote not found');
        throw Exception('Quote not found');
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to fetch quote: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to fetch quote');
      }
    } catch (e) {
      AppLogger.error('Fetch quote error: $e');
      rethrow;
    }
  }

  /// Update a quote
  Future<Quote> updateQuote(
    String quoteId, {
    String? description,
    double? estimatedPrice,
    String? currency,
    int? estimatedDuration,
    String? estimatedDurationUnit,
    DateTime? availableDate,
    String? availableTimeStart,
    String? availableTimeEnd,
    String? status,
  }) async {
    try {
      AppLogger.info('Updating quote: $quoteId');

      final response = await _client.put(
        Uri.parse('$_baseUrl/api/v1/quotes/me/quotes/$quoteId'),
        headers: await _getAuthHeaders(),
        body: jsonEncode({
          if (description?.isNotEmpty == true) 'description': description,
          if (estimatedPrice != null) 'estimated_price': estimatedPrice,
          if (currency?.isNotEmpty == true) 'currency': currency,
          if (estimatedDuration != null) 'estimated_duration': estimatedDuration,
          if (estimatedDurationUnit?.isNotEmpty == true) 'estimated_duration_unit': estimatedDurationUnit,
          if (availableDate != null) 'available_date': availableDate.toIso8601String(),
          if (availableTimeStart?.isNotEmpty == true) 'available_time_start': availableTimeStart,
          if (availableTimeEnd?.isNotEmpty == true) 'available_time_end': availableTimeEnd,
          if (status != null) 'status': status,
        }),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final quote = Quote.fromJson(data);

        AppLogger.info('Quote updated successfully: ${quote.id}');
        return quote;
      } else if (response.statusCode == 401) {
        AppLogger.error('Unauthorized to update quote');
        throw Exception('Unauthorized');
      } else if (response.statusCode == 404) {
        AppLogger.error('Quote not found');
        throw Exception('Quote not found');
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to update quote: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to update quote');
      }
    } catch (e) {
      AppLogger.error('Update quote error: $e');
      rethrow;
    }
  }

  /// Delete a quote
  Future<void> deleteQuote(String quoteId) async {
    try {
      AppLogger.info('Deleting quote: $quoteId');

      final response = await _client.delete(
        Uri.parse('$_baseUrl/api/v1/quotes/me/quotes/$quoteId'),
        headers: await _getAuthHeaders(),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 204) {
        AppLogger.info('Quote deleted successfully: $quoteId');
      } else if (response.statusCode == 401) {
        AppLogger.error('Unauthorized to delete quote');
        throw Exception('Unauthorized');
      } else if (response.statusCode == 404) {
        AppLogger.error('Quote not found');
        throw Exception('Quote not found');
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to delete quote: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to delete quote');
      }
    } catch (e) {
      AppLogger.error('Delete quote error: $e');
      rethrow;
    }
  }

  // =============================================================================
  // CUSTOMER QUOTE MANAGEMENT METHODS
  // =============================================================================

  /// List quotes for a service request
  Future<List<Quote>> listRequestQuotes(String requestId) async {
    try {
      AppLogger.info('Fetching quotes for request: $requestId');

      final response = await _client.get(
        Uri.parse('$_baseUrl/api/v1/quotes/me/requests/$requestId/quotes'),
        headers: await _getAuthHeaders(),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        final quotes =
            data.map((item) => Quote.fromJson(item as Map<String, dynamic>))
                .toList();

        AppLogger.info('Request quotes fetched successfully: ${quotes.length}');
        return quotes;
      } else if (response.statusCode == 401) {
        AppLogger.error('Unauthorized access to request quotes');
        throw Exception('Unauthorized');
      } else if (response.statusCode == 404) {
        AppLogger.error('Service request not found');
        throw Exception('Service request not found');
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to fetch request quotes: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to fetch request quotes');
      }
    } catch (e) {
      AppLogger.error('Fetch request quotes error: $e');
      rethrow;
    }
  }

  /// Accept a quote for a service request
  Future<Quote> acceptQuote(String requestId, String quoteId) async {
    try {
      AppLogger.info('Accepting quote: $quoteId for request: $requestId');

      final response = await _client.post(
        Uri.parse('$_baseUrl/api/v1/quotes/me/requests/$requestId/quotes/$quoteId/accept'),
        headers: await _getAuthHeaders(),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final quote = Quote.fromJson(data);

        AppLogger.info('Quote accepted successfully: ${quote.id}');
        return quote;
      } else if (response.statusCode == 401) {
        AppLogger.error('Unauthorized to accept quote');
        throw Exception('Unauthorized');
      } else if (response.statusCode == 404) {
        AppLogger.error('Quote or request not found');
        throw Exception('Quote or request not found');
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to accept quote: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to accept quote');
      }
    } catch (e) {
      AppLogger.error('Accept quote error: $e');
      rethrow;
    }
  }

  // =============================================================================
  // REQUEST MATCH METHODS
  // =============================================================================

  /// List eligible requests for the current provider
  Future<List<RequestMatch>> listEligibleRequests({
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      AppLogger.info('Fetching eligible requests');

      // Build query parameters
      final queryParams = <String, String>{
        'skip': skip.toString(),
        'limit': limit.toString(),
      };

      final uri = Uri.parse('$_baseUrl/api/v1/quotes/me/eligible-requests')
          .replace(queryParameters: queryParams);

      final response = await _client.get(
        uri,
        headers: await _getAuthHeaders(),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        final matches =
            data.map((item) => RequestMatch.fromJson(item as Map<String, dynamic>))
                .toList();

        AppLogger.info('Eligible requests fetched successfully: ${matches.length}');
        return matches;
      } else if (response.statusCode == 401) {
        AppLogger.error('Unauthorized access to eligible requests');
        throw Exception('Unauthorized');
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to fetch eligible requests: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to fetch eligible requests');
      }
    } catch (e) {
      AppLogger.error('Fetch eligible requests error: $e');
      rethrow;
    }
  }
}
