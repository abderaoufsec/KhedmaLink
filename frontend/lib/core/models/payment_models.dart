// Payment models for KhedmaLink Flutter app
// Contains data models for payments, transactions, and payouts

import 'package:khedmalink/core/config/app_config.dart';

/// Payment method enum
enum PaymentMethod {
  cash,
  manual,
  card,
}

/// Payment status enum
enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  refunded,
  partiallyRefunded,
}

/// Transaction type enum
enum TransactionType {
  capture,
  refund,
  payout,
}

/// Payout status enum
enum PayoutStatus {
  pending,
  processing,
  completed,
  failed,
}

/// Extension for PaymentMethod string conversion
extension PaymentMethodExtension on PaymentMethod {
  String toJson() {
    return toString().split('.').last;
  }

  static PaymentMethod fromJson(String value) {
    return PaymentMethod.values.firstWhere(
      (e) => e.toJson() == value,
      orElse: () => PaymentMethod.cash,
    );
  }

  /// Get localized display name
  String getDisplayName(String language) {
    switch (this) {
      case PaymentMethod.cash:
        return language == 'ar' ? 'نقداً' : 'Cash';
      case PaymentMethod.manual:
        return language == 'ar' ? 'يدوي' : 'Manual';
      case PaymentMethod.card:
        return language == 'ar' ? 'بطاقة' : 'Card';
    }
  }
}

/// Extension for PaymentStatus string conversion
extension PaymentStatusExtension on PaymentStatus {
  String toJson() {
    return toString().split('.').last;
  }

  static PaymentStatus fromJson(String value) {
    return PaymentStatus.values.firstWhere(
      (e) => e.toJson() == value,
      orElse: () => PaymentStatus.pending,
    );
  }

  /// Get localized display name
  String getDisplayName(String language) {
    switch (this) {
      case PaymentStatus.pending:
        return language == 'ar' ? 'معلق' : 'Pending';
      case PaymentStatus.processing:
        return language == 'ar' ? 'قيد المعالجة' : 'Processing';
      case PaymentStatus.completed:
        return language == 'ar' ? 'مكتمل' : 'Completed';
      case PaymentStatus.failed:
        return language == 'ar' ? 'فشل' : 'Failed';
      case PaymentStatus.refunded:
        return language == 'ar' ? 'مسترد' : 'Refunded';
      case PaymentStatus.partiallyRefunded:
        return language == 'ar' ? 'مسترد جزئياً' : 'Partially Refunded';
    }
  }
}

/// Extension for TransactionType string conversion
extension TransactionTypeExtension on TransactionType {
  String toJson() {
    return toString().split('.').last;
  }

  static TransactionType fromJson(String value) {
    return TransactionType.values.firstWhere(
      (e) => e.toJson() == value,
      orElse: () => TransactionType.capture,
    );
  }

  /// Get localized display name
  String getDisplayName(String language) {
    switch (this) {
      case TransactionType.capture:
        return language == 'ar' ? 'تحصيل' : 'Capture';
      case TransactionType.refund:
        return language == 'ar' ? 'استرداد' : 'Refund';
      case TransactionType.payout:
        return language == 'ar' ? 'دفع' : 'Payout';
    }
  }
}

/// Extension for PayoutStatus string conversion
extension PayoutStatusExtension on PayoutStatus {
  String toJson() {
    return toString().split('.').last;
  }

  static PayoutStatus fromJson(String value) {
    return PayoutStatus.values.firstWhere(
      (e) => e.toJson() == value,
      orElse: () => PayoutStatus.pending,
    );
  }

  /// Get localized display name
  String getDisplayName(String language) {
    switch (this) {
      case PayoutStatus.pending:
        return language == 'ar' ? 'معلق' : 'Pending';
      case PayoutStatus.processing:
        return language == 'ar' ? 'قيد المعالجة' : 'Processing';
      case PayoutStatus.completed:
        return language == 'ar' ? 'مكتمل' : 'Completed';
      case PayoutStatus.failed:
        return language == 'ar' ? 'فشل' : 'Failed';
    }
  }
}

