import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/admin_extended_service.dart';

class LeadApprovalScreen extends ConsumerWidget {
  const LeadApprovalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingLeadsAsync = ref.watch(adminPendingLeadsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Lead Requests Approval')),
      body: pendingLeadsAsync.when(
        data: (leads) {
          if (leads.isEmpty) {
            return const Center(child: Text('No pending requests'));
          }

          return ListView.builder(
            itemCount: leads.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final lead = leads[index];
              final teacher = lead['teacher']?['user']?['name'] ?? 'Unknown Teacher';
              final student = lead['tuition_request']?['guest_name'] ?? 
                             lead['tuition_request']?['student']?['user']?['name'] ?? 'Student';
              final area = lead['tuition_request']?['area_id']?.toString() ?? 'Lucknow'; // Should fetch name in real app

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Request from: $teacher',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text('Interested in: $student'),
                      Text('Class: ${lead['tuition_request']?['class']}'),
                      Text('Location: $area'),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => _handleRejection(context, ref, lead['id']),
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('Reject'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _handleApproval(context, ref, lead['id']),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                            child: const Text('Approve Contact'),
                          ),
                        ],
                      )
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

  void _handleApproval(BuildContext context, WidgetRef ref, int leadId) async {
    try {
      await ref.read(adminServiceExtendedProvider).approveLead(leadId);
      ref.invalidate(adminPendingLeadsProvider);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lead approved!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _handleRejection(BuildContext context, WidgetRef ref, int leadId) async {
    try {
      await ref.read(adminServiceExtendedProvider).rejectLead(leadId);
      ref.invalidate(adminPendingLeadsProvider);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lead rejected.')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
