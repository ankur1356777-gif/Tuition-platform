import 'package:flutter/material.dart';
final teacherDemoClassesProvider = FutureProvider<List<dynamic>>((ref) async {
  final apiService = ApiService();
  try {
    // Now hitting the real endpoint
    final response = await apiService.get('teacher/demos'); // Returns List
    return response as List<dynamic>; 
  } catch (e) {
    return [];
  }
});

class DemoNotifier extends StateNotifier<AsyncValue<void>> {
  final ApiService _apiService = ApiService();
  DemoNotifier() : super(const AsyncValue.data(null));

  Future<void> updateDemoStatus(int demoId, String status) async {
    state = const AsyncValue.loading();
    try {
      // Mock endpoint
      // await _apiService.post('teacher/demo/$demoId/status', {'status': status});
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final demoActionProvider = StateNotifierProvider<DemoNotifier, AsyncValue<void>>((ref) {
  return DemoNotifier();
});
