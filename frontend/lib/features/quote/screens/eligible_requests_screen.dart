// Eligible requests screen for KhedmaLink Flutter app
// Displays service requests that providers can quote on

import 'package:flutter/material.dart';
import 'package:khedmalink/core/models/quote_models.dart';
import 'package:khedmalink/core/services/quote_service.dart' as api;
import 'package:khedmalink/core/analytics/app_logger.dart';
import 'package:go_router/go_router.dart';

/// Eligible requests screen for provider
class EligibleRequestsScreen extends StatefulWidget {
  const EligibleRequestsScreen({super.key});

  @override
  State<EligibleRequestsScreen> createState() => _EligibleRequestsScreenState();
}

class _EligibleRequestsScreenState extends State<EligibleRequestsScreen> {
  final api.QuoteApiService _quoteService = api.QuoteApiService();
  List<RequestMatch> _matches = [];
  bool _isLoading = true;
  String? _errorMessage;

  String get language => 'ar'; // Will be from localization provider

  @override
  void initState() {
    super.initState();
    _loadEligibleRequests();
  }

  Future<void> _loadEligibleRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final matches = await _quoteService.listEligibleRequests();
      if (mounted) {
        setState(() {
          _matches = matches;
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('Load eligible requests error: $e');
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
          language == 'ar' ? 'الطلبات المتاحة' : 'Demandes disponibles',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEligibleRequests,
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
              onPressed: _loadEligibleRequests,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              language == 'ar' ? 'لا توجد طلبات متاحة' : 'Aucune demande disponible',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              language == 'ar'
                  ? 'تحقق لاحقًا للحصول على طلبات جديدة'
                  : 'Vérifiez plus tard pour de nouvelles demandes',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEligibleRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _matches.length,
        itemBuilder: (context, index) {
          final match = _matches[index];
          return _MatchCard(
            match: match,
            language: language,
            onCreateQuote: () => _createQuote(match.requestId),
          );
        },
      ),
    );
  }

  void _createQuote(String requestId) {
    context.pushNamed('quote_creation', pathParameters: {'requestId': requestId});
  }
}

class _MatchCard extends StatelessWidget {
  final RequestMatch match;
  final String language;
  final VoidCallback onCreateQuote;

  const _MatchCard({
    required this.match,
    required this.language,
    required this.onCreateQuote,
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
            // Request ID and status
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Request ID: ${match.requestId}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
                _MatchStatusBadge(status: match.status),
              ],
            ),
            const SizedBox(height: 8),
            // Match score
            if (match.matchScore != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.star_outline,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Match Score: ${(match.matchScore! * 100).toStringAsFixed(0)}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            // Eligibility reason
            if (match.eligibilityReason != null) ...[
              Text(
                match.eligibilityReason!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
            ],
            // Create quote button
            if (match.status == 'eligible')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onCreateQuote,
                  child: Text(
                    language == 'ar' ? 'إنشاء عرض' : 'Créer un devis',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MatchStatusBadge extends StatelessWidget {
  final String status;

  const _MatchStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case 'eligible':
        color = Colors.green;
        label = 'Eligible';
        break;
      case 'declined':
        color = Colors.orange;
        label = 'Declined';
        break;
      case 'quoted':
        color = Colors.blue;
        label = 'Quoted';
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
