import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tuition_app/services/auth_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Artificial delay for splash effect
    await Future.delayed(const Duration(seconds: 2));
    
    final authService = ref.read(authServiceProvider);
    final isAuthenticated = await authService.checkAuthStatus();
    
    if (!mounted) return;

    if (isAuthenticated) {
      final user = authService.currentUser;
      if (user != null) {
        switch (user.role) {
          case 'teacher':
            context.go('/teacher/dashboard');
            break;
          case 'student':
            context.go('/student/dashboard');
            break;
          case 'agent':
            context.go('/agent/dashboard');
            break;
          case 'admin':
            context.go('/admin/dashboard');
            break;
          default:
            context.go('/login');
        }
      } else {
        context.go('/login');
      }
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo placeholder
            Icon(Icons.school, size: 80, color: Theme.of(context).primaryColor),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
