import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/parent_service.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/app_widgets.dart';

class ChildProgressScreen extends ConsumerStatefulWidget {
  final int studentId;
  final String childName;

  const ChildProgressScreen({
    super.key,
    required this.studentId,
    required this.childName,
  });

  @override
  ConsumerState<ChildProgressScreen> createState() => _ChildProgressScreenState();
}

class _ChildProgressScreenState extends ConsumerState<ChildProgressScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  Map<String, dynamic>? _progressData;
  List<dynamic>? _testsData;
  List<dynamic>? _homeworkData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadProgress();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.index == 2 && _testsData == null) {
      _loadTests();
    } else if (_tabController.index == 3 && _homeworkData == null) {
      _loadHomework();
    }
  }

  Future<void> _loadProgress() async {
    try {
      setState(() { _isLoading = true; _error = null; });
      final data = await ref.read(parentServiceProvider).getChildProgress(widget.studentId);
      setState(() { _progressData = data; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _loadTests() async {
    try {
      final data = await ref.read(parentServiceProvider).getChildTestResults(widget.studentId);
      setState(() { _testsData = data['tests'] as List? ?? data['data'] as List? ?? []; });
    } catch (e) {
      setState(() { _testsData = []; });
    }
  }

  Future<void> _loadHomework() async {
    try {
      final data = await ref.read(parentServiceProvider).getChildHomework(widget.studentId);
      setState(() { _homeworkData = data['homework'] as List? ?? data['data'] as List? ?? []; });
    } catch (e) {
      setState(() { _homeworkData = []; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DesignSystem.backgroundDark : const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text('${widget.childName}\'s Progress', style: DesignSystem.heading3(color: null)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : DesignSystem.backgroundDark),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: DesignSystem.secondary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: DesignSystem.secondary,
          indicatorWeight: 3,
          labelStyle: DesignSystem.bodySmall(color: null).copyWith(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Attendance'),
            Tab(text: 'Tests'),
            Tab(text: 'Homework'),
          ],
        ),
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildErrorView()
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(isDark),
                      _buildAttendanceTab(isDark),
                      _buildTestsTab(isDark),
                      _buildHomeworkTab(isDark),
                    ],
                  ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 48, color: DesignSystem.error),
          const SizedBox(height: 16),
          Text('Error: $_error', style: DesignSystem.bodySmall(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadProgress, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(bool isDark) {
    final student = _progressData?['student'] ?? {};
    final stats = _progressData?['stats'] ?? {};
    final tuitions = _progressData?['active_tuitions'] as List? ?? [];

    return RefreshIndicator(
      onRefresh: _loadProgress,
      child: ListView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        children: [
          PremiumCard(
            glass: true,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: DesignSystem.secondary.withOpacity(0.1),
                  child: Text(
                    DesignSystem.getInitial(widget.childName, 'C'),
                    style: DesignSystem.heading2(color: DesignSystem.secondary),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student['name'] ?? widget.childName, style: DesignSystem.heading3(color: null)),
                      Text('Class ${student['class'] ?? 'N/A'} • ${student['school'] ?? 'Active Student'}', style: DesignSystem.bodySmall(color: Colors.grey)),
                    ],
                  ),
                ),
                RewardBadge(type: student['batch']?.toString().toLowerCase() ?? 'bronze', size: 40),
              ],
            ),
          ),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.15,
            children: [
              StatTile(label: 'Avg Score', value: '${stats['avg_test_score'] ?? 0}%', icon: Icons.analytics_rounded, color: Colors.blue, small: true),
              StatTile(label: 'Attendance', value: '${stats['attendance_rate'] ?? 0}%', icon: Icons.event_available_rounded, color: Colors.green, small: true),
              StatTile(label: 'Tests Passed', value: '${stats['passed_tests'] ?? 0}', icon: Icons.check_circle_rounded, color: Colors.purple, small: true),
              StatTile(label: 'Homework Done', value: '${stats['completed_homework'] ?? 0}', icon: Icons.task_alt_rounded, color: Colors.orange, small: true),
            ],
          ),
          const SizedBox(height: 32),
          Text('Active Tuitions', style: DesignSystem.heading3(color: isDark ? Colors.white : DesignSystem.backgroundDark)),
          const SizedBox(height: 16),
          if (tuitions.isEmpty)
            _buildEmptyState('No active tuitions linked.', Icons.school_outlined, isDark)
          else
            ...tuitions.map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildTuitionCard(t),
            )),
        ],
      ),
    );
  }

  Widget _buildTuitionCard(Map<String, dynamic> tuition) {
    return PremiumCard(
      glass: true,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: DesignSystem.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(Icons.school_rounded, color: DesignSystem.primary, size: 20),
        ),
        title: Text(tuition['teacher_name'] ?? 'Teacher', style: DesignSystem.bodyMedium(color: null).copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text(tuition['subject'] ?? 'General', style: DesignSystem.bodySmall(color: Colors.grey)),
        trailing: Text('₹${tuition['monthly_fee'] ?? 0}', style: DesignSystem.bodyMedium(color: Colors.green).copyWith(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildAttendanceTab(bool isDark) {
    final recentAttendance = _progressData?['recent_attendance'] as List? ?? [];
    return RefreshIndicator(
      onRefresh: _loadProgress,
      child: recentAttendance.isEmpty
          ? _buildEmptyState('No attendance records found.', Icons.event_busy_rounded, isDark)
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: recentAttendance.length,
              itemBuilder: (context, index) {
                final record = recentAttendance[index];
                final status = record['status']?.toString().toLowerCase() ?? 'absent';
                final color = status == 'present' ? Colors.green : DesignSystem.error;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PremiumCard(
                    glass: true,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: color.withOpacity(0.1),
                        child: Icon(status == 'present' ? Icons.check_rounded : Icons.close_rounded, color: color, size: 20),
                      ),
                      title: Text(record['date'] ?? 'N/A', style: DesignSystem.bodyMedium(color: null).copyWith(fontWeight: FontWeight.bold)),
                      subtitle: Text(record['teacher']?['user']?['name'] ?? 'Teacher', style: DesignSystem.bodySmall(color: Colors.grey)),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: Text(status.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 9, letterSpacing: 0.5)),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildTestsTab(bool isDark) {
    if (_testsData == null) return const Center(child: CircularProgressIndicator());
    if (_testsData!.isEmpty) return _buildEmptyState('No test results yet.', Icons.quiz_rounded, isDark);

    return RefreshIndicator(
      onRefresh: () async { _testsData = null; await _loadTests(); },
      child: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: _testsData!.length,
        itemBuilder: (context, index) {
          final test = _testsData![index] as Map<String, dynamic>;
          final score = test['score'] ?? test['obtained_marks'];
          final total = test['total_marks'] ?? test['max_marks'] ?? 100;
          final percentage = (score != null && total != null && total > 0) ? (score / total) : 0.0;
          final passed = percentage >= 0.4;
          final color = passed ? Colors.green : DesignSystem.error;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PremiumCard(
              glass: true,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: color.withOpacity(0.1),
                  child: Icon(passed ? Icons.check_circle_rounded : Icons.cancel_rounded, color: color, size: 20),
                ),
                title: Text(test['subject'] ?? test['title'] ?? 'Test', style: DesignSystem.bodyMedium(color: null).copyWith(fontWeight: FontWeight.bold)),
                subtitle: Text(test['date'] ?? 'Recent', style: DesignSystem.bodySmall(color: Colors.grey)),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${(percentage * 100).toInt()}%', style: DesignSystem.heading3(color: color).copyWith(fontSize: 18)),
                    Text('$score/$total', style: DesignSystem.bodySmall(color: Colors.grey).copyWith(fontSize: 10)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHomeworkTab(bool isDark) {
    if (_homeworkData == null) return const Center(child: CircularProgressIndicator());
    if (_homeworkData!.isEmpty) return _buildEmptyState('No homework assigned.', Icons.assignment_rounded, isDark);

    return RefreshIndicator(
      onRefresh: () async { _homeworkData = null; await _loadHomework(); },
      child: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: _homeworkData!.length,
        itemBuilder: (context, index) {
          final hw = _homeworkData![index] as Map<String, dynamic>;
          final status = hw['status']?.toString().toLowerCase() ?? 'pending';
          Color statusColor = Colors.orange;
          if (status == 'submitted' || status == 'completed' || status == 'reviewed') statusColor = Colors.green;
          else if (status == 'overdue') statusColor = DesignSystem.error;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PremiumCard(
              glass: true,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: statusColor.withOpacity(0.1),
                  child: Icon(statusColor == Colors.green ? Icons.check_circle_rounded : Icons.hourglass_empty_rounded, color: statusColor, size: 20),
                ),
                title: Text(hw['title'] ?? hw['subject'] ?? 'Homework', style: DesignSystem.bodyMedium(color: null).copyWith(fontWeight: FontWeight.bold)),
                subtitle: Text(hw['due_date'] != null ? 'Due: ${hw['due_date']}' : 'Ongoing', style: DesignSystem.bodySmall(color: Colors.grey)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 9, letterSpacing: 0.5)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(opacity: 0.3, child: Icon(icon, size: 60, color: isDark ? Colors.white : DesignSystem.backgroundDark)),
          const SizedBox(height: 16),
          Text(message, style: DesignSystem.bodySmall(color: Colors.grey)),
        ],
      ),
    );
  }
}
