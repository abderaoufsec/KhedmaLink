// Provider profile management screen for KhedmaLink Flutter app
// Allows providers to manage their profile, services, service areas, and availability

import 'package:flutter/material.dart';
import 'package:khedmalink/core/models/provider_models.dart';
import 'package:khedmalink/core/services/provider_service.dart' as api;
import 'package:khedmalink/core/analytics/app_logger.dart';

/// Provider profile management screen
class ProviderProfileManagementScreen extends StatefulWidget {
  const ProviderProfileManagementScreen({super.key});

  @override
  State<ProviderProfileManagementScreen> createState() =>
      _ProviderProfileManagementScreenState();
}

class _ProviderProfileManagementScreenState
    extends State<ProviderProfileManagementScreen> {
  final api.ProviderApiService _providerService = api.ProviderApiService();
  ProviderProfile? _profile;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profile = await _providerService.getMyProviderProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('Load profile error: $e');
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
          language == 'ar' ? 'إدارة الملف الشخصي' : 'Gestion du profil',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProfile,
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
              onPressed: _loadProfile,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_profile == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              language == 'ar' ? 'لا يوجد ملف شخصي' : 'Aucun profil',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: Create profile
              },
              child: Text(
                language == 'ar' ? 'إنشاء ملف شخصي' : 'Créer un profil',
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Business name
          Text(
            _profile!.businessName ?? 'Unknown',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          // Verification status
          _StatusBadge(status: _profile!.verificationStatus),
          const SizedBox(height: 16),
          // Description
          if (_profile!.descriptionAr != null || _profile!.descriptionFr != null) ...[
            Text(
              language == 'ar' ? 'الوصف' : 'Description',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              language == 'ar'
                  ? (_profile!.descriptionAr ?? '')
                  : (_profile!.descriptionFr ?? ''),
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
              '${_profile!.wilaya} - ${_profile!.city}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 16),
          // Contact
          _buildSection(
            context,
            language == 'ar' ? 'اتصال' : 'Contact',
            Icons.phone,
            Text(
              _profile!.phoneNumber ?? 'N/A',
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
                  _profile!.averageRating.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (_profile!.totalReviews > 0) ...[
                  const SizedBox(width: 8),
                  Text(
                    '(${_profile!.totalReviews} reviews)',
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

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case 'verified':
        color = Colors.green;
        label = 'Verified';
        break;
      case 'pending':
        color = Colors.orange;
        label = 'Pending';
        break;
      case 'rejected':
        color = Colors.red;
        label = 'Rejected';
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