/// Payment model
class Payment {
  final String id;
  final String bookingId;
  final String customerId;
  final String providerId;
  final double amount;
  final String currency;
  final double commissionRate;
  final double commissionAmount;
  final double providerAmount;
  final PaymentMethod paymentMethod;
  final PaymentStatus status;
  final String? externalPaymentId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  Payment({
    required this.id,
    required this.bookingId,
    required this.customerId,
    required this.providerId,
    required this.amount,
    required this.currency,
    required this.commissionRate,
    required this.commissionAmount,
    required this.providerAmount,
    required this.paymentMethod,
    required this.status,
    this.externalPaymentId,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      customerId: json['customer_id'] as String,
      providerId: json['provider_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      commissionRate: (json['commission_rate'] as num).toDouble(),
      commissionAmount: (json['commission_amount'] as num).toDouble(),
      providerAmount: (json['provider_amount'] as num).toDouble(),
      paymentMethod: PaymentMethodExtension.fromJson(json['payment_method'] as String),
      status: PaymentStatusExtension.fromJson(json['status'] as String),
      externalPaymentId: json['external_payment_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'customer_id': customerId,
      'provider_id': providerId,
      'amount': amount,
      'currency': currency,
      'commission_rate': commissionRate,
      'commission_amount': commissionAmount,
      'provider_amount': providerAmount,
      'payment_method': paymentMethod.toJson(),
      'status': status.toJson(),
      'external_payment_id': externalPaymentId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  /// Get formatted amount
  String get formattedAmount => '$amount $currency';

  /// Get formatted commission amount
  String get formattedCommissionAmount => '$commissionAmount $currency';

  /// Get formatted provider amount
  String get formattedProviderAmount => '$providerAmount $currency';
}

/// Transaction model
class Transaction {
  final String id;
  final String paymentId;
  final TransactionType transactionType;
  final double amount;
  final String currency;
  final String? externalTransactionId;
  final String? metadata;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.paymentId,
    required this.transactionType,
    required this.amount,
    required this.currency,
    this.externalTransactionId,
    this.metadata,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      paymentId: json['payment_id'] as String,
      transactionType: TransactionTypeExtension.fromJson(json['transaction_type'] as String),
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      externalTransactionId: json['external_transaction_id'] as String?,
      metadata: json['metadata'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'payment_id': paymentId,
      'transaction_type': transactionType.toJson(),
      'amount': amount,
      'currency': currency,
      'external_transaction_id': externalTransactionId,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Get formatted amount
  String get formattedAmount => '$amount $currency';
}

/// Payout model
class Payout {
  final String id;
  final String paymentId;
  final String providerId;
  final double amount;
  final String currency;
  final String payoutMethod;
  final PayoutStatus status;
  final String? externalPayoutId;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  Payout({
    required this.id,
    required this.paymentId,
    required this.providerId,
    required this.amount,
    required this.currency,
    required this.payoutMethod,
    required this.status,
    this.externalPayoutId,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  factory Payout.fromJson(Map<String, dynamic> json) {
    return Payout(
      id: json['id'] as String,
      paymentId: json['payment_id'] as String,
      providerId: json['provider_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      payoutMethod: json['payout_method'] as String,
      status: PayoutStatusExtension.fromJson(json['status'] as String),
      externalPayoutId: json['external_payout_id'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'payment_id': paymentId,
      'provider_id': providerId,
      'amount': amount,
      'currency': currency,
      'payout_method': payoutMethod,
      'status': status.toJson(),
      'external_payout_id': externalPayoutId,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  /// Get formatted amount
  String get formattedAmount => '$amount $currency';
}

/// Payment list response model
class PaymentListResponse {
  final List<Payment> items;
  final int total;
  final int page;
  final int pageSize;

  PaymentListResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory PaymentListResponse.fromJson(Map<String, dynamic> json) {
    return PaymentListResponse(
      items: (json['items'] as List).map((e) => Payment.fromJson(e as Map<String, dynamic>)).toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      pageSize: json['page_size'] as int,
    );
  }
}

/// Transaction list response model
class TransactionListResponse {
  final List<Transaction> items;

  TransactionListResponse({
    required this.items,
  });

  factory TransactionListResponse.fromJson(Map<String, dynamic> json) {
    return TransactionListResponse(
      items: (json['items'] as List).map((e) => Transaction.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

/// Payout list response model
class PayoutListResponse {
  final List<Payout> items;

  PayoutListResponse({
    required this.items,
  });

  factory PayoutListResponse.fromJson(Map<String, dynamic> json) {
    return PayoutListResponse(
      items: (json['items'] as List).map((e) => Payout.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
