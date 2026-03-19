import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../services/teacher_service.dart';

final demoListProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(teacherServiceProvider).getDemos();
});

class TeacherDemosScreen extends ConsumerWidget {
  const TeacherDemosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demosAsync = ref.watch(demoListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Demo Classes')),
      body: demosAsync.when(
        data: (demos) {
          if (demos.isEmpty) {
             return const Center(child: Text('No demo classes scheduled'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: demos.length,
            itemBuilder: (context, index) {
              final demo = demos[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                           Text(
                             demo['student_name'] ?? 'Unknown Student',
                             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                           ),
                           Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(demo['status']).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                (demo['status'] as String).toUpperCase(),
                                style: TextStyle(
                                  color: _getStatusColor(demo['status']),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                           ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Subject: ${demo['subject']}'),
                      Text('Scheduled: ${DateFormat('MMM dd, yyyy HH:mm').format(DateTime.parse(demo['scheduled_at']))}'),
                      const SizedBox(height: 4),
                      if (demo['is_contact_shared'] == true || demo['is_contact_shared'] == 1) ...[
                        Text('Phone: ${demo['phone']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                        Text('Address: ${demo['address']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      ] else ...[
                         const Text('Contact Info: HIDDEN (Admin will share after approval)', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey, fontSize: 12)),
                      ],
                      if (demo['feedback'] != null) ...[
                        const Divider(),
                        const Text('Feedback:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(demo['feedback']),
                      ],
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
      case 'scheduled': return Colors.blue;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }
}
