// Provider API service for KhedmaLink Flutter app
// Handles API communication for provider and category operations

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:khedmalink/core/config/app_config.dart';
import 'package:khedmalink/core/analytics/app_logger.dart';
import 'package:khedmalink/core/models/provider_models.dart';
import 'package:khedmalink/core/services/auth_service.dart';

/// Provider API service for handling categories and provider API operations
class ProviderApiService {
  final http.Client _client;
  final AuthService _authService;

  // Cache keys
  static const String _categoriesCacheKey = 'categories_cache';
  static const String _categoriesCacheTimeKey = 'categories_cache_time';

  /// Constructor
  ProviderApiService({http.Client? client, AuthService? authService})
      : _client = client ?? http.Client(),
        _authService = authService ?? AuthService();

  /// Get base URL from config
  String get _baseUrl => AppConfig.apiBaseUrlDirect;

  /// Get authorization headers
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      return {'Content-Type': 'application/json'};
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // =============================================================================
  // CATEGORY METHODS
  // =============================================================================

  /// List all categories
  Future<List<Category>> listCategories({
    bool activeOnly = true,
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      AppLogger.info('Fetching categories');

      final response = await _client.get(
        Uri.parse('$_baseUrl/api/v1/categories'),
        headers: await _getAuthHeaders(),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        final categories =
            data.map((item) => Category.fromJson(item as Map<String, dynamic>))
                .toList();

        // Cache categories
        await _cacheCategories(categories);

        AppLogger.info('Categories fetched successfully: ${categories.length}');
        return categories;
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to fetch categories: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to fetch categories');
      }
    } catch (e) {
      AppLogger.error('Fetch categories error: $e');
      rethrow;
    }
  }

  /// Get a specific category by ID
  Future<Category> getCategory(String categoryId) async {
    try {
      AppLogger.info('Fetching category: $categoryId');

      final response = await _client.get(
        Uri.parse('$_baseUrl/api/v1/categories/$categoryId'),
        headers: await _getAuthHeaders(),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final category = Category.fromJson(data);

        AppLogger.info('Category fetched successfully: ${category.id}');
        return category;
      } else if (response.statusCode == 404) {
        AppLogger.error('Category not found: $categoryId');
        throw Exception('Category not found');
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to fetch category: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to fetch category');
      }
    } catch (e) {
      AppLogger.error('Fetch category error: $e');
      rethrow;
    }
  }

  /// Get cached categories
  Future<List<Category>?> getCachedCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheTime = prefs.getInt(_categoriesCacheTimeKey);

      // Cache is valid for 1 hour
      if (cacheTime != null &&
          DateTime.now().millisecondsSinceEpoch - cacheTime < 3600000) {
        final cacheString = prefs.getString(_categoriesCacheKey);
        if (cacheString != null) {
          final data = jsonDecode(cacheString) as List;
          return data
              .map((item) => Category.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
      return null;
    } catch (e) {
      AppLogger.error('Get cached categories error: $e');
      return null;
    }
  }

  /// Cache categories
  Future<void> _cacheCategories(List<Category> categories) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheString = jsonEncode(
        categories.map((c) => c.toJson()).toList(),
      );
      await prefs.setString(_categoriesCacheKey, cacheString);
      await prefs.setInt(
        _categoriesCacheTimeKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      AppLogger.error('Cache categories error: $e');
    }
  }

  // =============================================================================
  // PROVIDER DISCOVERY METHODS
  // =============================================================================

  /// List public providers with optional filters
  Future<List<ProviderProfile>> listProviders({
    int skip = 0,
    int limit = 100,
    String? categoryId,
    String? city,
    String? wilaya,
    bool verifiedOnly = true,
    bool availableOnly = true,
  }) async {
    try {
      AppLogger.info('Fetching providers with filters');

      // Build query parameters
      final queryParams = <String, String>{
        'skip': skip.toString(),
        'limit': limit.toString(),
        'verified_only': verifiedOnly.toString(),
        'available_only': availableOnly.toString(),
      };

      if (categoryId != null) {
        queryParams['category_id'] = categoryId;
      }
      if (city != null) {
        queryParams['city'] = city;
      }
      if (wilaya != null) {
        queryParams['wilaya'] = wilaya;
      }

      final uri = Uri.parse('$_baseUrl/api/v1/providers')
          .replace(queryParameters: queryParams);

      final response = await _client.get(
        uri,
        headers: await _getAuthHeaders(),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        final providers =
            data.map((item) => ProviderProfile.fromJson(item as Map<String, dynamic>))
                .toList();

        AppLogger.info('Providers fetched successfully: ${providers.length}');
        return providers;
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to fetch providers: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to fetch providers');
      }
    } catch (e) {
      AppLogger.error('Fetch providers error: $e');
      rethrow;
    }
  }

