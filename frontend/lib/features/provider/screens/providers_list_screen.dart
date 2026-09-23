// Providers list screen for KhedmaLink Flutter app
// Displays provider discovery with filters
// Features modern UI with cards, animations, and professional design

import 'package:flutter/material.dart';
import 'package:khedmalink/core/models/provider_models.dart';
import 'package:khedmalink/core/services/provider_service.dart' as api;
import 'package:khedmalink/core/analytics/app_logger.dart';
import 'package:khedmalink/core/theme/app_theme.dart';

/// Providers list screen with modern professional design
class ProvidersListScreen extends StatefulWidget {
  final String? categoryId;
  final String? city;
  final String? wilaya;

  const ProvidersListScreen({
    super.key,
    this.categoryId,
    this.city,
    this.wilaya,
  });

  @override
  State<ProvidersListScreen> createState() => _ProvidersListScreenState();
}

class _ProvidersListScreenState extends State<ProvidersListScreen>
    with SingleTickerProviderStateMixin {
  final api.ProviderApiService _providerService = api.ProviderApiService();
  List<ProviderProfile> _providers = [];
  bool _isLoading = true;
  String? _errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _loadProviders();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadProviders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final providers = await _providerService.listProviders(
        categoryId: widget.categoryId,
        city: widget.city,
        wilaya: widget.wilaya,
      );
      if (mounted) {
        setState(() {
          _providers = providers;
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('Load providers error: $e');
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          language == 'ar' ? 'مقدمو الخدمات' : 'Fournisseurs',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _loadProviders,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
      body: _buildBody(context, language),
    );
  }

  Widget _buildBody(BuildContext context, String language) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              language == 'ar' ? 'جاري التحميل...' : 'Chargement...',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: AppTheme.errorColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Error: $_errorMessage',
                style: TextStyle(
                  color: AppTheme.errorColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: AppTheme.buttonShadow,
                ),
                child: ElevatedButton(
                  onPressed: _loadProviders,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: const Text('Retry'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_providers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_search_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.onSurface
                    .withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              language == 'ar' ? 'لا توجد نتائج' : 'Aucun résultat',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface
                        .withValues(alpha: 0.7),
                  ),
            ),
          ],
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        onRefresh: _loadProviders,
        color: AppTheme.primaryColor,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _providers.length,
          itemBuilder: (context, index) {
            final provider = _providers[index];
            return _ProviderCard(
              provider: provider,
              language: language,
              index: index,
              onTap: () {
                // Navigate to provider detail
                // context.go('/providers/${provider.id}');
              },
            );
          },
        ),
      ),
    );
  }
}

/// Modern provider card widget with professional design
class _ProviderCard extends StatelessWidget {
  final ProviderProfile provider;
  final String language;
  final int index;
  final VoidCallback onTap;

  const _ProviderCard({
    required this.provider,
    required this.language,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.grey800 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Provider avatar with gradient
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppTheme.buttonShadow,
                  ),
                  child: Center(
                    child: Text(
                      (provider.businessName ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Provider information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Provider name and verification badge
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              provider.businessName ?? 'Unknown',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (provider.verificationStatus == 'verified')
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.successColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppTheme.successColor.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.verified_rounded,
                                    size: 12,
                                    color: AppTheme.successColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Verified',
                                    style: TextStyle(
                                      color: AppTheme.successColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Location with icon
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 14,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${provider.wilaya} - ${provider.city}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Rating with stars
                      Row(
                        children: [
                          Row(
                            children: List.generate(5, (starIndex) {
                              return Icon(
                                starIndex <
                                        (provider.averageRating.round())
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                size: 14,
                                color: AppTheme.warningColor,
                              );
                            }),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            provider.averageRating.toStringAsFixed(1),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          if (provider.totalReviews > 0) ...[
                            const SizedBox(width: 4),
                            Text(
                              '(${provider.totalReviews})',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow icon
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
