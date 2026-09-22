// Booking models for KhedmaLink Flutter app
// Contains data models for bookings and booking events

/// Booking model
class Booking {
  final String id;
  final String requestId;
  final String quoteId;
  final String customerId;
  final String providerId;
  final String? scheduledDate;
  final String? scheduledTimeStart;
  final String? scheduledTimeEnd;
  final int? estimatedDuration;
  final String? estimatedDurationUnit;
  final double agreedPrice;
  final String currency;
  final String? address;
  final String? city;
  final String? wilaya;
  final double? latitude;
  final double? longitude;
  final String status;
  final String? cancelledAt;
  final String? cancelledBy;
  final String? cancellationReason;
  final String? completedAt;
  final String? completionNotes;
  final String createdAt;
  final String? updatedAt;

  Booking({
    required this.id,
    required this.requestId,
    required this.quoteId,
    required this.customerId,
    required this.providerId,
    this.scheduledDate,
    this.scheduledTimeStart,
    this.scheduledTimeEnd,
    this.estimatedDuration,
    this.estimatedDurationUnit,
    required this.agreedPrice,
    required this.currency,
    this.address,
    this.city,
    this.wilaya,
    this.latitude,
    this.longitude,
    required this.status,
    this.cancelledAt,
    this.cancelledBy,
    this.cancellationReason,
    this.completedAt,
    this.completionNotes,
    required this.createdAt,
    this.updatedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      requestId: json['request_id'] as String,
      quoteId: json['quote_id'] as String,
      customerId: json['customer_id'] as String,
      providerId: json['provider_id'] as String,
      scheduledDate: json['scheduled_date'] as String?,
      scheduledTimeStart: json['scheduled_time_start'] as String?,
      scheduledTimeEnd: json['scheduled_time_end'] as String?,
      estimatedDuration: json['estimated_duration'] as int?,
      estimatedDurationUnit: json['estimated_duration_unit'] as String?,
      agreedPrice: json['agreed_price'] as double,
      currency: json['currency'] as String,
      address: json['address'] as String?,
      city: json['city'] as String?,
      wilaya: json['wilaya'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      status: json['status'] as String,
      cancelledAt: json['cancelled_at'] as String?,
      cancelledBy: json['cancelled_by'] as String?,
      cancellationReason: json['cancellation_reason'] as String?,
      completedAt: json['completed_at'] as String?,
      completionNotes: json['completion_notes'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'request_id': requestId,
      'quote_id': quoteId,
      'customer_id': customerId,
      'provider_id': providerId,
      'scheduled_date': scheduledDate,
      'scheduled_time_start': scheduledTimeStart,
      'scheduled_time_end': scheduledTimeEnd,
      'estimated_duration': estimatedDuration,
      'estimated_duration_unit': estimatedDurationUnit,
      'agreed_price': agreedPrice,
      'currency': currency,
      'address': address,
      'city': city,
      'wilaya': wilaya,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'cancelled_at': cancelledAt,
      'cancelled_by': cancelledBy,
      'cancellation_reason': cancellationReason,
      'completed_at': completedAt,
      'completion_notes': completionNotes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Check if the booking is accepted
  bool get isAccepted => status == 'accepted';

  /// Check if the booking is scheduled
  bool get isScheduled => status == 'scheduled';

  /// Check if the booking is in progress
  bool get isInProgress => status == 'in_progress';

  /// Check if the booking is completed
  bool get isCompleted => status == 'completed';

  /// Check if the booking is cancelled
  bool get isCancelled => status == 'cancelled';

  /// Check if the booking is disputed
  bool get isDisputed => status == 'disputed';

  /// Get formatted price
  String get formattedPrice => '$agreedPrice $currency';

  /// Check if the booking can be cancelled
  bool get canBeCancelled => ['accepted', 'scheduled'].contains(status);

  /// Check if the booking can be started (provider only)
  bool get canBeStarted => status == 'scheduled';

  /// Check if the booking can be completed (provider only)
  bool get canBeCompleted => status == 'in_progress';
}

/// Booking event model
class BookingEvent {
  final String id;
  final String bookingId;
  final String? triggeredBy;
  final String eventType;
  final String? oldStatus;
  final String? newStatus;
  final String? notes;
  final String? eventMetadata;
  final String createdAt;

  BookingEvent({
    required this.id,
    required this.bookingId,
    this.triggeredBy,
    required this.eventType,
    this.oldStatus,
    this.newStatus,
    this.notes,
    this.eventMetadata,
    required this.createdAt,
  });

  factory BookingEvent.fromJson(Map<String, dynamic> json) {
    return BookingEvent(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      triggeredBy: json['triggered_by'] as String?,
      eventType: json['event_type'] as String,
      oldStatus: json['old_status'] as String?,
      newStatus: json['new_status'] as String?,
      notes: json['notes'] as String?,
      eventMetadata: json['event_metadata'] as String?,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'triggered_by': triggeredBy,
      'event_type': eventType,
      'old_status': oldStatus,
      'new_status': newStatus,
      'notes': notes,
      'event_metadata': eventMetadata,
      'created_at': createdAt,
    };
  }
}