  /// Get a specific provider profile by ID
  Future<ProviderProfile> getProviderProfile(String providerId) async {
    try {
      AppLogger.info('Fetching provider profile: $providerId');

      final response = await _client.get(
        Uri.parse('$_baseUrl/api/v1/providers/$providerId'),
        headers: await _getAuthHeaders(),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final provider = ProviderProfile.fromJson(data);

        AppLogger.info('Provider profile fetched successfully: ${provider.id}');
        return provider;
      } else if (response.statusCode == 404) {
        AppLogger.error('Provider profile not found: $providerId');
        throw Exception('Provider profile not found');
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to fetch provider profile: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to fetch provider profile');
      }
    } catch (e) {
      AppLogger.error('Fetch provider profile error: $e');
      rethrow;
    }
  }

  // =============================================================================
  // PROVIDER PROFILE MANAGEMENT METHODS
  // =============================================================================

  /// Get current user's provider profile
  Future<ProviderProfile> getMyProviderProfile() async {
    try {
      AppLogger.info('Fetching my provider profile');

      final response = await _client.get(
        Uri.parse('$_baseUrl/api/v1/providers/me/profile'),
        headers: await _getAuthHeaders(),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final profile = ProviderProfile.fromJson(data);

        AppLogger.info('My provider profile fetched successfully: ${profile.id}');
        return profile;
      } else if (response.statusCode == 404) {
        AppLogger.error('Provider profile not found');
        throw Exception('Provider profile not found. Please create a profile first.');
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to fetch provider profile: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to fetch provider profile');
      }
    } catch (e) {
      AppLogger.error('Fetch my provider profile error: $e');
      rethrow;
    }
  }

  /// Create a provider profile for the current user
  Future<ProviderProfile> createProviderProfile({
    String? businessName,
    String? businessDescriptionAr,
    String? businessDescriptionFr,
    int? yearsExperience,
    String? city,
    String? wilaya,
    String? address,
  }) async {
    try {
      AppLogger.info('Creating provider profile');

      final response = await _client.post(
        Uri.parse('$_baseUrl/api/v1/providers/me/profile'),
        headers: await _getAuthHeaders(),
        body: jsonEncode({
          if (businessName?.isNotEmpty == true) 'business_name': businessName,
          if (businessDescriptionAr?.isNotEmpty == true)
            'business_description_ar': businessDescriptionAr,
          if (businessDescriptionFr?.isNotEmpty == true)
            'business_description_fr': businessDescriptionFr,
          if (yearsExperience != null) 'years_experience': yearsExperience,
          if (city?.isNotEmpty == true) 'city': city,
          if (wilaya?.isNotEmpty == true) 'wilaya': wilaya,
          if (address?.isNotEmpty == true) 'address': address,
        }),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final profile = ProviderProfile.fromJson(data);

        AppLogger.info('Provider profile created successfully: ${profile.id}');
        return profile;
      } else if (response.statusCode == 400) {
        AppLogger.error('Provider profile already exists');
        throw Exception('Provider profile already exists');
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to create provider profile: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to create provider profile');
      }
    } catch (e) {
      AppLogger.error('Create provider profile error: $e');
      rethrow;
    }
  }

