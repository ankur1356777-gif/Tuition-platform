import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api_service.dart';

final studentPerformanceProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final apiService = ApiService();
  try {
    return await apiService.get('student/dashboard');
  } catch (e) {
    return {};
  }
});

final studentTestResultsProvider = FutureProvider<List<dynamic>>((ref) async {
  final apiService = ApiService();
  try {
    final response = await apiService.get('student/test-results');
    return response['data'] ?? [];
  } catch (e) {
    return [];
  }
});
