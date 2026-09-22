// Payment list screen for KhedmaLink Flutter app
// Displays payments for the current user

import 'package:flutter/material.dart';
import 'package:khedmalink/core/models/payment_models.dart';
import 'package:khedmalink/core/services/payment_service.dart' as api;
import 'package:khedmalink/core/analytics/app_logger.dart';

/// Payment list screen
class PaymentListScreen extends StatefulWidget {
  const PaymentListScreen({super.key});

  @override
  State<PaymentListScreen> createState() => _PaymentListScreenState();
}

class _PaymentListScreenState extends State<PaymentListScreen> {
  final _paymentService = api.PaymentApiService();
  PaymentListResponse? _paymentList;
  bool _isLoading = false;
  String? _error;
  final int _pageSize = 20;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _paymentService.listPayments(
        page: _currentPage,
        pageSize: _pageSize,
      );
      setState(() {
        _paymentList = result;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.error('Error loading payments: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode == 'ar' ? 'ar' : 'fr';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          language == 'ar' ? 'المدفوعات' : 'Payments',
        ),
      ),
      body: _buildBody(context, language),
    );
  }

  Widget _buildBody(BuildContext context, String language) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              language == 'ar' ? 'خطأ في تحميل البيانات' : 'Error loading data',
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPayments,
              child: Text(
                language == 'ar' ? 'إعادة المحاولة' : 'Retry',
              ),
            ),
          ],
        ),
      );
    }

    if (_paymentList == null || _paymentList!.items.isEmpty) {
      return Center(
        child: Text(
          language == 'ar' ? 'لا توجد مدفوعات' : 'No payments found',
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _paymentList!.items.length,
            itemBuilder: (context, index) {
              final payment = _paymentList!.items[index];
              return _buildPaymentCard(context, payment, language);
            },
          ),
        ),
        if (_paymentList!.total > _pageSize) _buildPagination(language),
      ],
    );
  }

  Widget _buildPaymentCard(BuildContext context, Payment payment, String language) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(payment.formattedAmount),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(payment.paymentMethod.getDisplayName(language)),
            Text(payment.status.getDisplayName(language)),
            Text('${language == 'ar' ? 'العمولة' : 'Commission'}: ${payment.formattedCommissionAmount}'),
          ],
        ),
        trailing: Icon(
          _getStatusIcon(payment.status),
          color: _getStatusColor(payment.status),
        ),
        onTap: () {
          // TODO: Navigate to payment detail
          AppLogger.info('Payment tapped: ${payment.id}');
        },
      ),
    );
  }

  IconData _getStatusIcon(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return Icons.pending;
      case PaymentStatus.processing:
        return Icons.sync;
      case PaymentStatus.completed:
        return Icons.check_circle;
      case PaymentStatus.failed:
        return Icons.error;
      case PaymentStatus.refunded:
        return Icons.restore;
      case PaymentStatus.partiallyRefunded:
        return Icons.restore;
    }
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.processing:
        return Colors.blue;
      case PaymentStatus.completed:
        return Colors.green;
      case PaymentStatus.failed:
        return Colors.red;
      case PaymentStatus.refunded:
        return Colors.purple;
      case PaymentStatus.partiallyRefunded:
        return Colors.purple.shade300;
    }
  }

  Widget _buildPagination(String language) {
    final totalPages = (_paymentList!.total / _pageSize).ceil();
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: _currentPage > 1
                ? () {
                    setState(() {
                      _currentPage--;
                    });
                    _loadPayments();
                  }
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          Text(
            '$_currentPage / $totalPages',
            style: const TextStyle(fontSize: 16),
          ),
          IconButton(
            onPressed: _currentPage < totalPages
                ? () {
                    setState(() {
                      _currentPage++;
                    });
                    _loadPayments();
                  }
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
