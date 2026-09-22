// Simple request list screen for KhedmaLink Flutter app
// Displays customer's service requests

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:khedmalink/core/models/request_models.dart';
import 'package:khedmalink/core/services/request_service.dart' as api;
import 'package:khedmalink/core/analytics/app_logger.dart';

/// Simple request list screen
class RequestListScreen extends StatefulWidget {
  const RequestListScreen({super.key});

  @override
  State<RequestListScreen> createState() => _RequestListScreenState();
}

class _RequestListScreenState extends State<RequestListScreen> {
  final api.RequestApiService _requestService = api.RequestApiService();
  List<ServiceRequest> _requests = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final requests = await _requestService.listMyRequests();
      if (mounted) {
        setState(() {
          _requests = requests;
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('Load requests error: $e');
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = 'ar'; // Will be from localization provider

    return Scaffold(
      appBar: AppBar(
        title: Text(
          language == 'ar' ? 'طلباتي' : 'Mes demandes',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRequests,
          ),
        ],
      ),
      body: _buildBody(context, language),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/requests/create');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(BuildContext context, String language) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error: $_errorMessage',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRequests,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              language == 'ar' ? 'لا توجد طلبات' : 'Aucune demande',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              language == 'ar'
                  ? 'ابدأ بإنشاء طلب خدمة جديد'
                  : 'Commencez par créer une nouvelle demande de service',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          final request = _requests[index];
          return _RequestCard(
            request: request,
            language: language,
            onTap: () {
              context.go('/requests/${request.id}');
            },
          );
        },
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final ServiceRequest request;
  final String language;
  final VoidCallback onTap;

  const _RequestCard({
    required this.request,
    required this.language,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      request.getLocalizedName(language),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _StatusBadge(status: request.status),
                ],
              ),
              const SizedBox(height: 8),
              // Description
              Text(
                request.getLocalizedDescription(language),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Location
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${request.wilaya} - ${request.city}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Urgency and date
              Row(
                children: [
                  Icon(
                    Icons.flag_outlined,
                    size: 16,
                    color: _getUrgencyColor(request.urgency),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getUrgencyLabel(request.urgency, language),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getUrgencyColor(request.urgency),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (request.preferredDate != null)
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  if (request.preferredDate != null)
                    const SizedBox(width: 4),
                  if (request.preferredDate != null)
                    Text(
                      request.preferredDate.toString().split(' ')[0],
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      case 'urgent':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getUrgencyLabel(String urgency, String language) {
    switch (urgency) {
      case 'low':
        return language == 'ar' ? 'منخفض' : 'Faible';
      case 'medium':
        return language == 'ar' ? 'متوسط' : 'Moyen';
      case 'high':
        return language == 'ar' ? 'عالي' : 'Élevé';
      case 'urgent':
        return language == 'ar' ? 'عاجل' : 'Urgent';
      default:
        return urgency;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color color;
    String label;

    switch (status) {
      case 'draft':
        color = Colors.grey;
        label = 'Draft';
        break;
      case 'open':
        color = Colors.green;
        label = 'Open';
        break;
      case 'closed':
        color = Colors.blue;
        label = 'Closed';
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'Cancelled';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
