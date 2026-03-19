import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/student_service.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/app_widgets.dart';

final batchStatusProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(studentServiceProvider).getBatchStatus();
});

class StudentBatchScreen extends ConsumerWidget {
  const StudentBatchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batchAsync = ref.watch(batchStatusProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DesignSystem.backgroundDark : const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text('My Batch Status', style: DesignSystem.heading3(color: null)),
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
        child: batchAsync.when(
          data: (data) => _buildBatchContent(context, data, isDark),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err', style: DesignSystem.bodySmall(color: Colors.grey))),
        ),
      ),
    );
  }

  Widget _buildBatchContent(BuildContext context, Map<String, dynamic> data, bool isDark) {
    final batch = data['batch']?.toString().toLowerCase() ?? 'bronze';
    final consecutiveScores = data['consecutive_high_scores'] ?? 0;
    final scoresToUpgrade = 3 - (consecutiveScores as int);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Batch Hero Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            decoration: BoxDecoration(
              gradient: _getBatchGradient(batch),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _getBatchColor(batch).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(_getBatchIcon(batch), size: 100, color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  '${batch.toUpperCase()} BATCH',
                  style: DesignSystem.heading1(color: Colors.white).copyWith(letterSpacing: 4, fontSize: 32),
                ),
                const SizedBox(height: 12),
                Text(
                  _getBatchDescription(batch),
                  style: DesignSystem.bodySmall(color: Colors.white.withOpacity(0.9)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          if (batch != 'gold') ...[
            Text('RANK PROGRESS', style: DesignSystem.bodySmall(color: DesignSystem.primary).copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 16),
            PremiumCard(
              glass: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Next Level: ${batch == 'bronze' ? 'Silver' : 'Gold'}', style: DesignSystem.bodyMedium(color: null).copyWith(fontWeight: FontWeight.bold)),
                      Text('$consecutiveScores / 3', style: DesignSystem.bodySmall(color: DesignSystem.primary).copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: consecutiveScores / 3,
                      minHeight: 12,
                      backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                      valueColor: AlwaysStoppedAnimation<Color>(DesignSystem.primary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    scoresToUpgrade > 0
                        ? 'Score 80%+ on $scoresToUpgrade more weekly tests to upgrade!'
                        : 'Ready for upgrade!',
                    style: DesignSystem.bodySmall(color: scoresToUpgrade > 0 ? Colors.grey : Colors.green),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
          
          Text('BATCH BENEFITS', style: DesignSystem.bodySmall(color: DesignSystem.primary).copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 16),
          PremiumCard(
            glass: true,
            child: Column(
              children: [
                _buildBenefitRow(Icons.account_balance_rounded, 'Standard', 'Base platform access & tracking', batch == 'bronze'),
                const Divider(height: 24, indent: 48),
                _buildBenefitRow(Icons.auto_awesome_rounded, 'Priority', 'Fast-track teacher matching', batch == 'silver'),
                const Divider(height: 24, indent: 48),
                _buildBenefitRow(Icons.workspace_premium_rounded, 'VIP', 'Exclusive discounts & resources', batch == 'gold'),
              ],
            ),
          ),
          const SizedBox(height: 40),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: DesignSystem.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: DesignSystem.primary.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.tips_and_updates_rounded, color: DesignSystem.primary, size: 20),
                    const SizedBox(width: 8),
                    Text('How to Upgrade?', style: DesignSystem.heading3(color: null).copyWith(fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildStep(1, 'Take weekly tests assigned by teacher.'),
                _buildStep(2, 'Maintain 80% or higher score consistently.'),
                _buildStep(3, 'Repeat for 3 consecutive weeks.'),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStep(int num, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$num.', style: TextStyle(fontWeight: FontWeight.bold, color: DesignSystem.primary)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: DesignSystem.bodySmall(color: Colors.grey))),
        ],
      ),
    );
  }

  Widget _buildBenefitRow(IconData icon, String title, String subtitle, bool isActive) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isActive ? DesignSystem.primary.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: isActive ? DesignSystem.primary : Colors.grey, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: DesignSystem.bodyMedium(color: null).copyWith(fontWeight: FontWeight.bold, color: isActive ? null : Colors.grey)),
              Text(subtitle, style: DesignSystem.bodySmall(color: Colors.grey)),
            ],
          ),
        ),
        if (isActive)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: const Text('ACTIVE', style: TextStyle(color: Colors.green, fontSize: 8, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }

  LinearGradient _getBatchGradient(String batch) {
    switch (batch) {
      case 'gold':
        return const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFF59E0B)], begin: Alignment.topLeft, end: Alignment.bottomRight);
      case 'silver':
        return const LinearGradient(colors: [Color(0xFF94A3B8), Color(0xFF475569)], begin: Alignment.topLeft, end: Alignment.bottomRight);
      default:
        return const LinearGradient(colors: [Color(0xFFD97706), Color(0xFF92400E)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    }
  }

  Color _getBatchColor(String batch) {
    switch (batch) {
      case 'gold': return const Color(0xFFFFD700);
      case 'silver': return const Color(0xFF64748B);
      default: return const Color(0xFFD97706);
    }
  }

  IconData _getBatchIcon(String batch) {
    switch (batch) {
      case 'gold': return Icons.emoji_events_rounded;
      case 'silver': return Icons.workspace_premium_rounded;
      default: return Icons.military_tech_rounded;
    }
  }

  String _getBatchDescription(String batch) {
    switch (batch) {
      case 'gold': return 'Excellence Personified! You are in the top tier.';
      case 'silver': return 'Rising Star! You are making great progress.';
      default: return 'Start your journey! Score high to upgrade.';
    }
  }
}
