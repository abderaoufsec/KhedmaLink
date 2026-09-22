// Categories list screen for KhedmaLink Flutter app
// Displays all service categories with localized names and descriptions

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khedmalink/core/models/provider_models.dart';
import 'package:khedmalink/core/services/provider_service.dart' as api;
import 'package:khedmalink/core/analytics/app_logger.dart';
import 'package:khedmalink/shared/widgets/loading_states.dart';
import 'package:khedmalink/shared/widgets/error_states.dart';
import 'package:khedmalink/shared/widgets/empty_states.dart';

/// Provider for categories data
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final providerService = api.ProviderApiService();
  // Try to get cached categories first
  final cached = await providerService.getCachedCategories();
  if (cached != null) {
    return cached;
  }
  // Fetch from API if no cache
  return await providerService.listCategories();
});

/// Categories list screen
class CategoriesListScreen extends ConsumerWidget {
  const CategoriesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch language from app config (simulated for now)
    final language = 'ar'; // Will be from localization provider

    return Scaffold(
      appBar: AppBar(
        title: Text(
          language == 'ar' ? 'الفئات' : 'Catégories',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Invalidate cache and refetch
          ref.invalidate(categoriesProvider);
        },
        child: Consumer(
          builder: (context, ref, child) {
            final categoriesAsync = ref.watch(categoriesProvider);

            return categoriesAsync.when(
              data: (categories) {
                if (categories.isEmpty) {
                  return EmptyState(
                    icon: Icons.category_outlined,
                    title: language == 'ar'
                        ? 'لا توجد فئات'
                        : 'Aucune catégorie',
                    subtitle: language == 'ar'
                        ? 'لم يتم العثور على فئات في الوقت الحالي'
                        : 'Aucune catégorie trouvée pour le moment',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return _CategoryCard(
                      category: category,
                      language: language,
                      onTap: () {
                        // Navigate to providers list for this category
                        _navigateToProviders(context, category.id, language);
                      },
                    );
                  },
                );
              },
              loading: () => const FullScreenLoading(),
              error: (error, stack) {
                AppLogger.error('Categories load error: $error');
                return ErrorState(
                  title: language == 'ar'
                      ? 'خطأ في التحميل'
                      : 'Erreur de chargement',
                  subtitle: language == 'ar'
                      ? 'فشل تحميل الفئات. حاول مرة أخرى.'
                      : 'Échec du chargement des catégories. Réessayez.',
                  onRetry: () {
                    ref.invalidate(categoriesProvider);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  /// Navigate to providers list for selected category
  void _navigateToProviders(
    BuildContext context,
    String categoryId,
    String language,
  ) {
    // TODO: Navigate to providers list screen with category filter
    // This will be implemented when we add routing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          language == 'ar'
              ? 'سيتم عرض مقدمي الخدمات لهذه الفئة قريبًا'
              : 'Les fournisseurs pour cette catégorie seront bientôt disponibles',
        ),
      ),
    );
  }
}

/// Category card widget
class _CategoryCard extends StatelessWidget {
  final Category category;
  final String language;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.language,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Category icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(category.icon),
                  size: 28,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              // Category info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.getLocalizedName(language),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (category.getLocalizedDescription(language) != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          category.getLocalizedDescription(language)!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              // Arrow icon
              Icon(
                language == 'ar'
                    ? Icons.arrow_back_ios_new
                    : Icons.arrow_forward_ios,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get icon for category
  IconData _getCategoryIcon(String? icon) {
    // Default icons based on category name if no custom icon
    if (icon != null && icon.isNotEmpty) {
      // In a real app, you might use a custom icon package
      return Icons.category;
    }

    // Return appropriate icon based on category name
    final nameAr = category.nameAr.toLowerCase();
    final nameFr = category.nameFr.toLowerCase();

    if (nameAr.contains('إصلاح') ||
        nameFr.contains('réparation') ||
        nameFr.contains('réparateur')) {
      return Icons.build;
    } else if (nameAr.contains('تكييف') ||
        nameFr.contains('climatisation') ||
        nameFr.contains('climat')) {
      return Icons.ac_unit;
    } else if (nameAr.contains('تنظيف') ||
        nameFr.contains('nettoyage') ||
        nameFr.contains('nettoyage')) {
      return Icons.cleaning_services;
    } else if (nameAr.contains('صيانة') ||
        nameFr.contains('maintenance') ||
        nameFr.contains('bricoleur')) {
      return Icons.handyman;
    } else if (nameAr.contains('سباكة') ||
        nameFr.contains('plomberie') ||
        nameFr.contains('plombier')) {
      return Icons.plumbing;
    }

    return Icons.category;
  }
}
