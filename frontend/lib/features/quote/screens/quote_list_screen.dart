// Quote list screen for KhedmaLink Flutter app
// Displays quotes for a service request (customer view)

import 'package:flutter/material.dart';
import 'package:khedmalink/core/models/quote_models.dart';
import 'package:khedmalink/core/services/quote_service.dart' as api;
import 'package:khedmalink/core/analytics/app_logger.dart';

/// Quote list screen for customer
class QuoteListScreen extends StatefulWidget {
  final String requestId;

  const QuoteListScreen({super.key, required this.requestId});

  @override
  State<QuoteListScreen> createState() => _QuoteListScreenState();
}

class _QuoteListScreenState extends State<QuoteListScreen> {
  final api.QuoteApiService _quoteService = api.QuoteApiService();
  List<Quote> _quotes = [];
  bool _isLoading = true;
  String? _errorMessage;

  String get _language => 'ar'; // Will be from localization provider

  @override
  void initState() {
    super.initState();
    _loadQuotes();
  }

  Future<void> _loadQuotes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final quotes = await _quoteService.listRequestQuotes(widget.requestId);
      if (mounted) {
        setState(() {
          _quotes = quotes;
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('Load quotes error: $e');
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
          language == 'ar' ? 'العروض' : 'Devis',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadQuotes,
          ),
        ],
      ),
      body: _buildBody(context, _language),
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
              onPressed: _loadQuotes,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_quotes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              language == 'ar' ? 'لا توجد عروض' : 'Aucun devis',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              language == 'ar'
                  ? 'لم يتقدم أي مزود بعدُ عرضًا'
                  : 'Aucun fournisseur n\'a encore soumis de devis',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadQuotes,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _quotes.length,
        itemBuilder: (context, index) {
          final quote = _quotes[index];
          return _QuoteCard(
            quote: quote,
            language: language,
            onAccept: () => _acceptQuote(quote),
          );
        },
      ),
    );
  }

  Future<void> _acceptQuote(Quote quote) async {
    try {
      await _quoteService.acceptQuote(widget.requestId, quote.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _language == 'ar' ? 'تم قبول العرض' : 'Devis accepté',
            ),
            backgroundColor: Colors.green,
          ),
        );
        await _loadQuotes();
      }
    } catch (e) {
      AppLogger.error('Accept quote error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _language == 'ar' ? 'فشل قبول العرض: $e' : 'Échec de l\'acceptation: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _QuoteCard extends StatelessWidget {
  final Quote quote;
  final String language;
  final VoidCallback onAccept;

  const _QuoteCard({
    required this.quote,
    required this.language,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Price and status
            Row(
              children: [
                Expanded(
                  child: Text(
                    quote.formattedPrice,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                _StatusBadge(status: quote.status),
              ],
            ),
            const SizedBox(height: 8),
            // Description
            if (quote.description != null) ...[
              Text(
                quote.description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
            ],
            // Duration
            if (quote.estimatedDuration != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.access_time_outlined,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${quote.estimatedDuration} ${quote.estimatedDurationUnit ?? ''}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            // Availability
            if (quote.availableDate != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    quote.availableDate.toString().split(' ')[0],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            // Accept button
            if (quote.status == 'submitted')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onAccept,
                  child: Text(
                    language == 'ar' ? 'قبول العرض' : 'Accepter le devis',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
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
      case 'submitted':
        color = Colors.blue;
        label = 'Submitted';
        break;
      case 'withdrawn':
        color = Colors.orange;
        label = 'Withdrawn';
        break;
      case 'accepted':
        color = Colors.green;
        label = 'Accepted';
        break;
      case 'rejected':
        color = Colors.red;
        label = 'Rejected';
        break;
      case 'expired':
        color = Colors.purple;
        label = 'Expired';
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