  /// Update current user's provider profile
  Future<ProviderProfile> updateProviderProfile({
    String? businessName,
    String? businessDescriptionAr,
    String? businessDescriptionFr,
    int? yearsExperience,
    String? city,
    String? wilaya,
    String? address,
    bool? isPublic,
    bool? isAvailable,
  }) async {
    try {
      AppLogger.info('Updating provider profile');

      final response = await _client.put(
        Uri.parse('$_baseUrl/api/v1/providers/me/profile'),
        headers: await _getAuthHeaders(),
        body: jsonEncode({
          if (businessName?.isNotEmpty == true) 'business_name': businessName,
          if (businessDescriptionAr?.isNotEmpty == true)
            'business_description_ar': businessDescriptionAr,
          if (businessDescriptionFr?.isNotEmpty == true)
            'business_description_fr': businessDescriptionFr,
          if (yearsExperience != null) 'years_experience': yearsExperience,
          if (city?.isNotEmpty == true) 'city': city,
          if (wilaya?.isNotEmpty == true) 'wilaya': wilaya,
          if (address?.isNotEmpty == true) 'address': address,
          if (isPublic != null) 'is_public': isPublic,
          if (isAvailable != null) 'is_available': isAvailable,
        }),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final profile = ProviderProfile.fromJson(data);

        AppLogger.info('Provider profile updated successfully: ${profile.id}');
        return profile;
      } else if (response.statusCode == 404) {
        AppLogger.error('Provider profile not found');
        throw Exception('Provider profile not found');
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to update provider profile: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to update provider profile');
      }
    } catch (e) {
      AppLogger.error('Update provider profile error: $e');
      rethrow;
    }
  }

  // =============================================================================
  // PROVIDER SERVICES METHODS
  // =============================================================================

  /// List current provider's services
  Future<List<ProviderServiceModel>> listMyServices() async {
    try {
      AppLogger.info('Fetching my services');

      final response = await _client.get(
        Uri.parse('$_baseUrl/api/v1/providers/me/services'),
        headers: await _getAuthHeaders(),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        final services =
            data.map((item) => ProviderServiceModel.fromJson(item as Map<String, dynamic>))
                .toList();

        AppLogger.info('My services fetched successfully: ${services.length}');
        return services;
      } else if (response.statusCode == 404) {
        AppLogger.error('Provider profile not found');
        throw Exception('Provider profile not found');
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to fetch services: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to fetch services');
      }
    } catch (e) {
      AppLogger.error('Fetch my services error: $e');
      rethrow;
    }
  }

  /// Create a new service for the current provider
  Future<ProviderServiceModel> createService({
    required String categoryId,
    required String titleAr,
    required String titleFr,
    String? descriptionAr,
    String? descriptionFr,
    double? basePrice,
    String? priceUnit,
  }) async {
    try {
      AppLogger.info('Creating service');

      final response = await _client.post(
        Uri.parse('$_baseUrl/api/v1/providers/me/services'),
        headers: await _getAuthHeaders(),
        body: jsonEncode({
          'category_id': categoryId,
          'title_ar': titleAr,
          'title_fr': titleFr,
          if (descriptionAr?.isNotEmpty == true) 'description_ar': descriptionAr,
          if (descriptionFr?.isNotEmpty == true) 'description_fr': descriptionFr,
          if (basePrice != null) 'base_price': basePrice,
          if (priceUnit?.isNotEmpty == true) 'price_unit': priceUnit,
        }),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final service = ProviderServiceModel.fromJson(data);

        AppLogger.info('Service created successfully: ${service.id}');
        return service;
      } else if (response.statusCode == 400) {
        AppLogger.error('Provider already has a service for this category');
        throw Exception('Provider already has a service for this category');
      } else if (response.statusCode == 404) {
        AppLogger.error('Category not found');
        throw Exception('Category not found');
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to create service: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to create service');
      }
    } catch (e) {
      AppLogger.error('Create service error: $e');
      rethrow;
    }
  }

  /// Update a service
  Future<ProviderServiceModel> updateService(
    String serviceId, {
    String? titleAr,
    String? titleFr,
    String? descriptionAr,
    String? descriptionFr,
    double? basePrice,
    String? priceUnit,
    bool? isActive,
  }) async {
    try {
      AppLogger.info('Updating service: $serviceId');

      final response = await _client.put(
        Uri.parse('$_baseUrl/api/v1/providers/me/services/$serviceId'),
        headers: await _getAuthHeaders(),
        body: jsonEncode({
          if (titleAr?.isNotEmpty == true) 'title_ar': titleAr,
          if (titleFr?.isNotEmpty == true) 'title_fr': titleFr,
          if (descriptionAr?.isNotEmpty == true) 'description_ar': descriptionAr,
          if (descriptionFr?.isNotEmpty == true) 'description_fr': descriptionFr,
          if (basePrice != null) 'base_price': basePrice,
          if (priceUnit?.isNotEmpty == true) 'price_unit': priceUnit,
          if (isActive != null) 'is_active': isActive,
        }),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final service = ProviderServiceModel.fromJson(data);

        AppLogger.info('Service updated successfully: ${service.id}');
        return service;
      } else if (response.statusCode == 404) {
        AppLogger.error('Service not found');
        throw Exception('Service not found');
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to update service: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to update service');
      }
    } catch (e) {
      AppLogger.error('Update service error: $e');
      rethrow;
    }
  }

