import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../services/api_service.dart';

class TuitionRequestScreen extends ConsumerStatefulWidget {
  const TuitionRequestScreen({super.key});

  @override
  ConsumerState<TuitionRequestScreen> createState() => _TuitionRequestScreenState();
}

class _TuitionRequestScreenState extends ConsumerState<TuitionRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _gradeController = TextEditingController();
  final _budgetController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _timingController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final apiService = ApiService(); 
      // Note: In a real app, use a provider, but ApiService is a singleton/service.
      // We need to pass dummy lat/long/address because validation in controller might effectively ignore them 
      // OR we updated controller validation to validation. 
      // Wait, let's check validation in StudentController again.
      // It validates: 'subject', 'grade', 'budget', 'latitude', 'longitude', 'address'
      // BUT we removed 'budget', 'latitude' etc from CREATE call.
      // WE DID NOT REMOVE THEM FROM VALIDATION. 
      // I need to update the validation in backend too! 
      // Assuming I'll fix the backend validation next step. 

      await apiService.post('student/request', {
        'subject': _subjectController.text,
        'grade': _gradeController.text,
        'budget': double.tryParse(_budgetController.text) ?? 0.0,
        'description': _descriptionController.text,
        'preferred_timing': _timingController.text,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request submitted successfully!')),
        );
        context.pop(); // Go back to dashboard
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Tuition Request')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(labelText: 'Subject', hintText: 'e.g. Mathematics'),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _gradeController,
                decoration: const InputDecoration(labelText: 'Class/Grade', hintText: 'e.g. 10th Grade'),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _budgetController,
                decoration: const InputDecoration(labelText: 'Monthly Budget (₹)'),
                keyboardType: TextInputType.number,
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description/Specific Topics', hintText: 'e.g. Calculus help needed'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _timingController,
                decoration: const InputDecoration(labelText: 'Preferred Timing', hintText: 'e.g. Evening 5-7 PM'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _submitRequest,
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text('Submit Request'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
