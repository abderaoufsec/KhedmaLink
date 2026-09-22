// Admin models for KhedmaLink Flutter app
// Contains data models for admin operations and audit logs

import 'package:khedmalink/core/config/app_config.dart';

/// Audit action type enum
enum AuditActionType {
  verificationApproved,
  verificationRejected,
  verificationRevoked,
  userSuspended,
  userUnsuspended,
  reviewDeleted,
  requestDeleted,
  categoryCreated,
  categoryUpdated,
  categoryDeleted,
  platformSettingChanged,
  featureFlagChanged,
  disputeResolved,
}

/// Extension for AuditActionType string conversion
extension AuditActionTypeExtension on AuditActionType {
  String toJson() {
    return toString().split('.').last;
  }

  static AuditActionType fromJson(String value) {
    return AuditActionType.values.firstWhere(
      (e) => e.toJson() == value,
      orElse: () => AuditActionType.platformSettingChanged,
    );
  }

  /// Get localized display name
  String getDisplayName(String language) {
    switch (this) {
      case AuditActionType.verificationApproved:
        return language == 'ar' ? 'موافقة التحقق' : 'Verification Approved';
      case AuditActionType.verificationRejected:
        return language == 'ar' ? 'رفض التحقق' : 'Verification Rejected';
      case AuditActionType.verificationRevoked:
        return language == 'ar' ? 'إلغاء التحقق' : 'Verification Revoked';
      case AuditActionType.userSuspended:
        return language == 'ar' ? 'تعليق المستخدم' : 'User Suspended';
      case AuditActionType.userUnsuspended:
        return language == 'ar' ? 'إلغاء تعليق المستخدم' : 'User Unsuspended';
      case AuditActionType.reviewDeleted:
        return language == 'ar' ? 'حذف التقييم' : 'Review Deleted';
      case AuditActionType.requestDeleted:
        return language == 'ar' ? 'حذف الطلب' : 'Request Deleted';
      case AuditActionType.categoryCreated:
        return language == 'ar' ? 'إنشاء الفئة' : 'Category Created';
      case AuditActionType.categoryUpdated:
        return language == 'ar' ? 'تحديث الفئة' : 'Category Updated';
      case AuditActionType.categoryDeleted:
        return language == 'ar' ? 'حذف الفئة' : 'Category Deleted';
      case AuditActionType.platformSettingChanged:
        return language == 'ar' ? 'تغيير إعدادات المنصة' : 'Platform Setting Changed';
      case AuditActionType.featureFlagChanged:
        return language == 'ar' ? 'تغيير ميزة' : 'Feature Flag Changed';
      case AuditActionType.disputeResolved:
        return language == 'ar' ? 'حل النزاع' : 'Dispute Resolved';
    }
  }
}

/// Audit log model
class AuditLog {
  final String id;
  final AuditActionType actionType;
  final String actorId;
  final String? targetUserId;
  final String? targetResourceType;
  final String? targetResourceId;
  final String description;
  final String? reason;
  final String? changes;
  final String? ipAddress;
  final String? userAgent;
  final DateTime createdAt;

