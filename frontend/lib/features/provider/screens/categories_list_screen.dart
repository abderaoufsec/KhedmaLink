// Categories list screen for KhedmaLink Flutter app
// Displays all service categories with localized names and descriptions
// Features modern UI with grid layout, animations, and professional design

import 'package:flutter/material.dart';
import 'package:khedmalink/core/models/provider_models.dart';
import 'package:khedmalink/core/services/provider_service.dart' as api;
import 'package:khedmalink/core/analytics/app_logger.dart';
import 'package:khedmalink/core/theme/app_theme.dart';

/// Categories list screen with modern professional design
class CategoriesListScreen extends StatefulWidget {
  const CategoriesListScreen({super.key});

  @override
  State<CategoriesListScreen> createState() => _CategoriesListScreenState();
}

class _CategoriesListScreenState extends State<CategoriesListScreen>
    with SingleTickerProviderStateMixin {
  final api.ProviderApiService _providerService = api.ProviderApiService();
  List<Category> _categories = [];
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

    _loadCategories();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final categories = await _providerService.listCategories();
      if (mounted) {
        setState(() {
          _categories = categories;
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('Load categories error: $e');
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
          language == 'ar' ? 'الفئات' : 'Catégories',
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
              onPressed: _loadCategories,
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
                  onPressed: _loadCategories,
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

    if (_categories.isEmpty) {
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
                Icons.category_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.onSurface
                    .withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              language == 'ar' ? 'لا توجد فئات' : 'Aucune catégorie',
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
        onRefresh: _loadCategories,
        color: AppTheme.primaryColor,
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            return _CategoryCard(
              category: category,
              language: language,
              index: index,
              onTap: () {
                // Navigate to providers in this category
                // context.go('/providers?category_id=${category.id}');
              },
            );
          },
        ),
      ),
    );
  }
}

/// Modern category card widget with professional design
class _CategoryCard extends StatelessWidget {
  final Category category;
  final String language;
  final int index;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.language,
    required this.index,
    required this.onTap,
  });

  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('plumbing') || name.contains('سباكة')) {
      return Icons.plumbing_rounded;
    } else if (name.contains('electric') || name.contains('كهرباء')) {
      return Icons.electrical_services_rounded;
    } else if (name.contains('clean') || name.contains('تنظيف')) {
      return Icons.cleaning_services_rounded;
    } else if (name.contains('paint') || name.contains('دهان')) {
      return Icons.format_paint_rounded;
    } else if (name.contains('carpent') || name.contains('نجارة')) {
      return Icons.carpenter_rounded;
    } else if (name.contains('moving') || name.contains('نقل')) {
      return Icons.local_shipping_rounded;
    } else if (name.contains('garden') || name.contains('حدائق')) {
      return Icons.yard_rounded;
    } else if (name.contains('repair') || name.contains('إصلاح')) {
      return Icons.build_rounded;
    } else {
      return Icons.miscellaneous_services_rounded;
    }
  }

  Color _getCategoryColor(int index) {
    final colors = [
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
      AppTheme.accentColor,
      AppTheme.successColor,
      AppTheme.warningColor,
      AppTheme.infoColor,
    ];
    return colors[index % colors.length];
  }

  String _getCategoryName(Category category, String language) {
    return language == 'ar' ? category.nameAr : category.nameFr;
  }

  String? _getCategoryDescription(Category category, String language) {
    return language == 'ar' ? category.descriptionAr : category.descriptionFr;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final categoryColor = _getCategoryColor(index);
    final categoryIcon = _getCategoryIcon(_getCategoryName(category, language));

    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOut,
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
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Category icon with gradient background
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        categoryColor,
                        categoryColor.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: categoryColor.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    categoryIcon,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // Category name
                Text(
                  _getCategoryName(category, language),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Category description
                Builder(
                  builder: (context) {
                    final description = _getCategoryDescription(category, language);
                    if (description != null && description.isNotEmpty) {
                      return Text(
                        description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
