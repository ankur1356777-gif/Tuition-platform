import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/student_service.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/app_widgets.dart';

class StudentTestsScreen extends ConsumerWidget {
  const StudentTestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testsAsync = ref.watch(availableTestsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DesignSystem.backgroundDark : const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text('Available Tests', style: DesignSystem.heading3(color: null)),
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
        child: testsAsync.when(
          data: (tests) {
            if (tests.isEmpty) {
              return _buildEmptyState(isDark);
            }
            return ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: tests.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final test = tests[index];
                return _TestCard(test: test, isDark: isDark);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err', style: DesignSystem.bodySmall(color: Colors.grey))),
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
            opacity: 0.5,
            child: Icon(Icons.assignment_turned_in_rounded, size: 80, color: isDark ? Colors.white : DesignSystem.backgroundDark),
          ),
          const SizedBox(height: 24),
          Text('No Pending Tests', style: DesignSystem.heading3(color: null)),
          const SizedBox(height: 8),
          Text('Great job! You\'ve completed all your currently assigned tests.', style: DesignSystem.bodySmall(color: Colors.grey), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _TestCard extends StatelessWidget {
  final dynamic test;
  final bool isDark;
  const _TestCard({required this.test, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      glass: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: DesignSystem.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.quiz_rounded, color: DesignSystem.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      test['title'] ?? 'Untitled Test',
                      style: DesignSystem.bodyLarge(color: null).copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      test['subject'] ?? 'General',
                      style: DesignSystem.bodySmall(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildInfoChip(Icons.timer_outlined, '${test['duration_minutes']} Mins'),
              const SizedBox(width: 12),
              _buildInfoChip(Icons.help_outline_rounded, '${(test['questions'] as List?)?.length ?? 0} Questions'),
            ],
          ),
          const SizedBox(height: 24),
          GradientButton(
            text: 'START ASSESSMENT',
            onPressed: () => context.push('/student/take-test', extra: test),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 6),
          Text(label, style: DesignSystem.bodySmall(color: Colors.grey).copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}
