import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api_service.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/app_widgets.dart';

class TeacherLeadsScreen extends ConsumerStatefulWidget {
  const TeacherLeadsScreen({super.key});

  @override
  ConsumerState<TeacherLeadsScreen> createState() => _TeacherLeadsScreenState();
}

class _TeacherLeadsScreenState extends ConsumerState<TeacherLeadsScreen> {
  bool _isLoading = true;
  List<dynamic> _leads = [];

  @override
  void initState() {
    super.initState();
    _fetchLeads();
  }

  Future<void> _fetchLeads() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService().get('teacher/leads');
      setState(() {
        _leads = response as List<dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: DesignSystem.error));
      }
    }
  }

  Future<void> _manageLead(int leadId, String status) async {
    try {
      await ApiService().post('teacher/leads/$leadId/manage', {'status': status});
      _fetchLeads();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lead $status!'), backgroundColor: Colors.green));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: DesignSystem.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DesignSystem.backgroundDark : const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text('Business Leads', style: DesignSystem.heading3(color: null)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : DesignSystem.backgroundDark),
        actions: [
          IconButton(onPressed: _fetchLeads, icon: const Icon(Icons.refresh_rounded)),
          const SizedBox(width: 8),
        ],
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _leads.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _leads.length,
                    itemBuilder: (context, index) {
                      final lead = _leads[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _LeadCard(lead: lead, onManage: _manageLead),
                      );
                    },
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
            child: Icon(Icons.rocket_launch_rounded, size: 80, color: isDark ? Colors.white : DesignSystem.backgroundDark),
          ),
          const SizedBox(height: 24),
          Text('No New Leads', style: DesignSystem.heading3(color: null)),
          const SizedBox(height: 8),
          Text('New opportunities will appear here soon.', style: DesignSystem.bodySmall(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _LeadCard extends StatelessWidget {
  final dynamic lead;
  final Function(int, String) onManage;
  const _LeadCard({required this.lead, required this.onManage});

  @override
  Widget build(BuildContext context) {
    final request = lead['tuition_request'];
    final subjects = request?['subjects'] is List ? (request['subjects'] as List).join(', ') : request?['subjects']?.toString() ?? 'N/A';
    final score = lead['match_score'] ?? 0;
    
    return PremiumCard(
      glass: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: DesignSystem.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text('MATCH $score%', style: TextStyle(color: DesignSystem.primary, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5)),
              ),
              _StatusIndicator(status: lead['status']),
            ],
          ),
          const SizedBox(height: 16),
          Text(request?['guest_name'] ?? 'Potential Student', style: DesignSystem.heading3(color: null)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            children: [
              _InfoChip(label: 'Grade ${request?['class'] ?? 'N/A'}', icon: Icons.school_rounded),
              _InfoChip(label: '₹${request?['budget'] ?? 'N/A'}/mo', icon: Icons.payments_rounded),
            ],
          ),
          const SizedBox(height: 12),
          Text(subjects, style: DesignSystem.bodySmall(color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
          const Divider(height: 32),
          if (lead['is_contact_shared'] == true || lead['is_contact_shared'] == 1) ...[
            Text('ADDRESS', style: DesignSystem.bodySmall(color: Colors.grey).copyWith(fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 4),
            Text(request?['location'] ?? 'Location shared', style: DesignSystem.bodyMedium(color: null).copyWith(fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            GradientButton(
              text: 'CONTACT: ${request?['guest_phone'] ?? 'N/A'}',
              onPressed: () {},
              icon: Icons.phone_rounded,
            ),
          ] else ...[
            if (lead['status'] == 'sent')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => onManage(lead['id'], 'rejected'),
                      style: OutlinedButton.styleFrom(side: BorderSide(color: DesignSystem.error.withOpacity(0.5)), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: Text('REJECT', style: DesignSystem.bodySmall(color: DesignSystem.error).copyWith(fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GradientButton(
                      text: 'ACCEPT',
                      onPressed: () => onManage(lead['id'], 'accepted'),
                      icon: Icons.check_circle_rounded,
                    ),
                  ),
                ],
              )
            else
              Center(child: Text('Awaiting Admin Approval', style: DesignSystem.bodySmall(color: Colors.grey).copyWith(fontStyle: FontStyle.italic))),
          ],
        ],
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final String? status;
  const _StatusIndicator({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color = status == 'accepted' || status == 'active' ? Colors.green : (status == 'sent' ? DesignSystem.primary : Colors.orange);
    return Row(
      children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(status?.toUpperCase() ?? 'PENDING', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 9, letterSpacing: 0.5)),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _InfoChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.grey.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey),
          const SizedBox(width: 4),
          Text(label, style: DesignSystem.bodySmall(color: Colors.grey).copyWith(fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
