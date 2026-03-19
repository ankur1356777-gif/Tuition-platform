import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../services/student_service.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/app_widgets.dart';

final studentHomeworkProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(studentServiceProvider).getHomework();
});

class StudentHomeworkScreen extends ConsumerStatefulWidget {
  const StudentHomeworkScreen({super.key});

  @override
  ConsumerState<StudentHomeworkScreen> createState() => _StudentHomeworkScreenState();
}

class _StudentHomeworkScreenState extends ConsumerState<StudentHomeworkScreen> {
  final _answerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final homeworkAsync = ref.watch(studentHomeworkProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DesignSystem.backgroundDark : const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text('My Homework', style: DesignSystem.heading3(color: null)),
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
        child: homeworkAsync.when(
          data: (homework) => _buildHomeworkList(homework, isDark),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err', style: DesignSystem.bodySmall(color: Colors.grey))),
        ),
      ),
    );
  }

  Widget _buildHomeworkList(List<dynamic> homework, bool isDark) {
    if (homework.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: 0.3,
              child: Icon(Icons.assignment_turned_in_outlined, size: 80, color: isDark ? Colors.white : DesignSystem.backgroundDark),
            ),
            const SizedBox(height: 24),
            Text('All Caught Up!', style: DesignSystem.heading3(color: null)),
            const SizedBox(height: 8),
            Text('No pending homework assignments found.', style: DesignSystem.bodySmall(color: Colors.grey), textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: homework.length,
      separatorBuilder: (context, index) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final hw = homework[index];
        return _HomeworkCard(
          hw: hw, 
          isDark: isDark,
          onSubmit: () => _showSubmitDialog(hw['id'], hw['title'], isDark),
        );
      },
    );
  }

  void _showSubmitDialog(int homeworkId, String? title, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2E2E3E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: DesignSystem.shadowMedium,
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24, right: 24, top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: Text('Submit Homework', style: DesignSystem.heading3(color: null))),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(title ?? 'Untitled Assignment', style: DesignSystem.bodySmall(color: Colors.grey)),
              const SizedBox(height: 24),
              TextField(
                controller: _answerController,
                maxLines: 5,
                style: DesignSystem.bodyMedium(color: null),
                decoration: InputDecoration(
                  hintText: 'Write your answer or solution here...',
                  hintStyle: DesignSystem.bodySmall(color: Colors.grey),
                  filled: true,
                  fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              GradientButton(
                text: 'SUBMIT NOW',
                onPressed: () async {
                  if (_answerController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please write your answer'), backgroundColor: Colors.red),
                    );
                    return;
                  }
                  
                  try {
                    await ref.read(studentServiceProvider).submitHomework(homeworkId, {
                      'answer': _answerController.text,
                    });
                    Navigator.pop(context);
                    _answerController.clear();
                    ref.invalidate(studentHomeworkProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Homework submitted successfully!'), backgroundColor: Colors.green),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                    );
                  }
                },
                icon: Icons.send_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeworkCard extends StatelessWidget {
  final dynamic hw;
  final bool isDark;
  final VoidCallback onSubmit;

  const _HomeworkCard({required this.hw, required this.isDark, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    final dueDate = DateTime.tryParse(hw['due_date'] ?? '') ?? DateTime.now();
    final isOverdue = dueDate.isBefore(DateTime.now());
    final submission = hw['my_submission'];

    return PremiumCard(
      glass: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hw['title'] ?? 'Untitled',
                      style: DesignSystem.heading3(color: null).copyWith(fontSize: 16),
                    ),
                    Text(hw['subject'] ?? 'General', style: DesignSystem.bodySmall(color: DesignSystem.primary)),
                  ],
                ),
              ),
              _buildStatusBadge(hw['status'], submission),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            hw['description'] ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: DesignSystem.bodySmall(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 14, color: isOverdue ? DesignSystem.error : Colors.grey),
              const SizedBox(width: 4),
              Text(
                'Due: ${DateFormat('dd MMM yyyy').format(dueDate)}',
                style: DesignSystem.bodySmall(color: isOverdue ? DesignSystem.error : Colors.grey),
              ),
            ],
          ),
          if (submission != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),
            if (submission['marks'] != null)
              Row(
                children: [
                  Icon(Icons.stars_rounded, color: Colors.amber.shade700, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Score: ${submission['marks']}/100',
                    style: DesignSystem.bodyMedium(color: null).copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            if (submission['remarks'] != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: DesignSystem.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: DesignSystem.primary.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TEACHER REMARKS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: DesignSystem.primary, letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    Text(submission['remarks'], style: DesignSystem.bodySmall(color: null)),
                  ],
                ),
              ),
            ],
          ] else ...[
            const SizedBox(height: 20),
            GradientButton(
              text: isOverdue ? 'OVERDUE' : 'SUBMIT HOMEWORK',
              onPressed: isOverdue ? null : onSubmit,
              icon: Icons.upload_rounded,
              height: 44,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String? status, dynamic submission) {
    String label = 'Pending';
    Color color = Colors.orange;

    if (submission != null && submission['marks'] != null) {
      label = 'GRADED';
      color = Colors.green;
    } else if (submission != null) {
      label = 'SUBMITTED';
      color = DesignSystem.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }
}
