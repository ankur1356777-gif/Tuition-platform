import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../services/agent_service.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/app_widgets.dart';

final agentWalletProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(agentServiceProvider).getWalletHistory();
});

class AgentWalletScreen extends ConsumerWidget {
  const AgentWalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(agentWalletProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DesignSystem.backgroundDark : const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text('My Portfolio', style: DesignSystem.heading3(color: null)),
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
        child: walletAsync.when(
          data: (transactions) => _buildContent(context, ref, transactions, isDark),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err', style: DesignSystem.bodySmall(color: Colors.grey))),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, List<dynamic> transactions, bool isDark) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildBalanceHero(context, ref, isDark)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          sliver: SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('TRANSACTION HISTORY', style: DesignSystem.bodySmall(color: DesignSystem.primary).copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                Icon(Icons.receipt_long_rounded, color: DesignSystem.primary, size: 20),
              ],
            ),
          ),
        ),
        if (transactions.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _buildEmptyTransactions(isDark),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final tx = transactions[index];
                  final amount = double.tryParse(tx['amount'].toString()) ?? 0;
                  final isCredit = tx['type'] == 'credit' || amount > 0;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: PremiumCard(
                      glass: true,
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: (isCredit ? Colors.green : DesignSystem.error).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              isCredit ? Icons.add_circle_outline_rounded : Icons.remove_circle_outline_rounded,
                              color: isCredit ? Colors.green : DesignSystem.error,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(tx['description'] ?? 'Referral Payout', style: DesignSystem.bodyMedium(color: null).copyWith(fontWeight: FontWeight.bold)),
                                Text(
                                  DateFormat('MMM dd, yyyy • HH:mm').format(DateTime.parse(tx['created_at'])),
                                  style: DesignSystem.bodySmall(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${isCredit ? "+" : "-"}${DesignSystem.currency}${amount.abs().toStringAsFixed(0)}',
                            style: DesignSystem.bodyLarge(color: isCredit ? Colors.green : DesignSystem.error).copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: transactions.length,
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  Widget _buildBalanceHero(BuildContext context, WidgetRef ref, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF6B21A8), const Color(0xFF3B0764)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.purple.withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 15)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Available Balance', style: DesignSystem.bodySmall(color: Colors.white.withOpacity(0.8)).copyWith(letterSpacing: 1)),
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 20)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding: const EdgeInsets.only(top: 8, right: 4), child: Text(DesignSystem.currency, style: DesignSystem.heading3(color: Colors.white).copyWith(fontSize: 24))),
              Text('5,400', style: DesignSystem.heading1(color: Colors.white).copyWith(fontSize: 48)),
              Padding(padding: const EdgeInsets.only(top: 24, left: 2), child: Text('.00', style: DesignSystem.heading3(color: Colors.white.withOpacity(0.6)).copyWith(fontSize: 18))),
            ],
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => _showPayoutDialog(context, ref),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.purple, minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.outbound_rounded),
                const SizedBox(width: 12),
                Text('REQUEST PAYOUT', style: DesignSystem.bodyMedium(color: Colors.purple.shade900).copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTransactions(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(opacity: 0.2, child: Icon(Icons.receipt_long_rounded, size: 64, color: isDark ? Colors.white : DesignSystem.backgroundDark)),
          const SizedBox(height: 16),
          Text('No transactions yet', style: DesignSystem.bodyMedium(color: Colors.grey)),
        ],
      ),
    );
  }

  void _showPayoutDialog(BuildContext context, WidgetRef ref) {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Request Payout', style: DesignSystem.heading3(color: null)),
        content: TextField(
          controller: amountController,
          decoration: DesignSystem.inputDecoration('Amount', Icons.currency_rupee_rounded),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('CANCEL', style: DesignSystem.bodySmall(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                try {
                  await ref.read(agentServiceProvider).requestPayout(amount);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payout requested!'), backgroundColor: Colors.green));
                    ref.invalidate(agentWalletProvider);
                  }
                } catch (e) {
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: DesignSystem.error));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: DesignSystem.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('SUBMIT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
