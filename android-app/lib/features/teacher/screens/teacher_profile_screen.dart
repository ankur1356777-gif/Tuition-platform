import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuition_app/services/api_service.dart';
import 'package:tuition_app/services/auth_service.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/app_widgets.dart';

class TeacherProfileScreen extends ConsumerStatefulWidget {
  const TeacherProfileScreen({super.key});

  @override
  ConsumerState<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends ConsumerState<TeacherProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _bioController = TextEditingController();
  final _experienceController = TextEditingController();
  final _subjectsController = TextEditingController();
  final _classesController = TextEditingController();
  final _qualificationsController = TextEditingController();
  
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
          
          if (response['teacher'] != null) {
            final teacher = response['teacher'];
            _whatsappController.text = teacher['whatsapp_number'] ?? '';
            _bioController.text = teacher['bio'] ?? '';
            _experienceController.text = teacher['experience_years']?.toString() ?? '';
            
            if (teacher['subjects'] is List) {
              _subjectsController.text = (teacher['subjects'] as List).join(', ');
            }
            if (teacher['classes'] is List) {
              _classesController.text = (teacher['classes'] as List).join(', ');
            }
            if (teacher['qualifications'] is List) {
              _qualificationsController.text = (teacher['qualifications'] as List).join(', ');
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e', style: DesignSystem.bodySmall(color: Colors.white)), backgroundColor: DesignSystem.error),
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
      await api.post('profile', {'name': _nameController.text, 'email': _emailController.text});
      await api.post('profile/teacher', {
        'whatsapp_number': _whatsappController.text,
        'bio': _bioController.text,
        'experience_years': int.tryParse(_experienceController.text) ?? 0,
        'subjects': _subjectsController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
        'classes': _classesController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
        'qualifications': _qualificationsController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated!'), backgroundColor: Colors.green));
        setState(() => _isEditing = false);
        await ref.read(authServiceProvider).loadUser();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $e'), backgroundColor: DesignSystem.error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authServiceProvider).currentUser;

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
                SliverAppBar(
                  expandedHeight: 180,
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
                          const SizedBox(height: 48),
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: DesignSystem.primary.withOpacity(0.1),
                            child: Text(
                              DesignSystem.getInitial(user?.name, 'T'),
                              style: DesignSystem.heading1(color: DesignSystem.primary).copyWith(fontSize: 32),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(user?.name ?? "My Profile", style: DesignSystem.heading3(color: null)),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          _buildSection(
                            "PERSONAL INFO",
                            isDark,
                            [
                              _buildProfileField(controller: _nameController, label: 'Full Name', icon: Icons.person_outline_rounded, enabled: _isEditing),
                              const SizedBox(height: 16),
                              _buildProfileField(controller: _emailController, label: 'Email', icon: Icons.email_outlined, enabled: _isEditing, keyboardType: TextInputType.emailAddress),
                              const SizedBox(height: 16),
                              _buildProfileField(controller: _whatsappController, label: 'WhatsApp', icon: Icons.phone_android_rounded, enabled: _isEditing, keyboardType: TextInputType.phone),
                            ],
                          ),
                          const SizedBox(height: 32),
                          _buildSection(
                            "PROFESSIONAL DETAILS",
                            isDark,
                            [
                              _buildProfileField(controller: _bioController, label: 'Bio', icon: Icons.description_outlined, enabled: _isEditing, maxLines: 3),
                              const SizedBox(height: 16),
                              _buildProfileField(controller: _experienceController, label: 'Years Exp', icon: Icons.work_outline_rounded, enabled: _isEditing, keyboardType: TextInputType.number),
                              const SizedBox(height: 16),
                              _buildProfileField(controller: _subjectsController, label: 'Subjects', icon: Icons.book_outlined, enabled: _isEditing, hint: 'Math, Science...'),
                              const SizedBox(height: 16),
                              _buildProfileField(controller: _classesController, label: 'Classes', icon: Icons.school_outlined, enabled: _isEditing, hint: '1st, 2nd...'),
                            ],
                          ),
                          const SizedBox(height: 32),
                          _buildSection(
                            "QUALIFICATIONS",
                            isDark,
                            [
                              _buildProfileField(controller: _qualificationsController, label: 'Qualifications', icon: Icons.history_edu_rounded, enabled: _isEditing, hint: 'B.Ed, M.Sc...'),
                            ],
                          ),
                          const SizedBox(height: 48),
                          if (_isEditing)
                            GradientButton(
                              text: 'SAVE CHANGES',
                              onPressed: _isLoading ? null : _updateProfile,
                              icon: Icons.save_rounded,
                            ),
                          const SizedBox(height: 64),
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

  Widget _buildSection(String title, bool isDark, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(title, style: DesignSystem.bodySmall(color: DesignSystem.primary).copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 10)),
        ),
        PremiumCard(
          glass: true,
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildProfileField({
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
        border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.withOpacity(0.1))),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.withOpacity(0.05))),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: DesignSystem.primary)),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
    );
  }
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _whatsappController.dispose();
    _bioController.dispose();
    _experienceController.dispose();
    _subjectsController.dispose();
    _classesController.dispose();
    _qualificationsController.dispose();
    super.dispose();
  }
}
