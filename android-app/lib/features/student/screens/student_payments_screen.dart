import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../services/student_service.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/app_widgets.dart';

final studentPaymentsProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(studentServiceProvider).getPaymentHistory();
});

class StudentPaymentsScreen extends ConsumerWidget {
  const StudentPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(studentPaymentsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DesignSystem.backgroundDark : const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text('Payment History', style: DesignSystem.heading3(color: null)),
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
        child: paymentsAsync.when(
          data: (payments) {
            if (payments.isEmpty) {
              return _buildEmptyState(isDark);
            }
            
            return ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: payments.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final payment = payments[index];
                return _PaymentCard(payment: payment, isDark: isDark);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err', style: DesignSystem.bodySmall(color: Colors.grey))),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: 0.3,
            child: Icon(Icons.account_balance_wallet_outlined, size: 80, color: isDark ? Colors.white : DesignSystem.backgroundDark),
          ),
          const SizedBox(height: 24),
          Text('No Transactions Yet', style: DesignSystem.heading3(color: null)),
          const SizedBox(height: 8),
          Text('Your payment history and invoices will appear here.', style: DesignSystem.bodySmall(color: Colors.grey), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final dynamic payment;
  final bool isDark;
  const _PaymentCard({required this.payment, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final status = payment['status']?.toString().toLowerCase() ?? 'success';
    final isSuccess = status == 'success' || status == 'completed';

    return PremiumCard(
      glass: true,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isSuccess ? Colors.green : DesignSystem.error).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSuccess ? Icons.check_rounded : Icons.close_rounded,
              color: isSuccess ? Colors.green : DesignSystem.error,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment['description'] ?? 'Tuition Fee',
                  style: DesignSystem.bodyMedium(color: null).copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  DateFormat('MMM dd, yyyy • hh:mm a').format(DateTime.parse(payment['created_at'])),
                  style: DesignSystem.bodySmall(color: Colors.grey),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${payment['amount']}',
                style: DesignSystem.heading3(color: null).copyWith(fontSize: 18),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isSuccess ? Colors.green : DesignSystem.error).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: isSuccess ? Colors.green : DesignSystem.error,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
