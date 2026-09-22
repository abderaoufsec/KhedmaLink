// Authentication service for KhedmaLink Flutter app
// Handles API communication for authentication operations

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:khedmalink/core/config/app_config.dart';
import 'package:khedmalink/core/analytics/app_logger.dart';

/// Authentication service for handling login, register, and token management
class AuthService {
  final http.Client _client;

  // Storage keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userRolesKey = 'user_roles';

  /// Constructor
  AuthService({http.Client? client}) : _client = client ?? http.Client();

  /// Get base URL from config
  String get _baseUrl => AppConfig.apiBaseUrlDirect;

  /// Register a new user
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String? fullName,
    String? phone,
  }) async {
    try {
      AppLogger.info('Registering user: $email');

      final response = await _client.post(
        Uri.parse('$_baseUrl/api/v1/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          if (fullName?.isNotEmpty == true) 'full_name': fullName,
          if (phone?.isNotEmpty == true) 'phone': phone,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        AppLogger.info('User registered successfully: ${data['id']}');
        return data;
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Registration failed: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Registration failed');
      }
    } catch (e) {
      AppLogger.error('Registration error: $e');
      rethrow;
    }
  }

  /// Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.info('Logging in user: $email');

      final response = await _client.post(
        Uri.parse('$_baseUrl/api/v1/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // Store tokens
        await _storeTokens(
          accessToken: data['access_token'] as String,
          refreshToken: data['refresh_token'] as String,
        );

        AppLogger.info('User logged in successfully');
        return data;
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Login failed: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Login failed');
      }
    } catch (e) {
      AppLogger.error('Login error: $e');
      rethrow;
    }
  }

  /// Refresh access token
  Future<Map<String, dynamic>> refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();

      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      AppLogger.info('Refreshing access token');

      final response = await _client.post(
        Uri.parse('$_baseUrl/api/v1/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // Update stored tokens
        await _storeTokens(
          accessToken: data['access_token'] as String,
          refreshToken: data['refresh_token'] as String,
        );

        AppLogger.info('Token refreshed successfully');
        return data;
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Token refresh failed: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Token refresh failed');
      }
    } catch (e) {
      AppLogger.error('Token refresh error: $e');
      rethrow;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      AppLogger.info('Logging out user');

      // Call logout endpoint (optional, token is stateless)
      await _client.post(
        Uri.parse('$_baseUrl/api/v1/auth/logout'),
        headers: await _getAuthHeaders(),
      );

      // Clear stored tokens
      await _clearTokens();

      AppLogger.info('User logged out successfully');
    } catch (e) {
      AppLogger.error('Logout error: $e');
      // Clear tokens even if API call fails
      await _clearTokens();
      rethrow;
    }
  }

  /// Get current user profile
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      AppLogger.info('Fetching current user profile');

      final response = await _client.get(
        Uri.parse('$_baseUrl/api/v1/users/me'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // Store user info
        await _storeUserInfo(data);

        AppLogger.info('User profile fetched successfully');
        return data;
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to fetch user profile: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to fetch user profile');
      }
    } catch (e) {
      AppLogger.error('Get current user error: $e');
      rethrow;
    }
  }

  /// Update user profile
  Future<Map<String, dynamic>> updateUserProfile({
    String? fullName,
    String? phone,
  }) async {
    try {
      AppLogger.info('Updating user profile');

      final response = await _client.patch(
        Uri.parse('$_baseUrl/api/v1/users/me'),
        headers: await _getAuthHeaders(),
        body: jsonEncode({
          if (fullName?.isNotEmpty == true) 'full_name': fullName,
          if (phone?.isNotEmpty == true) 'phone': phone,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        AppLogger.info('User profile updated successfully');
        return data;
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Profile update failed: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Profile update failed');
      }
    } catch (e) {
      AppLogger.error('Update profile error: $e');
      rethrow;
    }
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      AppLogger.info('Changing password');

      final response = await _client.post(
        Uri.parse('$_baseUrl/api/v1/users/me/change-password'),
        headers: await _getAuthHeaders(),
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode == 204) {
        AppLogger.info('Password changed successfully');
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Password change failed: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Password change failed');
      }
    } catch (e) {
      AppLogger.error('Change password error: $e');
      rethrow;
    }
  }

  // =============================================================================
  // TOKEN MANAGEMENT
  // =============================================================================

  /// Get access token
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Store tokens locally
  Future<void> _storeTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  /// Clear tokens locally
  Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userRolesKey);
  }

  /// Store user info locally
  Future<void> _storeUserInfo(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userData['id'] as String);
    await prefs.setString(_userEmailKey, userData['email'] as String);
    await prefs.setStringList(
      _userRolesKey,
      (userData['roles'] as List).map((e) => e.toString()).toList(),
    );
  }

  /// Get user ID
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  /// Get user email
  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  /// Get user roles
  Future<List<String>> getUserRoles() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_userRolesKey) ?? [];
  }

  /// Check if user has specific role
  Future<bool> hasRole(String role) async {
    final roles = await getUserRoles();
    return roles.contains(role);
  }

  /// Check if user is admin
  Future<bool> isAdmin() async {
    return await hasRole('admin') || await hasRole('super_admin');
  }

  /// Check if user is provider
  Future<bool> isProvider() async {
    return await hasRole('provider');
  }

  /// Check if user is customer
  Future<bool> isCustomer() async {
    return await hasRole('customer');
  }

  // =============================================================================
  // HTTP HELPERS
  // =============================================================================

  /// Get authorization headers
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
