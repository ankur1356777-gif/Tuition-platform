import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/admin_extended_service.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/app_widgets.dart';

class AdminLeadsScreen extends ConsumerWidget {
  const AdminLeadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leadsAsync = ref.watch(adminLeadsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark 
                  ? [DesignSystem.backgroundDark, const Color(0xFF1E1E2E)]
                  : [const Color(0xFFF8FAFF), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, isDark),
                Expanded(
                  child: leadsAsync.when(
                    data: (leads) {
                      if (leads.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox_rounded, size: 64, color: Colors.grey.withOpacity(0.5)),
                              const SizedBox(height: 16),
                              Text('No leads found', style: DesignSystem.bodyLarge(color: Colors.grey)),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                        itemCount: leads.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final lead = leads[index];
                          final studentName = lead['tuition_request']?['student']?['user']?['name'] ?? 'Unknown Student';
                          final teacherName = lead['teacher']?['user']?['name'] ?? 'Not Assigned';
                          final status = lead['status']?.toString() ?? 'pending';
                          
                          return PremiumCard(
                            glass: true,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              studentName,
                                              style: DesignSystem.bodyLarge(color: null).copyWith(fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Request ID: #${lead['tuition_request_id']}',
                                              style: DesignSystem.bodySmall(color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                      _buildStatusChip(status),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _buildInfoRow(Icons.person_outline_rounded, 'Teacher', teacherName),
                                  const SizedBox(height: 8),
                                  _buildInfoRow(
                                    Icons.calendar_today_rounded, 
                                    'Generated', 
                                    lead['created_at']?.split('T')[0] ?? 'N/A'
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          // Detailed view or action
                                        },
                                        child: Text(
                                          'View Details', 
                                          style: DesignSystem.bodySmall(color: DesignSystem.primary).copyWith(fontWeight: FontWeight.bold)
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(
                      child: Text('Error: $err', style: DesignSystem.bodySmall(color: DesignSystem.error))
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : DesignSystem.backgroundDark),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text(
            'Admin Leads',
            style: DesignSystem.heading3(color: isDark ? Colors.white : DesignSystem.backgroundDark),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: DesignSystem.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.filter_list_rounded, color: DesignSystem.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text('$label: ', style: DesignSystem.bodySmall(color: Colors.grey)),
        Text(value, style: DesignSystem.bodySmall(color: null).copyWith(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'accepted': color = DesignSystem.success; break;
      case 'rejected': color = DesignSystem.error; break;
      case 'pending': color = Colors.orange; break;
      default: color = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: DesignSystem.bodySmall(color: color).copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}
