import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/student_service.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/app_widgets.dart';

final teachingPlansProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(studentServiceProvider).getTeachingPlans();
});

class StudentTeachingPlansScreen extends ConsumerWidget {
  const StudentTeachingPlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(teachingPlansProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DesignSystem.backgroundDark : const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text('Teaching Plans', style: DesignSystem.heading3(color: null)),
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
        child: plansAsync.when(
          data: (plans) {
            final planList = plans as List? ?? [];
            if (planList.isEmpty) {
              return _buildEmptyState(isDark);
            }
            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(teachingPlansProvider),
              child: ListView.separated(
                padding: const EdgeInsets.all(24),
                itemCount: planList.length,
                separatorBuilder: (context, index) => const SizedBox(height: 20),
                itemBuilder: (context, index) {
                  final plan = planList[index] as Map<String, dynamic>;
                  return _PlanCard(plan: plan, isDark: isDark);
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: $err', style: DesignSystem.bodySmall(color: Colors.grey)),
                const SizedBox(height: 16),
                GradientButton(
                  text: 'RETRY',
                  onPressed: () => ref.invalidate(teachingPlansProvider),
                  width: 120,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: 0.3,
            child: Icon(Icons.menu_book_rounded, size: 80, color: isDark ? Colors.white : DesignSystem.backgroundDark),
          ),
          const SizedBox(height: 24),
          Text('No Plans Yet', style: DesignSystem.heading3(color: null)),
          const SizedBox(height: 8),
          Text('Your teacher\'s lesson plans will appear here.', style: DesignSystem.bodySmall(color: Colors.grey), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final Map<String, dynamic> plan;
  final bool isDark;
  const _PlanCard({required this.plan, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final status = plan['status']?.toString().toLowerCase() ?? 'draft';
    Color statusColor = Colors.grey;
    if (status == 'active') statusColor = DesignSystem.primary;
    if (status == 'completed') statusColor = Colors.green;

    return PremiumCard(
      glass: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  plan['title'] ?? plan['subject'] ?? 'Teaching Plan',
                  style: DesignSystem.heading3(color: null).copyWith(fontSize: 16),
                ),
              ),
              _buildStatusBadge(status, statusColor),
            ],
          ),
          const SizedBox(height: 12),
          if (plan['teacher_name'] != null)
            Row(
              children: [
                Icon(Icons.person_outline_rounded, size: 14, color: DesignSystem.primary),
                const SizedBox(width: 4),
                Text(plan['teacher_name'], style: DesignSystem.bodySmall(color: Colors.grey)),
              ],
            ),
          const SizedBox(height: 4),
          if (plan['week_start'] != null)
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${plan['week_start']} - ${plan['week_end'] ?? ''}',
                  style: DesignSystem.bodySmall(color: Colors.grey),
                ),
              ],
            ),
          if (plan['topics'] != null) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: (plan['topics'] is List
                      ? plan['topics'] as List
                      : [plan['topics'].toString()])
                  .map<Widget>((topic) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: DesignSystem.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: DesignSystem.primary.withOpacity(0.1)),
                        ),
                        child: Text(topic.toString(), style: TextStyle(fontSize: 10, color: DesignSystem.primary, fontWeight: FontWeight.w500)),
                      ))
                  .toList(),
            ),
          ],
          if (plan['notes'] != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                plan['notes'],
                style: DesignSystem.bodySmall(color: null).copyWith(fontSize: 12),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }
}
