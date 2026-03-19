import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/admin_service.dart';
import '../../../core/theme/design_system.dart';

final studentListProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(adminServiceProvider).getStudents();
});

class StudentListScreen extends ConsumerWidget {
  const StudentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(studentListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Students')),
      body: studentsAsync.when(
        data: (data) {
          final students = (data['data'] as List?) ?? [];
          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              final user = student['user'];
              final status = user['status'];
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Text(DesignSystem.getInitial(user['name'], 'S')),
                  ),
                  title: Text(user['name']),
                  subtitle: Text(
                    '${user['email']}\nStatus: ${status.toUpperCase()}',
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) => _updateStatus(context, ref, user['id'].toString(), value),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'active', child: Text('Activate')),
                      const PopupMenuItem(value: 'inactive', child: Text('Deactivate')),
                    ],
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

  Future<void> _updateStatus(BuildContext context, WidgetRef ref, String userId, String status) async {
    try {
      await ref.read(adminServiceProvider).updateUserStatus(userId, status);
      ref.refresh(studentListProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User status updated to $status')),
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
