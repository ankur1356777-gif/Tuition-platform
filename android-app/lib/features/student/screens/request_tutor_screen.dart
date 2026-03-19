import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/student_provider.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/app_widgets.dart';

class RequestTutorScreen extends ConsumerStatefulWidget {
  const RequestTutorScreen({super.key});

  @override
  ConsumerState<RequestTutorScreen> createState() => _RequestTutorScreenState();
}

class _RequestTutorScreenState extends ConsumerState<RequestTutorScreen> {
  final _formKey = GlobalKey<FormState>();
  String _grade = '10th';
  final List<String> _selectedSubjects = [];
  final _addressController = TextEditingController();
  final _budgetController = TextEditingController();
  String _preferredGender = 'any';

  final List<String> _grades = ['1st', '2nd', '3rd', '4th', '5th', '6th', '7th', '8th', '9th', '10th', '11th', '12th', 'Other'];
  final List<String> _subjects = ['Mathematics', 'Science', 'English', 'Hindi', 'Social Science', 'Physics', 'Chemistry', 'Biology'];

  @override
  void dispose() {
    _addressController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(studentActionProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DesignSystem.backgroundDark : const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text('Find a Tutor', style: DesignSystem.heading3(color: null)),
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
        child: state.when(
          data: (_) => _buildForm(isDark),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: $err', style: DesignSystem.bodySmall(color: DesignSystem.error)),
                const SizedBox(height: 16),
                GradientButton(
                  text: 'RETRY',
                  onPressed: () => ref.invalidate(studentActionProvider),
                  width: 120,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What do you want to learn?',
              style: DesignSystem.heading2(color: isDark ? Colors.white : DesignSystem.backgroundDark),
            ),
            const SizedBox(height: 8),
            Text(
              'Tell us your requirements and we\'ll find the best match for you.',
              style: DesignSystem.bodySmall(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            
            PremiumCard(
              glass: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('ACADEMIC LEVEL'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _grade,
                    dropdownColor: isDark ? const Color(0xFF2E2E3E) : Colors.white,
                    style: DesignSystem.bodyMedium(color: null),
                    decoration: _inputDecoration('Grade', Icons.school_outlined),
                    items: _grades.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                    onChanged: (val) => setState(() => _grade = val!),
                  ),
                  const SizedBox(height: 24),
                  
                  _buildSectionHeader('SUBJECTS'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _subjects.map((s) {
                      final isSelected = _selectedSubjects.contains(s);
                      return ChoiceChip(
                        label: Text(s),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedSubjects.add(s);
                            } else {
                              _selectedSubjects.remove(s);
                            }
                          });
                        },
                        selectedColor: DesignSystem.primary.withOpacity(0.2),
                        backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                        labelStyle: DesignSystem.bodySmall(color: isSelected ? DesignSystem.primary : null).copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: isSelected ? DesignSystem.primary : Colors.transparent),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            PremiumCard(
              glass: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('LOCATION & LOGISTICS'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    style: DesignSystem.bodyMedium(color: null),
                    decoration: _inputDecoration('Full address for offline tuition', Icons.location_on_outlined),
                    maxLines: 2,
                    validator: (v) => v!.isEmpty ? 'Please enter address' : null,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader('MONTHLY BUDGET'),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _budgetController,
                              style: DesignSystem.bodyMedium(color: null),
                              decoration: _inputDecoration('Budget (₹)', Icons.currency_rupee_rounded),
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader('PREFERENCE'),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: _preferredGender,
                              dropdownColor: isDark ? const Color(0xFF2E2E3E) : Colors.white,
                              style: DesignSystem.bodyMedium(color: null),
                              decoration: _inputDecoration('Gender', Icons.wc_rounded),
                              items: const [
                                DropdownMenuItem(value: 'any', child: Text('No Preference')),
                                DropdownMenuItem(value: 'male', child: Text('Male')),
                                DropdownMenuItem(value: 'female', child: Text('Female')),
                              ],
                              onChanged: (val) => setState(() => _preferredGender = val!),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            GradientButton(
              text: 'POST TUITION REQUEST',
              onPressed: _submit,
              icon: Icons.send_rounded,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: DesignSystem.bodySmall(color: DesignSystem.primary).copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2),
    );
  }

  InputDecoration _inputDecoration(String hin, IconData icon) {
    return InputDecoration(
      hintText: hin,
      hintStyle: DesignSystem.bodySmall(color: Colors.grey),
      prefixIcon: Icon(icon, size: 20, color: DesignSystem.primary.withOpacity(0.7)),
      filled: true,
      fillColor: Colors.transparent,
      border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.withOpacity(0.2))),
      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.withOpacity(0.1))),
      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: DesignSystem.primary)),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSubjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one subject', style: DesignSystem.bodySmall(color: Colors.white)),
          backgroundColor: DesignSystem.error,
        )
      );
      return;
    }

    await ref.read(studentActionProvider.notifier).createTuitionRequest(
      grade: _grade,
      subjects: _selectedSubjects,
      address: _addressController.text,
      lat: 26.8467, 
      lng: 80.9462,
      preferredGender: _preferredGender,
      budget: double.tryParse(_budgetController.text),
    );

    if (mounted && ref.read(studentActionProvider).hasError == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request posted successfully!'), backgroundColor: Colors.green),
      );
      context.pop();
    }
  }
}
