// Provider detail screen for KhedmaLink Flutter app
// Displays detailed information about a provider

import 'package:flutter/material.dart';
import 'package:khedmalink/core/models/provider_models.dart';
import 'package:khedmalink/core/services/provider_service.dart' as api;
import 'package:khedmalink/core/analytics/app_logger.dart';

/// Provider detail screen
class ProviderDetailScreen extends StatefulWidget {
  final String providerId;

  const ProviderDetailScreen({super.key, required this.providerId});

  @override
  State<ProviderDetailScreen> createState() => _ProviderDetailScreenState();
}

class _ProviderDetailScreenState extends State<ProviderDetailScreen> {
  final api.ProviderApiService _providerService = api.ProviderApiService();
  ProviderProfile? _provider;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProvider();
  }

  Future<void> _loadProvider() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final provider = await _providerService.getProviderProfile(widget.providerId);
      if (mounted) {
        setState(() {
          _provider = provider;
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('Load provider error: $e');
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
          language == 'ar' ? 'تفاصيل مقدم الخدمة' : 'Détails du fournisseur',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
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
              onPressed: _loadProvider,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_provider == null) {
      return const Center(
        child: Text('Provider not found'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Business name and verification
          Row(
            children: [
              Expanded(
                child: Text(
                  _provider!.businessName ?? 'Unknown',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              if (_provider!.verificationStatus == 'verified')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Verified',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Description
          if (_provider!.descriptionAr != null || _provider!.descriptionFr != null) ...[
            Text(
              language == 'ar' ? 'الوصف' : 'Description',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              language == 'ar'
                  ? (_provider!.descriptionAr ?? '')
                  : (_provider!.descriptionFr ?? ''),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
          ],
          // Location
          _buildSection(
            context,
            language == 'ar' ? 'الموقع' : 'Emplacement',
            Icons.location_on_outlined,
            Text(
              '${_provider!.wilaya} - ${_provider!.city}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 16),
          // Rating
          _buildSection(
            context,
            language == 'ar' ? 'التقييم' : 'Note',
            Icons.star,
            Row(
              children: [
                const Icon(Icons.star, size: 20, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  _provider!.averageRating.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (_provider!.totalReviews > 0) ...[
                  const SizedBox(width: 8),
                  Text(
                    '(${_provider!.totalReviews} reviews)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ],
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
}
