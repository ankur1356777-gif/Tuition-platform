import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../services/student_service.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/app_widgets.dart';

final studentResultsProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(studentServiceProvider).getTestResults();
});

class StudentResultsScreen extends ConsumerWidget {
  const StudentResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(studentResultsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DesignSystem.backgroundDark : const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text('Test Performance', style: DesignSystem.heading3(color: null)),
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
        child: resultsAsync.when(
          data: (results) {
            if (results.isEmpty) {
              return _buildEmptyState(isDark);
            }

            return ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: results.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final result = results[index];
                return _ResultCard(result: result, isDark: isDark);
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
            child: Icon(Icons.analytics_outlined, size: 80, color: isDark ? Colors.white : DesignSystem.backgroundDark),
          ),
          const SizedBox(height: 24),
          Text('No Results Yet', style: DesignSystem.heading3(color: null)),
          const SizedBox(height: 8),
          Text('Your test performance and rewards will be tracked here.', style: DesignSystem.bodySmall(color: Colors.grey), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final dynamic result;
  final bool isDark;
  const _ResultCard({required this.result, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final test = result['test'] ?? {};
    final score = result['score'] ?? 0;
    final totalMarks = test['total_marks'] ?? 100;
    final percentage = (score / totalMarks) * 100;
    
    // Logic for badge display (Backend handles actual rewards, but we reflect logic here)
    final hasGold = result['badge'] == 'gold';
    final hasSilver = result['badge'] == 'silver' || percentage >= 80;

    return PremiumCard(
      glass: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      test['title'] ?? 'Assessment',
                      style: DesignSystem.bodyLarge(color: null).copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      test['subject'] ?? 'General',
                      style: DesignSystem.bodySmall(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              if (hasGold) 
                const RewardBadge(type: 'gold')
              else if (hasSilver)
                const RewardBadge(type: 'silver'),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Score: $score / $totalMarks',
                style: DesignSystem.bodyMedium(color: null).copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: DesignSystem.heading3(color: percentage >= 80 ? Colors.green : (percentage >= 40 ? DesignSystem.primary : DesignSystem.error)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage >= 80 ? Colors.green : (percentage >= 40 ? DesignSystem.primary : DesignSystem.error),
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMM dd, yyyy').format(DateTime.parse(result['created_at'])),
                style: DesignSystem.bodySmall(color: Colors.grey),
              ),
              Text(
                percentage >= 40 ? 'PASSED' : 'FAILED',
                style: DesignSystem.bodySmall(color: percentage >= 40 ? Colors.green : DesignSystem.error).copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
