import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/admin_extended_service.dart';
import '../services/admin_service.dart'; // Reusing user status management

class AdminAgentsScreen extends ConsumerWidget {
  const AdminAgentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentsAsync = ref.watch(adminAgentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Referral Agents')),
      body: agentsAsync.when(
        data: (agents) {
          if (agents.isEmpty) return const Center(child: Text('No agents found'));

          return ListView.builder(
            itemCount: agents.length,
            itemBuilder: (context, index) {
              final agent = agents[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.support_agent)),
                  title: Text(agent['name'] ?? 'Unknown'),
                  subtitle: Text('Email: ${agent['email']}\nStatus: ${agent['status']}'),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (val) async {
                      try {
                        await ref.read(adminServiceProvider).updateUserStatus(agent['id'], val);
                        ref.refresh(adminAgentsProvider); // Refresh list
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Updated to $val')));
                      } catch (e) {
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'active', child: Text('Activate')),
                      const PopupMenuItem(value: 'inactive', child: Text('Deactivate')),
                      const PopupMenuItem(value: 'approved', child: Text('Approve')),
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
}
