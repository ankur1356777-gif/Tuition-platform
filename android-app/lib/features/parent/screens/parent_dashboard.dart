import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuition_app/services/auth_service.dart';
import '../services/parent_service.dart';
import 'child_progress_screen.dart';
import '../../shared/widgets/app_drawer.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/app_widgets.dart';

final parentDashboardProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(parentServiceProvider).getDashboard();
});

class ParentDashboard extends ConsumerWidget {
  const ParentDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authServiceProvider).currentUser;
    final dashboardAsync = ref.watch(parentDashboardProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: const AppDrawer(currentRole: 'parent'),
      body: Stack(
        children: [
          // Background
          Container(
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

          SafeArea(
            child: RefreshIndicator(
              onRefresh: () async => ref.refresh(parentDashboardProvider.future),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildAppBar(context, ref, user, isDark),
                  SliverToBoxAdapter(
                    child: dashboardAsync.when(
                      data: (data) => _buildDashboardContent(context, ref, user, data, isDark),
                      loading: () => const SizedBox(
                        height: 400,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (err, stack) => _buildErrorState(ref, err),
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
          onPressed: () => _showAddChildSheet(context, ref, isDark),
          backgroundColor: DesignSystem.secondary,
          elevation: 4,
          icon: const Icon(Icons.person_add_rounded, color: Colors.white),
          label: Text('Add Child', style: DesignSystem.bodyMedium(color: Colors.white)),
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
          icon: Icon(Icons.menu_open_rounded, color: isDark ? Colors.white : DesignSystem.backgroundDark),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_outlined, color: isDark ? Colors.white : DesignSystem.backgroundDark),
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
                      DesignSystem.getInitial(user?.name, 'P'),
                      style: DesignSystem.heading2(color: DesignSystem.primary),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome,',
                          style: DesignSystem.bodyMedium(color: Colors.grey[600]),
                        ),
                        Text(
                          user?.name ?? "Parent",
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

  Widget _buildDashboardContent(BuildContext context, WidgetRef ref, dynamic user, Map<String, dynamic> data, bool isDark) {
    final children = data['children'] as List<dynamic>? ?? [];
    
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
                label: "Total Children",
                value: "${data['total_children'] ?? 0}",
                icon: Icons.people_rounded,
                color: Colors.blue,
              ),
              StatTile(
                label: "Avg Score",
                value: "${data['avg_performance'] ?? 0}%",
                icon: Icons.auto_graph_rounded,
                color: Colors.green,
              ),
              StatTile(
                label: "Active Fees",
                value: "${data['active_tuitions'] ?? 0}",
                icon: Icons.payments_rounded,
                color: Colors.orange,
              ),
              StatTile(
                label: "Homework",
                value: "${data['pending_homework'] ?? 0}",
                icon: Icons.assignment_rounded,
                color: Colors.teal,
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Children's Progress",
                style: DesignSystem.heading3(color: isDark ? Colors.white : DesignSystem.backgroundDark),
              ),
              Text(
                '${children.length} Members',
                style: DesignSystem.bodySmall(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (children.isEmpty)
            _buildEmptyState(isDark)
          else
            ...children.map((child) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildChildCard(context, child, isDark),
            )),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildChildCard(BuildContext context, Map<String, dynamic> child, bool isDark) {
    final batch = child['batch'] ?? 'bronze';
    final latestScore = child['latest_test_score'];
    final progress = (latestScore ?? 0) / 100.0;

    return PremiumCard(
      glass: true,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChildProgressScreen(
              studentId: child['id'],
              childName: child['name'] ?? 'Child',
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: DesignSystem.secondary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    DesignSystem.getInitial(child['name'], 'C'),
                    style: DesignSystem.bodyLarge(color: DesignSystem.secondary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child['name'] ?? 'N/A',
                      style: DesignSystem.bodyLarge(color: null).copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Class ${child['class'] ?? 'N/A'} • ${child['school'] ?? 'N/A'}',
                      style: DesignSystem.bodySmall(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              RewardBadge(type: batch.toString().toLowerCase(), size: 36),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Performance',
                style: DesignSystem.bodySmall(color: isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: DesignSystem.bodySmall(color: DesignSystem.primary).copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: DesignSystem.primary.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 0.7 ? Colors.green : (progress > 0.4 ? Colors.orange : Colors.red),
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_month_rounded, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                'Attendance: ${child['attendance_percentage'] ?? 0}%',
                style: DesignSystem.bodySmall(color: Colors.grey),
              ),
              const Spacer(),
              Text(
                'View Report',
                style: DesignSystem.bodySmall(color: DesignSystem.primary),
              ),
              Icon(Icons.chevron_right_rounded, size: 16, color: DesignSystem.primary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return PremiumCard(
      glass: true,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Opacity(
                opacity: 0.5,
                child: Icon(Icons.child_care_rounded, size: 64, color: isDark ? Colors.white : DesignSystem.backgroundDark),
              ),
              const SizedBox(height: 16),
              Text(
                'No children linked yet',
                style: DesignSystem.bodyLarge(color: null),
              ),
              const SizedBox(height: 8),
              Text(
                'Add your child\'s phone number to start tracking',
                style: DesignSystem.bodySmall(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(WidgetRef ref, Object err) {
    return SizedBox(
      height: 400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: DesignSystem.error),
            const SizedBox(height: 16),
            Text('Error: $err', style: DesignSystem.bodySmall(color: Colors.grey)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => ref.refresh(parentDashboardProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddChildSheet(BuildContext context, WidgetRef ref, bool isDark) {
    final phoneController = TextEditingController();
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Link Your Child',
                style: DesignSystem.heading3(color: null),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the phone number used by your child during registration.',
                style: DesignSystem.bodySmall(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                style: DesignSystem.bodyLarge(color: null),
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_android_rounded),
                  hintText: 'e.g. 9876543210',
                ),
              ),
              const SizedBox(height: 24),
              GradientButton(
                text: 'Link Account',
                isLoading: isLoading,
                onPressed: () async {
                  if (phoneController.text.trim().isEmpty) return;
                  setSheetState(() => isLoading = true);
                  try {
                    await ref.read(parentServiceProvider).linkChild(phoneController.text.trim());
                    if (ctx.mounted) Navigator.pop(ctx);
                    ref.invalidate(parentDashboardProvider);
                  } catch (e) {
                    setSheetState(() => isLoading = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: DesignSystem.error),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
