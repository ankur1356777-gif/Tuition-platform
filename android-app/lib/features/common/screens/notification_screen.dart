import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notification_provider.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/app_widgets.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DesignSystem.backgroundDark : const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text('Notifications', style: DesignSystem.heading3(color: null)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : DesignSystem.backgroundDark),
        actions: [
          IconButton(
            icon: Tooltip(
              message: 'Mark all as read',
              child: Icon(Icons.done_all_rounded, color: DesignSystem.primary),
            ),
            onPressed: () {
              // mark all as read logic
            },
          ),
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
        child: notificationsAsync.when(
          data: (notifications) {
            if (notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Opacity(
                      opacity: 0.3,
                      child: Icon(Icons.notifications_none_rounded, size: 80, color: isDark ? Colors.white : DesignSystem.backgroundDark),
                    ),
                    const SizedBox(height: 24),
                    Text('All caught up!', style: DesignSystem.heading3(color: null)),
                    const SizedBox(height: 8),
                    Text('You have no new notifications.', style: DesignSystem.bodySmall(color: Colors.grey)),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () => ref.refresh(notificationsProvider.future),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                physics: const BouncingScrollPhysics(),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final n = notifications[index];
                  final isRead = n['is_read'] == 1 || n['read_at'] != null;
                  final type = n['type']?.toString() ?? 'default';
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: PremiumCard(
                      glass: true,
                      onTap: () {
                        if (!isRead) {
                          ref.read(notificationActionProvider.notifier).markAsRead(n['id']);
                          ref.refresh(notificationsProvider);
                        }
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: (isRead ? Colors.grey : _getColor(type)).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getIcon(type),
                              color: isRead ? Colors.grey : _getColor(type),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        n['title'] ?? 'Platform Update',
                                        style: DesignSystem.bodyMedium(color: null).copyWith(
                                          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (!isRead)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(n['body'] ?? '', style: DesignSystem.bodySmall(color: isDark ? Colors.grey[400] : Colors.grey[600])),
                                const SizedBox(height: 8),
                                Text(
                                  n['created_at'] != null ? _formatDate(n['created_at']) : '',
                                  style: DesignSystem.bodySmall(color: Colors.grey).copyWith(fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err', style: DesignSystem.bodySmall(color: Colors.grey))),
        ),
      ),
    );
  }

  IconData _getIcon(String? type) {
    switch (type) {
      case 'lead_received': return Icons.flash_on_rounded;
      case 'payment_received': return Icons.account_balance_wallet_rounded;
      case 'demo_scheduled': return Icons.video_camera_front_rounded;
      case 'attendance_marked': return Icons.check_circle_rounded;
      case 'homework_assigned': return Icons.assignment_rounded;
      case 'test_scheduled': return Icons.quiz_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color _getColor(String? type) {
    switch (type) {
      case 'lead_received': return Colors.orange;
      case 'payment_received': return Colors.green;
      case 'demo_scheduled': return Colors.purple;
      case 'attendance_marked': return Colors.teal;
      case 'homework_assigned': return Colors.blue;
      case 'test_scheduled': return Colors.deepOrange;
      default: return DesignSystem.primary;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inDays == 0) {
        if (diff.inHours == 0) return '${diff.inMinutes}m ago';
        return '${diff.inHours}h ago';
      }
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
