import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import '../services/student_service.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/app_widgets.dart';

class ActiveTuitionsScreen extends ConsumerWidget {
  const ActiveTuitionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tuitionsAsync = ref.watch(activeTuitionsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DesignSystem.backgroundDark : const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text('My Active Tuitions', style: DesignSystem.heading3(color: null)),
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
        child: tuitionsAsync.when(
          data: (tuitions) {
            if (tuitions.isEmpty) {
              return _buildEmptyState(isDark);
            }

            return ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: tuitions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                final tuition = tuitions[index];
                return _TuitionCard(tuition: tuition, isDark: isDark);
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
            child: Icon(Icons.school_outlined, size: 80, color: isDark ? Colors.white : DesignSystem.backgroundDark),
          ),
          const SizedBox(height: 24),
          Text('No Active Tuitions', style: DesignSystem.heading3(color: null)),
          const SizedBox(height: 8),
          Text('Your confirmed classes will appear here.', style: DesignSystem.bodySmall(color: Colors.grey), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _TuitionCard extends StatelessWidget {
  final dynamic tuition;
  final bool isDark;
  const _TuitionCard({required this.tuition, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final teacherName = tuition['teacher']?['user']?['name'] ?? 'Unknown Teacher';
    final teacherId = tuition['teacher']?['id'];
    final subjects = tuition['lead']?['tuition_request']?['subjects'] as List? ?? [];
    final subject = subjects.isNotEmpty ? subjects[0].toString() : 'N/A';
    final meetingId = tuition['meeting_id'];
    final isLive = meetingId != null;

    return PremiumCard(
      glass: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: DesignSystem.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.menu_book_rounded, color: DesignSystem.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subject, style: DesignSystem.heading3(color: null).copyWith(fontSize: 18)),
                    Text('with $teacherName', style: DesignSystem.bodySmall(color: Colors.grey)),
                  ],
                ),
              ),
              if (isLive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      const Text('LIVE', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: GradientButton(
                  text: isLive ? 'JOIN LIVE CLASS' : 'CLASS NOT STARTED',
                  onPressed: isLive ? () => _launchMeeting(meetingId) : null,
                  icon: Icons.videocam_rounded,
                  height: 48,
                ),
              ),
              const SizedBox(width: 12),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: teacherId != null ? () {
                    context.push('/student/rate-teacher', extra: {
                      'teacherId': teacherId,
                      'teacherName': teacherName,
                    });
                  } : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: DesignSystem.primary.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.star_outline_rounded, color: DesignSystem.primary, size: 22),
                  ),
                ),
              ),
            ],
          ),
          if (!isLive)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Waiting for teacher to start the session...',
                style: DesignSystem.bodySmall(color: Colors.grey).copyWith(fontStyle: FontStyle.italic, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _launchMeeting(String meetingId) async {
    final url = Uri.parse('https://meet.jit.si/$meetingId');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}
