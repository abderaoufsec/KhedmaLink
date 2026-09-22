// Review models for KhedmaLink Flutter app
// Contains data models for reviews and provider reputation

/// Review model
class Review {
  final String id;
  final String bookingId;
  final String customerId;
  final String providerId;
  final int rating; // 1-5 stars
  final String? title;
  final String? comment;
  final int? professionalism; // 1-5
  final int? quality; // 1-5
  final int? timeliness; // 1-5
  final int? communication; // 1-5
  final int? value; // 1-5
  final String? providerResponse;
  final String? providerResponseAt;
  final String createdAt;
  final String? updatedAt;

  Review({
    required this.id,
    required this.bookingId,
    required this.customerId,
    required this.providerId,
    required this.rating,
    this.title,
    this.comment,
    this.professionalism,
    this.quality,
    this.timeliness,
    this.communication,
    this.value,
    this.providerResponse,
    this.providerResponseAt,
    required this.createdAt,
    this.updatedAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      customerId: json['customer_id'] as String,
      providerId: json['provider_id'] as String,
      rating: json['rating'] as int,
      title: json['title'] as String?,
      comment: json['comment'] as String?,
      professionalism: json['professionalism'] as int?,
      quality: json['quality'] as int?,
      timeliness: json['timeliness'] as int?,
      communication: json['communication'] as int?,
      value: json['value'] as int?,
      providerResponse: json['provider_response'] as String?,
      providerResponseAt: json['provider_response_at'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'customer_id': customerId,
      'provider_id': providerId,
      'rating': rating,
      'title': title,
      'comment': comment,
      'professionalism': professionalism,
      'quality': quality,
      'timeliness': timeliness,
      'communication': communication,
      'value': value,
      'provider_response': providerResponse,
      'provider_response_at': providerResponseAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Check if review has detailed category ratings
  bool get hasCategoryRatings =>
      professionalism != null ||
      quality != null ||
      timeliness != null ||
      communication != null ||
      value != null;

  /// Get average of category ratings
  double? get averageCategoryRating {
    if (!hasCategoryRatings) return null;
    
    final ratings = <int>[];
    if (professionalism != null) ratings.add(professionalism!);
    if (quality != null) ratings.add(quality!);
    if (timeliness != null) ratings.add(timeliness!);
    if (communication != null) ratings.add(communication!);
    if (value != null) ratings.add(value!);
    
    if (ratings.isEmpty) return null;
    return ratings.reduce((a, b) => a + b) / ratings.length;
  }

  /// Check if provider has responded
  bool get hasProviderResponse => providerResponse != null;
}

/// Provider reputation model
class ProviderReputation {
  final double averageRating;
  final int totalReviews;
  final Map<String, int> ratingDistribution; // {"1": 5, "2": 3, ...}
  final Map<String, double> categoryAverages; // {"professionalism": 4.5, ...}
  final List<String> badges;

  ProviderReputation({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
    required this.categoryAverages,
    required this.badges,
  });

  factory ProviderReputation.fromJson(Map<String, dynamic> json) {
    return ProviderReputation(
      averageRating: json['average_rating'] as double,
      totalReviews: json['total_reviews'] as int,
      ratingDistribution: Map<String, int>.from(
        json['rating_distribution'] as Map<String, dynamic>,
      ),
      categoryAverages: Map<String, double>.from(
        json['category_averages'] as Map<String, dynamic>,
      ),
      badges: List<String>.from(json['badges'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'average_rating': averageRating,
      'total_reviews': totalReviews,
      'rating_distribution': ratingDistribution,
      'category_averages': categoryAverages,
      'badges': badges,
    };
  }

  /// Get formatted average rating
  String get formattedAverageRating => averageRating.toStringAsFixed(1);

  /// Check if provider has any reviews
  bool get hasReviews => totalReviews > 0;

  /// Check if provider is top rated (4.5+)
  bool get isTopRated => averageRating >= 4.5;

  /// Check if provider is highly rated (4.0+)
  bool get isHighlyRated => averageRating >= 4.0;
}
