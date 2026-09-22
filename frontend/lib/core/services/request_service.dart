// Request API service for KhedmaLink Flutter app
// Handles API communication for service request operations

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:khedmalink/core/config/app_config.dart';
import 'package:khedmalink/core/analytics/app_logger.dart';
import 'package:khedmalink/core/models/request_models.dart';
import 'package:khedmalink/core/services/auth_service.dart';

/// Request API service for handling service request API operations
class RequestApiService {
  final http.Client _client;
  final AuthService _authService;

  /// Constructor
  RequestApiService({http.Client? client, AuthService? authService})
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
  // CUSTOMER REQUEST MANAGEMENT METHODS
  // =============================================================================

  /// List current user's service requests
  Future<List<ServiceRequest>> listMyRequests({
    int skip = 0,
    int limit = 100,
    String? statusFilter,
  }) async {
    try {
      AppLogger.info('Fetching my service requests');

      // Build query parameters
      final queryParams = <String, String>{
        'skip': skip.toString(),
        'limit': limit.toString(),
      };

      if (statusFilter != null) {
        queryParams['status_filter'] = statusFilter;
      }

      final uri = Uri.parse('$_baseUrl/api/v1/requests/me/requests')
          .replace(queryParameters: queryParams);

      final response = await _client.get(
        uri,
        headers: await _getAuthHeaders(),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        final requests =
            data.map((item) => ServiceRequest.fromJson(item as Map<String, dynamic>))
                .toList();

        AppLogger.info('My service requests fetched successfully: ${requests.length}');
        return requests;
      } else if (response.statusCode == 401) {
        AppLogger.error('Unauthorized access to service requests');
        throw Exception('Unauthorized');
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to fetch service requests: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to fetch service requests');
      }
    } catch (e) {
      AppLogger.error('Fetch my service requests error: $e');
      rethrow;
    }
  }

  /// Create a new service request
  Future<ServiceRequest> createServiceRequest({
    required String categoryId,
    required String titleAr,
    required String titleFr,
    required String descriptionAr,
    required String descriptionFr,
    required String city,
    required String wilaya,
    String? commune,
    String? address,
    double? latitude,
    double? longitude,
    DateTime? preferredDate,
    String? preferredTimeStart,
    String? preferredTimeEnd,
    bool isFlexible = false,
    double? budgetMin,
    double? budgetMax,
    String currency = 'DZD',
    String urgency = 'medium',
    bool isPublic = true,
  }) async {
    try {
      AppLogger.info('Creating service request');

      final response = await _client.post(
        Uri.parse('$_baseUrl/api/v1/requests/me/requests'),
        headers: await _getAuthHeaders(),
        body: jsonEncode({
          'category_id': categoryId,
          'title_ar': titleAr,
          'title_fr': titleFr,
          'description_ar': descriptionAr,
          'description_fr': descriptionFr,
          'city': city,
          'wilaya': wilaya,
          if (commune?.isNotEmpty == true) 'commune': commune,
          if (address?.isNotEmpty == true) 'address': address,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
          if (preferredDate != null) 'preferred_date': preferredDate.toIso8601String(),
          if (preferredTimeStart?.isNotEmpty == true) 'preferred_time_start': preferredTimeStart,
          if (preferredTimeEnd?.isNotEmpty == true) 'preferred_time_end': preferredTimeEnd,
          'is_flexible': isFlexible,
          if (budgetMin != null) 'budget_min': budgetMin,
          if (budgetMax != null) 'budget_max': budgetMax,
          'currency': currency,
          'urgency': urgency,
          'is_public': isPublic,
        }),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final request = ServiceRequest.fromJson(data);

        AppLogger.info('Service request created successfully: ${request.id}');
        return request;
      } else if (response.statusCode == 401) {
        AppLogger.error('Unauthorized to create service request');
        throw Exception('Unauthorized');
      } else if (response.statusCode == 404) {
        AppLogger.error('Category not found');
        throw Exception('Category not found');
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to create service request: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to create service request');
      }
    } catch (e) {
      AppLogger.error('Create service request error: $e');
      rethrow;
    }
  }

  /// Get a specific service request
  Future<ServiceRequest> getMyRequest(String requestId) async {
    try {
      AppLogger.info('Fetching service request: $requestId');

      final response = await _client.get(
        Uri.parse('$_baseUrl/api/v1/requests/me/requests/$requestId'),
        headers: await _getAuthHeaders(),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final request = ServiceRequest.fromJson(data);

        AppLogger.info('Service request fetched successfully: ${request.id}');
        return request;
      } else if (response.statusCode == 401) {
        AppLogger.error('Unauthorized access to service request');
        throw Exception('Unauthorized');
      } else if (response.statusCode == 404) {
        AppLogger.error('Service request not found');
        throw Exception('Service request not found');
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to fetch service request: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to fetch service request');
      }
    } catch (e) {
      AppLogger.error('Fetch service request error: $e');
      rethrow;
    }
  }

