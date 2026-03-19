import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/app_widgets.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  final String role;
  final String? phone;

  const RegistrationScreen({
    super.key,
    required this.role,
    this.phone,
  });

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _bioController = TextEditingController();
  final _subjectsController = TextEditingController();
  final _classesController = TextEditingController();
  final _qualificationsController = TextEditingController();
  final _experienceController = TextEditingController();
  final _customAreaController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  
  List<dynamic> _areas = [];
  dynamic _selectedArea;
  bool _isAreasLoading = false;
  bool _isSubmitting = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _phoneController.text = widget.phone ?? '';
    _whatsappController.text = widget.phone ?? '';
    if (widget.role == 'teacher') {
      _fetchAreas();
    }
  }

  Future<void> _fetchAreas() async {
    setState(() => _isAreasLoading = true);
    try {
      final api = ApiService();
      await api.init();
      final response = await api.get('public/areas');
      if (response != null && response['success'] == true) {
        final List<dynamic> loadedAreas = List.from(response['data']);
        loadedAreas.add({'id': -1, 'name': 'Other (Type your area...)'});
        setState(() {
          _areas = loadedAreas;
        });
      }
    } catch (e) {
      debugPrint('Error fetching areas: $e');
    } finally {
      setState(() => _isAreasLoading = false);
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (widget.role == 'teacher' && _selectedArea == null) {
      _showError('Please select your area');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final Map<String, dynamic> data = {
        'name': _nameController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'role': widget.role,
      };

      if (_passwordController.text.isNotEmpty) {
        data['password'] = _passwordController.text;
      }

      if (widget.role == 'student' && _parentPhoneController.text.isNotEmpty) {
        data['parent_phone'] = _parentPhoneController.text;
      }

      if (widget.role == 'teacher') {
        if (_selectedArea['id'] == -1) {
          data['custom_area'] = _customAreaController.text;
          data['area_id'] = null;
        } else {
          data['area_id'] = _selectedArea['id'];
        }
        
        data['whatsapp_number'] = _whatsappController.text;
        data['bio'] = _bioController.text;
        data['experience_years'] = _experienceController.text;
        data['subjects'] = _subjectsController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
        data['classes'] = _classesController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
        data['qualifications'] = _qualificationsController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      }

      await ref.read(authServiceProvider).register(data);
      
      if (!mounted) return;
      
      final needsApproval = widget.role == 'teacher' || widget.role == 'agent';
      _showSuccess(needsApproval
          ? 'Registration successful! Awaiting admin approval.'
          : 'Registration successful! You can now login.');
      
      context.go('/login');
      
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: DesignSystem.bodyMedium(color: Colors.white)),
        backgroundColor: DesignSystem.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: DesignSystem.bodyMedium(color: Colors.white)),
        backgroundColor: DesignSystem.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final roleName = widget.role[0].toUpperCase() + widget.role.substring(1);

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark 
                  ? [DesignSystem.backgroundDark, const Color(0xFF1E1E2E)]
                  : [const Color(0xFFEEF2FF), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'Register as $roleName',
                    style: DesignSystem.heading2(color: isDark ? Colors.white : DesignSystem.backgroundDark),
                  ),
                  centerTitle: true,
                ),
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => context.pop(),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text(
                          'Fill in your details to get started with our platform.',
                          textAlign: TextAlign.center,
                          style: DesignSystem.bodyMedium(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 32),

                        // Section 1: Basic Information
                        _buildSectionHeader('Basic Information', Icons.person_outline_rounded),
                        PremiumCard(
                          glass: true,
                          child: Column(
                            key: const ValueKey('basic_info'),
                            children: [
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Full Name',
                                  prefixIcon: Icon(Icons.person_rounded),
                                ),
                                validator: (value) => (value?.isEmpty ?? true) ? 'Required' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _phoneController,
                                decoration: const InputDecoration(
                                  labelText: 'Phone Number',
                                  prefixIcon: Icon(Icons.phone_android_rounded),
                                ),
                                keyboardType: TextInputType.phone,
                                readOnly: widget.phone != null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  labelText: 'Email Address',
                                  prefixIcon: Icon(Icons.email_outlined),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) => (value?.isEmpty ?? true) ? 'Required' : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Section 2: Security
                        _buildSectionHeader('Security', Icons.lock_outline_rounded),
                        PremiumCard(
                          glass: true,
                          child: Column(
                            key: const ValueKey('security'),
                            children: [
                              TextFormField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.password_rounded),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                ),
                                obscureText: _obscurePassword,
                              ),
                              if (_passwordController.text.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  decoration: InputDecoration(
                                    labelText: 'Confirm Password',
                                    prefixIcon: const Icon(Icons.verified_user_outlined),
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                                    ),
                                  ),
                                  obscureText: _obscureConfirm,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Role-specific sections
                        if (widget.role == 'student') ...[
                          _buildSectionHeader('Parent Connection', Icons.family_restroom_rounded),
                          PremiumCard(
                            glass: true,
                            child: TextFormField(
                              controller: _parentPhoneController,
                              decoration: const InputDecoration(
                                labelText: 'Parent Phone (Optional)',
                                prefixIcon: Icon(Icons.phone_enabled_rounded),
                                helperText: 'Helps in auto-linking profiles',
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        if (widget.role == 'teacher') ..._buildTeacherSections(isDark),

                        const SizedBox(height: 16),
                        GradientButton(
                          text: 'Complete Registration',
                          isLoading: _isSubmitting,
                          onPressed: _register,
                        ),
                        const SizedBox(height: 20),
                        
                        TextButton(
                          onPressed: () => context.go('/login'),
                          child: Text(
                            'Already have an account? Login',
                            style: DesignSystem.bodyMedium(color: DesignSystem.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: DesignSystem.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: DesignSystem.bodyLarge().copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTeacherSections(bool isDark) {
    return [
      _buildSectionHeader('Professional Bio', Icons.description_outlined),
      PremiumCard(
        glass: true,
        child: Column(
          children: [
            TextFormField(
              controller: _whatsappController,
              decoration: const InputDecoration(
                labelText: 'WhatsApp Number',
                prefixIcon: Icon(Icons.message_rounded),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Short Bio',
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),

      _buildSectionHeader('Expertise & Experience', Icons.workspace_premium_outlined),
      PremiumCard(
        glass: true,
        child: Column(
          children: [
            TextFormField(
              controller: _subjectsController,
              decoration: const InputDecoration(
                labelText: 'Subjects',
                hintText: 'Math, Physics, etc.',
                prefixIcon: Icon(Icons.book_rounded),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _classesController,
              decoration: const InputDecoration(
                labelText: 'Classes',
                hintText: '10th, 12th, etc.',
                prefixIcon: Icon(Icons.grade_rounded),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _qualificationsController,
              decoration: const InputDecoration(
                labelText: 'Qualifications',
                hintText: 'B.Tech, M.Sc, etc.',
                prefixIcon: Icon(Icons.school_rounded),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _experienceController,
              decoration: const InputDecoration(
                labelText: 'Years of Experience',
                prefixIcon: Icon(Icons.work_history_rounded),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),

      _buildSectionHeader('Location', Icons.map_outlined),
      PremiumCard(
        glass: true,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: 'Lucknow',
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'City'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: 'UP',
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'State'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isAreasLoading)
              const CircularProgressIndicator()
            else
              DropdownButtonFormField<dynamic>(
                value: _selectedArea,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Locality',
                  prefixIcon: Icon(Icons.location_on_rounded),
                ),
                items: _areas.map((area) {
                  return DropdownMenuItem<dynamic>(
                    value: area,
                    child: Text(area['name']),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedArea = value),
              ),
            if (_selectedArea != null && _selectedArea['id'] == -1) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _customAreaController,
                decoration: const InputDecoration(
                  labelText: 'Type your locality',
                  prefixIcon: Icon(Icons.edit_location_rounded),
                ),
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: 24),
    ];
  }
}
