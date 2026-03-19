import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuition_app/services/auth_service.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import '../services/agent_service.dart';
import '../../shared/widgets/app_drawer.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/app_widgets.dart';

final agentDashboardProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(agentServiceProvider).getDashboardStats();
});

class AgentDashboard extends ConsumerWidget {
  const AgentDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authServiceProvider).currentUser;
    final dashboardAsync = ref.watch(agentDashboardProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: const AppDrawer(currentRole: 'agent'),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark 
                  ? [DesignSystem.backgroundDark, const Color(0xFF1A1A2E)]
                  : [const Color(0xFFF8FAFF), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          SafeArea(
            child: RefreshIndicator(
              onRefresh: () async => ref.refresh(agentDashboardProvider.future),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildAppBar(context, ref, user, isDark),
                  SliverToBoxAdapter(
                    child: dashboardAsync.when(
                      data: (data) => _buildDashboardContent(context, user, data, isDark),
                      loading: () => const SizedBox(
                        height: 400,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (err, stack) => SizedBox(
                        height: 400,
                        child: Center(child: Text('Error: $err', style: DesignSystem.bodySmall(color: Colors.grey))),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, WidgetRef ref, dynamic user, bool isDark) {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.menu_rounded, color: isDark ? Colors.white : DesignSystem.backgroundDark),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.account_balance_wallet_outlined, color: isDark ? Colors.white : DesignSystem.backgroundDark),
          onPressed: () => context.push('/agent/wallet'),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: DesignSystem.primary.withOpacity(0.1),
                    child: Text(
                      DesignSystem.getInitial(user?.name, 'A'),
                      style: DesignSystem.heading2(color: DesignSystem.primary),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Partner Portal',
                          style: DesignSystem.bodyMedium(color: Colors.grey[600]),
                        ),
                        Text(
                          user?.name ?? "Agent",
                          style: DesignSystem.heading2(color: isDark ? Colors.white : DesignSystem.backgroundDark),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, dynamic user, Map<String, dynamic> data, bool isDark) {
    final stats = data['stats'] ?? {};
    final referralCode = data['referral_code'] ?? 'N/A';
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.15,
            children: [
              StatTile(
                label: "Total Referrals",
                value: "${stats['total_referrals'] ?? 0}",
                icon: Icons.people_rounded,
                color: Colors.blue,
                onTap: () => context.push('/agent/referrals'),
              ),
              StatTile(
                label: "Lifetime Earnings",
                value: "₹${stats['total_earnings'] ?? 0}",
                icon: Icons.currency_rupee_rounded,
                color: Colors.green,
                onTap: () => context.push('/agent/wallet'),
              ),
              StatTile(
                label: "Wallet Balance",
                value: "₹${stats['wallet_balance'] ?? 0}",
                icon: Icons.account_balance_wallet_rounded,
                color: Colors.purple,
                onTap: () => context.push('/agent/wallet'),
              ),
              StatTile(
                label: "Referral Rate",
                value: "85%", // Placeholder for a more complex metric
                icon: Icons.trending_up_rounded,
                color: Colors.orange,
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          _buildSectionHeader("Referral Program", isDark),
          const SizedBox(height: 16),
          _buildReferralCard(context, referralCode, isDark),

          const SizedBox(height: 32),

          _buildSectionHeader("Earning Overview", isDark),
          const SizedBox(height: 16),
          PremiumCard(
            glass: true,
            child: Column(
              children: [
                _buildActivityTile(
                  "Student Registration",
                  "Confirmed referral bonus",
                  "+ ₹300",
                  Colors.green,
                ),
                _buildDivider(),
                _buildActivityTile(
                  "Teacher Onboarding",
                  "In review for certification",
                  "Pending",
                  Colors.orange,
                ),
                _buildDivider(),
                _buildActivityTile(
                  "Direct Bonus",
                  "Level-1 commission",
                  "+ ₹150",
                  Colors.green,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildReferralCard(BuildContext context, String code, bool isDark) {
    return PremiumCard(
      glass: true,
      child: Column(
        children: [
          Text(
            'Share your unique referral code to earn bonuses for every new student or teacher who joins.',
            style: DesignSystem.bodySmall(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Code $code copied!', style: DesignSystem.bodySmall(color: Colors.white)),
                  backgroundColor: DesignSystem.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: DesignSystem.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: DesignSystem.primary.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    code,
                    style: DesignSystem.heading2(color: DesignSystem.primary).copyWith(
                      letterSpacing: 4,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.copy_rounded, color: DesignSystem.primary, size: 24),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          GradientButton(
            text: 'Share Invitation',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening Share Menu...'))
              );
            },
            icon: Icons.ios_share_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: DesignSystem.heading3(color: isDark ? Colors.white : DesignSystem.backgroundDark),
    );
  }

  Widget _buildActivityTile(String title, String subtitle, String amount, Color amountColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: amountColor.withOpacity(0.1),
            child: Icon(
              amount.startsWith('+') ? Icons.add_rounded : Icons.pending_rounded,
              color: amountColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: DesignSystem.bodyLarge(color: null)),
                Text(subtitle, style: DesignSystem.bodySmall(color: Colors.grey)),
              ],
            ),
          ),
          Text(
            amount,
            style: DesignSystem.bodyLarge(color: amountColor).copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.grey.withOpacity(0.1));
  }
}