  /// Update a service request
  Future<ServiceRequest> updateServiceRequest(
    String requestId, {
    String? categoryId,
    String? titleAr,
    String? titleFr,
    String? descriptionAr,
    String? descriptionFr,
    String? city,
    String? wilaya,
    String? commune,
    String? address,
    double? latitude,
    double? longitude,
    DateTime? preferredDate,
    String? preferredTimeStart,
    String? preferredTimeEnd,
    bool? isFlexible,
    double? budgetMin,
    double? budgetMax,
    String? currency,
    String? status,
    String? urgency,
    bool? isPublic,
  }) async {
    try {
      AppLogger.info('Updating service request: $requestId');

      final response = await _client.put(
        Uri.parse('$_baseUrl/api/v1/requests/me/requests/$requestId'),
        headers: await _getAuthHeaders(),
        body: jsonEncode({
          if (categoryId != null) 'category_id': categoryId,
          if (titleAr?.isNotEmpty == true) 'title_ar': titleAr,
          if (titleFr?.isNotEmpty == true) 'title_fr': titleFr,
          if (descriptionAr?.isNotEmpty == true) 'description_ar': descriptionAr,
          if (descriptionFr?.isNotEmpty == true) 'description_fr': descriptionFr,
          if (city?.isNotEmpty == true) 'city': city,
          if (wilaya?.isNotEmpty == true) 'wilaya': wilaya,
          if (commune?.isNotEmpty == true) 'commune': commune,
          if (address?.isNotEmpty == true) 'address': address,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
          if (preferredDate != null) 'preferred_date': preferredDate.toIso8601String(),
          if (preferredTimeStart?.isNotEmpty == true) 'preferred_time_start': preferredTimeStart,
          if (preferredTimeEnd?.isNotEmpty == true) 'preferred_time_end': preferredTimeEnd,
          if (isFlexible != null) 'is_flexible': isFlexible,
          if (budgetMin != null) 'budget_min': budgetMin,
          if (budgetMax != null) 'budget_max': budgetMax,
          if (currency?.isNotEmpty == true) 'currency': currency,
          if (status != null) 'status': status,
          if (urgency != null) 'urgency': urgency,
          if (isPublic != null) 'is_public': isPublic,
        }),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final request = ServiceRequest.fromJson(data);

        AppLogger.info('Service request updated successfully: ${request.id}');
        return request;
      } else if (response.statusCode == 401) {
        AppLogger.error('Unauthorized to update service request');
        throw Exception('Unauthorized');
      } else if (response.statusCode == 404) {
        AppLogger.error('Service request not found');
        throw Exception('Service request not found');
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to update service request: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to update service request');
      }
    } catch (e) {
      AppLogger.error('Update service request error: $e');
      rethrow;
    }
  }

  /// Delete a service request
  Future<void> deleteServiceRequest(String requestId) async {
    try {
      AppLogger.info('Deleting service request: $requestId');

      final response = await _client.delete(
        Uri.parse('$_baseUrl/api/v1/requests/me/requests/$requestId'),
        headers: await _getAuthHeaders(),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 204) {
        AppLogger.info('Service request deleted successfully: $requestId');
      } else if (response.statusCode == 401) {
        AppLogger.error('Unauthorized to delete service request');
        throw Exception('Unauthorized');
      } else if (response.statusCode == 404) {
        AppLogger.error('Service request not found');
        throw Exception('Service request not found');
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to delete service request: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to delete service request');
      }
    } catch (e) {
      AppLogger.error('Delete service request error: $e');
      rethrow;
    }
  }

  // =============================================================================
  // PUBLIC REQUEST DISCOVERY METHODS
  // =============================================================================

  /// List public service requests
  Future<List<ServiceRequest>> listPublicRequests({
    int skip = 0,
    int limit = 100,
    String? categoryId,
    String? city,
    String? wilaya,
    String? urgency,
  }) async {
    try {
      AppLogger.info('Fetching public service requests');

      // Build query parameters
      final queryParams = <String, String>{
        'skip': skip.toString(),
        'limit': limit.toString(),
      };

      if (categoryId != null) {
        queryParams['category_id'] = categoryId;
      }
      if (city != null) {
        queryParams['city'] = city;
      }
      if (wilaya != null) {
        queryParams['wilaya'] = wilaya;
      }
      if (urgency != null) {
        queryParams['urgency'] = urgency;
      }

      final uri = Uri.parse('$_baseUrl/api/v1/requests/public/requests')
          .replace(queryParameters: queryParams);

      final response = await _client.get(
        uri,
        headers: await _getAuthHeaders(),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        final requests =
            data.map((item) => ServiceRequest.fromJson(item as Map<String, dynamic>))
                .toList();

        AppLogger.info('Public service requests fetched successfully: ${requests.length}');
        return requests;
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to fetch public service requests: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to fetch public service requests');
      }
    } catch (e) {
      AppLogger.error('Fetch public service requests error: $e');
      rethrow;
    }
  }

