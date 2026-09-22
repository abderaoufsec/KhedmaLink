// Provider profile management screen for KhedmaLink Flutter app
// Allows providers to create and edit their profile

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khedmalink/core/models/provider_models.dart';
import 'package:khedmalink/core/services/provider_service.dart' as api;
import 'package:khedmalink/core/analytics/app_logger.dart';
import 'package:khedmalink/shared/widgets/loading_states.dart';
import 'package:khedmalink/shared/widgets/error_states.dart';

/// Provider for current provider profile
final myProviderProfileProvider =
    FutureProvider<ProviderProfile>((ref) async {
  final providerService = api.ProviderApiService();
  return await providerService.getMyProviderProfile();
});

/// Provider profile management screen
class ProviderProfileManagementScreen extends ConsumerStatefulWidget {
  const ProviderProfileManagementScreen({super.key});

  @override
  ConsumerState<ProviderProfileManagementScreen> createState() =>
      _ProviderProfileManagementScreenState();
}

class _ProviderProfileManagementScreenState
    extends ConsumerState<ProviderProfileManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _businessDescriptionArController = TextEditingController();
  final _businessDescriptionFrController = TextEditingController();
  final _yearsExperienceController = TextEditingController();
  final _cityController = TextEditingController();
  final _wilayaController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isPublic = false;
  bool _isAvailable = true;
  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void dispose() {
    _businessNameController.dispose();
    _businessDescriptionArController.dispose();
    _businessDescriptionFrController.dispose();
    _yearsExperienceController.dispose();
    _cityController.dispose();
    _wilayaController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = 'ar'; // Will be from localization provider

    return Scaffold(
      appBar: AppBar(
        title: Text(
          language == 'ar' ? 'إدارة الملف الشخصي' : 'Gestion du profil',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isEditMode
          ? _buildEditForm(context, language)
          : _buildProfileView(context, language),
    );
  }

  /// Build profile view
  Widget _buildProfileView(BuildContext context, String language) {
    final profileAsync = ref.watch(myProviderProfileProvider);

    return profileAsync.when(
      data: (profile) {
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(myProviderProfileProvider);
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Profile header
                _ProfileHeader(
                  profile: profile,
                  language: language,
                  onEdit: () {
                    _loadProfileData(profile);
                    setState(() {
                      _isEditMode = true;
                    });
                  },
                ),
                // Profile details
                _ProfileDetails(
                  profile: profile,
                  language: language,
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const FullScreenLoading(),
      error: (error, stack) {
        AppLogger.error('Profile load error: $error');
        // Show create form if profile doesn't exist
        return _buildCreateForm(context, language);
      },
    );
  }

  /// Build create form for new profile
  Widget _buildCreateForm(BuildContext context, String language) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            language == 'ar' ? 'إنشاء ملف شخصي' : 'Créer un profil',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          _buildFormFields(context, language),
          const SizedBox(height: 24),
          _buildSubmitButton(context, language, isCreate: true),
        ],
      ),
    );
  }

  /// Build edit form
  Widget _buildEditForm(BuildContext context, String language) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            language == 'ar' ? 'تعديل الملف الشخصي' : 'Modifier le profil',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          _buildFormFields(context, language),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildSubmitButton(context, language, isCreate: false),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isEditMode = false;
                    });
                  },
                  child: Text(
                    language == 'ar' ? 'إلغاء' : 'Annuler',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build form fields
  Widget _buildFormFields(BuildContext context, String language) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Business name
          TextFormField(
            controller: _businessNameController,
            decoration: InputDecoration(
              labelText: language == 'ar' ? 'اسم النشاط التجاري' : 'Nom de l\'entreprise',
              hintText: language == 'ar'
                  ? 'أدخل اسم نشاطك التجاري'
                  : 'Entrez le nom de votre entreprise',
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return language == 'ar'
                    ? 'هذا الحقل مطلوب'
                    : 'Ce champ est requis';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Business description in Arabic
          TextFormField(
            controller: _businessDescriptionArController,
            decoration: InputDecoration(
              labelText: language == 'ar' ? 'الوصف بالعربية' : 'Description en arabe',
              hintText: language == 'ar'
                  ? 'وصف نشاطك التجاري بالعربية'
                  : 'Description de votre entreprise en arabe',
              border: const OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          // Business description in French
          TextFormField(
            controller: _businessDescriptionFrController,
            decoration: InputDecoration(
              labelText: language == 'ar' ? 'الوصف بالفرنسية' : 'Description en français',
              hintText: language == 'ar'
                  ? 'وصف نشاطك التجاري بالفرنسية'
                  : 'Description de votre entreprise en français',
              border: const OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          // Years of experience
          TextFormField(
            controller: _yearsExperienceController,
            decoration: InputDecoration(
              labelText: language == 'ar' ? 'سنوات الخبرة' : 'Années d\'expérience',
              hintText: language == 'ar'
                  ? 'عدد سنوات الخبرة'
                  : 'Nombre d\'années d\'expérience',
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final years = int.tryParse(value);
                if (years == null || years < 0) {
                  return language == 'ar'
                      ? 'قيمة غير صالحة'
                      : 'Valeur invalide';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // City
          TextFormField(
            controller: _cityController,
            decoration: InputDecoration(
              labelText: language == 'ar' ? 'المدينة' : 'Ville',
              hintText: language == 'ar' ? 'مدينتك' : 'Votre ville',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          // Wilaya
          TextFormField(
            controller: _wilayaController,
            decoration: InputDecoration(
              labelText: language == 'ar' ? 'الولاية' : 'Wilaya',
              hintText: language == 'ar' ? 'ولايته' : 'Votre wilaya',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          // Address
          TextFormField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: language == 'ar' ? 'العنوان' : 'Adresse',
              hintText: language == 'ar' ? 'عنوانك الكامل' : 'Votre adresse complète',
              border: const OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          // Is public switch
          SwitchListTile(
            title: Text(
              language == 'ar' ? 'جعل الملف عاماً' : 'Rendre le profil public',
            ),
            subtitle: Text(
              language == 'ar'
                  ? 'سيتمكن العملاء من رؤية ملفك الشخصي'
                  : 'Les clients pourront voir votre profil',
            ),
            value: _isPublic,
            onChanged: (value) {
              setState(() {
                _isPublic = value;
              });
            },
          ),
          const SizedBox(height: 8),
          // Is available switch
          SwitchListTile(
            title: Text(
              language == 'ar' ? 'متاح للعمل' : 'Disponible pour le travail',
            ),
            subtitle: Text(
              language == 'ar'
                  ? 'سيتمكن العملاء من إرسال طلبات إليك'
                  : 'Les clients pourront vous envoyer des demandes',
            ),
            value: _isAvailable,
            onChanged: (value) {
              setState(() {
                _isAvailable = value;
              });
            },
          ),
        ],
      ),
    );
  }

  /// Build submit button
  Widget _buildSubmitButton(BuildContext context, String language,
      {required bool isCreate}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : () {
                if (_formKey.currentState!.validate()) {
                  _submitProfile(context, language, isCreate: isCreate);
                }
              },
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                isCreate
                    ? (language == 'ar' ? 'إنشاء' : 'Créer')
                    : (language == 'ar' ? 'حفظ التغييرات' : 'Enregistrer'),
              ),
      ),
    );
  }

  /// Load profile data into form
  void _loadProfileData(ProviderProfile profile) {
    _businessNameController.text = profile.businessName ?? '';
    _businessDescriptionArController.text =
        profile.businessDescriptionAr ?? '';
    _businessDescriptionFrController.text =
        profile.businessDescriptionFr ?? '';
    _yearsExperienceController.text =
        profile.yearsExperience?.toString() ?? '';
    _cityController.text = profile.city ?? '';
    _wilayaController.text = profile.wilaya ?? '';
    _addressController.text = profile.address ?? '';
    _isPublic = profile.isPublic;
    _isAvailable = profile.isAvailable;
  }

  /// Submit profile
  Future<void> _submitProfile(BuildContext context, String language,
      {required bool isCreate}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final providerService = api.ProviderApiService();

      final yearsExperience = _yearsExperienceController.text.isEmpty
          ? null
          : int.tryParse(_yearsExperienceController.text);

      if (isCreate) {
        await providerService.createProviderProfile(
          businessName: _businessNameController.text,
          businessDescriptionAr: _businessDescriptionArController.text,
          businessDescriptionFr: _businessDescriptionFrController.text,
          yearsExperience: yearsExperience,
          city: _cityController.text,
          wilaya: _wilayaController.text,
          address: _addressController.text,
        );
      } else {
        await providerService.updateProviderProfile(
          businessName: _businessNameController.text,
          businessDescriptionAr: _businessDescriptionArController.text,
          businessDescriptionFr: _businessDescriptionFrController.text,
          yearsExperience: yearsExperience,
          city: _cityController.text,
          wilaya: _wilayaController.text,
          address: _addressController.text,
          isPublic: _isPublic,
          isAvailable: _isAvailable,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isCreate
                  ? (language == 'ar'
                      ? 'تم إنشاء الملف الشخصي بنجاح'
                      : 'Profil créé avec succès')
                  : (language == 'ar'
                      ? 'تم تحديث الملف الشخصي بنجاح'
                      : 'Profil mis à jour avec succès'),
            ),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          _isEditMode = false;
          _isLoading = false;
        });

        // Refresh profile data
        ref.invalidate(myProviderProfileProvider);
      }
    } catch (e) {
      AppLogger.error('Profile submission error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              language == 'ar'
                  ? 'فشل: ${e.toString()}'
                  : 'Échec: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

/// Profile header widget
class _ProfileHeader extends StatelessWidget {
  final ProviderProfile profile;
  final String language;
  final VoidCallback onEdit;

  const _ProfileHeader({
    required this.profile,
    required this.language,
    required this.onEdit,
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
        children: [
          // Business name
          Text(
            profile.businessName ??
                (language == 'ar' ? 'مزود خدمة' : 'Fournisseur'),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          // Verification badge
          if (profile.isVerified)
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
          const SizedBox(height: 16),
          // Edit button
          OutlinedButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit),
            label: Text(
              language == 'ar' ? 'تعديل الملف' : 'Modifier le profil',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

/// Profile details widget
class _ProfileDetails extends StatelessWidget {
  final ProviderProfile profile;
  final String language;

  const _ProfileDetails({
    required this.profile,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          if (profile.getLocalizedDescription(language) != null)
            _DetailSection(
              icon: Icons.description_outlined,
              title: language == 'ar' ? 'الوصف' : 'Description',
              content: profile.getLocalizedDescription(language)!,
            ),
          // Experience
          if (profile.yearsExperience != null)
            _DetailSection(
              icon: Icons.workspace_premium_outlined,
              title: language == 'ar' ? 'سنوات الخبرة' : 'Années d\'expérience',
              content: '${profile.yearsExperience} ${language == 'ar' ? 'سنة' : 'ans'}',
            ),
          // Location
          if (profile.city != null || profile.wilaya != null)
            _DetailSection(
              icon: Icons.location_on_outlined,
              title: language == 'ar' ? 'الموقع' : 'Emplacement',
              content: '${profile.wilaya ?? ''} ${profile.city ?? ''}',
            ),
          // Stats
          _StatsRow(
            profile: profile,
            language: language,
          ),
          // Status badges
          _StatusBadges(
            profile: profile,
            language: language,
          ),
        ],
      ),
    );
  }
}

/// Detail section widget
class _DetailSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _DetailSection({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stats row widget
class _StatsRow extends StatelessWidget {
  final ProviderProfile profile;
  final String language;

  const _StatsRow({
    required this.profile,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(
              icon: Icons.star,
              value: profile.ratingAverage.toStringAsFixed(1),
              label: language == 'ar' ? 'التقييم' : 'Note',
            ),
            _StatItem(
              icon: Icons.reviews,
              value: profile.ratingCount.toString(),
              label: language == 'ar' ? 'المراجعات' : 'Avis',
            ),
            _StatItem(
              icon: Icons.work,
              value: profile.completedJobs.toString(),
              label: language == 'ar' ? 'المهام' : 'Tâches',
            ),
          ],
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

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
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

/// Status badges widget
class _StatusBadges extends StatelessWidget {
  final ProviderProfile profile;
  final String language;

  const _StatusBadges({
    required this.profile,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Public status
            Chip(
              label: Text(
                profile.isPublic
                    ? (language == 'ar' ? 'عام' : 'Public')
                    : (language == 'ar' ? 'خاص' : 'Privé'),
              ),
              backgroundColor: profile.isPublic
                  ? Colors.green.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
            ),
            const SizedBox(width: 8),
            // Available status
            Chip(
              label: Text(
                profile.isAvailable
                    ? (language == 'ar' ? 'متاح' : 'Disponible')
                    : (language == 'ar' ? 'غير متاح' : 'Indisponible'),
              ),
              backgroundColor: profile.isAvailable
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
            ),
          ],
        ),
      ),
    );
  }
}
