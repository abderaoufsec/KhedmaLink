// Provider reviews list screen for KhedmaLink Flutter app
// Displays reviews for a provider

import 'package:flutter/material.dart';
import 'package:khedmalink/core/models/review_models.dart';
import 'package:khedmalink/core/services/review_service.dart' as api;
import 'package:khedmalink/core/analytics/app_logger.dart';

/// Provider reviews list screen
class ProviderReviewsScreen extends StatefulWidget {
  final String providerId;

  const ProviderReviewsScreen({super.key, required this.providerId});

  @override
  State<ProviderReviewsScreen> createState() => _ProviderReviewsScreenState();
}

class _ProviderReviewsScreenState extends State<ProviderReviewsScreen> {
  final api.ReviewApiService _reviewService = api.ReviewApiService();
  List<Review> _reviews = [];
  ProviderReputation? _reputation;
  bool _isLoading = true;
  String? _errorMessage;

  String get language => 'ar'; // Will be from localization provider

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final reviews = await _reviewService.listProviderReviews(widget.providerId);
      final reputation = await _reviewService.getProviderReputation(widget.providerId);
      
      if (mounted) {
        setState(() {
          _reviews = reviews;
          _reputation = reputation;
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('Load reviews error: $e');
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
          language == 'ar' ? 'التقييمات' : 'Reviews',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
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
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Reputation summary
          if (_reputation != null) _ReputationCard(reputation: _reputation!, language: language),
          const SizedBox(height: 16),
          // Reviews list
          if (_reviews.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star_border_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    language == 'ar' ? 'لا توجد تقييمات' : 'No reviews yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    language == 'ar'
                        ? 'كن أول من يقيّم هذا المقدم'
                        : 'Be the first to review this provider',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          else
            ..._reviews.map((review) => _ReviewCard(review: review, language: language)),
        ],
      ),
    );
  }
}

class _ReputationCard extends StatelessWidget {
  final ProviderReputation reputation;
  final String language;

  const _ReputationCard({
    required this.reputation,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Average rating
            Row(
              children: [
                Text(
                  reputation.formattedAverageRating,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(width: 8),
                ...List.generate(5, (index) {
                  return Icon(
                    index < reputation.averageRating.floor()
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 20,
                  );
                }),
              ],
            ),
            const SizedBox(height: 8),
            // Total reviews
            Text(
              '${reputation.totalReviews} ${language == 'ar' ? 'تقييم' : 'reviews'}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 12),
            // Badges
            if (reputation.badges.isNotEmpty) ...[
              Text(
                language == 'ar' ? 'الشارات' : 'Badges',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: reputation.badges.map((badge) {
                  return Chip(
                    label: Text(badge),
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;
  final String language;

  const _ReviewCard({
    required this.review,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rating and date
            Row(
              children: [
                ...List.generate(5, (index) {
                  return Icon(
                    index < review.rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 20,
                  );
                }),
                const SizedBox(width: 8),
                Text(
                  review.createdAt.toString().split(' ')[0],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Title
            if (review.title != null) ...[
              Text(
                review.title!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
            ],
            // Comment
            if (review.comment != null)
              Text(
                review.comment!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            // Category ratings
            if (review.hasCategoryRatings) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (review.professionalism != null)
                  _CategoryBadge(
                    label: language == 'ar' ? 'احتراف' : 'Professionalism',
                    rating: review.professionalism!,
                  ),
                  if (review.quality != null)
                  _CategoryBadge(
                    label: language == 'ar' ? 'جودة' : 'Quality',
                    rating: review.quality!,
                  ),
                  if (review.timeliness != null)
                  _CategoryBadge(
                    label: language == 'ar' ? 'مواعد' : 'Timeliness',
                    rating: review.timeliness!,
                  ),
                  if (review.communication != null)
                  _CategoryBadge(
                    label: language == 'ar' ? 'تواصل' : 'Communication',
                    rating: review.communication!,
                  ),
                  if (review.value != null)
                  _CategoryBadge(
                    label: language == 'ar' ? 'قيمة' : 'Value',
                    rating: review.value!,
                  ),
                ],
              ),
            ],
            // Provider response
            if (review.hasProviderResponse) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language == 'ar' ? 'رد مقدم الخدمة' : 'Provider Response',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      review.providerResponse!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String label;
  final int rating;

  const _CategoryBadge({
    required this.label,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 14, color: Colors.amber),
          const SizedBox(width: 4),
          Text(
            '$label: $rating',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