  /// Get a public service request
  Future<ServiceRequest> getPublicRequest(String requestId) async {
    try {
      AppLogger.info('Fetching public service request: $requestId');

      final response = await _client.get(
        Uri.parse('$_baseUrl/api/v1/requests/public/requests/$requestId'),
        headers: await _getAuthHeaders(),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final request = ServiceRequest.fromJson(data);

        AppLogger.info('Public service request fetched successfully: ${request.id}');
        return request;
      } else if (response.statusCode == 404) {
        AppLogger.error('Public service request not found');
        throw Exception('Service request not found');
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to fetch public service request: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to fetch public service request');
      }
    } catch (e) {
      AppLogger.error('Fetch public service request error: $e');
      rethrow;
    }
  }

  // =============================================================================
  // REQUEST ATTACHMENT METHODS
  // =============================================================================

  /// List attachments for a service request
  Future<List<RequestAttachment>> listRequestAttachments(String requestId) async {
    try {
      AppLogger.info('Fetching request attachments: $requestId');

      final response = await _client.get(
        Uri.parse('$_baseUrl/api/v1/requests/me/requests/$requestId/attachments'),
        headers: await _getAuthHeaders(),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        final attachments =
            data.map((item) => RequestAttachment.fromJson(item as Map<String, dynamic>))
                .toList();

        AppLogger.info('Request attachments fetched successfully: ${attachments.length}');
        return attachments;
      } else if (response.statusCode == 401) {
        AppLogger.error('Unauthorized access to request attachments');
        throw Exception('Unauthorized');
      } else if (response.statusCode == 404) {
        AppLogger.error('Service request not found');
        throw Exception('Service request not found');
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to fetch request attachments: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to fetch request attachments');
      }
    } catch (e) {
      AppLogger.error('Fetch request attachments error: $e');
      rethrow;
    }
  }

  /// Create a new attachment for a service request
  Future<RequestAttachment> createRequestAttachment(
    String requestId, {
    required String fileUrl,
    required String fileName,
    required String fileType,
    required int fileSize,
    String? thumbnailUrl,
    String attachmentType = 'photo',
  }) async {
    try {
      AppLogger.info('Creating request attachment for: $requestId');

      final response = await _client.post(
        Uri.parse('$_baseUrl/api/v1/requests/me/requests/$requestId/attachments'),
        headers: await _getAuthHeaders(),
        body: jsonEncode({
          'file_url': fileUrl,
          'file_name': fileName,
          'file_type': fileType,
          'file_size': fileSize,
          if (thumbnailUrl?.isNotEmpty == true) 'thumbnail_url': thumbnailUrl,
          'attachment_type': attachmentType,
        }),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final attachment = RequestAttachment.fromJson(data);

        AppLogger.info('Request attachment created successfully: ${attachment.id}');
        return attachment;
      } else if (response.statusCode == 401) {
        AppLogger.error('Unauthorized to create attachment');
        throw Exception('Unauthorized');
      } else if (response.statusCode == 404) {
        AppLogger.error('Service request not found');
        throw Exception('Service request not found');
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to create request attachment: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to create request attachment');
      }
    } catch (e) {
      AppLogger.error('Create request attachment error: $e');
      rethrow;
    }
  }

  /// Delete an attachment from a service request
  Future<void> deleteRequestAttachment(String requestId, String attachmentId) async {
    try {
      AppLogger.info('Deleting request attachment: $attachmentId');

      final response = await _client.delete(
        Uri.parse('$_baseUrl/api/v1/requests/me/requests/$requestId/attachments/$attachmentId'),
        headers: await _getAuthHeaders(),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 204) {
        AppLogger.info('Request attachment deleted successfully: $attachmentId');
      } else if (response.statusCode == 401) {
        AppLogger.error('Unauthorized to delete attachment');
        throw Exception('Unauthorized');
      } else if (response.statusCode == 404) {
        AppLogger.error('Attachment not found');
        throw Exception('Attachment not found');
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to delete request attachment: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to delete request attachment');
      }
    } catch (e) {
      AppLogger.error('Delete request attachment error: $e');
      rethrow;
    }
  }
}