  /// Delete a service
  Future<void> deleteService(String serviceId) async {
    try {
      AppLogger.info('Deleting service: $serviceId');

      final response = await _client.delete(
        Uri.parse('$_baseUrl/api/v1/providers/me/services/$serviceId'),
        headers: await _getAuthHeaders(),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 204) {
        AppLogger.info('Service deleted successfully: $serviceId');
      } else if (response.statusCode == 404) {
        AppLogger.error('Service not found');
        throw Exception('Service not found');
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to delete service: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to delete service');
      }
    } catch (e) {
      AppLogger.error('Delete service error: $e');
      rethrow;
    }
  }

  // =============================================================================
  // SERVICE AREA METHODS
  // =============================================================================

  /// List current provider's service areas
  Future<List<ServiceArea>> listMyServiceAreas() async {
    try {
      AppLogger.info('Fetching my service areas');

      final response = await _client.get(
        Uri.parse('$_baseUrl/api/v1/providers/me/service-areas'),
        headers: await _getAuthHeaders(),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        final areas =
            data.map((item) => ServiceArea.fromJson(item as Map<String, dynamic>))
                .toList();

        AppLogger.info('My service areas fetched successfully: ${areas.length}');
        return areas;
      } else if (response.statusCode == 404) {
        AppLogger.error('Provider profile not found');
        throw Exception('Provider profile not found');
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to fetch service areas: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to fetch service areas');
      }
    } catch (e) {
      AppLogger.error('Fetch my service areas error: $e');
      rethrow;
    }
  }

  /// Create a new service area
  Future<ServiceArea> createServiceArea({
    required String city,
    required String wilaya,
    String? commune,
    String? addressDetails,
    double? latitude,
    double? longitude,
    double? radiusKm,
  }) async {
    try {
      AppLogger.info('Creating service area');

      final response = await _client.post(
        Uri.parse('$_baseUrl/api/v1/providers/me/service-areas'),
        headers: await _getAuthHeaders(),
        body: jsonEncode({
          'city': city,
          'wilaya': wilaya,
          if (commune?.isNotEmpty == true) 'commune': commune,
          if (addressDetails?.isNotEmpty == true) 'address_details': addressDetails,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
          if (radiusKm != null) 'radius_km': radiusKm,
        }),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final area = ServiceArea.fromJson(data);

        AppLogger.info('Service area created successfully: ${area.id}');
        return area;
      } else if (response.statusCode == 404) {
        AppLogger.error('Provider profile not found');
        throw Exception('Provider profile not found');
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to create service area: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to create service area');
      }
    } catch (e) {
      AppLogger.error('Create service area error: $e');
      rethrow;
    }
  }

  /// Update a service area
  Future<ServiceArea> updateServiceArea(
    String areaId, {
    String? city,
    String? wilaya,
    String? commune,
    String? addressDetails,
    double? latitude,
    double? longitude,
    double? radiusKm,
    bool? isActive,
  }) async {
    try {
      AppLogger.info('Updating service area: $areaId');

      final response = await _client.put(
        Uri.parse('$_baseUrl/api/v1/providers/me/service-areas/$areaId'),
        headers: await _getAuthHeaders(),
        body: jsonEncode({
          if (city?.isNotEmpty == true) 'city': city,
          if (wilaya?.isNotEmpty == true) 'wilaya': wilaya,
          if (commune?.isNotEmpty == true) 'commune': commune,
          if (addressDetails?.isNotEmpty == true) 'address_details': addressDetails,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
          if (radiusKm != null) 'radius_km': radiusKm,
          if (isActive != null) 'is_active': isActive,
        }),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final area = ServiceArea.fromJson(data);

        AppLogger.info('Service area updated successfully: ${area.id}');
        return area;
      } else if (response.statusCode == 404) {
        AppLogger.error('Service area not found');
        throw Exception('Service area not found');
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to update service area: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to update service area');
      }
    } catch (e) {
      AppLogger.error('Update service area error: $e');
      rethrow;
    }
  }

