import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuition_app/services/auth_service.dart';
import 'package:go_router/go_router.dart';
import '../services/student_service.dart';
import '../../shared/widgets/app_drawer.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/app_widgets.dart';

final studentDashboardProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(studentServiceProvider).getDashboardStats();
});

class StudentDashboard extends ConsumerWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authServiceProvider).currentUser;
    final dashboardAsync = ref.watch(studentDashboardProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: const AppDrawer(currentRole: 'student'),
      body: Stack(
        children: [
          // Background
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
            child: RefreshIndicator(
              onRefresh: () => ref.refresh(studentDashboardProvider.future),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: FloatingActionButton.extended(
          onPressed: () => context.push('/student/request'),
          backgroundColor: DesignSystem.primary,
          elevation: 4,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: Text('New Request', style: DesignSystem.bodyMedium(color: Colors.white)),
        ),
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
          icon: Icon(Icons.grid_view_rounded, color: isDark ? Colors.white : DesignSystem.backgroundDark),
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
                    backgroundColor: DesignSystem.secondary.withOpacity(0.2),
                    child: Text(
                      DesignSystem.getInitial(user?.name, 'S'),
                      style: DesignSystem.heading2(color: DesignSystem.secondary),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Keep learning,',
                          style: DesignSystem.bodyMedium(color: Colors.grey[600]),
                        ),
                        Text(
                          user?.name ?? "Student",
                          style: DesignSystem.heading2(color: isDark ? Colors.white : DesignSystem.backgroundDark),
                        ),
                      ],
                    ),
                  ),
                  if (user?.role == 'student' && user?.badge != null)
                    RewardBadge(type: user?.badge ?? 'silver', size: 44),
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
    final requests = data['recent_requests'] as List? ?? [];
    
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
                label: "Classes",
                value: "${stats['active_tuitions'] ?? 0}",
                icon: Icons.class_rounded,
                color: Colors.indigo,
                onTap: () => context.push('/student/active-tuitions'),
              ),
              StatTile(
                label: "Attendance",
                value: "${stats['attendance_percentage'] ?? 0}%",
                icon: Icons.calendar_month_rounded,
                color: Colors.green,
                onTap: () => context.push('/student/attendance'),
              ),
              StatTile(
                label: "Homework",
                value: "View",
                icon: Icons.assignment_rounded,
                color: Colors.orange,
                onTap: () => context.push('/student/homework'),
              ),
              StatTile(
                label: "Tests",
                value: "Start",
                icon: Icons.quiz_rounded,
                color: Colors.purple,
                onTap: () => context.push('/student/tests'),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          _buildSectionHeader("Academic Progress", isDark),
          const SizedBox(height: 12),
          PremiumCard(
            glass: true,
            child: Column(
              children: [
                _buildActionTile(
                  context,
                  "My Results",
                  "Check your performance and grades",
                  Icons.grade_rounded,
                  Colors.amber,
                  () => context.push('/student/results'),
                ),
                _buildDivider(),
                _buildActionTile(
                  context,
                  "Batch Status",
                  "Current rank: ${stats['batch']?.toUpperCase() ?? 'BRONZE'}",
                  Icons.workspace_premium_rounded,
                  Colors.blueAccent,
                  () => context.push('/student/batch'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionHeader("Recent Requests", isDark),
              TextButton(
                onPressed: () {},
                child: Text('View All', style: DesignSystem.bodySmall(color: DesignSystem.primary)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (requests.isEmpty)
             const PremiumCard(
                glass: true,
                child: Center(child: Padding(padding: EdgeInsets.all(16), child: Text("No requests yet"))),
              )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: requests.length > 3 ? 3 : requests.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final req = requests[index];
                return PremiumCard(
                  glass: true,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('${req['subjects'][0]} (Class ${req['class']})', style: DesignSystem.bodyLarge(color: null)),
                    subtitle: Text('Status: ${req['status'].toString().toUpperCase()}', style: DesignSystem.bodySmall(color: Colors.grey)),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                  ),
                );
              },
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
