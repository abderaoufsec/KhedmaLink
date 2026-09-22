// Admin verification screen for KhedmaLink Flutter app
// Displays and manages provider verification queue

import 'package:flutter/material.dart';
import 'package:khedmalink/core/models/admin_models.dart';
import 'package:khedmalink/core/services/admin_service.dart' as api;
import 'package:khedmalink/core/analytics/app_logger.dart';

/// Admin verification screen
class AdminVerificationScreen extends StatefulWidget {
  const AdminVerificationScreen({super.key});

  @override
  State<AdminVerificationScreen> createState() => _AdminVerificationScreenState();
}

class _AdminVerificationScreenState extends State<AdminVerificationScreen> {
  final _adminService = api.AdminApiService();
  VerificationQueueResponse? _queue;
  bool _isLoading = false;
  String? _error;
  final int _pageSize = 20;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadQueue();
  }

  Future<void> _loadQueue() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _adminService.listVerificationQueue(
        page: _currentPage,
        pageSize: _pageSize,
      );
      setState(() {
        _queue = result;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.error('Error loading verification queue: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _performAction(String providerId, String action) async {
    try {
      await _adminService.performVerificationAction(
        providerId: providerId,
        action: action,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Action performed successfully')),
      );
      _loadQueue();
    } catch (e) {
      AppLogger.error('Error performing action: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode == 'ar' ? 'ar' : 'fr';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          language == 'ar' ? 'قائمة التحقق' : 'Verification Queue',
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
              onPressed: _loadQueue,
              child: Text(
                language == 'ar' ? 'إعادة المحاولة' : 'Retry',
              ),
            ),
          ],
        ),
      );
    }

    if (_queue == null || _queue!.items.isEmpty) {
      return Center(
        child: Text(
          language == 'ar' ? 'لا توجد طلبات تحقق معلقة' : 'No pending verification requests',
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _queue!.items.length,
            itemBuilder: (context, index) {
              final item = _queue!.items[index];
              return _buildVerificationCard(context, item, language);
            },
          ),
        ),
        if (_queue!.total > _pageSize) _buildPagination(language),
      ],
    );
  }

  Widget _buildVerificationCard(
    BuildContext context,
    ProviderVerificationQueueItem item,
    String language,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(item.businessName ?? (language == 'ar' ? 'مقدم خدمة' : 'Provider')),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.getVerificationStatusDisplay(language)),
            if (item.submittedAt != null)
              Text(
                'Submitted: ${item.submittedAt!.toLocal().toString().split('.')[0]}',
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: () => _performAction(item.providerId, 'approve'),
              tooltip: language == 'ar' ? 'موافقة' : 'Approve',
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => _performAction(item.providerId, 'reject'),
              tooltip: language == 'ar' ? 'رفض' : 'Reject',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination(String language) {
    final totalPages = (_queue!.total / _pageSize).ceil();
    
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
                    _loadQueue();
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
                    _loadQueue();
                  }
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
