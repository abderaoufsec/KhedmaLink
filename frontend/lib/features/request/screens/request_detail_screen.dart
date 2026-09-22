// Simple request detail screen for KhedmaLink Flutter app
// Displays details of a service request

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:khedmalink/core/models/request_models.dart';
import 'package:khedmalink/core/services/request_service.dart' as api;
import 'package:khedmalink/core/analytics/app_logger.dart';

/// Simple request detail screen
class RequestDetailScreen extends StatefulWidget {
  final String requestId;

  const RequestDetailScreen({super.key, required this.requestId});

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  final api.RequestApiService _requestService = api.RequestApiService();
  ServiceRequest? _request;
  List<RequestAttachment> _attachments = [];
  bool _isLoading = true;
  String? _errorMessage;

  String get language => 'ar'; // Will be from localization provider

  @override
  void initState() {
    super.initState();
    _loadRequest();
  }

  Future<void> _loadRequest() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final request = await _requestService.getMyRequest(widget.requestId);
      final attachments = await _requestService.listRequestAttachments(widget.requestId);
      
      if (mounted) {
        setState(() {
          _request = request;
          _attachments = attachments;
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('Load request error: $e');
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          language == 'ar' ? 'تفاصيل الطلب' : 'Détails de la demande',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          if (_request?.status == 'open')
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // TODO: Implement edit functionality
              },
            ),
        ],
      ),
      body: _buildBody(context, language),
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
              onPressed: _loadRequest,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_request == null) {
      return const Center(
        child: Text('Request not found'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status and urgency
          Row(
            children: [
              _StatusBadge(status: _request!.status),
              const SizedBox(width: 8),
              _UrgencyBadge(urgency: _request!.urgency),
            ],
          ),
          const SizedBox(height: 16),
          // Title
          Text(
            _request!.getLocalizedName(language),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          // Description
          Text(
            language == 'ar' ? 'الوصف' : 'Description',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _request!.getLocalizedDescription(language),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          // Location
          _buildSection(
            context,
            language == 'ar' ? 'الموقع' : 'Emplacement',
            Icons.location_on_outlined,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_request!.wilaya} - ${_request!.city}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (_request!.commune != null)
                  Text(
                    _request!.commune!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                if (_request!.address != null)
                  Text(
                    _request!.address!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Preferred date
          if (_request!.preferredDate != null)
            _buildSection(
              context,
              language == 'ar' ? 'التاريخ المفضل' : 'Date préférée',
              Icons.calendar_today_outlined,
              Text(
                _request!.preferredDate.toString().split(' ')[0],
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          if (_request!.preferredDate != null) const SizedBox(height: 16),
          // Time range
          if (_request!.preferredTimeStart != null || _request!.preferredTimeEnd != null)
            _buildSection(
              context,
              language == 'ar' ? 'الوقت المفضل' : 'Heure préférée',
              Icons.access_time_outlined,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_request!.preferredTimeStart != null)
                    Text(
                      'Start: ${_request!.preferredTimeStart}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  if (_request!.preferredTimeEnd != null)
                    Text(
                      'End: ${_request!.preferredTimeEnd}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  if (_request!.isFlexible)
                    Text(
                      language == 'ar' ? 'مرن' : 'Flexible',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                ],
              ),
            ),
          if (_request!.preferredTimeStart != null || _request!.preferredTimeEnd != null)
            const SizedBox(height: 16),
          // Budget
          if (_request!.budgetMin != null || _request!.budgetMax != null)
            _buildSection(
              context,
              language == 'ar' ? 'الميزانية' : 'Budget',
              Icons.payments_outlined,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_request!.budgetMin != null)
                    Text(
                      'Min: ${_request!.budgetMin} ${_request!.currency}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  if (_request!.budgetMax != null)
                    Text(
                      'Max: ${_request!.budgetMax} ${_request!.currency}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                ],
              ),
            ),
          if (_request!.budgetMin != null || _request!.budgetMax != null)
            const SizedBox(height: 16),
          // Attachments
          if (_attachments.isNotEmpty) ...[
            Text(
              language == 'ar' ? 'المرفقات' : 'Pièces jointes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _attachments.length,
                itemBuilder: (context, index) {
                  final attachment = _attachments[index];
                  return _AttachmentCard(
                    attachment: attachment,
                    onDelete: () => _deleteAttachment(attachment.id),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Created date
          Text(
            language == 'ar' ? 'تاريخ الإنشاء' : 'Date de création',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _request!.createdAt,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 24),
          // View quotes button
          if (_request!.status == 'open' || _request!.status == 'draft')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.pushNamed('quote_list', pathParameters: {'requestId': widget.requestId});
                },
                child: Text(
                  language == 'ar' ? 'عرض العروض' : 'Voir les devis',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    Widget child,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 28),
          child: child,
        ),
      ],
    );
  }

  Future<void> _deleteAttachment(String attachmentId) async {
    try {
      await _requestService.deleteRequestAttachment(
        widget.requestId,
        attachmentId,
      );
      await _loadRequest();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              language == 'ar' ? 'تم حذف المرفق بنجاح' : 'Attachment deleted successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Delete attachment error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete attachment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _UrgencyBadge extends StatelessWidget {
  final String urgency;

  const _UrgencyBadge({required this.urgency});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (urgency) {
      case 'low':
        color = Colors.green;
        label = 'Low';
        break;
      case 'medium':
        color = Colors.orange;
        label = 'Medium';
        break;
      case 'high':
        color = Colors.red;
        label = 'High';
        break;
      case 'urgent':
        color = Colors.purple;
        label = 'Urgent';
        break;
      default:
        color = Colors.grey;
        label = urgency;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _AttachmentCard extends StatelessWidget {
  final RequestAttachment attachment;
  final VoidCallback onDelete;

  const _AttachmentCard({
    required this.attachment,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(right: 12),
      child: SizedBox(
        width: 100,
        child: Stack(
          children: [
            Center(
              child: Icon(
                attachment.isPhoto ? Icons.image : Icons.insert_drive_file,
                size: 48,
                color: Colors.grey[400],
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                icon: const Icon(Icons.delete, size: 20),
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
