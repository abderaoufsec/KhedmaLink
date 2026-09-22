// Service request models for KhedmaLink Flutter app
// Contains data models for customer service requests and attachments

/// Service request model
class ServiceRequest {
  final String id;
  final String customerId;
  final String categoryId;
  final String titleAr;
  final String titleFr;
  final String descriptionAr;
  final String descriptionFr;
  final String city;
  final String wilaya;
  final String? commune;
  final String? address;
  final double? latitude;
  final double? longitude;
  final DateTime? preferredDate;
  final String? preferredTimeStart;
  final String? preferredTimeEnd;
  final bool isFlexible;
  final double? budgetMin;
  final double? budgetMax;
  final String currency;
  final String status;
  final String urgency;
  final bool isPublic;
  final String createdAt;
  final String? updatedAt;
  final String? closedAt;

  ServiceRequest({
    required this.id,
    required this.customerId,
    required this.categoryId,
    required this.titleAr,
    required this.titleFr,
    required this.descriptionAr,
    required this.descriptionFr,
    required this.city,
    required this.wilaya,
    this.commune,
    this.address,
    this.latitude,
    this.longitude,
    this.preferredDate,
    this.preferredTimeStart,
    this.preferredTimeEnd,
    required this.isFlexible,
    this.budgetMin,
    this.budgetMax,
    required this.currency,
    required this.status,
    required this.urgency,
    required this.isPublic,
    required this.createdAt,
    this.updatedAt,
    this.closedAt,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'] as String,
      customerId: json['customer_id'] as String,
      categoryId: json['category_id'] as String,
      titleAr: json['title_ar'] as String,
      titleFr: json['title_fr'] as String,
      descriptionAr: json['description_ar'] as String,
      descriptionFr: json['description_fr'] as String,
      city: json['city'] as String,
      wilaya: json['wilaya'] as String,
      commune: json['commune'] as String?,
      address: json['address'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      preferredDate: json['preferred_date'] != null
          ? DateTime.parse(json['preferred_date'] as String)
          : null,
      preferredTimeStart: json['preferred_time_start'] as String?,
      preferredTimeEnd: json['preferred_time_end'] as String?,
      isFlexible: json['is_flexible'] as bool,
      budgetMin: json['budget_min'] as double?,
      budgetMax: json['budget_max'] as double?,
      currency: json['currency'] as String,
      status: json['status'] as String,
      urgency: json['urgency'] as String,
      isPublic: json['is_public'] as bool,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String?,
      closedAt: json['closed_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'category_id': categoryId,
      'title_ar': titleAr,
      'title_fr': titleFr,
      'description_ar': descriptionAr,
      'description_fr': descriptionFr,
      'city': city,
      'wilaya': wilaya,
      'commune': commune,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'preferred_date': preferredDate?.toIso8601String(),
      'preferred_time_start': preferredTimeStart,
      'preferred_time_end': preferredTimeEnd,
      'is_flexible': isFlexible,
      'budget_min': budgetMin,
      'budget_max': budgetMax,
      'currency': currency,
      'status': status,
      'urgency': urgency,
      'is_public': isPublic,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'closed_at': closedAt,
    };
  }

  /// Get the localized title based on the current language
  String getLocalizedName(String language) {
    return language == 'ar' ? titleAr : titleFr;
  }

  /// Get the localized description based on the current language
  String getLocalizedDescription(String language) {
    return language == 'ar' ? descriptionAr : descriptionFr;
  }

  /// Check if the request is open
  bool get isOpen => status == 'open';

  /// Check if the request is closed
  bool get isClosed => status == 'closed';

  /// Check if the request is cancelled
  bool get isCancelled => status == 'cancelled';

  /// Check if the request is draft
  bool get isDraft => status == 'draft';
}

/// Request attachment model
class RequestAttachment {
  final String id;
  final String requestId;
  final String fileUrl;
  final String fileName;
  final String fileType;
  final int fileSize;
  final String? thumbnailUrl;
  final String attachmentType;
  final String? uploadedBy;
  final String uploadStatus;
  final String createdAt;

  RequestAttachment({
    required this.id,
    required this.requestId,
    required this.fileUrl,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    this.thumbnailUrl,
    required this.attachmentType,
    this.uploadedBy,
    required this.uploadStatus,
    required this.createdAt,
  });

  factory RequestAttachment.fromJson(Map<String, dynamic> json) {
    return RequestAttachment(
      id: json['id'] as String,
      requestId: json['request_id'] as String,
      fileUrl: json['file_url'] as String,
      fileName: json['file_name'] as String,
      fileType: json['file_type'] as String,
      fileSize: json['file_size'] as int,
      thumbnailUrl: json['thumbnail_url'] as String?,
      attachmentType: json['attachment_type'] as String,
      uploadedBy: json['uploaded_by'] as String?,
      uploadStatus: json['upload_status'] as String,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'request_id': requestId,
      'file_url': fileUrl,
      'file_name': fileName,
      'file_type': fileType,
      'file_size': fileSize,
      'thumbnail_url': thumbnailUrl,
      'attachment_type': attachmentType,
      'uploaded_by': uploadedBy,
      'upload_status': uploadStatus,
      'created_at': createdAt,
    };
  }

  /// Check if attachment is a photo
  bool get isPhoto => attachmentType == 'photo';

  /// Check if attachment is a document
  bool get isDocument => attachmentType == 'document';

  /// Get file size in KB
  double get fileSizeKB => fileSize / 1024;

  /// Get file size in MB
  double get fileSizeMB => fileSize / (1024 * 1024);
}
