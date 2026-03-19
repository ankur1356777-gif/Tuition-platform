import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tuition_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../../../core/theme/design_system.dart';
import '../../../core/theme/app_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // OTP login controllers
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;
  bool _isLoading = false;

  // Password login controllers
  final _loginController = TextEditingController(); // email or phone
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ===== OTP Login Flow (Firebase) =====

  Future<void> _sendOtp() async {
    if (_phoneController.text.trim().length < 10) {
      _showError('Please enter a valid phone number');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).sendFirebaseOtp(
        _phoneController.text.trim(),
        onCodeSent: (verId) {
          setState(() {
            _otpSent = true;
            _isLoading = false;
          });
          _showSuccess('OTP sent successfully');
        },
        onVerificationFailed: (e) {
          setState(() => _isLoading = false);
          _showError('Verification failed: ${e.message}');
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error: ${e.toString()}');
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.trim().length != 6) {
      _showError('Please enter a valid 6-digit OTP');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await ref.read(authServiceProvider).verifyFirebaseOtp(
        _otpController.text.trim(),
      );

      if (!mounted) return;

      if (response['is_new_user'] == true) {
        context.push('/register?phone=${_phoneController.text.trim()}');
      } else {
        _navigateByRole();
      }
    } catch (e) {
      String message = e.toString();
      if (e is fb_auth.FirebaseAuthException) {
        message = e.message ?? 'Verification failed';
      }
      _showError(message.replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ===== Password Login Flow =====

  Future<void> _loginWithPassword() async {
    if (_loginController.text.trim().isEmpty) {
      _showError('Please enter your email or phone number');
      return;
    }
    if (_passwordController.text.isEmpty) {
      _showError('Please enter your password');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).loginWithPassword(
        _loginController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;
      _navigateByRole();
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ===== Navigation & Helpers =====

  void _navigateByRole() {
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    switch (user.role) {
      case 'teacher':
        context.go('/teacher/dashboard');
      case 'student':
        context.go('/student/dashboard');
      case 'agent':
        context.go('/agent/dashboard');
      case 'admin':
        context.go('/admin/dashboard');
      case 'parent':
        context.go('/parent/dashboard');
      default:
        context.go('/');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
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
    if (!mounted) return;
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

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
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
          
          // Decorative Circles
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: DesignSystem.primary.withOpacity(isDark ? 0.1 : 0.05),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Hero(
                      tag: 'app_logo',
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          gradient: DesignSystem.primaryGradient,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: DesignSystem.premiumShadow,
                        ),
                        child: const Icon(Icons.school_rounded, color: Colors.white, size: 48),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Tuition Platform',
                      style: DesignSystem.heading1(),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your personal home tuition partner',
                      style: DesignSystem.bodyMedium(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 40),

                    // Login Form Card
                    PremiumCard(
                      glass: true,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Custom TabBar
                          Container(
                            height: 48,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.black26 : Colors.black.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: TabBar(
                              controller: _tabController,
                              indicator: BoxDecoration(
                                color: isDark ? DesignSystem.primary : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: isDark ? null : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                              ),
                              labelColor: isDark ? Colors.white : DesignSystem.primary,
                              unselectedLabelColor: Colors.grey[600],
                              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                              dividerColor: Colors.transparent,
                              tabs: const [
                                Tab(text: 'OTP'),
                                Tab(text: 'Password'),
                                Tab(text: 'Demo'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Tab Content
                          SizedBox(
                            height: 280,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _buildOtpTab(),
                                _buildPasswordTab(),
                                _buildDemoTab(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Register Section
                    Text(
                      "Don't have an account?",
                      style: DesignSystem.bodyMedium(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildRegisterButton('Teacher', Icons.workspace_premium, '/register?role=teacher'),
                        _buildRegisterButton('Student', Icons.school, '/register?role=student'),
                        _buildRegisterButton('Parent', Icons.family_restroom, '/register?role=parent'),
                        _buildRegisterButton('Agent', Icons.people, '/register?role=agent'),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton(String label, IconData icon, String route) {
    return InkWell(
      onTap: () => context.push(route),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.05 : 0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: DesignSystem.primary.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: DesignSystem.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: DesignSystem.bodyMedium(color: DesignSystem.primary).copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // ===== OTP Login Tab =====
  Widget _buildOtpTab() {
    return Column(
      children: [
        TextField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            hintText: '10-digit number',
            prefixIcon: Icon(Icons.phone_android_rounded),
            prefixText: '+91 ',
          ),
          keyboardType: TextInputType.phone,
          maxLength: 10,
          enabled: !_otpSent,
        ),
        if (_otpSent) ...[
          const SizedBox(height: 20),
          TextField(
            controller: _otpController,
            decoration: const InputDecoration(
              labelText: 'OTP',
              hintText: 'Enter 6-digit code',
              prefixIcon: Icon(Icons.vibration_rounded),
            ),
            keyboardType: TextInputType.number,
            maxLength: 6,
            autofocus: true,
          ),
        ],
        const Spacer(),
        GradientButton(
          text: _otpSent ? 'Verify & Login' : 'Send OTP',
          isLoading: _isLoading,
          onPressed: _otpSent ? _verifyOtp : _sendOtp,
        ),
      ],
    );
  }

  // ===== Password Login Tab =====
  Widget _buildPasswordTab() {
    return Column(
      children: [
        TextField(
          controller: _loginController,
          decoration: const InputDecoration(
            labelText: 'Email or Phone',
            prefixIcon: Icon(Icons.alternate_email_rounded),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          obscureText: _obscurePassword,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: Text('Forgot Password?', style: DesignSystem.caption(color: DesignSystem.primary)),
          ),
        ),
        const Spacer(),
        GradientButton(
          text: 'Login',
          isLoading: _isLoading,
          onPressed: _loginWithPassword,
        ),
      ],
    );
  }

  // ===== Demo Accounts Tab =====
  Widget _buildDemoTab() {
    final demoAccounts = [
      {'role': 'Teacher', 'phone': '9876543210', 'icon': Icons.person, 'color': Colors.blue},
      {'role': 'Student', 'phone': '9876543211', 'icon': Icons.school, 'color': Colors.green},
      {'role': 'Parent', 'phone': '9876543212', 'icon': Icons.family_restroom, 'color': Colors.orange},
      {'role': 'Agent', 'phone': '9876543213', 'icon': Icons.people, 'color': Colors.purple},
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: demoAccounts.map((account) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _isLoading ? null : () => _loginWithDemo(account['phone'] as String, '123456'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: (account['color'] as Color).withOpacity(0.2)),
                    color: (account['color'] as Color).withOpacity(0.05),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (account['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(account['icon'] as IconData, color: account['color'] as Color, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Login as ${account['role']}',
                          style: DesignSystem.bodyMedium().copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _loginWithDemo(String phone, String otp) async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).sendOtp(phone);
      final response = await ref.read(authServiceProvider).verifyOtp(phone, otp);

      if (!mounted) return;

      if (response['is_new_user'] == true) {
        _showError('Demo account not registered yet.');
      } else {
        _showSuccess('Logged in as ${response['user']?['role'] ?? 'user'}');
        _navigateByRole();
      }
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
