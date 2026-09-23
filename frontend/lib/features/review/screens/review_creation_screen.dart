// Review creation screen for KhedmaLink Flutter app
// Allows customers to review completed bookings

import 'package:flutter/material.dart';
import 'package:khedmalink/core/services/review_service.dart' as api;
import 'package:khedmalink/core/analytics/app_logger.dart';

/// Review creation screen
class ReviewCreationScreen extends StatefulWidget {
  final String bookingId;

  const ReviewCreationScreen({super.key, required this.bookingId});

  @override
  State<ReviewCreationScreen> createState() => _ReviewCreationScreenState();
}

class _ReviewCreationScreenState extends State<ReviewCreationScreen> {
  final api.ReviewApiService _reviewService = api.ReviewApiService();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _commentController = TextEditingController();

  int _rating = 5;
  int? _professionalism;
  int? _quality;
  int? _timeliness;
  int? _communication;
  int? _value;
  bool _isSubmitting = false;
  String? _errorMessage;

  String get language => 'ar'; // Will be from localization provider

  @override
  void dispose() {
    _titleController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final review = await _reviewService.createReview(
        widget.bookingId,
        _rating,
        title: _titleController.text.isEmpty ? null : _titleController.text,
        comment: _commentController.text.isEmpty ? null : _commentController.text,
        professionalism: _professionalism,
        quality: _quality,
        timeliness: _timeliness,
        communication: _communication,
        value: _value,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              language == 'ar' ? 'تم إرسال التقييم بنجاح' : 'Review submitted successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(review);
      }
    } catch (e) {
      AppLogger.error('Submit review error: $e');
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          language == 'ar' ? 'تقييم الحجز' : 'Review Booking',
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
              // Overall rating
              Text(
                language == 'ar' ? 'التقييم العام' : 'Overall Rating',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Row(
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                    onPressed: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 24),
              // Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: language == 'ar' ? 'العنوان (اختياري)' : 'Title (optional)',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Comment
              TextFormField(
                controller: _commentController,
                decoration: InputDecoration(
                  labelText: language == 'ar' ? 'التعليق' : 'Comment',
                  border: const OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 24),
              // Category ratings
              Text(
                language == 'ar' ? 'التقييم التفصيلي (اختياري)' : 'Detailed Ratings (optional)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              _CategoryRatingRow(
                label: language == 'ar' ? 'الاحترافية' : 'Professionalism',
                rating: _professionalism,
                onRatingChanged: (value) {
                  setState(() {
                    _professionalism = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              _CategoryRatingRow(
                label: language == 'ar' ? 'الجودة' : 'Quality',
                rating: _quality,
                onRatingChanged: (value) {
                  setState(() {
                    _quality = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              _CategoryRatingRow(
                label: language == 'ar' ? 'المواعد' : 'Timeliness',
                rating: _timeliness,
                onRatingChanged: (value) {
                  setState(() {
                    _timeliness = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              _CategoryRatingRow(
                label: language == 'ar' ? 'التواصل' : 'Communication',
                rating: _communication,
                onRatingChanged: (value) {
                  setState(() {
                    _communication = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              _CategoryRatingRow(
                label: language == 'ar' ? 'القيمة' : 'Value',
                rating: _value,
                onRatingChanged: (value) {
                  setState(() {
                    _value = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              // Error message
              if (_errorMessage != null)
                Text(
                  'Error: $_errorMessage',
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 16),
              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReview,
                  child: _isSubmitting
                      ? const CircularProgressIndicator()
                      : Text(
                          language == 'ar' ? 'إرسال التقييم' : 'Submit Review',
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryRatingRow extends StatelessWidget {
  final String label;
  final int? rating;
  final Function(int) onRatingChanged;

  const _CategoryRatingRow({
    required this.label,
    required this.rating,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label),
        ),
        Row(
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                rating != null && index < rating! ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 24,
              ),
              onPressed: () {
                onRatingChanged(index + 1);
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            );
          }),
        ),
      ],
    );
  }
}
