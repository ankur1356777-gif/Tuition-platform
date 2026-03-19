import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/teacher_service.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/app_widgets.dart';

final availableRequirementsProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(teacherServiceProvider).getAvailableRequirements();
});

class AvailableRequirementsScreen extends ConsumerWidget {
  const AvailableRequirementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requirementsAsync = ref.watch(availableRequirementsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DesignSystem.backgroundDark : const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text('Explore Tuitions', style: DesignSystem.heading3(color: null)),
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
        child: requirementsAsync.when(
          data: (requirements) => _buildRequirementsList(context, requirements, isDark),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err', style: DesignSystem.bodySmall(color: Colors.grey))),
        ),
      ),
    );
  }

  Widget _buildRequirementsList(BuildContext context, List<dynamic> requirements, bool isDark) {
    if (requirements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: 0.3,
              child: Icon(Icons.explore_off_rounded, size: 80, color: isDark ? Colors.white : DesignSystem.backgroundDark),
            ),
            const SizedBox(height: 24),
            Text('No Nearby Tuitions', style: DesignSystem.heading3(color: null)),
            const SizedBox(height: 8),
            Text('Check back later for new teaching opportunities.', style: DesignSystem.bodySmall(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      physics: const BouncingScrollPhysics(),
      itemCount: requirements.length,
      itemBuilder: (context, index) {
        final req = requirements[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _RequirementCard(requirement: req),
        );
      },
    );
  }
}

class _RequirementCard extends StatelessWidget {
  final dynamic requirement;
  const _RequirementCard({required this.requirement});

  @override
  Widget build(BuildContext context) {
    final subjects = requirement['subjects'] is List ? (requirement['subjects'] as List).join(", ") : requirement['subjects'];
    
    return PremiumCard(
      glass: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('GRADE ${requirement['class']}', style: DesignSystem.bodySmall(color: DesignSystem.primary).copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 10)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: DesignSystem.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Icon(Icons.location_on_rounded, size: 10, color: DesignSystem.primary),
                    const SizedBox(width: 4),
                    Text(requirement['area_name'] ?? 'Lucknow', style: DesignSystem.bodySmall(color: DesignSystem.primary).copyWith(fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(subjects ?? 'General Tuition', style: DesignSystem.heading3(color: null)),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatItem(icon: Icons.payments_rounded, label: '₹${requirement['budget']}/mo', color: Colors.green),
              const SizedBox(width: 24),
              _StatItem(icon: Icons.person_rounded, label: requirement['student_name'] ?? 'Parent', color: Colors.blue),
            ],
          ),
          const Divider(height: 32),
          _InterestButton(requirementId: requirement['id']),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatItem({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color.withOpacity(0.7)),
        const SizedBox(width: 6),
        Text(label, style: DesignSystem.bodySmall(color: null).copyWith(fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _InterestButton extends StatefulWidget {
  final int requirementId;
  const _InterestButton({required this.requirementId});

  @override
  State<_InterestButton> createState() => _InterestButtonState();
}

class _InterestButtonState extends State<_InterestButton> {
  bool _isLoading = false;
  bool _isSuccess = false;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return _isSuccess 
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.withOpacity(0.2))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_rounded, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Text('INTEREST SENT', style: DesignSystem.bodySmall(color: Colors.green).copyWith(fontWeight: FontWeight.bold, letterSpacing: 1)),
                ],
              ),
            )
          : GradientButton(
              text: 'EXPRESS INTEREST',
              onPressed: _isLoading ? null : () async {
                setState(() => _isLoading = true);
                try {
                  await ref.read(teacherServiceProvider).expressInterest(widget.requirementId);
                  setState(() { _isLoading = false; _isSuccess = true; });
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Interest sent! Admin will review.')));
                } catch (e) {
                  setState(() => _isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: DesignSystem.error));
                }
              },
              loading: _isLoading,
              icon: Icons.favorite_rounded,
            );
      },
    );
  }
}
