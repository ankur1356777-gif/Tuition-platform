import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuition_app/services/auth_service.dart';
import 'package:go_router/go_router.dart';
import '../services/teacher_service.dart';
import '../../shared/widgets/app_drawer.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/app_widgets.dart';

final teacherDashboardProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(teacherServiceProvider).getDashboardStats();
});

class TeacherDashboard extends ConsumerWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authServiceProvider).currentUser;
    final dashboardAsync = ref.watch(teacherDashboardProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: const AppDrawer(currentRole: 'teacher'),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark 
                  ? [DesignSystem.backgroundDark, const Color(0xFF1E1E2E)]
                  : [const Color(0xFFF8FAFC), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () => ref.refresh(teacherDashboardProvider.future),
              child: CustomScrollView(
                slivers: [
                  _buildAppBar(context, ref, user, isDark),
                  SliverToBoxAdapter(
                    child: dashboardAsync.when(
                      data: (data) => _buildDashboardContent(context, user, data, isDark),
                      loading: () => const SizedBox(
                        height: 400,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (err, stack) => SizedBox(
                        height: 400,
                        child: Center(child: Text('Error: $err')),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, WidgetRef ref, dynamic user, bool isDark) {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.menu_rounded, color: isDark ? Colors.white : DesignSystem.backgroundDark),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_none_rounded, color: isDark ? Colors.white : DesignSystem.backgroundDark),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: DesignSystem.primary.withOpacity(0.2),
                    child: Text(
                      DesignSystem.getInitial(user?.name, 'T'),
                      style: DesignSystem.heading2(color: DesignSystem.primary),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: DesignSystem.bodyMedium(color: Colors.grey[600]),
                        ),
                        Text(
                          user?.name ?? "Teacher",
                          style: DesignSystem.heading2(color: isDark ? Colors.white : DesignSystem.backgroundDark),
                        ),
                      ],
                    ),
                  ),
                  if (user?.role == 'teacher' && user?.isHero == true)
                    const RewardBadge(type: 'hero', size: 40),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, dynamic user, Map<String, dynamic> data, bool isDark) {
    final stats = data['stats'] ?? {};
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.15,
            children: [
              StatTile(
                label: "Active Classes",
                value: "${stats['active_leads'] ?? 0}",
                icon: Icons.school_rounded,
                color: Colors.blue,
                onTap: () => context.push('/teacher/active-classes'),
              ),
              StatTile(
                label: "Earnings",
                value: "₹${stats['total_earnings'] ?? 0}",
                icon: Icons.account_balance_wallet_rounded,
                color: Colors.green,
                onTap: () => context.push('/teacher/wallet'),
              ),
              StatTile(
                label: "Demo Classes",
                value: "${stats['pending_demos'] ?? 0}",
                icon: Icons.timer_rounded,
                color: Colors.orange,
                onTap: () => context.push('/teacher/demos'),
              ),
              StatTile(
                label: "Attendance",
                value: "Mark",
                icon: Icons.event_available_rounded,
                color: Colors.purple,
                onTap: () => context.push('/teacher/attendance'),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          _buildSectionHeader("Quick Actions", isDark),
          const SizedBox(height: 12),
          PremiumCard(
            glass: true,
            child: Column(
              children: [
                _buildActionTile(
                  context,
                  "Available Tuitions",
                  "Browse student requirements near you",
                  Icons.location_on_rounded,
                  Colors.redAccent,
                  () => context.push('/teacher/available-requirements'),
                ),
                _buildDivider(),
                _buildActionTile(
                  context,
                  "My Active Leads",
                  "Manage current trial and active leads",
                  Icons.person_search_rounded,
                  Colors.blueAccent,
                  () => context.push('/teacher/leads'),
                ),
                _buildDivider(),
                _buildActionTile(
                  context,
                  "Leave Application",
                  "Request leave or check status",
                  Icons.beach_access_rounded,
                  Colors.teal,
                  () => context.push('/teacher/leaves'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          _buildSectionHeader("Academic Management", isDark),
          const SizedBox(height: 12),
          PremiumCard(
            glass: true,
            child: Column(
              children: [
                _buildActionTile(
                  context,
                  "Create New Test",
                  "Generate test for your students",
                  Icons.note_add_rounded,
                  Colors.indigo,
                  () => context.push('/teacher/tests/create'),
                ),
                _buildDivider(),
                _buildActionTile(
                  context,
                  "Homework Tracker",
                  "Assign and review daily tasks",
                  Icons.book_rounded,
                  Colors.orangeAccent,
                  () => context.push('/teacher/homework'),
                ),
                _buildDivider(),
                _buildActionTile(
                  context,
                  "Teaching Plans",
                  "Plan your weekly curriculum",
                  Icons.calendar_month_rounded,
                  Colors.cyan,
                  () => context.push('/teacher/teaching-plans'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: DesignSystem.heading3(color: isDark ? Colors.white : DesignSystem.backgroundDark),
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: DesignSystem.bodyLarge(color: null)),
                  Text(subtitle, style: DesignSystem.bodySmall(color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.grey.withOpacity(0.1));
  }
}
