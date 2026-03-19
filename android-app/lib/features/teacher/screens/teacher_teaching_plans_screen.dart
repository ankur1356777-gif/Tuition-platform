import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../services/teacher_service.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/app_widgets.dart';

final teachingPlansProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(teacherServiceProvider).getTeachingPlans();
});

class TeacherTeachingPlansScreen extends ConsumerStatefulWidget {
  const TeacherTeachingPlansScreen({super.key});

  @override
  ConsumerState<TeacherTeachingPlansScreen> createState() => _TeacherTeachingPlansScreenState();
}

class _TeacherTeachingPlansScreenState extends ConsumerState<TeacherTeachingPlansScreen> {
  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(teachingPlansProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DesignSystem.backgroundDark : const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text('Academic Planner', style: DesignSystem.heading3(color: null)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : DesignSystem.backgroundDark),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePlanDialog(context),
        backgroundColor: DesignSystem.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
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
          data: (plans) => _buildPlansList(plans, isDark),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err', style: DesignSystem.bodySmall(color: Colors.grey))),
        ),
      ),
    );
  }

  Widget _buildPlansList(List<dynamic> plans, bool isDark) {
    if (plans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: 0.3,
              child: Icon(Icons.menu_book_rounded, size: 80, color: isDark ? Colors.white : DesignSystem.backgroundDark),
            ),
            const SizedBox(height: 24),
            Text('No Plans Created', style: DesignSystem.heading3(color: null)),
            const SizedBox(height: 8),
            Text('Start by creating your first weekly teaching plan.', style: DesignSystem.bodySmall(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      physics: const BouncingScrollPhysics(),
      itemCount: plans.length,
      itemBuilder: (context, index) {
        final plan = plans[index];
        final weekStart = DateTime.tryParse(plan['week_start'] ?? '') ?? DateTime.now();
        final weekEnd = weekStart.add(const Duration(days: 6));
        final plannedTopics = List<String>.from(plan['planned_topics'] ?? []);
        final completedTopics = List<String>.from(plan['completed_topics'] ?? []);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: PremiumCard(
            glass: true,
            padding: EdgeInsets.zero,
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(plan['status']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_getStatusIcon(plan['status']), color: _getStatusColor(plan['status']), size: 20),
                ),
                title: Text(
                  'Week: ${DateFormat('dd MMM').format(weekStart)} - ${DateFormat('dd MMM').format(weekEnd)}',
                  style: DesignSystem.bodyMedium(color: null).copyWith(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${completedTopics.length}/${plannedTopics.length} Topics Covered',
                  style: DesignSystem.bodySmall(color: Colors.grey),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(height: 1),
                        const SizedBox(height: 16),
                        Text('LEAD TOPICS', style: DesignSystem.bodySmall(color: DesignSystem.primary).copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 10)),
                        const SizedBox(height: 12),
                        ...plannedTopics.map((topic) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Icon(
                                completedTopics.contains(topic) ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
                                size: 18,
                                color: completedTopics.contains(topic) ? Colors.green : Colors.grey.withOpacity(0.5),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(topic, style: DesignSystem.bodySmall(color: null).copyWith(
                                decoration: completedTopics.contains(topic) ? TextDecoration.lineThrough : null,
                                color: completedTopics.contains(topic) ? Colors.grey : null,
                              ))),
                            ],
                          ),
                        )),
                        if (plan['status'] == 'incomplete' && plan['incomplete_reason'] != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: DesignSystem.error.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: DesignSystem.error.withOpacity(0.1))),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline_rounded, color: DesignSystem.error, size: 16),
                                const SizedBox(width: 8),
                                Expanded(child: Text(plan['incomplete_reason'], style: DesignSystem.bodySmall(color: DesignSystem.error))),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        if (plan['status'] != 'completed')
                          GradientButton(
                            text: 'UPDATE PROGRESS',
                            onPressed: () => _markTopicsComplete(plan['id'], plannedTopics, completedTopics),
                            icon: Icons.edit_note_rounded,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'completed': return Colors.green;
      case 'in_progress': return DesignSystem.primary;
      case 'incomplete': return DesignSystem.error;
      default: return Colors.orange;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'completed': return Icons.verified_rounded;
      case 'in_progress': return Icons.history_edu_rounded;
      case 'incomplete': return Icons.report_problem_rounded;
      default: return Icons.pending_actions_rounded;
    }
  }

  void _markTopicsComplete(int planId, List<String> allTopics, List<String> alreadyCompleted) {
    final selectedTopics = List<String>.from(alreadyCompleted);
    final reasonController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final allDone = selectedTopics.length == allTopics.length;

          return Container(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 32, left: 24, right: 24, top: 32),
            decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E2E) : Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(32))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Update Progress', style: DesignSystem.heading3(color: null)),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 24),
                ...allTopics.map((topic) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => setModalState(() {
                      if (selectedTopics.contains(topic)) selectedTopics.remove(topic); else selectedTopics.add(topic);
                    }),
                    borderRadius: BorderRadius.circular(12),
                    child: PremiumCard(
                      glass: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Icon(selectedTopics.contains(topic) ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded, color: selectedTopics.contains(topic) ? DesignSystem.primary : Colors.grey),
                          const SizedBox(width: 12),
                          Expanded(child: Text(topic, style: DesignSystem.bodyMedium(color: null))),
                        ],
                      ),
                    ),
                  ),
                )),
                if (!allDone) ...[
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Text('WHY ARE SOME TOPICS INCOMPLETE?', style: DesignSystem.bodySmall(color: DesignSystem.error).copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 10)),
                  ),
                  CustomTextField(controller: reasonController, hintText: 'Enter reason...', prefixIcon: Icons.error_outline_rounded, maxLines: 2),
                ],
                const SizedBox(height: 32),
                GradientButton(
                  text: 'SAVE PROGRESS',
                  onPressed: () async {
                    if (!allDone && reasonController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reason required for incomplete topics'))); return;
                    }
                    try {
                      await ref.read(teacherServiceProvider).updateTeachingPlan(planId, {'completed_topics': selectedTopics, 'status': allDone ? 'completed' : 'incomplete', 'incomplete_reason': allDone ? null : reasonController.text.trim()});
                      Navigator.pop(context); ref.invalidate(teachingPlansProvider);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Updated successfully'), backgroundColor: Colors.green));
                    } catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: DesignSystem.error)); }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showCreatePlanDialog(BuildContext context) {
    DateTime selectedWeekStart = DateTime.now();
    final topicsController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setModalState) => Container(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 32, left: 24, right: 24, top: 32),
            decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E2E) : Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(32))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('New Weekly Plan', style: DesignSystem.heading3(color: null)),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 24),
                _DatePickerField(
                  label: 'WEEK STARTING',
                  date: selectedWeekStart,
                  onTap: () async {
                    final date = await showDatePicker(context: context, initialDate: selectedWeekStart, firstDate: DateTime.now().subtract(const Duration(days: 7)), lastDate: DateTime.now().add(const Duration(days: 365)));
                    if (date != null) setModalState(() => selectedWeekStart = date);
                  },
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text('PLANNED TOPICS', style: DesignSystem.bodySmall(color: DesignSystem.primary).copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 10)),
                ),
                CustomTextField(controller: topicsController, hintText: 'Topic 1, Topic 2, Topic 3...', prefixIcon: Icons.list_alt_rounded, maxLines: 3),
                const SizedBox(height: 32),
                GradientButton(
                  text: 'CREATE PLAN',
                  onPressed: () async {
                    if (topicsController.text.isEmpty) return;
                    final topics = topicsController.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
                    try {
                      await ref.read(teacherServiceProvider).createTeachingPlan({'week_start': selectedWeekStart.toIso8601String(), 'planned_topics': topics});
                      Navigator.pop(context); ref.invalidate(teachingPlansProvider);
                    } catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: DesignSystem.error)); }
                  },
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  const _DatePickerField({required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: PremiumCard(
        glass: true,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: DesignSystem.bodySmall(color: Colors.grey).copyWith(fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(date != null ? DateFormat('dd MMM yyyy').format(date!) : 'Select Date', style: DesignSystem.bodyMedium(color: null).copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            Icon(Icons.calendar_today_rounded, size: 20, color: DesignSystem.primary),
          ],
        ),
      ),
    );
  }
}
