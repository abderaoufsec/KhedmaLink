// Simple create request screen for KhedmaLink Flutter app
// Allows customers to create service requests

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:khedmalink/core/services/request_service.dart' as api;
import 'package:khedmalink/core/analytics/app_logger.dart';

/// Simple create request screen
class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cityController = TextEditingController();
  final _wilayaController = TextEditingController();
  final _addressController = TextEditingController();
  final _budgetMinController = TextEditingController();
  final _budgetMaxController = TextEditingController();

  String? _selectedCategory;
  DateTime? _preferredDate;
  bool _isFlexible = false;
  String _urgency = 'medium';
  bool _isLoading = false;

  String get language => 'ar'; // Will be from localization provider

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _wilayaController.dispose();
    _addressController.dispose();
    _budgetMinController.dispose();
    _budgetMaxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          language == 'ar' ? 'إنشاء طلب خدمة' : 'Créer une demande de service',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category selection
              Text(
                language == 'ar' ? 'الفئة' : 'Catégorie',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Select category',
                ),
                items: const [
                  DropdownMenuItem(value: '1', child: Text('Appliance Repair')),
                  DropdownMenuItem(value: '2', child: Text('AC Service')),
                  DropdownMenuItem(value: '3', child: Text('Cleaning')),
                  DropdownMenuItem(value: '4', child: Text('Maintenance')),
                  DropdownMenuItem(value: '5', child: Text('Plumbing')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return language == 'ar' ? 'هذا الحقل مطلوب' : 'This field is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: language == 'ar' ? 'العنوان' : 'Titre',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return language == 'ar' ? 'هذا الحقل مطلوب' : 'This field is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: language == 'ar' ? 'الوصف' : 'Description',
                  border: const OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return language == 'ar' ? 'هذا الحقل مطلوب' : 'This field is required';
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
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return language == 'ar' ? 'هذا الحقل مطلوب' : 'This field is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Wilaya
              TextFormField(
                controller: _wilayaController,
                decoration: InputDecoration(
                  labelText: language == 'ar' ? 'الولاية' : 'Wilaya',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return language == 'ar' ? 'هذا الحقل مطلوب' : 'This field is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Address
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: language == 'ar' ? 'العنوان' : 'Adresse',
                  border: const OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              // Preferred date
              ListTile(
                title: Text(
                  language == 'ar' ? 'التاريخ المفضل' : 'Date préférée',
                ),
                subtitle: Text(
                  _preferredDate != null
                      ? _preferredDate.toString().split(' ')[0]
                      : (language == 'ar' ? 'اختر تاريخ' : 'Choisir une date'),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),
              // Flexible schedule
              SwitchListTile(
                title: Text(
                  language == 'ar' ? 'جدول مرن' : 'Horaire flexible',
                ),
                subtitle: Text(
                  language == 'ar'
                      ? 'أنا مرن بخصوص الوقت'
                      : 'Je suis flexible sur l\'horaire',
                ),
                value: _isFlexible,
                onChanged: (value) {
                  setState(() {
                    _isFlexible = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Urgency
              Text(
                language == 'ar' ? 'الاستعجال' : 'Urgence',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'low',
                    label: Text('Low'),
                  ),
                  ButtonSegment(
                    value: 'medium',
                    label: Text('Medium'),
                  ),
                  ButtonSegment(
                    value: 'high',
                    label: Text('High'),
                  ),
                  ButtonSegment(
                    value: 'urgent',
                    label: Text('Urgent'),
                  ),
                ],
                selected: {_urgency},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _urgency = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Budget (optional)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _budgetMinController,
                      decoration: InputDecoration(
                        labelText: language == 'ar' ? 'الحد الأدنى للميزانية' : 'Budget min',
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _budgetMaxController,
                      decoration: InputDecoration(
                        labelText: language == 'ar' ? 'الحد الأقصى للميزانية' : 'Budget max',
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitRequest,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          language == 'ar' ? 'إرسال الطلب' : 'Envoyer la demande',
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null && mounted) {
      setState(() {
        _preferredDate = picked;
      });
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final requestService = api.RequestApiService();
      
      final budgetMin = _budgetMinController.text.isEmpty
          ? null
          : double.tryParse(_budgetMinController.text);
      final budgetMax = _budgetMaxController.text.isEmpty
          ? null
          : double.tryParse(_budgetMaxController.text);

      await requestService.createServiceRequest(
        categoryId: _selectedCategory!,
        titleAr: _titleController.text,
        titleFr: _titleController.text, // Simplified: using same text for both
        descriptionAr: _descriptionController.text,
        descriptionFr: _descriptionController.text, // Simplified
        city: _cityController.text,
        wilaya: _wilayaController.text,
        address: _addressController.text,
        preferredDate: _preferredDate,
        isFlexible: _isFlexible,
        budgetMin: budgetMin,
        budgetMax: budgetMax,
        urgency: _urgency,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              language == 'ar' ? 'تم إنشاء الطلب بنجاح' : 'Service request created successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/requests');
      }
    } catch (e) {
      AppLogger.error('Create request error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
