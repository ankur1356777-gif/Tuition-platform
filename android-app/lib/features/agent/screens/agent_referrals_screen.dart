import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/agent_service.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/app_widgets.dart';

final agentReferralsProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(agentServiceProvider).getReferrals();
});

class AgentReferralsScreen extends ConsumerWidget {
  const AgentReferralsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final referralsAsync = ref.watch(agentReferralsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DesignSystem.backgroundDark : const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text('My Network', style: DesignSystem.heading3(color: null)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : DesignSystem.backgroundDark),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark 
              ? [DesignSystem.backgroundDark, const Color(0xFF1E1E2E)]
              : [const Color(0xFFF0F4FF), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: referralsAsync.when(
          data: (referrals) => _buildReferralsList(context, referrals, isDark, ref),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err', style: DesignSystem.bodySmall(color: Colors.grey))),
        ),
      ),
    );
  }

  Widget _buildReferralsList(BuildContext context, List<dynamic> referrals, bool isDark, WidgetRef ref) {
    if (referrals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: 0.3,
              child: Icon(Icons.people_outline_rounded, size: 80, color: isDark ? Colors.white : DesignSystem.backgroundDark),
            ),
            const SizedBox(height: 24),
            Text('No Referrals Yet', style: DesignSystem.heading3(color: null)),
            const SizedBox(height: 8),
            Text('Start sharing your code to build your network.', style: DesignSystem.bodySmall(color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(agentReferralsProvider),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        physics: const BouncingScrollPhysics(),
        itemCount: referrals.length,
        itemBuilder: (context, index) {
          final referral = referrals[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _ReferralCard(referral: referral),
          );
        },
      ),
    );
  }
}

class _ReferralCard extends StatelessWidget {
  final dynamic referral;
  const _ReferralCard({required this.referral});

  @override
  Widget build(BuildContext context) {
    final user = referral['user'] ?? {};
    final status = referral['status']?.toString().toLowerCase() ?? 'pending';
    final type = referral['type']?.toString().toUpperCase() ?? 'STUDENT';
    final statusColor = status == 'active' ? Colors.green : (status == 'rejected' ? DesignSystem.error : Colors.orange);

    return PremiumCard(
      glass: true,
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: DesignSystem.primary.withOpacity(0.1),
            child: Text(
              DesignSystem.getInitial(user['name'], '?'),
              style: DesignSystem.heading3(color: DesignSystem.primary).copyWith(fontSize: 18),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(user['name'] ?? 'Unknown User', style: DesignSystem.bodyLarge(color: null).copyWith(fontWeight: FontWeight.bold)),
                    _StatusBadge(status: status, color: statusColor),
                  ],
                ),
                Text(user['email'] ?? 'No email provided', style: DesignSystem.bodySmall(color: Colors.grey)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: DesignSystem.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(4)),
                      child: Text(type, style: DesignSystem.bodySmall(color: DesignSystem.primary).copyWith(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.access_time_rounded, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('Joined recently', style: DesignSystem.bodySmall(color: Colors.grey).copyWith(fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;
  const _StatusBadge({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.2))),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 9, letterSpacing: 0.5)),
    );
  }
}
