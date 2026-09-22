// Authentication models for KhedmaLink Flutter app
// Data models for authentication operations

/// User model representing a user in the system
class User {
  final String id;
  final String email;
  final String? fullName;
  final String? phone;
  final bool isActive;
  final bool isVerified;
  final String status;
  final List<String> roles;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    this.fullName,
    this.phone,
    required this.isActive,
    required this.isVerified,
    required this.status,
    required this.roles,
    required this.createdAt,
  });

  /// Create User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      phone: json['phone'] as String?,
      isActive: json['is_active'] as bool,
      isVerified: json['is_verified'] as bool,
      status: json['status'] as String,
      roles: (json['roles'] as List).map((e) => e.toString()).toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'is_active': isActive,
      'is_verified': isVerified,
      'status': status,
      'roles': roles,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Check if user has specific role
  bool hasRole(String role) {
    return roles.contains(role);
  }

  /// Check if user is admin
  bool get isAdmin => hasRole('admin') || hasRole('super_admin');

  /// Check if user is provider
  bool get isProvider => hasRole('provider');

  /// Check if user is customer
  bool get isCustomer => hasRole('customer');

  /// Check if user is verified
  bool get isUserVerified => isVerified;

  /// Check if user account is active
  bool get isUserActive => isActive && status == 'active';
}

/// Token response model
class TokenResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;

  TokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
  });

  /// Create TokenResponse from JSON
  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: json['token_type'] as String,
      expiresIn: json['expires_in'] as int,
    );
  }

  /// Convert TokenResponse to JSON
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
    };
  }
}

/// Login request model
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  /// Convert LoginRequest to JSON
  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}

/// Register request model
class RegisterRequest {
  final String email;
  final String password;
  final String? fullName;
  final String? phone;

  RegisterRequest({
    required this.email,
    required this.password,
    this.fullName,
    this.phone,
  });

  /// Convert RegisterRequest to JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      if (fullName != null) 'full_name': fullName,
      if (phone != null) 'phone': phone,
    };
  }
}

/// User update request model
class UserUpdateRequest {
  final String? fullName;
  final String? phone;

  UserUpdateRequest({this.fullName, this.phone});

  /// Convert UserUpdateRequest to JSON
  Map<String, dynamic> toJson() {
    return {
      if (fullName != null) 'full_name': fullName,
      if (phone != null) 'phone': phone,
    };
  }
}

/// Password change request model
class PasswordChangeRequest {
  final String currentPassword;
  final String newPassword;

  PasswordChangeRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  /// Convert PasswordChangeRequest to JSON
  Map<String, dynamic> toJson() {
    return {'current_password': currentPassword, 'new_password': newPassword};
  }
}

/// Token refresh request model
class TokenRefreshRequest {
  final String refreshToken;

  TokenRefreshRequest({required this.refreshToken});

  /// Convert TokenRefreshRequest to JSON
  Map<String, dynamic> toJson() {
    return {'refresh_token': refreshToken};
  }
}

/// Authentication state enum
enum AuthState {
  /// User is not authenticated
  unauthenticated,

  /// User is in the process of authenticating
  authenticating,

  /// User is authenticated
  authenticated,

  /// Authentication failed
  authenticationFailed,

  /// User is logging out
  loggingOut,
}

/// Authentication exception
class AuthException implements Exception {
  final String message;
  final int? statusCode;

  AuthException(this.message, {this.statusCode});

  @override
  String toString() => 'AuthException: $message (status: $statusCode)';
}
