import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/teacher/screens/leads_screen.dart';
import '../../features/student/screens/tuition_request_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/teacher/screens/teacher_dashboard.dart';
import '../../features/student/screens/student_dashboard.dart';
import '../../features/agent/screens/agent_dashboard.dart';
import '../../features/admin/screens/admin_dashboard.dart';
import '../../features/admin/screens/teacher_list_screen.dart';
import '../../features/admin/screens/student_list_screen.dart';
import '../../features/admin/screens/commission_settings_screen.dart';
import '../../features/teacher/screens/teacher_wallet_screen.dart';
import '../../features/teacher/screens/teacher_demos_screen.dart';
import '../../features/teacher/screens/attendance_marking_screen.dart';
import '../../features/teacher/screens/teacher_leaves_screen.dart';
import '../../features/student/screens/student_attendance_screen.dart';
import '../../features/student/screens/student_payments_screen.dart';
import '../../features/student/screens/student_results_screen.dart';
import '../../features/agent/screens/agent_referrals_screen.dart';
import '../../features/agent/screens/agent_wallet_screen.dart';
import '../../features/common/screens/document_upload_screen.dart';
import '../../features/common/screens/payment_screen.dart';
import '../../features/common/screens/edit_profile_screen.dart';
import '../../features/teacher/screens/create_test_screen.dart';
import '../../features/admin/screens/admin_payouts_screen.dart';
import '../../features/admin/screens/admin_documents_screen.dart';
import '../../features/admin/screens/admin_leads_screen.dart';
import '../../features/admin/screens/admin_agents_screen.dart';
import '../../features/admin/screens/admin_attendance_logs_screen.dart';
import '../../features/admin/screens/admin_broadcast_screen.dart';
import '../../features/admin/screens/lead_approval_screen.dart';
import '../../features/teacher/screens/active_tuitions_screen.dart';
import '../../features/student/screens/active_tuitions_screen.dart';
import '../../features/student/screens/student_tests_screen.dart';
import '../../features/student/screens/take_test_screen.dart';
import '../../services/auth_service.dart';
import '../../features/public/screens/landing_screen.dart';
import '../../features/public/screens/public_request_screen.dart';
import '../../features/auth/screens/registration_screen.dart';
import '../../features/teacher/screens/available_requirements_screen.dart';
// New screens
import '../../features/teacher/screens/teacher_homework_screen.dart';
import '../../features/teacher/screens/teacher_teaching_plans_screen.dart';
import '../../features/student/screens/student_homework_screen.dart';
import '../../features/student/screens/student_batch_screen.dart';
import '../../features/student/screens/teacher_rating_screen.dart';
import '../../features/teacher/screens/teacher_weekly_tests_screen.dart';
import '../../features/student/screens/student_teaching_plans_screen.dart';
import '../../features/common/screens/change_password_screen.dart';
import '../../features/common/screens/notification_screen.dart';
import '../../features/parent/screens/child_progress_screen.dart';

