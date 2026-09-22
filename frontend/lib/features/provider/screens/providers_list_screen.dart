// Provider list screen for KhedmaLink Flutter app
// Displays providers with filtering options

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khedmalink/core/models/provider_models.dart';
import 'package:khedmalink/core/services/provider_service.dart' as api;
import 'package:khedmalink/core/analytics/app_logger.dart';
import 'package:khedmalink/shared/widgets/loading_states.dart';
import 'package:khedmalink/shared/widgets/error_states.dart';
import 'package:khedmalink/shared/widgets/empty_states.dart';

/// Provider for providers data with filters
class ProvidersFilter {
  final String? categoryId;
  final String? city;
  final String? wilaya;
  final bool verifiedOnly;
  final bool availableOnly;

  const ProvidersFilter({
    this.categoryId,
    this.city,
    this.wilaya,
    this.verifiedOnly = true,
    this.availableOnly = true,
  });

  ProvidersFilter copyWith({
    String? categoryId,
    String? city,
    String? wilaya,
    bool? verifiedOnly,
    bool? availableOnly,
  }) {
    return ProvidersFilter(
      categoryId: categoryId ?? this.categoryId,
      city: city ?? this.city,
      wilaya: wilaya ?? this.wilaya,
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
      availableOnly: availableOnly ?? this.availableOnly,
    );
  }

  bool get hasFilters =>
      categoryId != null || city != null || wilaya != null;

  @override
  bool operator ==(Object other) =>
      other is ProvidersFilter &&
      other.categoryId == categoryId &&
      other.city == city &&
      other.wilaya == wilaya &&
      other.verifiedOnly == verifiedOnly &&
      other.availableOnly == availableOnly;

  @override
  int get hashCode =>
      categoryId.hashCode ^
      city.hashCode ^
      wilaya.hashCode ^
      verifiedOnly.hashCode ^
      availableOnly.hashCode;
}

/// Providers filter provider
final providersFilterProvider =
    StateProvider<ProvidersFilter>((ref) => const ProvidersFilter());

/// Providers list provider
final providersListProvider =
    FutureProvider.family<List<ProviderProfile>, ProvidersFilter>(
  (ref, filter) async {
    final providerService = api.ProviderApiService();
    return await providerService.listProviders(
      categoryId: filter.categoryId,
      city: filter.city,
      wilaya: filter.wilaya,
      verifiedOnly: filter.verifiedOnly,
      availableOnly: filter.availableOnly,
    );
  },
);

/// Provider list screen
class ProvidersListScreen extends ConsumerStatefulWidget {
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
  ConsumerState<ProvidersListScreen> createState() =>
      _ProvidersListScreenState();
}

class _ProvidersListScreenState extends ConsumerState<ProvidersListScreen> {
  @override
  void initState() {
    super.initState();
    // Set initial filter from route parameters
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(providersFilterProvider.notifier).state = ProvidersFilter(
        categoryId: widget.categoryId,
        city: widget.city,
        wilaya: widget.wilaya,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final language = 'ar'; // Will be from localization provider
    final filter = ref.watch(providersFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          language == 'ar' ? 'مقدمو الخدمات' : 'Fournisseurs',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(context, language),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          if (filter.hasFilters)
            _FilterChips(
              filter: filter,
              language: language,
              onRemoveFilter: (key) {
                ref.read(providersFilterProvider.notifier).state =
                    _removeFilterKey(filter, key);
              },
              onClearAll: () {
                ref.read(providersFilterProvider.notifier).state =
                    const ProvidersFilter();
              },
            ),
          // Providers list
          Expanded(
            child: _ProvidersList(
              filter: filter,
              language: language,
            ),
          ),
        ],
      ),
    );
  }

  /// Show filter bottom sheet
  void _showFilterBottomSheet(BuildContext context, String language) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FilterBottomSheet(
        currentFilter: ref.read(providersFilterProvider),
        language: language,
        onApply: (newFilter) {
          ref.read(providersFilterProvider.notifier).state = newFilter;
          Navigator.pop(context);
        },
      ),
    );
  }

  /// Remove a specific filter key
  ProvidersFilter _removeFilterKey(ProvidersFilter filter, String key) {
    switch (key) {
      case 'categoryId':
        return filter.copyWith(categoryId: null);
      case 'city':
        return filter.copyWith(city: null);
      case 'wilaya':
        return filter.copyWith(wilaya: null);
      default:
        return filter;
    }
  }
}

