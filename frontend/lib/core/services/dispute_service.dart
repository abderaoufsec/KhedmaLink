// Dispute service for KhedmaLink Flutter app
// Handles API communication for dispute operations

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:khedmalink/core/config/app_config.dart';
import 'package:khedmalink/core/models/dispute_models.dart';
import 'package:khedmalink/core/analytics/app_logger.dart';

/// Dispute API service for dispute operations
class DisputeApiService {
  final String _baseUrl;
  final String _apiVersion;
  String? _authToken;

  DisputeApiService()
      : _baseUrl = AppConfig.apiBaseUrlDirect,
        _apiVersion = AppConfig.apiVersion;

  /// Set authentication token
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// Clear authentication token
  void clearAuthToken() {
    _authToken = null;
  }

  /// Get authorization headers
  Map<String, String> _getHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  /// Create a new dispute
  Future<Dispute> createDispute({
    required String bookingId,
    required DisputeType disputeType,
    required String title,
    required String description,
  }) async {
    try {
      AppLogger.info('Creating dispute for booking: $bookingId');
      
      final uri = Uri.parse('$_baseUrl/$_apiVersion/disputes');
      final body = json.encode({
        'booking_id': bookingId,
        'dispute_type': disputeType.toJson(),
        'title': title,
        'description': description,
      });

      final response = await http.post(uri, headers: _getHeaders(), body: body);

      if (response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        AppLogger.info('Dispute created successfully');
        return Dispute.fromJson(data);
      } else {
        AppLogger.error('Failed to create dispute: ${response.statusCode}');
        throw Exception('Failed to create dispute: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Error creating dispute: $e');
      rethrow;
    }
  }

  /// List disputes for current user
  Future<DisputeListResponse> listDisputes({
    int page = 1,
    int pageSize = 20,
    String? statusFilter,
  }) async {
    try {
      AppLogger.info('Listing disputes: status=$statusFilter');
      
      final queryParams = <String, String>{
        'page': page.toString(),
        'page_size': pageSize.toString(),
      };
      if (statusFilter != null) queryParams['status_filter'] = statusFilter;

      final uri = Uri.parse('$_baseUrl/$_apiVersion/disputes')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _getHeaders());

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        AppLogger.info('Disputes listed successfully: ${data['total']} total');
        return DisputeListResponse.fromJson(data);
      } else {
        AppLogger.error('Failed to list disputes: ${response.statusCode}');
        throw Exception('Failed to list disputes: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Error listing disputes: $e');
      rethrow;
    }
  }

  /// Get a specific dispute
  Future<Dispute> getDispute(String disputeId) async {
    try {
      AppLogger.info('Getting dispute: $disputeId');
      
      final uri = Uri.parse('$_baseUrl/$_apiVersion/disputes/$disputeId');

      final response = await http.get(uri, headers: _getHeaders());

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        AppLogger.info('Dispute retrieved successfully');
        return Dispute.fromJson(data);
      } else {
        AppLogger.error('Failed to get dispute: ${response.statusCode}');
        throw Exception('Failed to get dispute: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Error getting dispute: $e');
      rethrow;
    }
  }

  /// Update dispute (add response)
  Future<Dispute> updateDispute({
    required String disputeId,
    String? response,
  }) async {
    try {
      AppLogger.info('Updating dispute: $disputeId');
      
      final uri = Uri.parse('$_baseUrl/$_apiVersion/disputes/$disputeId');
      final body = json.encode({
        if (response != null) 'response': response,
      });

      final httpResponse = await http.put(uri, headers: _getHeaders(), body: body);

      if (httpResponse.statusCode == 200) {
        final data = json.decode(httpResponse.body) as Map<String, dynamic>;
        AppLogger.info('Dispute updated successfully');
        return Dispute.fromJson(data);
      } else {
        AppLogger.error('Failed to update dispute: ${httpResponse.statusCode}');
        throw Exception('Failed to update dispute: ${httpResponse.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Error updating dispute: $e');
      rethrow;
    }
  }

  /// Add evidence to a dispute
  Future<DisputeEvidence> addEvidence({
    required String disputeId,
    required String evidenceType,
    String? fileUrl,
    String? fileName,
    String? fileSize,
    String? mimeType,
    String? description,
  }) async {
    try {
      AppLogger.info('Adding evidence to dispute: $disputeId');
      
      final uri = Uri.parse('$_baseUrl/$_apiVersion/disputes/$disputeId/evidence');
      final body = json.encode({
        'evidence_type': evidenceType,
        if (fileUrl != null) 'file_url': fileUrl,
        if (fileName != null) 'file_name': fileName,
        if (fileSize != null) 'file_size': fileSize,
        if (mimeType != null) 'mime_type': mimeType,
        if (description != null) 'description': description,
      });

      final response = await http.post(uri, headers: _getHeaders(), body: body);

      if (response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        AppLogger.info('Evidence added successfully');
        return DisputeEvidence.fromJson(data);
      } else {
        AppLogger.error('Failed to add evidence: ${response.statusCode}');
        throw Exception('Failed to add evidence: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Error adding evidence: $e');
      rethrow;
    }
  }

  /// List evidence for a dispute
  Future<DisputeEvidenceListResponse> listEvidence(String disputeId) async {
    try {
      AppLogger.info('Listing evidence for dispute: $disputeId');
      
      final uri = Uri.parse('$_baseUrl/$_apiVersion/disputes/$disputeId/evidence');

      final response = await http.get(uri, headers: _getHeaders());

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        AppLogger.info('Evidence listed successfully');
        return DisputeEvidenceListResponse.fromJson(data);
      } else {
        AppLogger.error('Failed to list evidence: ${response.statusCode}');
        throw Exception('Failed to list evidence: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Error listing evidence: $e');
      rethrow;
    }
  }
}
