import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';
import '../services/teacher_service.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/app_widgets.dart';

class TeacherActiveTuitionsScreen extends ConsumerWidget {
  const TeacherActiveTuitionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tuitionsAsync = ref.watch(activeTuitionsTeacherProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DesignSystem.backgroundDark : const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text('My Active Classes', style: DesignSystem.heading3(color: null)),
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
            if (tuitions.isEmpty) return _buildEmptyState(isDark);

            return ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: tuitions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                final tuition = tuitions[index];
                return _ActiveTuitionCard(tuition: tuition, isDark: isDark);
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
          Text('No Active Classes', style: DesignSystem.heading3(color: null)),
          const SizedBox(height: 8),
          Text('Classes you are teaching will appear here.', style: DesignSystem.bodySmall(color: Colors.grey), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _ActiveTuitionCard extends ConsumerWidget {
  final dynamic tuition;
  final bool isDark;
  const _ActiveTuitionCard({required this.tuition, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final student = tuition['student']?['user']?['name'] ?? 'Unknown Student';
    final subject = tuition['lead']?['tuition_request']?['subjects']?[0] ?? 'N/A';
    final meetingId = tuition['meeting_id'];
    final bool isLive = meetingId != null;

    return PremiumCard(
      glass: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: DesignSystem.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.class_rounded, color: DesignSystem.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subject, style: DesignSystem.heading3(color: null).copyWith(fontSize: 18)),
                    Text('Student: $student', style: DesignSystem.bodySmall(color: Colors.grey)),
                  ],
                ),
              ),
              if (isLive)
                _LiveIndicator(),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: GradientButton(
                  text: isLive ? 'JOIN LIVE CLASS' : 'START CLASS',
                  onPressed: () => _startOrJoinMeeting(ref, tuition['id'], meetingId, context),
                  icon: isLive ? Icons.videocam_rounded : Icons.play_arrow_rounded,
                ),
              ),
              if (isLive) ...[
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () => _endMeeting(ref, tuition['id']),
                  icon: const Icon(Icons.stop_circle_rounded, color: DesignSystem.error, size: 32),
                  tooltip: 'End Class',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _startOrJoinMeeting(WidgetRef ref, int tuitionId, String? existingMeetingId, BuildContext context) async {
    String meetingId = existingMeetingId ?? _generateRandomString(12);
    
    if (existingMeetingId == null) {
      await ref.read(teacherServiceProvider).updateMeetingId(tuitionId, meetingId);
      ref.invalidate(activeTuitionsTeacherProvider);
    }

    final url = Uri.parse('https://meet.jit.si/$meetingId');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open meeting link')));
      }
    }
  }

  void _endMeeting(WidgetRef ref, int tuitionId) async {
    await ref.read(teacherServiceProvider).updateMeetingId(tuitionId, null);
    ref.invalidate(activeTuitionsTeacherProvider);
  }

  String _generateRandomString(int len) {
    var r = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(len, (index) => chars[r.nextInt(chars.length)]).join();
  }
}

class _LiveIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: DesignSystem.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: DesignSystem.error.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(color: DesignSystem.error, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          const Text('LIVE', style: TextStyle(color: DesignSystem.error, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1)),
        ],
      ),
    );
  }
}
