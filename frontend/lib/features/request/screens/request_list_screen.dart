// Request list screen for KhedmaLink Flutter app
// Displays customer's service requests
// Features modern UI with cards, animations, and professional design

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:khedmalink/core/models/request_models.dart';
import 'package:khedmalink/core/services/request_service.dart' as api;
import 'package:khedmalink/core/analytics/app_logger.dart';
import 'package:khedmalink/core/theme/app_theme.dart';

/// Request list screen with modern professional design
class RequestListScreen extends StatefulWidget {
  const RequestListScreen({super.key});

  @override
  State<RequestListScreen> createState() => _RequestListScreenState();
}

class _RequestListScreenState extends State<RequestListScreen>
    with SingleTickerProviderStateMixin {
  final api.RequestApiService _requestService = api.RequestApiService();
  List<ServiceRequest> _requests = [];
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

    _loadRequests();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final requests = await _requestService.listMyRequests();
      if (mounted) {
        setState(() {
          _requests = requests;
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('Load requests error: $e');
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
          language == 'ar' ? 'طلباتي' : 'Mes demandes',
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
              onPressed: _loadRequests,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
      body: _buildBody(context, language),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.floatingShadow,
        ),
        child: FloatingActionButton(
          onPressed: () {
            context.go('/requests/create');
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ),
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
                  onPressed: _loadRequests,
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

    if (_requests.isEmpty) {
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
                Icons.description_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.onSurface
                    .withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              language == 'ar' ? 'لا توجد طلبات' : 'Aucune demande',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface
                        .withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              language == 'ar' ? 'أنشئ طلبك الأول' : 'Créez votre première demande',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface
                        .withValues(alpha: 0.5),
                  ),
            ),
          ],
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        onRefresh: _loadRequests,
        color: AppTheme.primaryColor,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _requests.length,
          itemBuilder: (context, index) {
            final request = _requests[index];
            return _RequestCard(
              request: request,
              language: language,
              index: index,
              onTap: () {
                context.go('/requests/${request.id}');
              },
            );
          },
        ),
      ),
    );
  }
}

/// Modern request card widget with professional design
class _RequestCard extends StatelessWidget {
  final ServiceRequest request;
  final String language;
  final int index;
  final VoidCallback onTap;

  const _RequestCard({
    required this.request,
    required this.language,
    required this.index,
    required this.onTap,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return AppTheme.infoColor;
      case 'in_progress':
        return AppTheme.warningColor;
      case 'closed':
        return AppTheme.successColor;
      case 'cancelled':
        return AppTheme.errorColor;
      default:
        return AppTheme.grey500;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return language == 'ar' ? 'مفتوح' : 'Ouvert';
      case 'in_progress':
        return language == 'ar' ? 'قيد التنفيذ' : 'En cours';
      case 'closed':
        return language == 'ar' ? 'مغلق' : 'Fermé';
      case 'cancelled':
        return language == 'ar' ? 'ملغي' : 'Annulé';
      default:
        return status;
    }
  }

  String _getRequestTitle(ServiceRequest request, String language) {
    return language == 'ar' ? request.titleAr : request.titleFr;
  }

  String _getRequestDescription(ServiceRequest request, String language) {
    return language == 'ar' ? request.descriptionAr : request.descriptionFr;
  }

  String _getBudgetDisplay(ServiceRequest request) {
    if (request.budgetMin != null && request.budgetMax != null) {
      return '${request.budgetMin} - ${request.budgetMax} DZD';
    } else if (request.budgetMin != null) {
      return '${request.budgetMin}+ DZD';
    } else if (request.budgetMax != null) {
      return 'Up to ${request.budgetMax} DZD';
    } else {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statusColor = _getStatusColor(request.status);

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and status
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _getRequestTitle(request, language),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        _getStatusText(request.status),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Description preview
                Builder(
                  builder: (context) {
                    final description = _getRequestDescription(request, language);
                    if (description.isNotEmpty) {
                      return Text(
                        description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                if (_getRequestDescription(request, language).isNotEmpty)
                const SizedBox(height: 12),

                // Category and location
                Row(
                  children: [
                    Icon(
                      Icons.category_rounded,
                      size: 14,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'General',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.location_on_rounded,
                      size: 14,
                      color: AppTheme.secondaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${request.wilaya} - ${request.city}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Date and budget
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      request.createdAt.split('T')[0],
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.attach_money_rounded,
                      size: 14,
                      color: AppTheme.successColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getBudgetDisplay(request),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.successColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
