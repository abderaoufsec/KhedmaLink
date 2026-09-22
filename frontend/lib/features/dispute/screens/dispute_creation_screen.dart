// Dispute creation screen for KhedmaLink Flutter app
// Allows customers and providers to create disputes for bookings

import 'package:flutter/material.dart';
import 'package:khedmalink/core/models/dispute_models.dart';
import 'package:khedmalink/core/services/dispute_service.dart' as api;
import 'package:khedmalink/core/analytics/app_logger.dart';

/// Dispute creation screen
class DisputeCreationScreen extends StatefulWidget {
  final String bookingId;

  const DisputeCreationScreen({super.key, required this.bookingId});

  @override
  State<DisputeCreationScreen> createState() => _DisputeCreationScreenState();
}

class _DisputeCreationScreenState extends State<DisputeCreationScreen> {
  final _disputeService = api.DisputeApiService();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DisputeType _selectedType = DisputeType.other;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitDispute() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _disputeService.createDispute(
        bookingId: widget.bookingId,
        disputeType: _selectedType,
        title: _titleController.text,
        description: _descriptionController.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dispute created successfully')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      AppLogger.error('Error creating dispute: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode == 'ar' ? 'ar' : 'fr';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          language == 'ar' ? 'إنشاء نزاع' : 'Create Dispute',
        ),
      ),
      body: _buildBody(context, language),
    );
  }

  Widget _buildBody(BuildContext context, String language) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _error!,
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            DropdownButtonFormField<DisputeType>(
              initialValue: _selectedType,
              decoration: InputDecoration(
                labelText: language == 'ar' ? 'نوع النزاع' : 'Dispute Type',
                border: const OutlineInputBorder(),
              ),
              items: DisputeType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.getDisplayName(language)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
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
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: language == 'ar' ? 'العنوان' : 'Title',
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
            TextFormField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: language == 'ar' ? 'الوصف' : 'Description',
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return language == 'ar' ? 'هذا الحقل مطلوب' : 'This field is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitDispute,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Text(language == 'ar' ? 'إرسال' : 'Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
