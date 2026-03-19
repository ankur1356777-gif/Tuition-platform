import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/auth_service.dart';
import '../../../services/api_service.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/app_widgets.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authServiceProvider).currentUser;
    _nameController = TextEditingController(text: user?.name);
    _emailController = TextEditingController(text: user?.email);
    _phoneController = TextEditingController(text: user?.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ApiService().post('profile', {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
      });

      // Reload user data
      await ref.read(authServiceProvider).loadUser();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DesignSystem.backgroundDark : const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text('Edit Profile', style: DesignSystem.heading3(color: null)),
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
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              _buildAvatarSection(isDark),
              const SizedBox(height: 48),
              TextFormField(
                controller: _nameController,
                style: DesignSystem.bodyLarge(color: null),
                decoration: DesignSystem.inputDecoration('Full Name', Icons.person_rounded),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: DesignSystem.bodyLarge(color: null),
                decoration: DesignSystem.inputDecoration('Email Address', Icons.email_rounded),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _phoneController,
                readOnly: true,
                style: DesignSystem.bodyLarge(color: Colors.grey),
                decoration: DesignSystem.inputDecoration('Phone Number', Icons.phone_android_rounded).copyWith(
                  suffixIcon: const Icon(Icons.lock_rounded, size: 16, color: Colors.grey),
                  helperText: 'Phone number is verified and cannot be changed',
                  helperStyle: DesignSystem.bodySmall(color: Colors.grey).copyWith(fontSize: 10),
                ),
              ),
              const SizedBox(height: 48),
              GradientButton(
                text: 'SAVE CHANGES',
                isLoading: _isLoading,
                onPressed: _updateProfile,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection(bool isDark) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: DesignSystem.primaryGradient,
            boxShadow: [
              BoxShadow(color: DesignSystem.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
            ],
          ),
          padding: const EdgeInsets.all(4),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? DesignSystem.backgroundDark : Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : '?',
                style: DesignSystem.heading1(color: DesignSystem.primary).copyWith(fontSize: 48),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile image upload coming soon')),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: DesignSystem.secondary,
                shape: BoxShape.circle,
                border: Border.all(color: isDark ? DesignSystem.backgroundDark : Colors.white, width: 3),
              ),
              child: const Icon(Icons.camera_alt_rounded, size: 20, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
