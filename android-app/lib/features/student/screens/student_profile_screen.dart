import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuition_app/services/api_service.dart';
import 'package:tuition_app/services/auth_service.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/app_widgets.dart';

class StudentProfileScreen extends ConsumerStatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  ConsumerState<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends ConsumerState<StudentProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _classController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _subjectsController = TextEditingController();
  
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final api = ApiService();
      await api.init();
      final response = await api.get('profile');
      
      if (response != null && mounted) {
        setState(() {
          _nameController.text = response['name'] ?? '';
          _emailController.text = response['email'] ?? '';
          
          if (response['student'] != null) {
            final student = response['student'];
            _classController.text = student['class'] ?? '';
            _addressController.text = student['address'] ?? '';
            _cityController.text = student['city'] ?? '';
            _stateController.text = student['state'] ?? '';
            _pincodeController.text = student['pincode'] ?? '';
            
            if (student['subjects_needed'] is List) {
              _subjectsController.text = (student['subjects_needed'] as List).join(', ');
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e', style: DesignSystem.bodySmall(color: Colors.white)), backgroundColor: DesignSystem.error),
        );
      }
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    try {
      final api = ApiService();
      await api.init();
      
      await api.post('profile', {
        'name': _nameController.text,
        'email': _emailController.text,
      });

      await api.post('profile/student', {
        'class': _classController.text,
        'address': _addressController.text,
        'city': _cityController.text,
        'state': _stateController.text,
        'pincode': _pincodeController.text,
        'subjects_needed': _subjectsController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
        );
        setState(() => _isEditing = false);
        await ref.read(authServiceProvider).loadUser();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e'), backgroundColor: DesignSystem.error),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? DesignSystem.backgroundDark : const Color(0xFFF8FAFF),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark 
                  ? [DesignSystem.backgroundDark, const Color(0xFF1E1E2E)]
                  : [const Color(0xFFF0F4FF), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(context, isDark),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader("Account Details", isDark),
                          const SizedBox(height: 16),
                          PremiumCard(
                            glass: true,
                            child: Column(
                              children: [
                                _buildTextField(
                                  controller: _nameController,
                                  label: 'Full Name',
                                  icon: Icons.person_outline_rounded,
                                  enabled: _isEditing,
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _emailController,
                                  label: 'Email Address',
                                  icon: Icons.email_outlined,
                                  enabled: _isEditing,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildSectionHeader("Academic Info", isDark),
                          const SizedBox(height: 16),
                          PremiumCard(
                            glass: true,
                            child: Column(
                              children: [
                                _buildTextField(
                                  controller: _classController,
                                  label: 'Current Grade/Class',
                                  icon: Icons.school_outlined,
                                  enabled: _isEditing,
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _subjectsController,
                                  label: 'Subjects Needed',
                                  icon: Icons.book_outlined,
                                  enabled: _isEditing,
                                  hint: 'e.g. Math, Science',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildSectionHeader("Contact & Address", isDark),
                          const SizedBox(height: 16),
                          PremiumCard(
                            glass: true,
                            child: Column(
                              children: [
                                _buildTextField(
                                  controller: _addressController,
                                  label: 'Street Address',
                                  icon: Icons.home_outlined,
                                  enabled: _isEditing,
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildTextField(
                                        controller: _cityController,
                                        label: 'City',
                                        icon: Icons.location_city_rounded,
                                        enabled: _isEditing,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildTextField(
                                        controller: _pincodeController,
                                        label: 'Pincode',
                                        icon: Icons.pin_drop_rounded,
                                        enabled: _isEditing,
                                        keyboardType: TextInputType.number,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _stateController,
                                  label: 'State',
                                  icon: Icons.map_outlined,
                                  enabled: _isEditing,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                          if (_isEditing)
                            GradientButton(
                              text: 'SAVE CHANGES',
                              onPressed: _isLoading ? null : _updateProfile,
                              loading: _isLoading,
                              icon: Icons.save_rounded,
                            ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    final user = ref.watch(authServiceProvider).currentUser;
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : DesignSystem.backgroundDark),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(_isEditing ? Icons.close_rounded : Icons.edit_rounded, color: isDark ? Colors.white : DesignSystem.backgroundDark),
          onPressed: () => setState(() => _isEditing = !_isEditing),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              CircleAvatar(
                radius: 40,
                backgroundColor: DesignSystem.primary.withOpacity(0.1),
                child: Text(
                  DesignSystem.getInitial(user?.name, 'S'),
                  style: DesignSystem.heading1(color: DesignSystem.primary).copyWith(fontSize: 32),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                user?.name ?? "Student Profile",
                style: DesignSystem.heading2(color: isDark ? Colors.white : DesignSystem.backgroundDark),
              ),
              Text(
                'Scholar Scholar',
                style: DesignSystem.bodySmall(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: DesignSystem.heading3(color: isDark ? Colors.white : DesignSystem.backgroundDark),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? hint,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: DesignSystem.bodyMedium(color: null),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: DesignSystem.primary.withOpacity(0.7)),
        filled: true,
        fillColor: Colors.transparent,
        border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.withOpacity(0.2))),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.withOpacity(0.1))),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: DesignSystem.primary)),
      ),
      validator: (v) => v?.isEmpty ?? true ? 'This field is required' : null,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _classController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _subjectsController.dispose();
    super.dispose();
  }
}
