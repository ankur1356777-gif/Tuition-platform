import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/admin_service.dart';
import '../../../core/theme/design_system.dart';

final teacherListProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(adminServiceProvider).getTeachers();
});

class TeacherListScreen extends ConsumerWidget {
  const TeacherListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teachersAsync = ref.watch(teacherListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Teachers')),
      body: teachersAsync.when(
        data: (data) {
          final teachers = (data['data'] as List?) ?? [];
          return ListView.builder(
            itemCount: teachers.length,
            itemBuilder: (context, index) {
              final teacher = teachers[index];
              final user = teacher['user'];
              final status = user['status'];
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(status),
                    child: Text(DesignSystem.getInitial(user['name'], 'T')),
                  ),
                  title: Text(user['name']),
                  subtitle: Text(
                    '${user['email']}\nStatus: ${status.toUpperCase()}',
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) => _updateStatus(context, ref, user['id'].toString(), value),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'active', child: Text('Approve / Active')),
                      const PopupMenuItem(value: 'pending', child: Text('Pending')),
                      const PopupMenuItem(value: 'rejected', child: Text('Reject')),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active': return Colors.green;
      case 'pending': return Colors.orange;
      case 'rejected': return Colors.red;
      default: return Colors.grey;
    }
  }

  Future<void> _updateStatus(BuildContext context, WidgetRef ref, String userId, String status) async {
    try {
      await ref.read(adminServiceProvider).updateUserStatus(userId, status);
      ref.refresh(teacherListProvider); // Refresh list
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User updated to $status')),
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