  /// Delete a service area
  Future<void> deleteServiceArea(String areaId) async {
    try {
      AppLogger.info('Deleting service area: $areaId');

      final response = await _client.delete(
        Uri.parse('$_baseUrl/api/v1/providers/me/service-areas/$areaId'),
        headers: await _getAuthHeaders(),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 204) {
        AppLogger.info('Service area deleted successfully: $areaId');
      } else if (response.statusCode == 404) {
        AppLogger.error('Service area not found');
        throw Exception('Service area not found');
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to delete service area: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to delete service area');
      }
    } catch (e) {
      AppLogger.error('Delete service area error: $e');
      rethrow;
    }
  }

  // =============================================================================
  // AVAILABILITY RULE METHODS
  // =============================================================================

  /// List current provider's availability rules
  Future<List<AvailabilityRule>> listMyAvailability() async {
    try {
      AppLogger.info('Fetching my availability rules');

      final response = await _client.get(
        Uri.parse('$_baseUrl/api/v1/providers/me/availability'),
        headers: await _getAuthHeaders(),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        final rules =
            data.map((item) => AvailabilityRule.fromJson(item as Map<String, dynamic>))
                .toList();

        AppLogger.info('My availability rules fetched successfully: ${rules.length}');
        return rules;
      } else if (response.statusCode == 404) {
        AppLogger.error('Provider profile not found');
        throw Exception('Provider profile not found');
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to fetch availability rules: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to fetch availability rules');
      }
    } catch (e) {
      AppLogger.error('Fetch my availability error: $e');
      rethrow;
    }
  }

  /// Create a new availability rule
  Future<AvailabilityRule> createAvailabilityRule({
    required int dayOfWeek,
    required String startTime,
    required String endTime,
  }) async {
    try {
      AppLogger.info('Creating availability rule');

      final response = await _client.post(
        Uri.parse('$_baseUrl/api/v1/providers/me/availability'),
        headers: await _getAuthHeaders(),
        body: jsonEncode({
          'day_of_week': dayOfWeek,
          'start_time': startTime,
          'end_time': endTime,
        }),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final rule = AvailabilityRule.fromJson(data);

        AppLogger.info('Availability rule created successfully: ${rule.id}');
        return rule;
      } else if (response.statusCode == 404) {
        AppLogger.error('Provider profile not found');
        throw Exception('Provider profile not found');
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to create availability rule: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to create availability rule');
      }
    } catch (e) {
      AppLogger.error('Create availability rule error: $e');
      rethrow;
    }
  }

  /// Update an availability rule
  Future<AvailabilityRule> updateAvailabilityRule(
    String ruleId, {
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    bool? isActive,
  }) async {
    try {
      AppLogger.info('Updating availability rule: $ruleId');

      final response = await _client.put(
        Uri.parse('$_baseUrl/api/v1/providers/me/availability/$ruleId'),
        headers: await _getAuthHeaders(),
        body: jsonEncode({
          if (dayOfWeek != null) 'day_of_week': dayOfWeek,
          if (startTime?.isNotEmpty == true) 'start_time': startTime,
          if (endTime?.isNotEmpty == true) 'end_time': endTime,
          if (isActive != null) 'is_active': isActive,
        }),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final rule = AvailabilityRule.fromJson(data);

        AppLogger.info('Availability rule updated successfully: ${rule.id}');
        return rule;
      } else if (response.statusCode == 404) {
        AppLogger.error('Availability rule not found');
        throw Exception('Availability rule not found');
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to update availability rule: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to update availability rule');
      }
    } catch (e) {
      AppLogger.error('Update availability rule error: $e');
      rethrow;
    }
  }

  /// Delete an availability rule
  Future<void> deleteAvailabilityRule(String ruleId) async {
    try {
      AppLogger.info('Deleting availability rule: $ruleId');

      final response = await _client.delete(
        Uri.parse('$_baseUrl/api/v1/providers/me/availability/$ruleId'),
        headers: await _getAuthHeaders(),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 204) {
        AppLogger.info('Availability rule deleted successfully: $ruleId');
      } else if (response.statusCode == 404) {
        AppLogger.error('Availability rule not found');
        throw Exception('Availability rule not found');
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        AppLogger.error('Failed to delete availability rule: ${error?['detail'] ?? 'Unknown error'}');
        throw Exception(error?['detail'] ?? 'Failed to delete availability rule');
      }
    } catch (e) {
      AppLogger.error('Delete availability rule error: $e');
      rethrow;
    }
  }
}
