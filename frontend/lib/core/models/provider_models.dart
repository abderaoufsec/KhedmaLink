// Provider and Category models for KhedmaLink Flutter app
// Contains data models for categories, provider profiles, services, areas, and availability

/// Category model representing service categories
class Category {
  final String id;
  final String nameAr;
  final String nameFr;
  final String? descriptionAr;
  final String? descriptionFr;
  final String? icon;
  final bool isActive;
  final int sortOrder;
  final String createdAt;
  final String? updatedAt;

  Category({
    required this.id,
    required this.nameAr,
    required this.nameFr,
    this.descriptionAr,
    this.descriptionFr,
    this.icon,
    required this.isActive,
    required this.sortOrder,
    required this.createdAt,
    this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      nameAr: json['name_ar'] as String,
      nameFr: json['name_fr'] as String,
      descriptionAr: json['description_ar'] as String?,
      descriptionFr: json['description_fr'] as String?,
      icon: json['icon'] as String?,
      isActive: json['is_active'] as bool,
      sortOrder: json['sort_order'] as int,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_ar': nameAr,
      'name_fr': nameFr,
      'description_ar': descriptionAr,
      'description_fr': descriptionFr,
      'icon': icon,
      'is_active': isActive,
      'sort_order': sortOrder,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Get the localized name based on the current language
  String getLocalizedName(String language) {
    return language == 'ar' ? nameAr : nameFr;
  }

  /// Get the localized description based on the current language
  String? getLocalizedDescription(String language) {
    return language == 'ar' ? descriptionAr : descriptionFr;
  }
}

/// Provider profile model
class ProviderProfile {
  final String id;
  final String userId;
  final String? businessName;
  final String? businessDescriptionAr;
  final String? businessDescriptionFr;
  final int? yearsExperience;
  final bool phoneVerified;
  final bool emailVerified;
  final String? city;
  final String? wilaya;
  final String? address;
  final String verificationStatus;
  final String? verificationRejectionReason;
  final bool isPublic;
  final bool isAvailable;
  final double ratingAverage;
  final int ratingCount;
  final int completedJobs;
  final String createdAt;
  final String? updatedAt;

  ProviderProfile({
    required this.id,
    required this.userId,
    this.businessName,
    this.businessDescriptionAr,
    this.businessDescriptionFr,
    this.yearsExperience,
    required this.phoneVerified,
    required this.emailVerified,
    this.city,
    this.wilaya,
    this.address,
    required this.verificationStatus,
    this.verificationRejectionReason,
    required this.isPublic,
    required this.isAvailable,
    required this.ratingAverage,
    required this.ratingCount,
    required this.completedJobs,
    required this.createdAt,
    this.updatedAt,
  });

  factory ProviderProfile.fromJson(Map<String, dynamic> json) {
    return ProviderProfile(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      businessName: json['business_name'] as String?,
      businessDescriptionAr: json['business_description_ar'] as String?,
      businessDescriptionFr: json['business_description_fr'] as String?,
      yearsExperience: json['years_experience'] as int?,
      phoneVerified: json['phone_verified'] as bool,
      emailVerified: json['email_verified'] as bool,
      city: json['city'] as String?,
      wilaya: json['wilaya'] as String?,
      address: json['address'] as String?,
      verificationStatus: json['verification_status'] as String,
      verificationRejectionReason: json['verification_rejection_reason'] as String?,
      isPublic: json['is_public'] as bool,
      isAvailable: json['is_available'] as bool,
      ratingAverage: (json['rating_average'] as num).toDouble(),
      ratingCount: json['rating_count'] as int,
      completedJobs: json['completed_jobs'] as int,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'business_name': businessName,
      'business_description_ar': businessDescriptionAr,
      'business_description_fr': businessDescriptionFr,
      'years_experience': yearsExperience,
      'phone_verified': phoneVerified,
      'email_verified': emailVerified,
      'city': city,
      'wilaya': wilaya,
      'address': address,
      'verification_status': verificationStatus,
      'verification_rejection_reason': verificationRejectionReason,
      'is_public': isPublic,
      'is_available': isAvailable,
      'rating_average': ratingAverage,
      'rating_count': ratingCount,
      'completed_jobs': completedJobs,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Check if the provider is verified
  bool get isVerified => verificationStatus == 'approved';

  /// Get the localized business description
  String? getLocalizedDescription(String language) {
    return language == 'ar' ? businessDescriptionAr : businessDescriptionFr;
  }
}

/// Provider service model
class ProviderServiceModel {
  final String id;
  final String providerId;
  final String categoryId;
  final String titleAr;
  final String titleFr;
  final String? descriptionAr;
  final String? descriptionFr;
  final double? basePrice;
  final String? priceUnit;
  final bool isActive;
  final String createdAt;
  final String? updatedAt;

  ProviderServiceModel({
    required this.id,
    required this.providerId,
    required this.categoryId,
    required this.titleAr,
    required this.titleFr,
    this.descriptionAr,
    this.descriptionFr,
    this.basePrice,
    this.priceUnit,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  factory ProviderServiceModel.fromJson(Map<String, dynamic> json) {
    return ProviderServiceModel(
      id: json['id'] as String,
      providerId: json['provider_id'] as String,
      categoryId: json['category_id'] as String,
      titleAr: json['title_ar'] as String,
      titleFr: json['title_fr'] as String,
      descriptionAr: json['description_ar'] as String?,
      descriptionFr: json['description_fr'] as String?,
      basePrice: json['base_price'] as double?,
      priceUnit: json['price_unit'] as String?,
      isActive: json['is_active'] as bool,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider_id': providerId,
      'category_id': categoryId,
      'title_ar': titleAr,
      'title_fr': titleFr,
      'description_ar': descriptionAr,
      'description_fr': descriptionFr,
      'base_price': basePrice,
      'price_unit': priceUnit,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Get the localized title
  String getLocalizedTitle(String language) {
    return language == 'ar' ? titleAr : titleFr;
  }

  /// Get the localized description
  String? getLocalizedDescription(String language) {
    return language == 'ar' ? descriptionAr : descriptionFr;
  }
}

/// Service area model
class ServiceArea {
  final String id;
  final String providerId;
  final String city;
  final String wilaya;
  final String? commune;
  final String? addressDetails;
  final double? latitude;
  final double? longitude;
  final double? radiusKm;
  final bool isActive;
  final String createdAt;
  final String? updatedAt;

  ServiceArea({
    required this.id,
    required this.providerId,
    required this.city,
    required this.wilaya,
    this.commune,
    this.addressDetails,
    this.latitude,
    this.longitude,
    this.radiusKm,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  factory ServiceArea.fromJson(Map<String, dynamic> json) {
    return ServiceArea(
      id: json['id'] as String,
      providerId: json['provider_id'] as String,
      city: json['city'] as String,
      wilaya: json['wilaya'] as String,
      commune: json['commune'] as String?,
      addressDetails: json['address_details'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      radiusKm: json['radius_km'] as double?,
      isActive: json['is_active'] as bool,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider_id': providerId,
      'city': city,
      'wilaya': wilaya,
      'commune': commune,
      'address_details': addressDetails,
      'latitude': latitude,
      'longitude': longitude,
      'radius_km': radiusKm,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

/// Availability rule model
class AvailabilityRule {
  final String id;
  final String providerId;
  final int dayOfWeek; // 0=Monday, 6=Sunday
  final String startTime; // HH:MM format
  final String endTime; // HH:MM format
  final bool isActive;
  final String createdAt;
  final String? updatedAt;

  AvailabilityRule({
    required this.id,
    required this.providerId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  factory AvailabilityRule.fromJson(Map<String, dynamic> json) {
    return AvailabilityRule(
      id: json['id'] as String,
      providerId: json['provider_id'] as String,
      dayOfWeek: json['day_of_week'] as int,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      isActive: json['is_active'] as bool,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider_id': providerId,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Get the day name in Arabic
  String getDayNameAr() {
    const days = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    return days[dayOfWeek];
  }

  /// Get the day name in French
  String getDayNameFr() {
    const days = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche',
    ];
    return days[dayOfWeek];
  }

  /// Get the localized day name
  String getLocalizedDayName(String language) {
    return language == 'ar' ? getDayNameAr() : getDayNameFr();
  }
}
