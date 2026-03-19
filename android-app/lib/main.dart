import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'services/api_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(); 
  } catch (e) {
    print("Warning: Firebase initialization failed (likely missing google-services.json). Notifications will not work.\nError: $e");
  }
  await ApiService().init();
  
  // Note: Notification init should ideally happen after login or in a provider, 
  // but for simplicity we can init local stuff here, or wait until app starts.
  // Proper place is usually inside a user session provider or initState of root widget.
  
  runApp(
    const ProviderScope(
      child: TuitionApp(),
    ),
  );
}

class TuitionApp extends ConsumerStatefulWidget {
  const TuitionApp({super.key});

  @override
  ConsumerState<TuitionApp> createState() => _TuitionAppState();
}

class _TuitionAppState extends ConsumerState<TuitionApp> {
  @override
  void initState() {
    super.initState();
    // Initialize notifications
    ref.read(notificationServiceProvider).init();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'Home Tuition Platform',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