  AuditLog({
    required this.id,
    required this.actionType,
    required this.actorId,
    this.targetUserId,
    this.targetResourceType,
    this.targetResourceId,
    required this.description,
    this.reason,
    this.changes,
    this.ipAddress,
    this.userAgent,
    required this.createdAt,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['id'] as String,
      actionType: AuditActionTypeExtension.fromJson(json['action_type'] as String),
      actorId: json['actor_id'] as String,
      targetUserId: json['target_user_id'] as String?,
      targetResourceType: json['target_resource_type'] as String?,
      targetResourceId: json['target_resource_id'] as String?,
      description: json['description'] as String,
      reason: json['reason'] as String?,
      changes: json['changes'] as String?,
      ipAddress: json['ip_address'] as String?,
      userAgent: json['user_agent'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action_type': actionType.toJson(),
      'actor_id': actorId,
      'target_user_id': targetUserId,
      'target_resource_type': targetResourceType,
      'target_resource_id': targetResourceId,
      'description': description,
      'reason': reason,
      'changes': changes,
      'ip_address': ipAddress,
      'user_agent': userAgent,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// User list item model
class UserListItem {
  final String id;
  final String email;
  final String? fullName;
  final String? phone;
  final String status;
  final bool isActive;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? lastLogin;

  UserListItem({
    required this.id,
    required this.email,
    this.fullName,
    this.phone,
    required this.status,
    required this.isActive,
    required this.isVerified,
    required this.createdAt,
    this.lastLogin,
  });

  factory UserListItem.fromJson(Map<String, dynamic> json) {
    return UserListItem(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      phone: json['phone'] as String?,
      status: json['status'] as String,
      isActive: json['is_active'] as bool,
      isVerified: json['is_verified'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastLogin: json['last_login'] != null ? DateTime.parse(json['last_login'] as String) : null,
    );
  }

  /// Get localized status display
  String getStatusDisplay(String language) {
    switch (status) {
      case 'active':
        return language == 'ar' ? 'نشط' : 'Active';
      case 'suspended':
        return language == 'ar' ? 'معلق' : 'Suspended';
      case 'deleted':
        return language == 'ar' ? 'محذوف' : 'Deleted';
      default:
        return status;
    }
  }
}

/// User list response model
class UserListResponse {
  final List<UserListItem> items;
  final int total;
  final int page;
  final int pageSize;

  UserListResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory UserListResponse.fromJson(Map<String, dynamic> json) {
    return UserListResponse(
      items: (json['items'] as List).map((e) => UserListItem.fromJson(e as Map<String, dynamic>)).toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      pageSize: json['page_size'] as int,
    );
  }
}

/// Provider verification queue item model
class ProviderVerificationQueueItem {
  final String providerId;
  final String userId;
  final String? businessName;
  final String? businessType;
  final String verificationStatus;
  final String verificationLevel;
  final DateTime? submittedAt;
  final DateTime createdAt;

  ProviderVerificationQueueItem({
    required this.providerId,
    required this.userId,
    this.businessName,
    this.businessType,
    required this.verificationStatus,
    required this.verificationLevel,
    this.submittedAt,
    required this.createdAt,
  });

  factory ProviderVerificationQueueItem.fromJson(Map<String, dynamic> json) {
    return ProviderVerificationQueueItem(
      providerId: json['provider_id'] as String,
      userId: json['user_id'] as String,
      businessName: json['business_name'] as String?,
      businessType: json['business_type'] as String?,
      verificationStatus: json['verification_status'] as String,
      verificationLevel: json['verification_level'] as String,
      submittedAt: json['submitted_at'] != null ? DateTime.parse(json['submitted_at'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Get localized verification status display
  String getVerificationStatusDisplay(String language) {
    switch (verificationStatus) {
      case 'pending':
        return language == 'ar' ? 'قيد الانتظار' : 'Pending';
      case 'verified':
        return language == 'ar' ? 'موثق' : 'Verified';
      case 'rejected':
        return language == 'ar' ? 'مرفوض' : 'Rejected';
      case 'unverified':
        return language == 'ar' ? 'غير موثق' : 'Unverified';
      default:
        return verificationStatus;
    }
  }
}

/// Verification queue response model
class VerificationQueueResponse {
  final List<ProviderVerificationQueueItem> items;
  final int total;
  final int page;
  final int pageSize;

  VerificationQueueResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory VerificationQueueResponse.fromJson(Map<String, dynamic> json) {
    return VerificationQueueResponse(
      items: (json['items'] as List).map((e) => ProviderVerificationQueueItem.fromJson(e as Map<String, dynamic>)).toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      pageSize: json['page_size'] as int,
    );
  }
}

/// Audit log list response model
class AuditLogListResponse {
  final List<AuditLog> items;
  final int total;
  final int page;
  final int pageSize;

  AuditLogListResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory AuditLogListResponse.fromJson(Map<String, dynamic> json) {
    return AuditLogListResponse(
      items: (json['items'] as List).map((e) => AuditLog.fromJson(e as Map<String, dynamic>)).toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      pageSize: json['page_size'] as int,
    );
  }
}
