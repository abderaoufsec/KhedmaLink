// Quote models for KhedmaLink Flutter app
// Contains data models for quotes and request matches

/// Quote model
class Quote {
  final String id;
  final String requestId;
  final String providerId;
  final String? description;
  final double estimatedPrice;
  final String currency;
  final int? estimatedDuration;
  final String? estimatedDurationUnit;
  final DateTime? availableDate;
  final String? availableTimeStart;
  final String? availableTimeEnd;
  final String status;
  final String? rejectionReason;
  final String? rejectedAt;
  final String createdAt;
  final String? updatedAt;
  final String? submittedAt;
  final String? acceptedAt;

  Quote({
    required this.id,
    required this.requestId,
    required this.providerId,
    this.description,
    required this.estimatedPrice,
    required this.currency,
    this.estimatedDuration,
    this.estimatedDurationUnit,
    this.availableDate,
    this.availableTimeStart,
    this.availableTimeEnd,
    required this.status,
    this.rejectionReason,
    this.rejectedAt,
    required this.createdAt,
    this.updatedAt,
    this.submittedAt,
    this.acceptedAt,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'] as String,
      requestId: json['request_id'] as String,
      providerId: json['provider_id'] as String,
      description: json['description'] as String?,
      estimatedPrice: json['estimated_price'] as double,
      currency: json['currency'] as String,
      estimatedDuration: json['estimated_duration'] as int?,
      estimatedDurationUnit: json['estimated_duration_unit'] as String?,
      availableDate: json['available_date'] != null
          ? DateTime.parse(json['available_date'] as String)
          : null,
      availableTimeStart: json['available_time_start'] as String?,
      availableTimeEnd: json['available_time_end'] as String?,
      status: json['status'] as String,
      rejectionReason: json['rejection_reason'] as String?,
      rejectedAt: json['rejected_at'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String?,
      submittedAt: json['submitted_at'] as String?,
      acceptedAt: json['accepted_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'request_id': requestId,
      'provider_id': providerId,
      'description': description,
      'estimated_price': estimatedPrice,
      'currency': currency,
      'estimated_duration': estimatedDuration,
      'estimated_duration_unit': estimatedDurationUnit,
      'available_date': availableDate?.toIso8601String(),
      'available_time_start': availableTimeStart,
      'available_time_end': availableTimeEnd,
      'status': status,
      'rejection_reason': rejectionReason,
      'rejected_at': rejectedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'submitted_at': submittedAt,
      'accepted_at': acceptedAt,
    };
  }

  /// Check if the quote is draft
  bool get isDraft => status == 'draft';

  /// Check if the quote is submitted
  bool get isSubmitted => status == 'submitted';

  /// Check if the quote is withdrawn
  bool get isWithdrawn => status == 'withdrawn';

  /// Check if the quote is accepted
  bool get isAccepted => status == 'accepted';

  /// Check if the quote is rejected
  bool get isRejected => status == 'rejected';

  /// Check if the quote is expired
  bool get isExpired => status == 'expired';

  /// Get formatted price
  String get formattedPrice => '$estimatedPrice $currency';
}

/// Request match model
class RequestMatch {
  final String id;
  final String requestId;
  final String providerId;
  final double? matchScore;
  final String? eligibilityReason;
  final String status;
  final String createdAt;
  final String? updatedAt;

  RequestMatch({
    required this.id,
    required this.requestId,
    required this.providerId,
    this.matchScore,
    this.eligibilityReason,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory RequestMatch.fromJson(Map<String, dynamic> json) {
    return RequestMatch(
      id: json['id'] as String,
      requestId: json['request_id'] as String,
      providerId: json['provider_id'] as String,
      matchScore: json['match_score'] as double?,
      eligibilityReason: json['eligibility_reason'] as String?,
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'request_id': requestId,
      'provider_id': providerId,
      'match_score': matchScore,
      'eligibility_reason': eligibilityReason,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Check if the match is eligible
  bool get isEligible => status == 'eligible';

  /// Check if the match is declined
  bool get isDeclined => status == 'declined';

  /// Check if the match is quoted
  bool get isQuoted => status == 'quoted';
}
