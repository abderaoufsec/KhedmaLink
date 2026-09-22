// Dispute list screen for KhedmaLink Flutter app
// Displays disputes for the current user

import 'package:flutter/material.dart';
import 'package:khedmalink/core/models/dispute_models.dart';
import 'package:khedmalink/core/services/dispute_service.dart' as api;
import 'package:khedmalink/core/analytics/app_logger.dart';

/// Dispute list screen
class DisputeListScreen extends StatefulWidget {
  const DisputeListScreen({super.key});

  @override
  State<DisputeListScreen> createState() => _DisputeListScreenState();
}

class _DisputeListScreenState extends State<DisputeListScreen> {
  final _disputeService = api.DisputeApiService();
  DisputeListResponse? _disputeList;
  bool _isLoading = false;
  String? _error;
  final int _pageSize = 20;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadDisputes();
  }

  Future<void> _loadDisputes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _disputeService.listDisputes(
        page: _currentPage,
        pageSize: _pageSize,
      );
      setState(() {
        _disputeList = result;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.error('Error loading disputes: $e');
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
          language == 'ar' ? 'النزاعات' : 'Disputes',
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
              onPressed: _loadDisputes,
              child: Text(
                language == 'ar' ? 'إعادة المحاولة' : 'Retry',
              ),
            ),
          ],
        ),
      );
    }

    if (_disputeList == null || _disputeList!.items.isEmpty) {
      return Center(
        child: Text(
          language == 'ar' ? 'لا توجد نزاعات' : 'No disputes found',
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _disputeList!.items.length,
            itemBuilder: (context, index) {
              final dispute = _disputeList!.items[index];
              return _buildDisputeCard(context, dispute, language);
            },
          ),
        ),
        if (_disputeList!.total > _pageSize) _buildPagination(language),
      ],
    );
  }

  Widget _buildDisputeCard(BuildContext context, Dispute dispute, String language) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(dispute.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dispute.disputeType.getDisplayName(language)),
            Text(dispute.status.getDisplayName(language)),
          ],
        ),
        trailing: Icon(
          _getStatusIcon(dispute.status),
          color: _getStatusColor(dispute.status),
        ),
        onTap: () {
          // TODO: Navigate to dispute detail
          AppLogger.info('Dispute tapped: ${dispute.id}');
        },
      ),
    );
  }

  IconData _getStatusIcon(DisputeStatus status) {
    switch (status) {
      case DisputeStatus.open:
        return Icons.open_in_new;
      case DisputeStatus.investigating:
        return Icons.search;
      case DisputeStatus.resolved:
        return Icons.check_circle;
      case DisputeStatus.closed:
        return Icons.close;
    }
  }

  Color _getStatusColor(DisputeStatus status) {
    switch (status) {
      case DisputeStatus.open:
        return Colors.orange;
      case DisputeStatus.investigating:
        return Colors.blue;
      case DisputeStatus.resolved:
        return Colors.green;
      case DisputeStatus.closed:
        return Colors.grey;
    }
  }

  Widget _buildPagination(String language) {
    final totalPages = (_disputeList!.total / _pageSize).ceil();
    
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
                    _loadDisputes();
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
                    _loadDisputes();
                  }
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
