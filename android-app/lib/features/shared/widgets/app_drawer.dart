import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../services/auth_service.dart';
import '../../../core/theme/design_system.dart';

/// A shared navigation drawer used across all role dashboards.
class AppDrawer extends ConsumerWidget {
  final String currentRole;

  const AppDrawer({super.key, required this.currentRole});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authServiceProvider).currentUser;
    final theme = Theme.of(context);

    return Drawer(
      child: Column(
        children: [
          // Header
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            accountName: Text(
              user?.name ?? 'User',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: Text(
              user?.email ?? user?.phone ?? '',
              style: const TextStyle(fontSize: 13),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                DesignSystem.getInitial(user?.name, 'U'),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ),
            otherAccountsPictures: [
              CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.3),
                child: Text(
                  DesignSystem.getInitial(currentRole, 'U'),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          // Dashboard
          _DrawerItem(
            icon: Icons.dashboard,
            title: 'Dashboard',
            onTap: () {
              Navigator.pop(context);
              context.go('/${currentRole}/dashboard');
            },
          ),

          const Divider(height: 1),

          // Role-specific items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(
                    '${currentRole[0].toUpperCase()}${currentRole.substring(1)} Menu',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                ..._getRoleItems(context),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(
                    'Account',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                _DrawerItem(
                  icon: Icons.person,
                  title: 'Edit Profile',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/common/edit-profile');
                  },
                ),
                _DrawerItem(
                  icon: Icons.lock,
                  title: 'Change Password',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/common/change-password');
                  },
                ),
                _DrawerItem(
                  icon: Icons.description,
                  title: 'My Documents',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/common/documents/upload');
                  },
                ),
                _DrawerItem(
                  icon: Icons.notifications,
                  title: 'Notifications',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/common/notifications');
                  },
                ),
              ],
            ),
          ),

          // Logout
          const Divider(height: 1),
          _DrawerItem(
            icon: Icons.logout,
            title: 'Logout',
            textColor: Colors.red,
            onTap: () {
              Navigator.pop(context);
              ref.read(authServiceProvider).logout();
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  List<Widget> _getRoleItems(BuildContext context) {
    switch (currentRole) {
      case 'teacher':
        return _teacherItems(context);
      case 'student':
        return _studentItems(context);
      case 'parent':
        return _parentItems(context);
      case 'agent':
        return _agentItems(context);
      default:
        return [];
    }
  }

  List<Widget> _teacherItems(BuildContext context) {
    return [
      _DrawerItem(
        icon: Icons.school,
        title: 'Active Classes',
        onTap: () {
          Navigator.pop(context);
          context.push('/teacher/active-classes');
        },
      ),
      _DrawerItem(
        icon: Icons.location_on,
        title: 'Available Tuitions',
        onTap: () {
          Navigator.pop(context);
          context.push('/teacher/available-requirements');
        },
      ),
      _DrawerItem(
        icon: Icons.person_search,
        title: 'My Leads',
        onTap: () {
          Navigator.pop(context);
          context.push('/teacher/leads');
        },
      ),
      _DrawerItem(
        icon: Icons.event_available,
        title: 'Mark Attendance',
        onTap: () {
          Navigator.pop(context);
          context.push('/teacher/attendance');
        },
      ),
      _DrawerItem(
        icon: Icons.timer,
        title: 'Demo Classes',
        onTap: () {
          Navigator.pop(context);
          context.push('/teacher/demos');
        },
      ),
      _DrawerItem(
        icon: Icons.account_balance_wallet,
        title: 'Wallet & Earnings',
        onTap: () {
          Navigator.pop(context);
          context.push('/teacher/wallet');
        },
      ),
      _DrawerItem(
        icon: Icons.beach_access,
        title: 'Leave Application',
        onTap: () {
          Navigator.pop(context);
          context.push('/teacher/leaves');
        },
      ),
      _DrawerItem(
        icon: Icons.note_add,
        title: 'Create Test',
        onTap: () {
          Navigator.pop(context);
          context.push('/teacher/tests/create');
        },
      ),
      _DrawerItem(
        icon: Icons.book,
        title: 'Homework',
        onTap: () {
          Navigator.pop(context);
          context.push('/teacher/homework');
        },
      ),
      _DrawerItem(
        icon: Icons.calendar_month,
        title: 'Teaching Plans',
        onTap: () {
          Navigator.pop(context);
          context.push('/teacher/teaching-plans');
        },
      ),
      _DrawerItem(
        icon: Icons.quiz,
        title: 'Weekly Tests',
        onTap: () {
          Navigator.pop(context);
          context.push('/teacher/weekly-tests');
        },
      ),
    ];
  }

  List<Widget> _studentItems(BuildContext context) {
    return [
      _DrawerItem(
        icon: Icons.class_,
        title: 'Active Tuitions',
        onTap: () {
          Navigator.pop(context);
          context.push('/student/active-tuitions');
        },
      ),
      _DrawerItem(
        icon: Icons.add_circle,
        title: 'Request Tutor',
        onTap: () {
          Navigator.pop(context);
          context.push('/student/request');
        },
      ),
      _DrawerItem(
        icon: Icons.calendar_month,
        title: 'Attendance',
        onTap: () {
          Navigator.pop(context);
          context.push('/student/attendance');
        },
      ),
      _DrawerItem(
        icon: Icons.quiz,
        title: 'Tests',
        onTap: () {
          Navigator.pop(context);
          context.push('/student/tests');
        },
      ),
      _DrawerItem(
        icon: Icons.grade,
        title: 'Results',
        onTap: () {
          Navigator.pop(context);
          context.push('/student/results');
        },
      ),
      _DrawerItem(
        icon: Icons.book,
        title: 'Homework',
        onTap: () {
          Navigator.pop(context);
          context.push('/student/homework');
        },
      ),
      _DrawerItem(
        icon: Icons.workspace_premium,
        title: 'Batch Status',
        onTap: () {
          Navigator.pop(context);
          context.push('/student/batch');
        },
      ),
      _DrawerItem(
        icon: Icons.payment,
        title: 'Payment History',
        onTap: () {
          Navigator.pop(context);
          context.push('/student/payments');
        },
      ),
      _DrawerItem(
        icon: Icons.menu_book,
        title: 'Teaching Plans',
        onTap: () {
          Navigator.pop(context);
          context.push('/student/teaching-plans');
        },
      ),
    ];
  }

  List<Widget> _parentItems(BuildContext context) {
    return [
      _DrawerItem(
        icon: Icons.people,
        title: 'My Children',
        onTap: () {
          Navigator.pop(context);
          context.go('/parent/dashboard');
        },
      ),
    ];
  }

  List<Widget> _agentItems(BuildContext context) {
    return [
      _DrawerItem(
        icon: Icons.people,
        title: 'Referrals',
        onTap: () {
          Navigator.pop(context);
          context.push('/agent/referrals');
        },
      ),
      _DrawerItem(
        icon: Icons.account_balance_wallet,
        title: 'Wallet & Earnings',
        onTap: () {
          Navigator.pop(context);
          context.push('/agent/wallet');
        },
      ),
    ];
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Theme.of(context).primaryColor.withOpacity(0.8), size: 22),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
