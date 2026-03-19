import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api_service.dart';
import '../../../models/lead.dart';
import '../../../models/tuition.dart';

final teacherDashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final apiService = ApiService();
  final response = await apiService.get('teacher/dashboard');
  return response;
});

final teacherLeadsProvider = FutureProvider<List<Lead>>((ref) async {
  final apiService = ApiService();
  final response = await apiService.get('teacher/dashboard');
  final List<dynamic> leadsJson = response['recent_leads'] ?? [];
  return leadsJson.map((json) => Lead.fromJson(json)).toList();
});

final teacherTuitionsProvider = FutureProvider<List<PaidTuition>>((ref) async {
  // In a real app we'd have a specific endpoint /teacher/tuitions
  // For now return empty or mock from dashboard if it contained them
  return [];
});

class TeacherNotifier extends StateNotifier<AsyncValue<void>> {
  final ApiService _apiService = ApiService();
  
  TeacherNotifier() : super(const AsyncValue.data(null));

  Future<void> manageLead(int leadId, String status) async {
    state = const AsyncValue.loading();
    try {
      await _apiService.post('teacher/leads/$leadId/manage', {'status': status});
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> markAttendance({
    required int tuitionId,
    required String status,
    required double lat,
    required double lng,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _apiService.post('teacher/attendance', {
        'tuition_id': tuitionId,
        'status': status,
        'latitude': lat,
        'longitude': lng,
      });
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final teacherActionProvider = StateNotifierProvider<TeacherNotifier, AsyncValue<void>>((ref) {
  return TeacherNotifier();
});
