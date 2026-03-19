import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../services/admin_management_service.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/app_widgets.dart';

class AdminPayoutsScreen extends ConsumerWidget {
  const AdminPayoutsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payoutsAsync = ref.watch(adminPayoutsProvider);
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
                  child: payoutsAsync.when(
                    data: (payouts) {
                      if (payouts.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.payments_outlined, size: 64, color: Colors.grey.withOpacity(0.5)),
                              const SizedBox(height: 16),
                              Text('No pending payout requests', style: DesignSystem.bodyLarge(color: Colors.grey)),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                        itemCount: payouts.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final req = payouts[index];
                          final amount = req['amount']?.toString() ?? '0';
                          final userName = req['user']?['name'] ?? 'Unknown User';
                          final requestedAt = req['created_at'] != null 
                              ? DateFormat('MMM dd, yyyy').format(DateTime.parse(req['created_at']))
                              : 'N/A';
                          
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
                                      Text(
                                        '₹$amount', 
                                        style: DesignSystem.heading3(color: DesignSystem.success).copyWith(letterSpacing: -0.5),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'PENDING', 
                                          style: DesignSystem.bodySmall(color: Colors.orange).copyWith(fontWeight: FontWeight.bold, fontSize: 10),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _buildInfoRow(Icons.person_rounded, userName),
                                  const SizedBox(height: 8),
                                  _buildInfoRow(Icons.access_time_filled_rounded, requestedAt),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        try {
                                          await ref.read(adminManagementProvider).approvePayout(req['id']);
                                          ref.refresh(adminPayoutsProvider);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Payout Approved Successfully')),
                                            );
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Error: $e')),
                                            );
                                          }
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: DesignSystem.success,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      child: Text('Approve Payout', style: DesignSystem.bodyMedium(color: Colors.white).copyWith(fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text('Error: $err', style: DesignSystem.bodySmall(color: DesignSystem.error))),
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
            'Payout Requests',
            style: DesignSystem.heading3(color: isDark ? Colors.white : DesignSystem.backgroundDark),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(value, style: DesignSystem.bodyMedium(color: null)),
      ],
    );
  }
}
