import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/teacher_provider.dart';
import '../../../models/lead.dart';

class LeadListingScreen extends ConsumerWidget {
  const LeadListingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leadsAsync = ref.watch(teacherLeadsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lead Opportunities'),
      ),
      body: leadsAsync.when(
        data: (leads) => RefreshIndicator(
          onRefresh: () => ref.refresh(teacherLeadsProvider.future),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: leads.length,
            itemBuilder: (context, index) {
              final lead = leads[index];
              return _LeadCard(lead: lead);
            },
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _LeadCard extends ConsumerWidget {
  final Lead lead;
  const _LeadCard({required this.lead});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = lead.tuitionRequest;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.between,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Match ${lead.matchScore}%',
                    style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                Text(
                  lead.status.toUpperCase(),
                  style: TextStyle(
                    color: lead.status == 'accepted' ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              tr?.subjectsString ?? 'Subject Not Specified',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Grade: ${tr?.grade ?? 'N/A'}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    tr?.location ?? 'Location Not Specified',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ),
                Text(
                  '${lead.distanceKm} km',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (lead.status == 'sent')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _manageLead(context, ref, 'rejected'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _manageLead(context, ref, 'accepted'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Accept Lead'),
                    ),
                  ),
                ],
              )
            else if (lead.status == 'accepted')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to lead details or demo scheduling
                  },
                  child: const Text('View Details'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _manageLead(BuildContext context, WidgetRef ref, String status) async {
    await ref.read(teacherActionProvider.notifier).manageLead(lead.id, status);
    ref.refresh(teacherLeadsProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lead $status successfully')),
      );
    }
  }
}
