import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/public_service.dart';
import '../../../services/api_service.dart';

class PublicRequestScreen extends ConsumerStatefulWidget {
  const PublicRequestScreen({super.key});

  @override
  ConsumerState<PublicRequestScreen> createState() => _PublicRequestScreenState();
}

class _PublicRequestScreenState extends ConsumerState<PublicRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _gradeController = TextEditingController();
  final _subjectController = TextEditingController();
  final _descController = TextEditingController();
  List<dynamic> _areas = [];
  dynamic _selectedArea;
  bool _isAreasLoading = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchAreas();
  }

  Future<void> _fetchAreas() async {
    setState(() => _isAreasLoading = true);
    try {
      final response = await ApiService().get('public/areas');
      if (response != null && response['success'] == true) {
        setState(() {
          _areas = response['data'];
        });
      }
    } catch (e) {
      debugPrint('Error fetching areas: $e');
    } finally {
      setState(() => _isAreasLoading = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedArea == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an area')));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref.read(publicServiceProvider).submitPublicRequest({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'area_id': _selectedArea['id'],
        'grade': _gradeController.text,
        'subject': _subjectController.text,
        'description': _descController.text,
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Request Sent'),
            content: const Text('We have received your request. Tutors in your area will be notified shortly.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.pop(); // Go back to landing
                },
                child: const Text('OK'),
              )
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request a Tutor')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Your Name', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty || v.length < 10 ? 'Valid phone required' : null,
              ),
              const SizedBox(height: 16),
              
              if (_isAreasLoading)
                const Center(child: CircularProgressIndicator())
              else
                DropdownButtonFormField<dynamic>(
                  value: _selectedArea,
                  decoration: const InputDecoration(labelText: 'Select Area (Lucknow)', border: OutlineInputBorder()),
                  items: _areas.map((area) {
                    return DropdownMenuItem<dynamic>(
                      value: area,
                      child: Text(area['name']),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedArea = v),
                  validator: (v) => v == null ? 'Required' : null,
                ),
                
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _gradeController,
                      decoration: const InputDecoration(labelText: 'Class/Grade', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _subjectController,
                      decoration: const InputDecoration(labelText: 'Subject', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Any specific requirements?', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: _isSubmitting 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text('SUBMIT REQUEST'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
