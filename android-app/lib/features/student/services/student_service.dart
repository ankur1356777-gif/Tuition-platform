import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api_service.dart';

final studentServiceProvider = Provider((ref) => StudentService());

final activeTuitionsProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(studentServiceProvider).getActiveTuitions();
});

final availableTestsProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(studentServiceProvider).getAvailableTests();
});

class StudentService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> getDashboardStats() async {
    final response = await _api.get('student/dashboard');
    return response as Map<String, dynamic>;
  }

  Future<List<dynamic>> getAttendance() async {
    final response = await _api.get('student/attendance');
    return response as List<dynamic>;
  }

  Future<List<dynamic>> getTestResults() async {
    final response = await _api.get('student/test-results');
    return response as List<dynamic>;
  }

  Future<List<dynamic>> getPaymentHistory() async {
    final response = await _api.get('student/payments');
    return response as List<dynamic>;
  }

  Future<void> submitDemoFeedback(int demoId, String feedback) async {
    await _api.post('student/demos/$demoId/feedback', {'feedback': feedback});
  }

  Future<List<dynamic>> getAvailableTests() async {
    final response = await _api.get('student/tests');
    return response as List<dynamic>;
  }

  Future<void> submitTest(int testId, Map<int, int> answers) async {
    // Map to JSON compatible format
    final formattedAnswers = answers.map((key, value) => MapEntry(key.toString(), value));
    await _api.post('student/tests/$testId/submit', {'answers': formattedAnswers});
  }

  Future<List<dynamic>> getActiveTuitions() async {
    final response = await _api.get('student/tuitions');
    return response as List<dynamic>;
  }

  // ==================== NEW FEATURES ====================

  // Homework
  Future<List<dynamic>> getHomework() async {
    final response = await _api.get('student/homework');
    return response as List<dynamic>;
  }

  Future<void> submitHomework(int homeworkId, Map<String, dynamic> data) async {
    await _api.post('student/homework/$homeworkId/submit', data);
  }

  // Teacher Rating
  Future<void> rateTeacher(int teacherId, Map<String, dynamic> data) async {
    await _api.post('student/teachers/$teacherId/rate', data);
  }

  Future<Map<String, dynamic>?> getTeacherRating(int teacherId) async {
    try {
      final response = await _api.get('student/teachers/$teacherId/rating');
      return response as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  // Teaching Plan View
  Future<Map<String, dynamic>?> getTeachingPlan(int tuitionId) async {
    try {
      final response = await _api.get('student/tuition/$tuitionId/teaching-plan');
      return response as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  // All Teaching Plans
  Future<List<dynamic>> getTeachingPlans() async {
    final response = await _api.get('student/teaching-plans');
    return response as List<dynamic>;
  }

  // Batch Status
  Future<Map<String, dynamic>> getBatchStatus() async {
    final response = await _api.get('student/batch-status');
    return response as Map<String, dynamic>;
  }
}