import '../../features/auth/screens/pending_approval_screen.dart';
import '../../features/parent/screens/parent_dashboard.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authService = ref.watch(authServiceProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: authService,
    redirect: (context, state) {
      final isAuth = authService.isAuthenticated;
      final user = authService.currentUser;
      final path = state.uri.path;
      final isPublic = path == '/' || path == '/login' || path.startsWith('/public') || path == '/register';

      // If user is authenticated and tries to access public pages (like login/landing), redirect to dashboard
      if (isAuth) {
        // Check for approval status (only for teacher and agent — students and parents are auto-approved)
        if (user != null && user.status != 'approved' && user.role != 'admin'
            && (user.role == 'teacher' || user.role == 'agent')) {
           if (path != '/pending-approval') return '/pending-approval';
           return null;
        }

        if (path == '/login' || path == '/' || path == '/pending-approval') {
          final role = user?.role;
          switch (role) {
            case 'admin': return '/admin/dashboard';
            case 'teacher': return '/teacher/dashboard';
            case 'student': return '/student/dashboard';
            case 'agent': return '/agent/dashboard';
            case 'parent': return '/parent/dashboard';
            default: return '/';
          }
        }
      }
      
      // If not authenticated, allow access to public pages
      if (!isAuth) {
        if (isPublic) return null; // Allow navigation
        return '/login'; // Redirect protected routes to login
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/pending-approval',
        builder: (context, state) => const PendingApprovalScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const LandingScreen(),
      ),
      GoRoute(
        path: '/public/request',
        builder: (context, state) => const PublicRequestScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) {
          final role = state.uri.queryParameters['role'] ?? 'teacher';
          final phone = state.uri.queryParameters['phone'];
          return RegistrationScreen(role: role, phone: phone);
        },
      ),
      GoRoute(
        path: '/teacher/dashboard',
        builder: (context, state) => const TeacherDashboard(),
      ),
      GoRoute(
        path: '/teacher/leads',
        builder: (context, state) => const TeacherLeadsScreen(),
      ),
      GoRoute(
        path: '/teacher/available-requirements',
        builder: (context, state) => const AvailableRequirementsScreen(),
      ),
      // ... keep existing routes ...
      GoRoute(
        path: '/teacher/wallet',
        builder: (context, state) => const TeacherWalletScreen(),
      ),
      GoRoute(
        path: '/teacher/demos',
        builder: (context, state) => const TeacherDemosScreen(),
      ),
      GoRoute(
        path: '/teacher/attendance',
        builder: (context, state) => const AttendanceMarkingScreen(),
      ),
      GoRoute(
        path: '/teacher/leaves',
        builder: (context, state) => const TeacherLeavesScreen(),
      ),
      GoRoute(
        path: '/teacher/active-classes',
        builder: (context, state) => const TeacherActiveTuitionsScreen(),
      ),
      // NEW TEACHER ROUTES
      GoRoute(
        path: '/teacher/homework',
        builder: (context, state) => const TeacherHomeworkScreen(),
      ),
      GoRoute(
        path: '/teacher/teaching-plans',
        builder: (context, state) => const TeacherTeachingPlansScreen(),
      ),
      GoRoute(
        path: '/teacher/weekly-tests',
        builder: (context, state) => const TeacherWeeklyTestsScreen(),
      ),
      GoRoute(
        path: '/student/dashboard',
        builder: (context, state) => const StudentDashboard(),
      ),
      GoRoute(
        path: '/student/request',
        builder: (context, state) => const TuitionRequestScreen(),
      ),
      GoRoute(
        path: '/student/attendance',
        builder: (context, state) => const StudentAttendanceScreen(),
      ),
      GoRoute(
        path: '/student/payments',
        builder: (context, state) => const StudentPaymentsScreen(),
      ),
      GoRoute(
        path: '/student/results',
        builder: (context, state) => const StudentResultsScreen(),
      ),
      GoRoute(
        path: '/student/active-tuitions',
        builder: (context, state) => const ActiveTuitionsScreen(),
      ),
      GoRoute(
        path: '/student/tests',
        builder: (context, state) => const StudentTestsScreen(),
      ),
      GoRoute(
        path: '/student/take-test',
        builder: (context, state) {
          final test = state.extra as Map<String, dynamic>;
          return TakeTestScreen(test: test);
        },
      ),
      // NEW STUDENT ROUTES
      GoRoute(
        path: '/student/homework',
        builder: (context, state) => const StudentHomeworkScreen(),
      ),
      GoRoute(
        path: '/student/batch',
        builder: (context, state) => const StudentBatchScreen(),
      ),
      GoRoute(
        path: '/student/rate-teacher',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return TeacherRatingScreen(
            teacherId: extra['teacherId'],
            teacherName: extra['teacherName'],
          );
        },
      ),
      GoRoute(
        path: '/agent/dashboard',
        builder: (context, state) => const AgentDashboard(),
      ),
      GoRoute(
        path: '/parent/dashboard',
        builder: (context, state) => const ParentDashboard(),
      ),
      GoRoute(
        path: '/parent/children/:id/progress',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ChildProgressScreen(
            studentId: int.parse(state.pathParameters['id']!),
            childName: extra?['childName'] ?? 'Child',
          );
        },
      ),
      GoRoute(
        path: '/student/teaching-plans',
        builder: (context, state) => const StudentTeachingPlansScreen(),
      ),
      GoRoute(
        path: '/agent/referrals',
        builder: (context, state) => const AgentReferralsScreen(),
      ),
      GoRoute(
        path: '/agent/wallet',
        builder: (context, state) => const AgentWalletScreen(),
      ),
      GoRoute(
        path: '/common/documents/upload',
        builder: (context, state) => const DocumentUploadScreen(),
      ),
      GoRoute(
        path: '/common/profile/edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/common/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/common/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/common/notifications',
        builder: (context, state) => const NotificationScreen(),
      ),
      GoRoute(
        path: '/common/payment',
        builder: (context, state) {
           final extra = state.extra as Map<String, dynamic>?;
           return PaymentScreen(
             amount: extra?['amount'] ?? 0.0,
             purpose: extra?['purpose'] ?? 'Payment',
             metadata: extra?['metadata'],
             onSuccess: extra?['onSuccess'],
           );
        },
      ),
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboard(),
      ),
      GoRoute(
        path: '/admin/teachers',
        builder: (context, state) => const TeacherListScreen(),
      ),
      GoRoute(
        path: '/admin/students',
        builder: (context, state) => const StudentListScreen(),
      ),
      GoRoute(
        path: '/teacher/tests/create',
        builder: (context, state) => const CreateTestScreen(),
      ),
      GoRoute(
        path: '/admin/settings',
        builder: (context, state) => const CommissionSettingsScreen(),
      ),
      GoRoute(
        path: '/admin/payouts',
        builder: (context, state) => const AdminPayoutsScreen(),
      ),
      GoRoute(
        path: '/admin/documents',
        builder: (context, state) => const AdminDocumentsScreen(),
      ),
      GoRoute(
        path: '/admin/leads',
        builder: (context, state) => const AdminLeadsScreen(),
      ),
      GoRoute(
        path: '/admin/lead-approvals',
        builder: (context, state) => const LeadApprovalScreen(),
      ),
      GoRoute(
        path: '/admin/agents',
        builder: (context, state) => const AdminAgentsScreen(),
      ),
      GoRoute(
        path: '/admin/attendance-logs',
        builder: (context, state) => const AdminAttendanceLogsScreen(),
      ),
      GoRoute(
        path: '/admin/broadcast',
        builder: (context, state) => const AdminBroadcastScreen(),
      ),
    ],
  );
});
