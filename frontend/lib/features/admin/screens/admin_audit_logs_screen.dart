// Admin audit logs screen for KhedmaLink Flutter app
// Displays audit log history for admins

import 'package:flutter/material.dart';
import 'package:khedmalink/core/models/admin_models.dart';
import 'package:khedmalink/core/services/admin_service.dart' as api;
import 'package:khedmalink/core/analytics/app_logger.dart';

/// Admin audit logs screen
class AdminAuditLogsScreen extends StatefulWidget {
  const AdminAuditLogsScreen({super.key});

  @override
  State<AdminAuditLogsScreen> createState() => _AdminAuditLogsScreenState();
}

class _AdminAuditLogsScreenState extends State<AdminAuditLogsScreen> {
  final _adminService = api.AdminApiService();
  AuditLogListResponse? _auditLogs;
  bool _isLoading = false;
  String? _error;
  final int _pageSize = 20;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadAuditLogs();
  }

  Future<void> _loadAuditLogs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _adminService.listAuditLogs(
        page: _currentPage,
        pageSize: _pageSize,
      );
      setState(() {
        _auditLogs = result;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.error('Error loading audit logs: $e');
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
          language == 'ar' ? 'سجلات التدقيق' : 'Audit Logs',
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
              onPressed: _loadAuditLogs,
              child: Text(
                language == 'ar' ? 'إعادة المحاولة' : 'Retry',
              ),
            ),
          ],
        ),
      );
    }

    if (_auditLogs == null || _auditLogs!.items.isEmpty) {
      return Center(
        child: Text(
          language == 'ar' ? 'لا توجد سجلات تدقيق' : 'No audit logs found',
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _auditLogs!.items.length,
            itemBuilder: (context, index) {
              final log = _auditLogs!.items[index];
              return _buildAuditLogCard(context, log, language);
            },
          ),
        ),
        if (_auditLogs!.total > _pageSize) _buildPagination(language),
      ],
    );
  }

  Widget _buildAuditLogCard(BuildContext context, AuditLog log, String language) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(log.actionType.getDisplayName(language)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(log.description),
            const SizedBox(height: 4),
            Text(
              log.createdAt.toLocal().toString().split('.')[0],
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        onTap: () {
          // TODO: Show detailed audit log
          AppLogger.info('Audit log tapped: ${log.id}');
        },
      ),
    );
  }

  Widget _buildPagination(String language) {
    final totalPages = (_auditLogs!.total / _pageSize).ceil();
    
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
                    _loadAuditLogs();
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
                    _loadAuditLogs();
                  }
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
