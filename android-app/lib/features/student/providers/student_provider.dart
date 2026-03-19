import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api_service.dart';

final studentDashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final apiService = ApiService();
  final response = await apiService.get('student/dashboard');
  return response;
});

class StudentNotifier extends StateNotifier<AsyncValue<void>> {
  final ApiService _apiService = ApiService();
  
  StudentNotifier() : super(const AsyncValue.data(null));

  Future<void> createTuitionRequest({
    required String grade,
    required List<String> subjects,
    required String address,
    required double lat,
    required double lng,
    String? preferredGender,
    double? budget,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _apiService.post('student/requests', {
        'class': grade,
        'subjects': subjects,
        'address': address,
        'latitude': lat,
        'longitude': lng,
        'preferred_gender': preferredGender,
        'budget': budget,
      });
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final studentActionProvider = StateNotifierProvider<StudentNotifier, AsyncValue<void>>((ref) {
  return StudentNotifier();
});
