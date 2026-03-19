import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api_service.dart';

final notificationsProvider = FutureProvider<List<dynamic>>((ref) async {
  final apiService = ApiService();
  try {
    final response = await apiService.get('notifications');
    return response['data']?['data'] ?? [];
  } catch (e) {
    return [];
  }
});

class NotificationNotifier extends StateNotifier<AsyncValue<void>> {
  final ApiService _apiService = ApiService();
  NotificationNotifier() : super(const AsyncValue.data(null));

  Future<void> markAsRead(int id) async {
    try {
      await _apiService.post('notifications/$id/read', {});
    } catch (e) {
      // fail silently
    }
  }
}

final notificationActionProvider = StateNotifierProvider<NotificationNotifier, AsyncValue<void>>((ref) {
  return NotificationNotifier();
});
