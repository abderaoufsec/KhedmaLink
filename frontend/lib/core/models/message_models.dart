// Message and notification models for KhedmaLink Flutter app
// Contains data models for messaging and notifications

/// Message model
class Message {
  final String id;
  final String bookingId;
  final String senderId;
  final String content;
  final String messageType; // text, image, system
  final bool isRead;
  final String? readAt;
  final String createdAt;
  final String? updatedAt;

  Message({
    required this.id,
    required this.bookingId,
    required this.senderId,
    required this.content,
    required this.messageType,
    required this.isRead,
    this.readAt,
    required this.createdAt,
    this.updatedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      messageType: json['message_type'] as String,
      isRead: json['is_read'] as bool,
      readAt: json['read_at'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'sender_id': senderId,
      'content': content,
      'message_type': messageType,
      'is_read': isRead,
      'read_at': readAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Check if message is a text message
  bool get isText => messageType == 'text';

  /// Check if message is an image
  bool get isImage => messageType == 'image';

  /// Check if message is a system message
  bool get isSystem => messageType == 'system';
}

/// Message attachment model
class MessageAttachment {
  final String id;
  final String messageId;
  final String fileName;
  final String fileUrl;
  final int fileSize;
  final String fileType;
  final String uploadStatus;
  final String createdAt;

  MessageAttachment({
    required this.id,
    required this.messageId,
    required this.fileName,
    required this.fileUrl,
    required this.fileSize,
    required this.fileType,
    required this.uploadStatus,
    required this.createdAt,
  });

  factory MessageAttachment.fromJson(Map<String, dynamic> json) {
    return MessageAttachment(
      id: json['id'] as String,
      messageId: json['message_id'] as String,
      fileName: json['file_name'] as String,
      fileUrl: json['file_url'] as String,
      fileSize: json['file_size'] as int,
      fileType: json['file_type'] as String,
      uploadStatus: json['upload_status'] as String,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message_id': messageId,
      'file_name': fileName,
      'file_url': fileUrl,
      'file_size': fileSize,
      'file_type': fileType,
      'upload_status': uploadStatus,
      'created_at': createdAt,
    };
  }

  /// Get formatted file size
  String get formattedFileSize {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Check if upload is pending
  bool get isPending => uploadStatus == 'pending';

  /// Check if upload is complete
  bool get isUploaded => uploadStatus == 'uploaded';

  /// Check if upload failed
  bool get isFailed => uploadStatus == 'failed';
}

/// App notification model (renamed to avoid conflict with Flutter's Notification)
class AppNotification {
  final String id;
  final String userId;
  final String notificationType;
  final String titleAr;
  final String titleFr;
  final String? bodyAr;
  final String? bodyFr;
  final String? entityType;
  final String? entityId;
  final bool isRead;
  final String? readAt;
  final String createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.notificationType,
    required this.titleAr,
    required this.titleFr,
    this.bodyAr,
    this.bodyFr,
    this.entityType,
    this.entityId,
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      notificationType: json['notification_type'] as String,
      titleAr: json['title_ar'] as String,
      titleFr: json['title_fr'] as String,
      bodyAr: json['body_ar'] as String?,
      bodyFr: json['body_fr'] as String?,
      entityType: json['entity_type'] as String?,
      entityId: json['entity_id'] as String?,
      isRead: json['is_read'] as bool,
      readAt: json['read_at'] as String?,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'notification_type': notificationType,
      'title_ar': titleAr,
      'title_fr': titleFr,
      'body_ar': bodyAr,
      'body_fr': bodyFr,
      'entity_type': entityType,
      'entity_id': entityId,
      'is_read': isRead,
      'read_at': readAt,
      'created_at': createdAt,
    };
  }

  /// Get localized title based on language
  String getLocalizedTitle(String language) {
    return language == 'ar' ? titleAr : titleFr;
  }

  /// Get localized body based on language
  String? getLocalizedBody(String language) {
    return language == 'ar' ? bodyAr : bodyFr;
  }

  /// Check if notification is about a quote
  bool get isAboutQuote => notificationType == 'quote_received' || notificationType == 'quote_accepted';

  /// Check if notification is about a booking
  bool get isAboutBooking => notificationType.startsWith('booking_');

  /// Check if notification is about a message
  bool get isAboutMessage => notificationType == 'message_received';

  /// Check if notification is unread
  bool get isUnread => !isRead;
}
