import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/performance_provider.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/app_widgets.dart';

class StudentPerformanceScreen extends ConsumerWidget {
  const StudentPerformanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(studentTestResultsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DesignSystem.backgroundDark : const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text('Academic Performance', style: DesignSystem.heading3(color: null)),
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOverallStats(isDark),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Recent Test Results',
                  style: DesignSystem.heading3(color: null),
                ),
              ),
              const SizedBox(height: 16),
              _buildRecentTests(resultsAsync, isDark),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverallStats(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: PremiumCard(
        glass: true,
        child: Column(
          children: [
            Text(
              'Your Overall Learning Progress',
              style: DesignSystem.bodySmall(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ShaderMask(
              shaderCallback: (bounds) => DesignSystem.primaryGradient.createShader(bounds),
              child: Text(
                '92%',
                style: DesignSystem.heading1(color: Colors.white).copyWith(fontSize: 56, letterSpacing: -2),
              ),
            ),
            Text(
              'Average Score',
              style: DesignSystem.bodyMedium(color: null).copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                StatTile(label: 'Tests Taken', value: '12', icon: Icons.quiz_outlined),
                StatTile(label: 'Attendance', value: '95%', icon: Icons.calendar_today_outlined),
                StatTile(label: 'Homework', value: '8/10', icon: Icons.assignment_outlined),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTests(AsyncValue<List<dynamic>> resultsAsync, bool isDark) {
    return resultsAsync.when(
      data: (results) {
        if (results.isEmpty) {
          return _buildMockList(isDark);
        }
        return ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          physics: const NeverScrollableScrollPhysics(),
          itemCount: results.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final test = results[index];
            return _TestResultCard(test: test, isDark: isDark);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err', style: DesignSystem.bodySmall(color: Colors.grey))),
    );
  }

  Widget _buildMockList(bool isDark) {
    final mockData = [
      {'title': 'Algebra Mid-Term', 'subject': 'Mathematics', 'marks': 45, 'total': 50, 'date': 'Today'},
      {'title': 'Organic Chemistry', 'subject': 'Science', 'marks': 38, 'total': 50, 'date': 'Yesterday'},
    ];

    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: mockData.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _TestResultCard(test: mockData[index], isDark: isDark);
      },
    );
  }
}

class _TestResultCard extends StatelessWidget {
  final dynamic test;
  final bool isDark;
  const _TestResultCard({required this.test, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final double marks = (test['marks'] as num).toDouble();
    final double total = (test['total'] as num).toDouble();
    final double percentage = (marks / total) * 100;
    final bool isExcellent = percentage >= 80;

    return PremiumCard(
      glass: true,
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 54,
                width: 54,
                child: CircularProgressIndicator(
                  value: percentage / 100,
                  strokeWidth: 4,
                  backgroundColor: (isExcellent ? Colors.green : Colors.orange).withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(isExcellent ? Colors.green : Colors.orange),
                ),
              ),
              Text(
                '${percentage.toInt()}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: isExcellent ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  test['title'],
                  style: DesignSystem.bodyMedium(color: null).copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  test['subject'],
                  style: DesignSystem.bodySmall(color: DesignSystem.primary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${test['marks']}/${test['total']}',
                style: DesignSystem.heading3(color: null).copyWith(fontSize: 16),
              ),
              Text(
                test['date'] ?? 'N/A',
                style: DesignSystem.bodySmall(color: Colors.grey).copyWith(fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
