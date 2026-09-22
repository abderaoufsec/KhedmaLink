// Provider detail screen for KhedmaLink Flutter app
// Displays detailed information about a specific provider

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khedmalink/core/models/provider_models.dart';
import 'package:khedmalink/core/services/provider_service.dart' as api;
import 'package:khedmalink/core/analytics/app_logger.dart';
import 'package:khedmalink/shared/widgets/loading_states.dart';
import 'package:khedmalink/shared/widgets/error_states.dart';

/// Provider for provider detail data
final providerDetailProvider =
    FutureProvider.family<ProviderProfile, String>(
  (ref, providerId) async {
    final providerService = api.ProviderApiService();
    return await providerService.getProviderProfile(providerId);
  },
);

/// Provider detail screen
class ProviderDetailScreen extends ConsumerWidget {
  final String providerId;

  const ProviderDetailScreen({
    super.key,
    required this.providerId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = 'ar'; // Will be from localization provider

    return Scaffold(
      appBar: AppBar(
        title: Text(
          language == 'ar' ? 'تفاصيل مزود الخدمة' : 'Détails du fournisseur',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(providerDetailProvider);
        },
        child: Consumer(
          builder: (context, ref, child) {
            final providerAsync = ref.watch(providerDetailProvider(providerId));

            return providerAsync.when(
              data: (provider) {
                return _ProviderDetailContent(
                  provider: provider,
                  language: language,
                );
              },
              loading: () => const FullScreenLoading(),
              error: (error, stack) {
                AppLogger.error('Provider detail load error: $error');
                return ErrorState(
                  title: language == 'ar'
                      ? 'خطأ في التحميل'
                      : 'Erreur de chargement',
                  subtitle: language == 'ar'
                      ? 'فشل تحميل تفاصيل مزود الخدمة. حاول مرة أخرى.'
                      : 'Échec du chargement des détails du fournisseur. Réessayez.',
                  onRetry: () {
                    ref.invalidate(providerDetailProvider);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// Provider detail content widget
class _ProviderDetailContent extends StatelessWidget {
  final ProviderProfile provider;
  final String language;

  const _ProviderDetailContent({
    required this.provider,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          _HeaderSection(
            provider: provider,
            language: language,
          ),
          const SizedBox(height: 16),
          // Description section
          if (provider.getLocalizedDescription(language) != null)
            _DescriptionSection(
              description: provider.getLocalizedDescription(language)!,
              language: language,
            ),
          const SizedBox(height: 16),
          // Stats section
          _StatsSection(
            provider: provider,
            language: language,
          ),
          const SizedBox(height: 16),
          // Location section
          if (provider.city != null || provider.wilaya != null)
            _LocationSection(
              provider: provider,
              language: language,
            ),
          const SizedBox(height: 16),
          // Experience section
          if (provider.yearsExperience != null)
            _ExperienceSection(
              yearsExperience: provider.yearsExperience!,
              language: language,
            ),
          const SizedBox(height: 16),
          // Verification status section
          _VerificationSection(
            verificationStatus: provider.verificationStatus,
            language: language,
          ),
          const SizedBox(height: 24),
          // Contact button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Navigate to contact or request creation
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        language == 'ar'
                            ? 'سيتم تفعيل التواصل قريبًا'
                            : 'La fonctionnalité de contact sera bientôt disponible',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.contact_page),
                label: Text(
                  language == 'ar' ? 'تواصل مع مزود الخدمة' : 'Contacter le fournisseur',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// Header section widget
class _HeaderSection extends StatelessWidget {
  final ProviderProfile provider;
  final String language;

  const _HeaderSection({
    required this.provider,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Business name
          Row(
            children: [
              Expanded(
                child: Text(
                  provider.businessName ??
                      (language == 'ar' ? 'مزود خدمة' : 'Fournisseur'),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              if (provider.isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        language == 'ar' ? 'موثق' : 'Vérifié',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Rating
          Row(
            children: [
              Icon(
                Icons.star,
                size: 20,
                color: Colors.amber,
              ),
              const SizedBox(width: 6),
              Text(
                provider.ratingAverage.toStringAsFixed(1),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '(${provider.ratingCount} ${language == 'ar' ? 'تقييم' : 'avis'})',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Description section widget
class _DescriptionSection extends StatelessWidget {
  final String description;
  final String language;

  const _DescriptionSection({
    required this.description,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.description_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    language == 'ar' ? 'الوصف' : 'Description',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Stats section widget
class _StatsSection extends StatelessWidget {
  final ProviderProfile provider;
  final String language;

  const _StatsSection({
    required this.provider,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Completed jobs
              _StatItem(
                icon: Icons.work_outline,
                value: provider.completedJobs.toString(),
                label: language == 'ar' ? 'مهمة مكتملة' : 'Tâches terminées',
                language: language,
              ),
              // Rating count
              _StatItem(
                icon: Icons.star_outline,
                value: provider.ratingCount.toString(),
                label: language == 'ar' ? 'تقييم' : 'Avis',
                language: language,
              ),
              // Availability
              _StatItem(
                icon: provider.isAvailable
                    ? Icons.check_circle_outline
                    : Icons.cancel_outlined,
                value: provider.isAvailable
                    ? (language == 'ar' ? 'متاح' : 'Disponible')
                    : (language == 'ar' ? 'غير متاح' : 'Indisponible'),
                label: language == 'ar' ? 'الحالة' : 'Statut',
                language: language,
                isText: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Stat item widget
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final String language;
  final bool isText;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.language,
    this.isText = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(
          icon,
          size: 32,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}

/// Location section widget
class _LocationSection extends StatelessWidget {
  final ProviderProfile provider;
  final String language;

  const _LocationSection({
    required this.provider,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    language == 'ar' ? 'الموقع' : 'Emplacement',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (provider.wilaya != null)
                _LocationRow(
                  label: language == 'ar' ? 'الولاية' : 'Wilaya',
                  value: provider.wilaya!,
                ),
              if (provider.city != null)
                _LocationRow(
                  label: language == 'ar' ? 'المدينة' : 'Ville',
                  value: provider.city!,
                ),
              if (provider.address != null)
                _LocationRow(
                  label: language == 'ar' ? 'العنوان' : 'Adresse',
                  value: provider.address!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Location row widget
class _LocationRow extends StatelessWidget {
  final String label;
  final String value;

  const _LocationRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// Experience section widget
class _ExperienceSection extends StatelessWidget {
  final int yearsExperience;
  final String language;

  const _ExperienceSection({
    required this.yearsExperience,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.workspace_premium_outlined,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language == 'ar' ? 'سنوات الخبرة' : 'Années d\'expérience',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$yearsExperience ${language == 'ar' ? 'سنة' : 'ans'}',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Verification status section widget
class _VerificationSection extends StatelessWidget {
  final String verificationStatus;
  final String language;

  const _VerificationSection({
    required this.verificationStatus,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final statusConfig = _getStatusConfig(verificationStatus, language);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        color: statusConfig.color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                statusConfig.icon,
                color: statusConfig.color,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language == 'ar' ? 'حالة التحقق' : 'Statut de vérification',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusConfig.label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: statusConfig.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get status configuration
  ({String label, Color color, IconData icon}) _getStatusConfig(
    String status,
    String language,
  ) {
    switch (status) {
      case 'approved':
        return (
          label: language == 'ar' ? 'موثق' : 'Vérifié',
          color: Colors.green,
          icon: Icons.verified,
        );
      case 'pending':
        return (
          label: language == 'ar' ? 'قيد الانتظار' : 'En attente',
          color: Colors.orange,
          icon: Icons.pending,
        );
      case 'submitted':
        return (
          label: language == 'ar' ? 'تم التقديم' : 'Soumis',
          color: Colors.blue,
          icon: Icons.upload_file,
        );
      case 'under_review':
        return (
          label: language == 'ar' ? 'قيد المراجعة' : 'En cours de révision',
          color: Colors.purple,
          icon: Icons.rate_review,
        );
      case 'rejected':
        return (
          label: language == 'ar' ? 'مرفوض' : 'Rejeté',
          color: Colors.red,
          icon: Icons.cancel,
        );
      case 'suspended':
        return (
          label: language == 'ar' ? 'معلق' : 'Suspendu',
          color: Colors.red,
          icon: Icons.block,
        );
      default:
        return (
          label: language == 'ar' ? 'غير معروف' : 'Inconnu',
          color: Colors.grey,
          icon: Icons.help_outline,
        );
    }
  }
}
