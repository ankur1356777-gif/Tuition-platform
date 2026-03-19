import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api_service.dart';

final adminAttendanceProvider = FutureProvider.autoDispose((ref) async {
  final response = await ApiService().get('admin/attendance-logs');
  return response['data'] as List<dynamic>;
});

class AdminNotificationService {
  final ApiService _api = ApiService();

  Future<void> broadcastNotification({
    required String title,
    required String body,
    String? role,
  }) async {
    await _api.post('admin/notifications/broadcast', {
      'title': title,
      'body': body,
      'role': role,
    });
  }
}

final adminNotificationProvider = Provider((ref) => AdminNotificationService());