/// Filter chips widget
class _FilterChips extends StatelessWidget {
  final ProvidersFilter filter;
  final String language;
  final Function(String) onRemoveFilter;
  final VoidCallback onClearAll;

  const _FilterChips({
    required this.filter,
    required this.language,
    required this.onRemoveFilter,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];

    if (filter.categoryId != null) {
      chips.add(
        FilterChip(
          label: Text(
            language == 'ar' ? 'فئة محددة' : 'Catégorie',
          ),
          onDeleted: () => onRemoveFilter('categoryId'),
          onSelected: (_) => onRemoveFilter('categoryId'),
          selected: true,
        ),
      );
    }

    if (filter.city != null) {
      chips.add(
        FilterChip(
          label: Text(filter.city!),
          onDeleted: () => onRemoveFilter('city'),
          onSelected: (_) => onRemoveFilter('city'),
          selected: true,
        ),
      );
    }

    if (filter.wilaya != null) {
      chips.add(
        FilterChip(
          label: Text(filter.wilaya!),
          onDeleted: () => onRemoveFilter('wilaya'),
          onSelected: (_) => onRemoveFilter('wilaya'),
          selected: true,
        ),
      );
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ...chips,
          TextButton(
            onPressed: onClearAll,
            child: Text(
              language == 'ar' ? 'مسح الكل' : 'Effacer tout',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Providers list widget
class _ProvidersList extends ConsumerWidget {
  final ProvidersFilter filter;
  final String language;

  const _ProvidersList({
    required this.filter,
    required this.language,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providersAsync = ref.watch(providersListProvider(filter));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(providersListProvider);
      },
      child: providersAsync.when(
        data: (providers) {
          if (providers.isEmpty) {
            return EmptyState(
              icon: Icons.person_search_outlined,
              title: language == 'ar'
                  ? 'لا يوجد مقدمو خدمات'
                  : 'Aucun fournisseur',
              subtitle: language == 'ar'
                  ? 'لم يتم العثور على مقدمي خدمات مطابقين لفلتر البحث'
                  : 'Aucun fournisseur trouvé correspondant aux filtres',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: providers.length,
            itemBuilder: (context, index) {
              final provider = providers[index];
              return _ProviderCard(
                provider: provider,
                language: language,
                onTap: () {
                  // Navigate to provider detail
                  _navigateToProviderDetail(context, provider.id, language);
                },
              );
            },
          );
        },
        loading: () => const FullScreenLoading(),
        error: (error, stack) {
          AppLogger.error('Providers load error: $error');
          return ErrorState(
            title: language == 'ar'
                ? 'خطأ في التحميل'
                : 'Erreur de chargement',
            subtitle: language == 'ar'
                ? 'فشل تحميل مقدمي الخدمات. حاول مرة أخرى.'
                : 'Échec du chargement des fournisseurs. Réessayez.',
            onRetry: () {
              ref.invalidate(providersListProvider);
            },
          );
        },
      ),
    );
  }

  /// Navigate to provider detail
  void _navigateToProviderDetail(
    BuildContext context,
    String providerId,
    String language,
  ) {
    // TODO: Navigate to provider detail screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          language == 'ar'
              ? 'تفاصيل مزود الخدمة قريباً'
              : 'Détails du fournisseur bientôt disponibles',
        ),
      ),
    );
  }
}

/// Provider card widget
class _ProviderCard extends StatelessWidget {
  final ProviderProfile provider;
  final String language;
  final VoidCallback onTap;

  const _ProviderCard({
    required this.provider,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Provider name and verification badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      provider.businessName ??
                          (language == 'ar' ? 'مزود خدمة' : 'Fournisseur'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (provider.isVerified)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            language == 'ar' ? 'موثق' : 'Vérifié',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Location
              if (provider.city != null || provider.wilaya != null)
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${provider.wilaya ?? ''} ${provider.city ?? ''}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              // Rating and completed jobs
              Row(
                children: [
                  Icon(
                    Icons.star,
                    size: 16,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    provider.ratingAverage.toStringAsFixed(1),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${provider.ratingCount})',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.work_outline,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${provider.completedJobs} ${language == 'ar' ? 'مهمة' : 'tâches'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              if (provider.getLocalizedDescription(language) != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    provider.getLocalizedDescription(language)!,
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
      ),
    );
  }
}

/// Filter bottom sheet
class _FilterBottomSheet extends StatefulWidget {
  final ProvidersFilter currentFilter;
  final String language;
  final Function(ProvidersFilter) onApply;

  const _FilterBottomSheet({
    required this.currentFilter,
    required this.language,
    required this.onApply,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late ProvidersFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  language == 'ar' ? 'تصفية النتائج' : 'Filtrer les résultats',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _filter = const ProvidersFilter();
                    });
                  },
                  child: Text(
                    language == 'ar' ? 'إعادة تعيين' : 'Réinitialiser',
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          // Filters
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Verified only
                SwitchListTile(
                  title: Text(
                    language == 'ar' ? 'الموثقون فقط' : 'Vérifiés uniquement',
                  ),
                  subtitle: Text(
                    language == 'ar'
                        ? 'عرض مقدمي الخدمات الموثقين فقط'
                        : 'Afficher uniquement les fournisseurs vérifiés',
                  ),
                  value: _filter.verifiedOnly,
                  onChanged: (value) {
                    setState(() {
                      _filter = _filter.copyWith(verifiedOnly: value);
                    });
                  },
                ),
                // Available only
                SwitchListTile(
                  title: Text(
                    language == 'ar' ? 'المتاحون فقط' : 'Disponibles uniquement',
                  ),
                  subtitle: Text(
                    language == 'ar'
                        ? 'عرض مقدمي الخدمات المتاحين للعمل فقط'
                        : 'Afficher uniquement les fournisseurs disponibles',
                  ),
                  value: _filter.availableOnly,
                  onChanged: (value) {
                    setState(() {
                      _filter = _filter.copyWith(availableOnly: value);
                    });
                  },
                ),
                // City filter
                TextField(
                  decoration: InputDecoration(
                    labelText: language == 'ar' ? 'المدينة' : 'Ville',
                    hintText: language == 'ar'
                        ? 'أدخل اسم المدينة'
                        : 'Entrez le nom de la ville',
                  ),
                  onChanged: (value) {
                    setState(() {
                      _filter = _filter.copyWith(
                        city: value.isEmpty ? null : value,
                      );
                    });
                  },
                  controller: TextEditingController(text: _filter.city),
                ),
                const SizedBox(height: 16),
                // Wilaya filter
                TextField(
                  decoration: InputDecoration(
                    labelText: language == 'ar' ? 'الولاية' : 'Wilaya',
                    hintText: language == 'ar'
                        ? 'أدخل اسم الولاية'
                        : 'Entrez le nom de la wilaya',
                  ),
                  onChanged: (value) {
                    setState(() {
                      _filter = _filter.copyWith(
                        wilaya: value.isEmpty ? null : value,
                      );
                    });
                  },
                  controller: TextEditingController(text: _filter.wilaya),
                ),
                const SizedBox(height: 24),
                // Apply button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply(_filter);
                    },
                    child: Text(
                      language == 'ar' ? 'تطبيق' : 'Appliquer',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
