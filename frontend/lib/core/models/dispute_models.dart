// Dispute models for KhedmaLink Flutter app
// Contains data models for disputes and dispute evidence

import 'package:khedmalink/core/config/app_config.dart';

/// Dispute status enum
enum DisputeStatus {
  open,
  investigating,
  resolved,
  closed,
}

/// Dispute type enum
enum DisputeType {
  serviceQuality,
  paymentIssue,
  communication,
  damage,
  safety,
  other,
}

/// Extension for DisputeStatus string conversion
extension DisputeStatusExtension on DisputeStatus {
  String toJson() {
    return toString().split('.').last;
  }

  static DisputeStatus fromJson(String value) {
    return DisputeStatus.values.firstWhere(
      (e) => e.toJson() == value,
      orElse: () => DisputeStatus.open,
    );
  }

  /// Get localized display name
  String getDisplayName(String language) {
    switch (this) {
      case DisputeStatus.open:
        return language == 'ar' ? 'مفتوح' : 'Open';
      case DisputeStatus.investigating:
        return language == 'ar' ? 'قيد التحقيق' : 'Investigating';
      case DisputeStatus.resolved:
        return language == 'ar' ? 'تم الحل' : 'Resolved';
      case DisputeStatus.closed:
        return language == 'ar' ? 'مغلق' : 'Closed';
    }
  }
}

/// Extension for DisputeType string conversion
extension DisputeTypeExtension on DisputeType {
  String toJson() {
    return toString().split('.').last;
  }

  static DisputeType fromJson(String value) {
    return DisputeType.values.firstWhere(
      (e) => e.toJson() == value,
      orElse: () => DisputeType.other,
    );
  }

  /// Get localized display name
  String getDisplayName(String language) {
    switch (this) {
      case DisputeType.serviceQuality:
        return language == 'ar' ? 'جودة الخدمة' : 'Service Quality';
      case DisputeType.paymentIssue:
        return language == 'ar' ? 'مشكلة دفع' : 'Payment Issue';
      case DisputeType.communication:
        return language == 'ar' ? 'التواصل' : 'Communication';
      case DisputeType.damage:
        return language == 'ar' ? 'أضرار' : 'Damage';
      case DisputeType.safety:
        return language == 'ar' ? 'السلامة' : 'Safety';
      case DisputeType.other:
        return language == 'ar' ? 'أخرى' : 'Other';
    }
  }
}

/// Dispute model
class Dispute {
  final String id;
  final String bookingId;
  final String raisedBy;
  final DisputeType disputeType;
  final DisputeStatus status;
  final String title;
  final String description;
  final String? resolution;
  final String? resolvedBy;
  final DateTime? resolvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Dispute({
    required this.id,
    required this.bookingId,
    required this.raisedBy,
    required this.disputeType,
    required this.status,
    required this.title,
    required this.description,
    this.resolution,
    this.resolvedBy,
    this.resolvedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Dispute.fromJson(Map<String, dynamic> json) {
    return Dispute(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      raisedBy: json['raised_by'] as String,
      disputeType: DisputeTypeExtension.fromJson(json['dispute_type'] as String),
      status: DisputeStatusExtension.fromJson(json['status'] as String),
      title: json['title'] as String,
      description: json['description'] as String,
      resolution: json['resolution'] as String?,
      resolvedBy: json['resolved_by'] as String?,
      resolvedAt: json['resolved_at'] != null ? DateTime.parse(json['resolved_at'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'raised_by': raisedBy,
      'dispute_type': disputeType.toJson(),
      'status': status.toJson(),
      'title': title,
      'description': description,
      'resolution': resolution,
      'resolved_by': resolvedBy,
      'resolved_at': resolvedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Dispute evidence model
class DisputeEvidence {
  final String id;
  final String disputeId;
  final String submittedBy;
  final String evidenceType;
  final String? fileUrl;
  final String? fileName;
  final String? fileSize;
  final String? mimeType;
  final String? description;
  final DateTime createdAt;

  DisputeEvidence({
    required this.id,
    required this.disputeId,
    required this.submittedBy,
    required this.evidenceType,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    this.mimeType,
    this.description,
    required this.createdAt,
  });

  factory DisputeEvidence.fromJson(Map<String, dynamic> json) {
    return DisputeEvidence(
      id: json['id'] as String,
      disputeId: json['dispute_id'] as String,
      submittedBy: json['submitted_by'] as String,
      evidenceType: json['evidence_type'] as String,
      fileUrl: json['file_url'] as String?,
      fileName: json['file_name'] as String?,
      fileSize: json['file_size'] as String?,
      mimeType: json['mime_type'] as String?,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dispute_id': disputeId,
      'submitted_by': submittedBy,
      'evidence_type': evidenceType,
      'file_url': fileUrl,
      'file_name': fileName,
      'file_size': fileSize,
      'mime_type': mimeType,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Dispute list response model
class DisputeListResponse {
  final List<Dispute> items;
  final int total;
  final int page;
  final int pageSize;

  DisputeListResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory DisputeListResponse.fromJson(Map<String, dynamic> json) {
    return DisputeListResponse(
      items: (json['items'] as List).map((e) => Dispute.fromJson(e as Map<String, dynamic>)).toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      pageSize: json['page_size'] as int,
    );
  }
}

/// Dispute evidence list response model
class DisputeEvidenceListResponse {
  final List<DisputeEvidence> items;

  DisputeEvidenceListResponse({
    required this.items,
  });

  factory DisputeEvidenceListResponse.fromJson(Map<String, dynamic> json) {
    return DisputeEvidenceListResponse(
      items: (json['items'] as List).map((e) => DisputeEvidence.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
