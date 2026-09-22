// Booking detail screen for KhedmaLink Flutter app
// Displays details of a booking and allows actions

import 'package:flutter/material.dart';
import 'package:khedmalink/core/models/booking_models.dart';
import 'package:khedmalink/core/services/booking_service.dart' as api;
import 'package:khedmalink/core/analytics/app_logger.dart';
import 'package:go_router/go_router.dart';

/// Booking detail screen
class BookingDetailScreen extends StatefulWidget {
  final String bookingId;

  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  final api.BookingApiService _bookingService = api.BookingApiService();
  Booking? _booking;
  List<BookingEvent> _events = [];
  bool _isLoading = true;
  String? _errorMessage;

  String get language => 'ar'; // Will be from localization provider

  @override
  void initState() {
    super.initState();
    _loadBooking();
  }

  Future<void> _loadBooking() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final booking = await _bookingService.getMyBooking(widget.bookingId);
      final events = await _bookingService.listBookingEvents(widget.bookingId);
      
      if (mounted) {
        setState(() {
          _booking = booking;
          _events = events;
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('Load booking error: $e');
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
          language == 'ar' ? 'تفاصيل الحجز' : 'Détails de la réservation',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBooking,
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () {
              context.push('/bookings/${widget.bookingId}/messages');
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
              onPressed: _loadBooking,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_booking == null) {
      return const Center(
        child: Text('Booking not found'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status and price
          Row(
            children: [
              Expanded(
                child: Text(
                  _booking!.formattedPrice,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
              _BookingStatusBadge(status: _booking!.status),
            ],
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
                if (_booking!.city != null)
                  Text(
                    '${_booking!.city} - ${_booking!.wilaya ?? ''}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                if (_booking!.address != null)
                  Text(
                    _booking!.address!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Scheduled date
          if (_booking!.scheduledDate != null)
            _buildSection(
              context,
              language == 'ar' ? 'التاريخ المجدول' : 'Date programmée',
              Icons.calendar_today_outlined,
              Text(
                _booking!.scheduledDate.toString().split(' ')[0],
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          // Estimated duration
          if (_booking!.estimatedDuration != null) ...[
            const SizedBox(height: 16),
            _buildSection(
              context,
              language == 'ar' ? 'المدة المقدرة' : 'Durée estimée',
              Icons.access_time_outlined,
              Text(
                '${_booking!.estimatedDuration} ${_booking!.estimatedDurationUnit ?? ''}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
          // Completion notes
          if (_booking!.completionNotes != null) ...[
            const SizedBox(height: 16),
            _buildSection(
              context,
              language == 'ar' ? 'ملاحظات الإنجاز' : 'Notes d\'achèvement',
              Icons.note_outlined,
              Text(
                _booking!.completionNotes!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
          // Cancellation reason
          if (_booking!.cancellationReason != null) ...[
            const SizedBox(height: 16),
            _buildSection(
              context,
              language == 'ar' ? 'سبب الإلغاء' : 'Raison d\'annulation',
              Icons.cancel_outlined,
              Text(
                _booking!.cancellationReason!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
          // Created date
          const SizedBox(height: 16),
          Text(
            language == 'ar' ? 'تاريخ الإنشاء' : 'Date de création',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _booking!.createdAt,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 24),
          // Action buttons
          if (_booking!.canBeStarted)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _startBooking(),
                child: Text(
                  language == 'ar' ? 'بدء العمل' : 'Commencer le travail',
                ),
              ),
            ),
          if (_booking!.canBeCompleted)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _completeBooking(),
                child: Text(
                  language == 'ar' ? 'إنهاء العمل' : 'Terminer le travail',
                ),
              ),
            ),
          if (_booking!.isCompleted)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.push('/bookings/${widget.bookingId}/review');
                },
                child: Text(
                  language == 'ar' ? 'تقييم الحجز' : 'Review Booking',
                ),
              ),
            ),
          if (_booking!.canBeCancelled)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _showCancelDialog(context),
                child: Text(
                  language == 'ar' ? 'إلغاء الحجز' : 'Annuler',
                ),
              ),
            ),
          if (_booking!.isDisputed || _booking!.isCompleted)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  context.push('/bookings/${widget.bookingId}/dispute');
                },
                child: Text(
                  language == 'ar' ? 'رفع نزاع' : 'Raise Dispute',
                ),
              ),
            ),
          const SizedBox(height: 24),
          // Events timeline
          Text(
            language == 'ar' ? 'سجل الأحداث' : 'Historique des événements',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          if (_events.isEmpty)
            Text(
              language == 'ar' ? 'لا توجد أحداث' : 'Aucun événement',
              style: TextStyle(color: Colors.grey[600]),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _events.length,
              itemBuilder: (context, index) {
                final event = _events[index];
                return _EventTile(event: event);
              },
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

  Future<void> _startBooking() async {
    try {
      await _bookingService.startBooking(widget.bookingId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              language == 'ar' ? 'تم بدء العمل' : 'Travail commencé',
            ),
            backgroundColor: Colors.green,
          ),
        );
        await _loadBooking();
      }
    } catch (e) {
      AppLogger.error('Start booking error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              language == 'ar' ? 'فشل بدء العمل: $e' : 'Échec: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _completeBooking() async {
    try {
      await _bookingService.completeBooking(widget.bookingId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              language == 'ar' ? 'تم إنهاء العمل' : 'Travail terminé',
            ),
            backgroundColor: Colors.green,
          ),
        );
        await _loadBooking();
      }
    } catch (e) {
      AppLogger.error('Complete booking error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              language == 'ar' ? 'فشل إنهاء العمل: $e' : 'Échec: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCancelDialog(BuildContext context) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(language == 'ar' ? 'إلغاء الحجز' : 'Annuler la réservation'),
        content: TextField(
          controller: reasonController,
          decoration: InputDecoration(
            labelText: language == 'ar' ? 'سبب الإلغاء' : 'Raison de l\'annulation',
            border: const OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(language == 'ar' ? 'إلغاء' : 'Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              if (reasonController.text.isNotEmpty) {
                await _bookingService.cancelBooking(
                  widget.bookingId,
                  reasonController.text,
                );
                await _loadBooking();
              }
            },
            child: Text(language == 'ar' ? 'تأكيد' : 'Confirmer'),
          ),
        ],
      ),
    );
  }
}

class _BookingStatusBadge extends StatelessWidget {
  final String status;

  const _BookingStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case 'accepted':
        color = Colors.blue;
        label = 'Accepted';
        break;
      case 'scheduled':
        color = Colors.purple;
        label = 'Scheduled';
        break;
      case 'in_progress':
        color = Colors.orange;
        label = 'In Progress';
        break;
      case 'completed':
        color = Colors.green;
        label = 'Completed';
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'Cancelled';
        break;
      case 'disputed':
        color = Colors.red.shade700;
        label = 'Disputed';
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

class _EventTile extends StatelessWidget {
  final BookingEvent event;

  const _EventTile({required this.event});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        _getEventIcon(event.eventType),
        color: _getEventColor(event.eventType),
      ),
      title: Text(_getEventLabel(event.eventType)),
      subtitle: Text(event.createdAt.toString().split('.')[0]),
      trailing: event.oldStatus != null
          ? Text(
              '${event.oldStatus} → ${event.newStatus}',
              style: const TextStyle(fontSize: 12),
            )
          : null,
    );
  }

  IconData _getEventIcon(String eventType) {
    switch (eventType) {
      case 'created':
        return Icons.add_circle_outline;
      case 'scheduled':
        return Icons.calendar_today;
      case 'started':
        return Icons.play_circle_outline;
      case 'completed':
        return Icons.check_circle_outline;
      case 'cancelled':
        return Icons.cancel;
      case 'disputed':
        return Icons.warning;
      default:
        return Icons.info_outline;
    }
  }

  Color _getEventColor(String eventType) {
    switch (eventType) {
      case 'created':
        return Colors.blue;
      case 'scheduled':
        return Colors.purple;
      case 'started':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'disputed':
        return Colors.red.shade700;
      default:
        return Colors.grey;
    }
  }

  String _getEventLabel(String eventType) {
    switch (eventType) {
      case 'created':
        return 'Created';
      case 'scheduled':
        return 'Scheduled';
      case 'started':
        return 'Started';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'disputed':
        return 'Disputed';
      default:
        return eventType;
    }
  }
}
