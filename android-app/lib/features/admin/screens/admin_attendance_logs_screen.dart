import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../services/admin_monitoring_service.dart';

class AdminAttendanceLogsScreen extends ConsumerWidget {
  const AdminAttendanceLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(adminAttendanceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Logs')),
      body: logsAsync.when(
        data: (logs) {
          if (logs.isEmpty) return const Center(child: Text('No attendance records found'));

          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(log['teacher']?['user']?['name'] ?? 'Unknown Teacher'),
                  subtitle: Text(
                    'Student: ${log['paid_tuition']?['student']?['user']?['name'] ?? 'Unknown'}\n'
                    'Time: ${DateFormat('MMM dd, hh:mm a').format(DateTime.parse(log['marked_at']))}'
                  ),
                  isThreeLine: true,
                  trailing: Icon(
                    log['status'] == 'present' ? Icons.check_circle : Icons.cancel,
                    color: log['status'] == 'present' ? Colors.green : Colors.red,
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
