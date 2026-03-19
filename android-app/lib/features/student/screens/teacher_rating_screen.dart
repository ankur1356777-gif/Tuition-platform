import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/student_service.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/app_widgets.dart';

class TeacherRatingScreen extends ConsumerStatefulWidget {
  final int teacherId;
  final String teacherName;

  const TeacherRatingScreen({
    super.key,
    required this.teacherId,
    required this.teacherName,
  });

  @override
  ConsumerState<TeacherRatingScreen> createState() => _TeacherRatingScreenState();
}

class _TeacherRatingScreenState extends ConsumerState<TeacherRatingScreen> {
  int _rating = 0;
  final _feedbackController = TextEditingController();
  bool _isSubmitting = false;
  Map<String, dynamic>? _existingRating;

  @override
  void initState() {
    super.initState();
    _loadExistingRating();
  }

  Future<void> _loadExistingRating() async {
    final rating = await ref.read(studentServiceProvider).getTeacherRating(widget.teacherId);
    if (rating != null && mounted) {
      setState(() {
        _existingRating = rating;
        _rating = rating['rating'] ?? 0;
        _feedbackController.text = rating['feedback'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DesignSystem.backgroundDark : const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text('Rate Teacher', style: DesignSystem.heading3(color: null)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : DesignSystem.backgroundDark),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark 
              ? [DesignSystem.backgroundDark, const Color(0xFF1E1E2E)]
              : [const Color(0xFFF0F4FF), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              _buildTeacherHeader(isDark),
              const SizedBox(height: 32),
              
              PremiumCard(
                glass: true,
                child: Column(
                  children: [
                    Text(
                      'How would you rate your experience?',
                      style: DesignSystem.bodyMedium(color: null).copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    _buildStarRating(),
                    const SizedBox(height: 12),
                    Text(
                      _getRatingText(_rating),
                      style: TextStyle(
                        fontSize: 16,
                        color: _rating > 0 ? Colors.amber.shade700 : Colors.grey,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _feedbackController,
                      maxLines: 4,
                      style: DesignSystem.bodyMedium(color: null),
                      decoration: InputDecoration(
                        hintText: 'Share your feedback (Optional)...',
                        hintStyle: DesignSystem.bodySmall(color: Colors.grey),
                        filled: true,
                        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              _buildPrivacyNotice(isDark),
              const SizedBox(height: 40),
              
              GradientButton(
                text: _existingRating != null ? 'UPDATE RATING' : 'SUBMIT FEEDBACK',
                onPressed: _rating > 0 && !_isSubmitting ? _submitRating : null,
                loading: _isSubmitting,
                icon: Icons.check_circle_outline_rounded,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeacherHeader(bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: DesignSystem.primaryGradient,
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: isDark ? DesignSystem.backgroundDark : Colors.white,
            child: Text(
              widget.teacherName.isNotEmpty ? widget.teacherName[0].toUpperCase() : 'T',
              style: DesignSystem.heading1(color: DesignSystem.primary).copyWith(fontSize: 40),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.teacherName,
          style: DesignSystem.heading2(color: null),
        ),
        if (_existingRating != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Text('PREVIOUSLY RATED', style: TextStyle(color: Colors.green, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            ),
          ),
      ],
    );
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () => setState(() => _rating = index + 1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Icon(
              index < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 48,
              color: index < _rating ? Colors.amber.shade700 : Colors.grey.withOpacity(0.3),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPrivacyNotice(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: DesignSystem.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DesignSystem.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline_rounded, size: 16, color: DesignSystem.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your feedback is private. Only administration can see it to improve service quality.',
              style: DesignSystem.bodySmall(color: Colors.grey).copyWith(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1: return 'Poor';
      case 2: return 'Fair';
      case 3: return 'Good';
      case 4: return 'Very Good';
      case 5: return 'Excellent';
      default: return 'Tap to rate';
    }
  }

  Future<void> _submitRating() async {
    setState(() => _isSubmitting = true);
    try {
      await ref.read(studentServiceProvider).rateTeacher(widget.teacherId, {
        'rating': _rating,
        'feedback': _feedbackController.text,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thank you for your rating!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: DesignSystem.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
