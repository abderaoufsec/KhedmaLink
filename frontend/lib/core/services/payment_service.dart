// Payment service for KhedmaLink Flutter app
// Handles API communication for payment operations

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:khedmalink/core/config/app_config.dart';
import 'package:khedmalink/core/models/payment_models.dart';
import 'package:khedmalink/core/analytics/app_logger.dart';

/// Payment API service for payment operations
class PaymentApiService {
  final String _baseUrl;
  final String _apiVersion;
  String? _authToken;

  PaymentApiService()
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

  /// Create a payment for a booking
  Future<Payment> createPayment({
    required String bookingId,
    required PaymentMethod paymentMethod,
    String? externalPaymentId,
  }) async {
    try {
      AppLogger.info('Creating payment for booking: $bookingId');
      
      final uri = Uri.parse('$_baseUrl/$_apiVersion/payments');
      final body = json.encode({
        'booking_id': bookingId,
        'payment_method': paymentMethod.toJson(),
        if (externalPaymentId != null) 'external_payment_id': externalPaymentId,
      });

      final response = await http.post(uri, headers: _getHeaders(), body: body);

      if (response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        AppLogger.info('Payment created successfully');
        return Payment.fromJson(data);
      } else {
        AppLogger.error('Failed to create payment: ${response.statusCode}');
        throw Exception('Failed to create payment: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Error creating payment: $e');
      rethrow;
    }
  }

  /// List payments for current user
  Future<PaymentListResponse> listPayments({
    int page = 1,
    int pageSize = 20,
    String? statusFilter,
  }) async {
    try {
      AppLogger.info('Listing payments: status=$statusFilter');
      
      final queryParams = <String, String>{
        'page': page.toString(),
        'page_size': pageSize.toString(),
      };
      if (statusFilter != null) queryParams['status_filter'] = statusFilter;

      final uri = Uri.parse('$_baseUrl/$_apiVersion/payments')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _getHeaders());

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        AppLogger.info('Payments listed successfully: ${data['total']} total');
        return PaymentListResponse.fromJson(data);
      } else {
        AppLogger.error('Failed to list payments: ${response.statusCode}');
        throw Exception('Failed to list payments: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Error listing payments: $e');
      rethrow;
    }
  }

  /// Get a specific payment
  Future<Payment> getPayment(String paymentId) async {
    try {
      AppLogger.info('Getting payment: $paymentId');
      
      final uri = Uri.parse('$_baseUrl/$_apiVersion/payments/$paymentId');

      final response = await http.get(uri, headers: _getHeaders());

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        AppLogger.info('Payment retrieved successfully');
        return Payment.fromJson(data);
      } else {
        AppLogger.error('Failed to get payment: ${response.statusCode}');
        throw Exception('Failed to get payment: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Error getting payment: $e');
      rethrow;
    }
  }

  /// List transactions for a payment
  Future<TransactionListResponse> listTransactions(String paymentId) async {
    try {
      AppLogger.info('Listing transactions for payment: $paymentId');
      
      final uri = Uri.parse('$_baseUrl/$_apiVersion/payments/$paymentId/transactions');

      final response = await http.get(uri, headers: _getHeaders());

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        AppLogger.info('Transactions listed successfully');
        return TransactionListResponse.fromJson(data);
      } else {
        AppLogger.error('Failed to list transactions: ${response.statusCode}');
        throw Exception('Failed to list transactions: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Error listing transactions: $e');
      rethrow;
    }
  }

  /// List payouts for a payment
  Future<PayoutListResponse> listPayouts(String paymentId) async {
    try {
      AppLogger.info('Listing payouts for payment: $paymentId');
      
      final uri = Uri.parse('$_baseUrl/$_apiVersion/payments/$paymentId/payouts');

      final response = await http.get(uri, headers: _getHeaders());

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        AppLogger.info('Payouts listed successfully');
        return PayoutListResponse.fromJson(data);
      } else {
        AppLogger.error('Failed to list payouts: ${response.statusCode}');
        throw Exception('Failed to list payouts: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Error listing payouts: $e');
      rethrow;
    }
  }
}
