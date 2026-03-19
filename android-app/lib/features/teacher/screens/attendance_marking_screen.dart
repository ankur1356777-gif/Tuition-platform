import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/teacher_provider.dart';
import '../../../models/tuition.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/app_widgets.dart';

class AttendanceMarkingScreen extends ConsumerStatefulWidget {
  const AttendanceMarkingScreen({super.key});

  @override
  ConsumerState<AttendanceMarkingScreen> createState() => _AttendanceMarkingScreenState();
}

class _AttendanceMarkingScreenState extends ConsumerState<AttendanceMarkingScreen> {
  PaidTuition? _selectedTuition;
  bool _isLocating = false;

  @override
  Widget build(BuildContext context) {
    final tuitionsAsync = ref.watch(teacherTuitionsProvider);
    final actionState = ref.watch(teacherActionProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DesignSystem.backgroundDark : const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text('Mark Attendance', style: DesignSystem.heading3(color: null)),
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
            return _buildContent(tuitions, actionState, isDark);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err', style: DesignSystem.bodySmall(color: Colors.grey))),
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
            child: Icon(Icons.calendar_today_rounded, size: 80, color: isDark ? Colors.white : DesignSystem.backgroundDark),
          ),
          const SizedBox(height: 24),
          Text('No Classes Found', style: DesignSystem.heading3(color: null)),
          const SizedBox(height: 8),
          Text('Active classes assigned to you will appear here.', style: DesignSystem.bodySmall(color: Colors.grey), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildContent(List<PaidTuition> tuitions, AsyncValue actionState, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SELECT CLASS', style: DesignSystem.bodySmall(color: DesignSystem.primary).copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 16),
          PremiumCard(
            glass: true,
            child: DropdownButtonFormField<PaidTuition>(
              value: _selectedTuition,
              dropdownColor: isDark ? const Color(0xFF2A2A3E) : Colors.white,
              decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: Icon(Icons.school_rounded, color: DesignSystem.primary, size: 20),
                hintText: 'Choose a tuition session',
                hintStyle: DesignSystem.bodySmall(color: Colors.grey),
              ),
              items: tuitions.map((t) => DropdownMenuItem(
                value: t, 
                child: Text('${t.studentName ?? 'Student'} - ${t.subjects}', style: DesignSystem.bodyMedium(color: null)),
              )).toList(),
              onChanged: (val) => setState(() => _selectedTuition = val),
            ),
          ),
          const SizedBox(height: 32),
          if (_selectedTuition != null) ...[
            Text('MARK STATUS', style: DesignSystem.bodySmall(color: DesignSystem.primary).copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'PRESENT',
                    icon: Icons.check_circle_rounded,
                    color: Colors.green,
                    isLoading: _isLocating && actionState.isLoading,
                    onTap: () => _mark('present'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ActionButton(
                    label: 'ABSENT',
                    icon: Icons.cancel_rounded,
                    color: DesignSystem.error,
                    isLoading: false,
                    onTap: () => _mark('absent'),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 48),
          _buildLocationNotice(isDark),
        ],
      ),
    );
  }

  Widget _buildLocationNotice(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on_rounded, color: Colors.amber.shade700, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your location is securely recorded for session verification and quality assurance purposes.',
              style: DesignSystem.bodySmall(color: Colors.grey).copyWith(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  void _mark(String status) async {
    setState(() => _isLocating = true);
    
    try {
      Position? position;
      if (status == 'present') {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) throw 'Location permissions are denied';
        }
        if (permission == LocationPermission.deniedForever) throw 'Location permissions are permanently denied';
        
        position = await Geolocator.getCurrentPosition();
      }

      await ref.read(teacherActionProvider.notifier).markAttendance(
        tuitionId: _selectedTuition!.id,
        status: status,
        lat: position?.latitude ?? 0,
        lng: position?.longitude ?? 0,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Attendance marked as ${status.toUpperCase()}'), backgroundColor: status == 'present' ? Colors.green : DesignSystem.error),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: DesignSystem.error));
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isLoading;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        ),
        child: Column(
          children: [
            if (isLoading)
              const SizedBox(height: 32, width: 32, child: CircularProgressIndicator(strokeWidth: 3))
            else
              Icon(icon, color: color, size: 40),
            const SizedBox(height: 16),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
