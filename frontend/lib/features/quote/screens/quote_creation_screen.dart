// Quote creation screen for KhedmaLink Flutter app
// Allows providers to create quotes for service requests

import 'package:flutter/material.dart';
import 'package:khedmalink/core/services/quote_service.dart' as api;
import 'package:khedmalink/core/analytics/app_logger.dart';

/// Quote creation screen for provider
class QuoteCreationScreen extends StatefulWidget {
  final String requestId;

  const QuoteCreationScreen({super.key, required this.requestId});

  @override
  State<QuoteCreationScreen> createState() => _QuoteCreationScreenState();
}

class _QuoteCreationScreenState extends State<QuoteCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _estimatedPriceController = TextEditingController();
  final _estimatedDurationController = TextEditingController();

  String? _estimatedDurationUnit;
  DateTime? _availableDate;
  bool _isLoading = false;

  String get language => 'ar'; // Will be from localization provider

  @override
  void dispose() {
    _descriptionController.dispose();
    _estimatedPriceController.dispose();
    _estimatedDurationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          language == 'ar' ? 'إنشاء عرض' : 'Créer un devis',
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
              // Estimated price
              TextFormField(
                controller: _estimatedPriceController,
                decoration: InputDecoration(
                  labelText: language == 'ar' ? 'السعر المقدر' : 'Prix estimé',
                  border: const OutlineInputBorder(),
                  prefixText: 'DZD ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return language == 'ar' ? 'هذا الحقل مطلوب' : 'This field is required';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price <= 0) {
                    return language == 'ar' ? 'السعر يجب أن يكون موجباً' : 'Price must be positive';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Estimated duration
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _estimatedDurationController,
                      decoration: InputDecoration(
                        labelText: language == 'ar' ? 'المدة المقدرة' : 'Durée estimée',
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _estimatedDurationUnit,
                      decoration: InputDecoration(
                        labelText: language == 'ar' ? 'الوحدة' : 'Unité',
                        border: const OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'minutes', child: Text('Minutes')),
                        DropdownMenuItem(value: 'hours', child: Text('Hours')),
                        DropdownMenuItem(value: 'days', child: Text('Days')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _estimatedDurationUnit = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Available date
              ListTile(
                title: Text(
                  language == 'ar' ? 'التاريخ المتاح' : 'Date disponible',
                ),
                subtitle: Text(
                  _availableDate != null
                      ? _availableDate.toString().split(' ')[0]
                      : (language == 'ar' ? 'اختر تاريخ' : 'Choisir une date'),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),
              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitQuote,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          language == 'ar' ? 'إرسال العرض' : 'Envoyer le devis',
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
        _availableDate = picked;
      });
    }
  }

  Future<void> _submitQuote() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final quoteService = api.QuoteApiService();
      
      final estimatedPrice = double.tryParse(_estimatedPriceController.text);
      final estimatedDuration = _estimatedDurationController.text.isEmpty
          ? null
          : int.tryParse(_estimatedDurationController.text);

      await quoteService.createQuote(
        requestId: widget.requestId,
        description: _descriptionController.text,
        estimatedPrice: estimatedPrice!,
        estimatedDuration: estimatedDuration,
        estimatedDurationUnit: _estimatedDurationUnit,
        availableDate: _availableDate,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              language == 'ar' ? 'تم إنشاء العرض بنجاح' : 'Devis créé avec succès',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      AppLogger.error('Create quote error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              language == 'ar' ? 'فشل إنشاء العرض: $e' : 'Échec de la création du devis: $e',
            ),
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
