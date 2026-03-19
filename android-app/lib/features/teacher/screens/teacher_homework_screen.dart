import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../services/teacher_service.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/app_widgets.dart';

final teacherHomeworkProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(teacherServiceProvider).getHomework();
});

class TeacherHomeworkScreen extends ConsumerStatefulWidget {
  const TeacherHomeworkScreen({super.key});

  @override
  ConsumerState<TeacherHomeworkScreen> createState() => _TeacherHomeworkScreenState();
}

class _TeacherHomeworkScreenState extends ConsumerState<TeacherHomeworkScreen> {
  @override
  Widget build(BuildContext context) {
    final homeworkAsync = ref.watch(teacherHomeworkProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DesignSystem.backgroundDark : const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text('Homework Management', style: DesignSystem.heading3(color: null)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : DesignSystem.backgroundDark),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateHomeworkDialog(context),
        backgroundColor: DesignSystem.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
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
              child: Icon(Icons.book_outlined, size: 80, color: isDark ? Colors.white : DesignSystem.backgroundDark),
            ),
            const SizedBox(height: 24),
            Text('No Homework Assigned', style: DesignSystem.heading3(color: null)),
            const SizedBox(height: 8),
            Text('Tasks you assign to students will appear here.', style: DesignSystem.bodySmall(color: Colors.grey), textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      itemCount: homework.length,
      itemBuilder: (context, index) {
        final hw = homework[index];
        final dueDate = DateTime.tryParse(hw['due_date'] ?? '') ?? DateTime.now();
        final isOverdue = dueDate.isBefore(DateTime.now()) && hw['status'] != 'reviewed';
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: PremiumCard(
            glass: true,
            onTap: () => _viewSubmissions(hw['id']),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getStatusColor(hw['status']).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    hw['status'] == 'reviewed' ? Icons.verified_rounded : Icons.menu_book_rounded,
                    color: _getStatusColor(hw['status']),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(hw['title'] ?? 'Untitled Task', style: DesignSystem.bodyLarge(color: null).copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: DesignSystem.primary.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(hw['subject'] ?? 'General', style: DesignSystem.bodySmall(color: DesignSystem.primary).copyWith(fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.access_time_rounded, size: 12, color: isOverdue ? DesignSystem.error : Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('dd MMM').format(dueDate),
                            style: DesignSystem.bodySmall(color: isOverdue ? DesignSystem.error : Colors.grey).copyWith(fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${hw['submissions_count'] ?? 0}',
                      style: DesignSystem.heading3(color: DesignSystem.primary).copyWith(fontSize: 18),
                    ),
                    Text('Submissions', style: DesignSystem.bodySmall(color: Colors.grey).copyWith(fontSize: 9)),
                  ],
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'reviewed': return Colors.green;
      case 'submitted': return Colors.blue;
      default: return Colors.orange;
    }
  }

  void _viewSubmissions(int homeworkId) {
    // Navigation logic for submissions
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening submissions gallery...')),
    );
  }

  void _showCreateHomeworkDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final subjectController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
            left: 24, right: 24, top: 32,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Assign Homework', style: DesignSystem.heading3(color: null)),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildFieldLabel('TASK TITLE'),
              CustomTextField(
                controller: titleController,
                hintText: 'e.g. Chapter 4 Exercises',
                prefixIcon: Icons.title_rounded,
              ),
              const SizedBox(height: 20),
              _buildFieldLabel('SUBJECT'),
              CustomTextField(
                controller: subjectController,
                hintText: 'e.g. Mathematics',
                prefixIcon: Icons.subject_rounded,
              ),
              const SizedBox(height: 20),
              _buildFieldLabel('DESCRIPTION'),
              CustomTextField(
                controller: descController,
                hintText: 'Assign specific problems or reading...',
                prefixIcon: Icons.description_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              _buildFieldLabel('DUE DATE'),
              PremiumCard(
                glass: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (date != null) setModalState(() => selectedDate = date);
                },
                child: Row(
                  children: [
                    Icon(Icons.calendar_month_rounded, color: DesignSystem.primary, size: 20),
                    const SizedBox(width: 16),
                    Text(DateFormat('EEEE, dd MMMM yyyy').format(selectedDate), style: DesignSystem.bodyMedium(color: null)),
                    const Spacer(),
                    const Icon(Icons.edit_calendar_rounded, color: Colors.grey, size: 18),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              GradientButton(
                text: 'PUBLISH HOMEWORK',
                onPressed: () async {
                  if (titleController.text.isEmpty) return;
                  
                  try {
                    await ref.read(teacherServiceProvider).createHomework({
                      'title': titleController.text,
                      'description': descController.text,
                      'subject': subjectController.text,
                      'due_date': selectedDate.toIso8601String(),
                      'paid_tuition_id': null, // Can be expanded for specific class selección
                    });
                    if (context.mounted) {
                      Navigator.pop(context);
                      ref.invalidate(teacherHomeworkProvider);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Homework published successfully!'), backgroundColor: Colors.green),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed: $e'), backgroundColor: DesignSystem.error),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: DesignSystem.bodySmall(color: DesignSystem.primary).copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 10),
      ),
    );
  }
}
