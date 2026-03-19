import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/teacher_service.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/app_widgets.dart';

final weeklyTestsProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(teacherServiceProvider).getWeeklyTests();
});

class TeacherWeeklyTestsScreen extends ConsumerStatefulWidget {
  const TeacherWeeklyTestsScreen({super.key});

  @override
  ConsumerState<TeacherWeeklyTestsScreen> createState() => _TeacherWeeklyTestsScreenState();
}

class _TeacherWeeklyTestsScreenState extends ConsumerState<TeacherWeeklyTestsScreen> {
  @override
  Widget build(BuildContext context) {
    final testsAsync = ref.watch(weeklyTestsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DesignSystem.backgroundDark : const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text('Weekly Tests', style: DesignSystem.heading3(color: null)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : DesignSystem.backgroundDark),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showScheduleTestSheet(context),
        backgroundColor: DesignSystem.primary,
        label: Text('SCHEDULE TEST', style: DesignSystem.bodySmall(color: Colors.white).copyWith(fontWeight: FontWeight.bold, letterSpacing: 1)),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
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
        child: testsAsync.when(
          data: (tests) => _buildTestsList(context, tests as List? ?? [], isDark),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err', style: DesignSystem.bodySmall(color: Colors.grey))),
        ),
      ),
    );
  }

  Widget _buildTestsList(BuildContext context, List<dynamic> tests, bool isDark) {
    if (tests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: 0.3,
              child: Icon(Icons.quiz_rounded, size: 80, color: isDark ? Colors.white : DesignSystem.backgroundDark),
            ),
            const SizedBox(height: 24),
            Text('No Tests Scheduled', style: DesignSystem.heading3(color: null)),
            const SizedBox(height: 8),
            Text('Scheduled weekly tests will appear here.', style: DesignSystem.bodySmall(color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(weeklyTestsProvider),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        physics: const BouncingScrollPhysics(),
        itemCount: tests.length,
        itemBuilder: (context, index) {
          final test = tests[index] as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _TestCard(test: test),
          );
        },
      ),
    );
  }

  void _showScheduleTestSheet(BuildContext context) {
    final subjectController = TextEditingController();
    final marksController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, spreadRadius: 5)],
          ),
          padding: EdgeInsets.only(
            left: 28,
            right: 28,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 24),
              Text('Schedule Test', style: DesignSystem.heading2(color: null)),
              const SizedBox(height: 24),
              TextField(
                controller: subjectController,
                decoration: DesignSystem.inputDecoration('Subject', Icons.subject_rounded),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: marksController,
                keyboardType: TextInputType.number,
                decoration: DesignSystem.inputDecoration('Total Marks', Icons.grade_rounded),
              ),
              const SizedBox(height: 16),
              PremiumCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today_rounded, size: 20, color: DesignSystem.primary),
                  title: Text('Scheduled Date', style: DesignSystem.bodySmall(color: Colors.grey)),
                  subtitle: Text(selectedDate.toString().split(' ')[0], style: DesignSystem.bodyMedium(color: null).copyWith(fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.edit_rounded, size: 18),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                    );
                    if (picked != null) setSheetState(() => selectedDate = picked);
                  },
                ),
              ),
              const SizedBox(height: 32),
              GradientButton(
                text: 'SCHEDULE NOW',
                onPressed: isLoading ? null : () async {
                  if (subjectController.text.trim().isEmpty) return;
                  setSheetState(() => isLoading = true);
                  try {
                    await ref.read(teacherServiceProvider).scheduleWeeklyTest({
                      'subject': subjectController.text.trim(),
                      'total_marks': int.tryParse(marksController.text) ?? 100,
                      'scheduled_date': selectedDate.toIso8601String().split('T')[0],
                    });
                    if (ctx.mounted) Navigator.pop(ctx);
                    ref.invalidate(weeklyTestsProvider);
                  } catch (e) {
                    setSheetState(() => isLoading = false);
                  }
                },
                loading: isLoading,
                icon: Icons.check_circle_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TestCard extends StatelessWidget {
  final Map<String, dynamic> test;
  const _TestCard({required this.test});

  @override
  Widget build(BuildContext context) {
    final status = test['status'] ?? 'scheduled';
    Color statusColor = status == 'completed' ? Colors.green : (status == 'cancelled' ? DesignSystem.error : DesignSystem.primary);
    
    return PremiumCard(
      glass: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(test['subject']?.toUpperCase() ?? 'WEEKLY TEST', style: DesignSystem.bodySmall(color: DesignSystem.primary).copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 10)),
              _StatusBadge(status: status, color: statusColor),
            ],
          ),
          const SizedBox(height: 16),
          Text(test['title'] ?? 'Full Syllabus Test', style: DesignSystem.heading3(color: null)),
          const SizedBox(height: 16),
          Row(
            children: [
              _InfoItem(icon: Icons.calendar_today_rounded, label: test['scheduled_date'] ?? 'N/A'),
              const SizedBox(width: 20),
              _InfoItem(icon: Icons.person_rounded, label: test['student_name'] ?? 'Student'),
            ],
          ),
          const SizedBox(height: 8),
          _InfoItem(icon: Icons.grade_rounded, label: 'Total Marks: ${test['total_marks'] ?? 100}'),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;
  const _StatusBadge({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.2))),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 9, letterSpacing: 0.5)),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 6),
        Text(label, style: DesignSystem.bodySmall(color: Colors.grey)),
      ],
    );
  }
}
