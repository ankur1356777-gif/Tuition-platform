import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../services/teacher_service.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/app_widgets.dart';

final demoClassesProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(teacherServiceProvider).getDemoClasses();
});

class TeacherDemoClassesScreen extends ConsumerWidget {
  const TeacherDemoClassesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demosAsync = ref.watch(demoClassesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DesignSystem.backgroundDark : const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text('Demo Requests', style: DesignSystem.heading3(color: null)),
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
        child: demosAsync.when(
          data: (demos) => _buildDemoList(context, demos, isDark),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err', style: DesignSystem.bodySmall(color: Colors.grey))),
        ),
      ),
    );
  }

  Widget _buildDemoList(BuildContext context, List<dynamic> demos, bool isDark) {
    if (demos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: 0.3,
              child: Icon(Icons.co_present_rounded, size: 80, color: isDark ? Colors.white : DesignSystem.backgroundDark),
            ),
            const SizedBox(height: 24),
            Text('No Demo Requests', style: DesignSystem.heading3(color: null)),
            const SizedBox(height: 8),
            Text('Availability requests will appear here.', style: DesignSystem.bodySmall(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      physics: const BouncingScrollPhysics(),
      itemCount: demos.length,
      itemBuilder: (context, index) {
        final demo = demos[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _DemoCard(demo: demo),
        );
      },
    );
  }
}

class _DemoCard extends StatelessWidget {
  final dynamic demo;
  final bool isDark;
  const _DemoCard({required this.demo, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final status = demo['status']?.toString().toUpperCase() ?? 'PENDING';
    final statusColor = _getStatusColor(status);

    return PremiumCard(
      glass: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                demo['student_name'] ?? 'New Student',
                style: DesignSystem.bodyLarge(color: null).copyWith(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.2)),
                ),
                child: Text(
                  status,
                  style: DesignSystem.bodySmall(color: statusColor).copyWith(fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.calendar_today_rounded, demo['scheduled_at'] ?? 'Date TBD'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.book_rounded, demo['subject'] ?? 'Mathematics'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.location_on_rounded, demo['landmark'] ?? 'Location not specified'),
          const SizedBox(height: 20),
          Divider(color: Colors.grey.withOpacity(0.1)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.phone_rounded, size: 18),
                  label: const Text('Contact'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GradientButton(
                  text: 'Start Demo',
                  onPressed: () {},
                  compact: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: DesignSystem.bodySmall(color: null),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'COMPLETED': return Colors.green;
      case 'CANCELLED': return Colors.red;
      case 'IN_PROGRESS': return Colors.orange;
      default: return DesignSystem.primary;
    }
  }
}
