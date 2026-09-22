// Admin service for KhedmaLink Flutter app
// Handles API communication for admin operations

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:khedmalink/core/config/app_config.dart';
import 'package:khedmalink/core/models/admin_models.dart';
import 'package:khedmalink/core/analytics/app_logger.dart';

/// Admin API service for admin operations
class AdminApiService {
  final String _baseUrl;
  final String _apiVersion;
  String? _authToken;

  AdminApiService()
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

  /// List users with optional filters
  Future<UserListResponse> listUsers({
    String? status,
    String? role,
    String? email,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      AppLogger.info('Listing users with filters: status=$status, role=$role, email=$email');
      
      final queryParams = <String, String>{
        'page': page.toString(),
        'page_size': pageSize.toString(),
      };
      if (status != null) queryParams['status'] = status;
      if (role != null) queryParams['role'] = role;
      if (email != null) queryParams['email'] = email;

      final uri = Uri.parse('$_baseUrl/$_apiVersion/admin/users')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _getHeaders());

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        AppLogger.info('Users listed successfully: ${data['total']} total');
        return UserListResponse.fromJson(data);
      } else {
        AppLogger.error('Failed to list users: ${response.statusCode}');
        throw Exception('Failed to list users: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Error listing users: $e');
      rethrow;
    }
  }

  /// Update user status (suspend/unsuspend)
  Future<void> updateUserStatus({
    required String userId,
    required String status,
    String? reason,
  }) async {
    try {
      AppLogger.info('Updating user status: userId=$userId, status=$status');
      
      final uri = Uri.parse('$_baseUrl/$_apiVersion/admin/users/status');
      final body = json.encode({
        'user_id': userId,
        'status': status,
        if (reason != null) 'reason': reason,
      });

      final response = await http.post(uri, headers: _getHeaders(), body: body);

      if (response.statusCode == 200) {
        AppLogger.info('User status updated successfully');
      } else {
        AppLogger.error('Failed to update user status: ${response.statusCode}');
        throw Exception('Failed to update user status: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Error updating user status: $e');
      rethrow;
    }
  }

  /// List verification queue
  Future<VerificationQueueResponse> listVerificationQueue({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      AppLogger.info('Listing verification queue');
      
      final queryParams = <String, String>{
        'page': page.toString(),
        'page_size': pageSize.toString(),
      };

      final uri = Uri.parse('$_baseUrl/$_apiVersion/admin/verification/queue')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _getHeaders());

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        AppLogger.info('Verification queue listed successfully: ${data['total']} total');
        return VerificationQueueResponse.fromJson(data);
      } else {
        AppLogger.error('Failed to list verification queue: ${response.statusCode}');
        throw Exception('Failed to list verification queue: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Error listing verification queue: $e');
      rethrow;
    }
  }

  /// Perform verification action (approve, reject, revoke)
  Future<void> performVerificationAction({
    required String providerId,
    required String action,
    String? reason,
  }) async {
    try {
      AppLogger.info('Performing verification action: providerId=$providerId, action=$action');
      
      final uri = Uri.parse('$_baseUrl/$_apiVersion/admin/verification/action');
      final body = json.encode({
        'provider_id': providerId,
        'action': action,
        if (reason != null) 'reason': reason,
      });

      final response = await http.post(uri, headers: _getHeaders(), body: body);

      if (response.statusCode == 200) {
        AppLogger.info('Verification action performed successfully');
      } else {
        AppLogger.error('Failed to perform verification action: ${response.statusCode}');
        throw Exception('Failed to perform verification action: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Error performing verification action: $e');
      rethrow;
    }
  }

  /// Delete content (reviews, requests, etc.)
  Future<void> deleteContent({
    required String resourceType,
    required String resourceId,
    String? reason,
  }) async {
    try {
      AppLogger.info('Deleting content: type=$resourceType, id=$resourceId');
      
      final uri = Uri.parse('$_baseUrl/$_apiVersion/admin/content/delete');
      final body = json.encode({
        'resource_type': resourceType,
        'resource_id': resourceId,
        if (reason != null) 'reason': reason,
      });

      final response = await http.post(uri, headers: _getHeaders(), body: body);

      if (response.statusCode == 200) {
        AppLogger.info('Content deleted successfully');
      } else {
        AppLogger.error('Failed to delete content: ${response.statusCode}');
        throw Exception('Failed to delete content: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Error deleting content: $e');
      rethrow;
    }
  }

  /// List audit logs
  Future<AuditLogListResponse> listAuditLogs({
    int page = 1,
    int pageSize = 20,
    String? actionType,
  }) async {
    try {
      AppLogger.info('Listing audit logs: actionType=$actionType');
      
      final queryParams = <String, String>{
        'page': page.toString(),
        'page_size': pageSize.toString(),
      };
      if (actionType != null) queryParams['action_type'] = actionType;

      final uri = Uri.parse('$_baseUrl/$_apiVersion/admin/audit-logs')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _getHeaders());

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        AppLogger.info('Audit logs listed successfully: ${data['total']} total');
        return AuditLogListResponse.fromJson(data);
      } else {
        AppLogger.error('Failed to list audit logs: ${response.statusCode}');
        throw Exception('Failed to list audit logs: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Error listing audit logs: $e');
      rethrow;
    }
  }
}
