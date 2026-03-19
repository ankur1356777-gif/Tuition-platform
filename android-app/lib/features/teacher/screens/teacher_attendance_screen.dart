import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/teacher_service.dart';

final activeTuitionsProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(teacherServiceProvider).getActiveTuitions();
});

class TeacherAttendanceScreen extends ConsumerWidget {
  const TeacherAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tuitionsAsync = ref.watch(activeTuitionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mark Attendance')),
      body: tuitionsAsync.when(
        data: (tuitions) {
          if (tuitions.isEmpty) {
            return const Center(child: Text('No active tuitions found'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tuitions.length,
            itemBuilder: (context, index) {
              final tuition = tuitions[index];
              return Card(
                child: ListTile(
                  title: Text(tuition['tuition_request']?['student']?['user']?['name'] ?? 'Student'),
                  subtitle: Text('Class: ${tuition['tuition_request']?['class'] ?? 'N/A'}'),
                  trailing: ElevatedButton(
                    onPressed: () => _showAttendanceDialog(context, ref, tuition['id']),
                    child: const Text('Mark'),
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

  void _showAttendanceDialog(BuildContext context, WidgetRef ref, int tuitionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark Attendance'),
        content: const Text('Is the student present today?'),
        actions: [
          TextButton(
            onPressed: () => _submitAttendance(context, ref, tuitionId, 'absent'),
            child: const Text('Absent', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () => _submitAttendance(context, ref, tuitionId, 'present'),
            child: const Text('Present'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitAttendance(BuildContext context, WidgetRef ref, int tuitionId, String status) async {
    Navigator.pop(context); // Close dialog
    try {
      // Mock coordinates for now
      await ref.read(teacherServiceProvider).markAttendance({
        'tuition_id': tuitionId,
        'status': status,
        'latitude': 0.0,
        'longitude': 0.0,
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Attendance marked: $status')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
