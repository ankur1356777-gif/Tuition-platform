import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuition_app/services/auth_service.dart';
import 'package:go_router/go_router.dart';
import '../services/admin_service.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/app_widgets.dart';

final adminDashboardProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(adminServiceProvider).getDashboardStats();
});

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(adminDashboardProvider);
    final user = ref.watch(authServiceProvider).currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
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
              onRefresh: () async => ref.refresh(adminDashboardProvider.future),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildAppBar(context, ref, user, isDark),
                  SliverToBoxAdapter(
                    child: dashboardAsync.when(
                      data: (data) => _buildDashboardContent(context, data, isDark),
                      loading: () => const SizedBox(
                        height: 400,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (err, stack) => SizedBox(
                        height: 400,
                        child: Center(child: Text('Error: $err', style: DesignSystem.bodySmall(color: Colors.grey))),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? DesignSystem.cardDark : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: 0,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: DesignSystem.primary,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: DesignSystem.bodySmall(color: DesignSystem.primary).copyWith(fontWeight: FontWeight.bold),
          unselectedLabelStyle: DesignSystem.bodySmall(color: Colors.grey),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: 'Teachers'),
            BottomNavigationBarItem(icon: Icon(Icons.school_rounded), label: 'Students'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_suggest_rounded), label: 'System'),
          ],
          onTap: (index) {
            if (index == 1) context.push('/admin/teachers');
            if (index == 2) context.push('/admin/students');
            if (index == 3) context.push('/admin/settings');
          },
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
      actions: [
        IconButton(
          icon: Icon(Icons.logout_rounded, color: isDark ? Colors.white : DesignSystem.backgroundDark),
          onPressed: () => ref.read(authServiceProvider).logout(),
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
                   Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: DesignSystem.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'System Administrator',
                          style: DesignSystem.bodyMedium(color: Colors.grey[600]),
                        ),
                        Text(
                          user?.name ?? "Admin",
                          style: DesignSystem.heading2(color: isDark ? Colors.white : DesignSystem.backgroundDark),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, Map<String, dynamic> data, bool isDark) {
    final stats = data['stats'];
    final pendingTeachers = data['pending_teachers'] as List? ?? [];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Platform Metrics", isDark),
          const SizedBox(height: 16),
          _buildAdminStatGrid(context, stats),
          
          const SizedBox(height: 32),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionHeader("Pending Approvals", isDark),
              if (pendingTeachers.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: DesignSystem.error.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text('${pendingTeachers.length} New', style: DesignSystem.bodySmall(color: DesignSystem.error).copyWith(fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPendingApprovals(context, pendingTeachers, isDark),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildAdminStatGrid(BuildContext context, Map<String, dynamic> stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.15,
      children: [
        StatTile(
          label: "Total Teachers",
          value: "${stats['total_teachers'] ?? 0}",
          icon: Icons.people_rounded,
          color: Colors.indigo,
          onTap: () => context.push('/admin/teachers'),
        ),
        StatTile(
          label: "Total Students",
          value: "${stats['total_students'] ?? 0}",
          icon: Icons.school_rounded,
          color: Colors.blue,
          onTap: () => context.push('/admin/students'),
        ),
        StatTile(
          label: "Revenue",
          value: "₹${stats['monthly_revenue'] ?? 0}",
          icon: Icons.account_balance_rounded,
          color: Colors.green,
          onTap: () => context.push('/admin/payouts'),
        ),
        StatTile(
          label: "Lead Status",
          value: "Action",
          icon: Icons.vpn_key_rounded,
          color: Colors.orange,
          onTap: () => context.push('/admin/lead-approvals'),
        ),
        StatTile(
          label: "Referrer Agents",
          value: "Manage",
          icon: Icons.support_agent_rounded,
          color: Colors.purple,
          onTap: () => context.push('/admin/agents'),
        ),
        StatTile(
          label: "Broadcast",
          value: "Notify",
          icon: Icons.campaign_rounded,
          color: Colors.deepOrange,
          onTap: () => context.push('/admin/broadcast'),
        ),
      ],
    );
  }

  Widget _buildPendingApprovals(BuildContext context, List pendingTeachers, bool isDark) {
    if (pendingTeachers.isEmpty) {
      return const PremiumCard(
        glass: true,
        child: Center(child: Padding(padding: EdgeInsets.all(32.0), child: Text("All caught up! No pending approvals."))),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pendingTeachers.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final teacher = pendingTeachers[index];
        return PremiumCard(
          glass: true,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: DesignSystem.primary.withOpacity(0.1),
              child: Text(DesignSystem.getInitial(teacher['name'], 'T'), style: TextStyle(color: DesignSystem.primary)),
            ),
            title: Text(teacher['name'] ?? 'Unknown', style: DesignSystem.bodyLarge(color: null).copyWith(fontWeight: FontWeight.bold)),
            subtitle: Text(teacher['email'] ?? 'No email', style: DesignSystem.bodySmall(color: Colors.grey)),
            trailing: TextButton(
              onPressed: () {},
              child: Text('Review', style: DesignSystem.bodySmall(color: DesignSystem.primary).copyWith(fontWeight: FontWeight.bold)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: DesignSystem.heading3(color: isDark ? Colors.white : DesignSystem.backgroundDark),
    );
  }
}
