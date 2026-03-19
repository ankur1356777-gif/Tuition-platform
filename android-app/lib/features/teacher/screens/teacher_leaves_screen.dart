import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../services/teacher_service.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/app_widgets.dart';

final leavesProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(teacherServiceProvider).getLeaves();
});

final leaveQuotaProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(teacherServiceProvider).getLeaveQuotaStatus();
});

class TeacherLeavesScreen extends ConsumerWidget {
  const TeacherLeavesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leavesAsync = ref.watch(leavesProvider);
    final quotaAsync = ref.watch(leaveQuotaProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DesignSystem.backgroundDark : const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text('Leave Management', style: DesignSystem.heading3(color: null)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : DesignSystem.backgroundDark),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showApplyLeaveDialog(context, ref),
        backgroundColor: DesignSystem.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('APPLY LEAVE', style: DesignSystem.bodyMedium(color: Colors.white).copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        elevation: 4,
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
        child: Column(
          children: [
            quotaAsync.when(
              data: (quota) => _buildQuotaHero(context, quota, isDark),
              loading: () => const Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),
            
            Expanded(
              child: leavesAsync.when(
                data: (leaves) => _buildLeaveList(leaves, isDark),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err', style: DesignSystem.bodySmall(color: Colors.grey))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuotaHero(BuildContext context, dynamic quota, bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [DesignSystem.primary, const Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: DesignSystem.primary.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _QuotaItem(
            label: 'AUTO LEAVES',
            value: '${quota['remaining_auto_leaves']}',
            icon: Icons.verified_user_rounded,
          ),
          Container(height: 40, width: 1, color: Colors.white.withOpacity(0.2)),
          _QuotaItem(
            label: 'USED (15D)',
            value: '${quota['leaves_in_last_15_days']}',
            icon: Icons.date_range_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveList(List<dynamic> leaves, bool isDark) {
    if (leaves.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: 0.3,
              child: Icon(Icons.event_busy_rounded, size: 80, color: isDark ? Colors.white : DesignSystem.backgroundDark),
            ),
            const SizedBox(height: 24),
            Text('No Records Found', style: DesignSystem.heading3(color: null)),
            const SizedBox(height: 8),
            Text('Your leave applications will appear here.', style: DesignSystem.bodySmall(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      physics: const BouncingScrollPhysics(),
      itemCount: leaves.length,
      itemBuilder: (context, index) {
        final leave = leaves[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _LeaveCard(leave: leave),
        );
      },
    );
  }

  void _showApplyLeaveDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ApplyLeaveBottomSheet(
        onSubmit: () {
          ref.invalidate(leavesProvider);
          ref.invalidate(leaveQuotaProvider);
        },
      ),
    );
  }
}

class _QuotaItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _QuotaItem({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 18),
        const SizedBox(height: 8),
        Text(value, style: DesignSystem.heading1(color: Colors.white).copyWith(fontSize: 32)),
        Text(label, style: DesignSystem.bodySmall(color: Colors.white.withOpacity(0.7)).copyWith(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
      ],
    );
  }
}

class _LeaveCard extends StatelessWidget {
  final dynamic leave;
  const _LeaveCard({required this.leave});

  @override
  Widget build(BuildContext context) {
    final startDate = DateTime.parse(leave['start_date']);
    final endDate = DateTime.parse(leave['end_date']);
    final status = leave['status']?.toString().toUpperCase() ?? 'PENDING';
    final reason = leave['reason'] as String? ?? '';
    final daysCount = endDate.difference(startDate).inDays + 1;

    return PremiumCard(
      glass: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: DesignSystem.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.calendar_month_rounded, color: DesignSystem.primary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${DateFormat('dd MMM').format(startDate)} - ${DateFormat('dd MMM yyyy').format(endDate)}',
                    style: DesignSystem.bodyMedium(color: null).copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              _StatusBadge(status: status),
            ],
          ),
          if (reason.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(reason, style: DesignSystem.bodySmall(color: Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Text('$daysCount day(s)', style: DesignSystem.bodySmall(color: DesignSystem.primary).copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(
                leave['leave_type'] == 'auto' ? 'Auto-Approved' : 'Manual Approval',
                style: DesignSystem.bodySmall(color: Colors.grey).copyWith(fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color = status == 'APPROVED' ? Colors.green : (status == 'REJECTED' ? DesignSystem.error : Colors.orange);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.2))),
      child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 9, letterSpacing: 0.5)),
    );
  }
}

class _ApplyLeaveBottomSheet extends ConsumerStatefulWidget {
  final VoidCallback onSubmit;
  const _ApplyLeaveBottomSheet({required this.onSubmit});

  @override
  ConsumerState<_ApplyLeaveBottomSheet> createState() => _ApplyLeaveBottomSheetState();
}

class _ApplyLeaveBottomSheetState extends ConsumerState<_ApplyLeaveBottomSheet> {
  DateTime? _startDate;
  DateTime? _endDate;
  final _reasonController = TextEditingController();
  bool _isLoading = false;
  bool _requiresReason = false;

  @override
  void initState() {
    super.initState();
    _checkQuota();
  }

  Future<void> _checkQuota() async {
    try {
      final quota = await ref.read(teacherServiceProvider).getLeaveQuotaStatus();
      if (mounted) setState(() => _requiresReason = (quota['remaining_auto_leaves'] as int) == 0);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 32, left: 24, right: 24, top: 32),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E2E) : Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(32))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Request Leave', style: DesignSystem.heading3(color: null)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _DatePickerField(label: 'START DATE', date: _startDate, onTap: () => _selectDate(true))),
              const SizedBox(width: 16),
              Expanded(child: _DatePickerField(label: 'END DATE', date: _endDate, onTap: () => _selectDate(false))),
            ],
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(_requiresReason ? 'REASON (REQUIRED)' : 'REASON (OPTIONAL)', style: DesignSystem.bodySmall(color: DesignSystem.primary).copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 10)),
          ),
          CustomTextField(controller: _reasonController, hintText: 'Explain why you need leave...', prefixIcon: Icons.description_outlined, maxLines: 3),
          if (_requiresReason) ...[
            const SizedBox(height: 8),
            Text('* Reason is required as auto-payout quota is exhausted.', style: TextStyle(color: DesignSystem.error, fontSize: 10)),
          ],
          const SizedBox(height: 32),
          GradientButton(
            text: _isLoading ? 'SUBMITTING...' : 'SUBMIT REQUEST',
            onPressed: _isLoading ? null : _submitLeave,
            icon: Icons.send_rounded,
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? DateTime.now().add(const Duration(days: 1)) : (_startDate ?? DateTime.now().add(const Duration(days: 1))),
      firstDate: isStart ? DateTime.now() : (_startDate ?? DateTime.now()),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) setState(() { if (isStart) { _startDate = picked; if (_endDate != null && _endDate!.isBefore(picked)) _endDate = null; } else { _endDate = picked; } });
  }

  Future<void> _submitLeave() async {
    if (_startDate == null || _endDate == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select dates'))); return; }
    if (_requiresReason && _reasonController.text.trim().isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reason required'))); return; }
    setState(() => _isLoading = true);
    try {
      await ref.read(teacherServiceProvider).applyLeave({'start_date': DateFormat('yyyy-MM-dd').format(_startDate!), 'end_date': DateFormat('yyyy-MM-dd').format(_endDate!), 'reason': _reasonController.text.trim()});
      if (mounted) { Navigator.pop(context); widget.onSubmit(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Success'), backgroundColor: Colors.green)); }
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: DesignSystem.error)); }
    finally { if (mounted) setState(() => _isLoading = false); }
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  const _DatePickerField({required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: PremiumCard(
        glass: true,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: DesignSystem.bodySmall(color: Colors.grey).copyWith(fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 14, color: DesignSystem.primary),
                const SizedBox(width: 8),
                Text(date != null ? DateFormat('dd MMM').format(date!) : 'Select', style: DesignSystem.bodyMedium(color: null).copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
