import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../services/student_service.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/app_widgets.dart';

final studentAttendanceProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(studentServiceProvider).getAttendance();
});

class StudentAttendanceScreen extends ConsumerWidget {
  const StudentAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync = ref.watch(studentAttendanceProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DesignSystem.backgroundDark : const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text('My Attendance', style: DesignSystem.heading3(color: null)),
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
        child: attendanceAsync.when(
          data: (attendance) {
            if (attendance.isEmpty) {
              return _buildEmptyState(isDark);
            }
            
            return ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: attendance.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final record = attendance[index];
                return _AttendanceCard(record: record, isDark: isDark);
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
            opacity: 0.3,
            child: Icon(Icons.calendar_today_outlined, size: 80, color: isDark ? Colors.white : DesignSystem.backgroundDark),
          ),
          const SizedBox(height: 24),
          Text('No Records Found', style: DesignSystem.heading3(color: null)),
          const SizedBox(height: 8),
          Text('Your attendance marked by teachers will appear here.', style: DesignSystem.bodySmall(color: Colors.grey), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  final dynamic record;
  final bool isDark;
  const _AttendanceCard({required this.record, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bool isPresent = record['status'] == 'present';
    final Color statusColor = isPresent ? Colors.green : DesignSystem.error;

    return PremiumCard(
      glass: true,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPresent ? Icons.check_circle_outline_rounded : Icons.cancel_outlined,
              color: statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, MMM dd, yyyy').format(DateTime.parse(record['marked_at'])),
                  style: DesignSystem.bodyMedium(color: null).copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Teacher: ${record['teacher']?['user']?['name'] ?? 'Unknown'}',
                  style: DesignSystem.bodySmall(color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withOpacity(0.2)),
            ),
            child: Text(
              isPresent ? 'PRESENT' : 'ABSENT',
              style: TextStyle(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
