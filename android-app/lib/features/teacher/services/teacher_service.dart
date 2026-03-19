import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api_service.dart';

final teacherServiceProvider = Provider((ref) => TeacherService());

final activeTuitionsTeacherProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(teacherServiceProvider).getActiveTuitions();
});

class TeacherService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> getDashboardStats() async {
    final response = await _api.get('teacher/dashboard');
    return response as Map<String, dynamic>;
  }

  Future<List<dynamic>> getLeads() async {
    final response = await _api.get('teacher/leads');
    return response as List<dynamic>;
  }

  Future<void> updateLeadStatus(String leadId, String status) async {
    await _api.post('teacher/leads/$leadId/manage', {'status': status});
  }

  Future<List<dynamic>> getDemos() async {
    final response = await _api.get('teacher/demos');
    return response as List<dynamic>;
  }

  Future<List<dynamic>> getWalletHistory() async {
    final response = await _api.get('teacher/wallet');
    return response as List<dynamic>;
  }

  Future<void> markAttendance(Map<String, dynamic> data) async {
    await _api.post('teacher/attendance', data);
  }

  Future<List<dynamic>> getActiveTuitions() async {
    final response = await _api.get('teacher/tuitions');
    return response as List<dynamic>;
  }

  Future<void> updateMeetingId(int tuitionId, String? meetingId) async {
    await _api.post('teacher/tuition/$tuitionId/meeting', {'meeting_id': meetingId});
  }

  Future<void> createTest(Map<String, dynamic> data) async {
    await _api.post('teacher/tests', data);
  }

  Future<List<dynamic>> getLeaves() async {
    final response = await _api.get('teacher/leaves');
    return response as List<dynamic>;
  }

  Future<void> applyLeave(Map<String, dynamic> data) async {
    await _api.post('teacher/leaves', data);
  }

  Future<Map<String, dynamic>> getLeaveQuotaStatus() async {
    final response = await _api.get('teacher/leaves/quota');
    return response as Map<String, dynamic>;
  }

  Future<List<dynamic>> getAvailableRequirements() async {
    final response = await _api.get('teacher/available-requirements');
    return response as List<dynamic>;
  }

  Future<void> expressInterest(int requirementId) async {
    await _api.post('teacher/requirements/$requirementId/interest', {});
  }

  // ==================== NEW FEATURES ====================

  // Homework Management
  Future<List<dynamic>> getHomework() async {
    final response = await _api.get('teacher/homework');
    return response as List<dynamic>;
  }

  Future<void> createHomework(Map<String, dynamic> data) async {
    await _api.post('teacher/homework', data);
  }

  Future<List<dynamic>> getHomeworkSubmissions(int homeworkId) async {
    final response = await _api.get('teacher/homework/$homeworkId/submissions');
    return response as List<dynamic>;
  }

  Future<void> reviewHomework(int submissionId, Map<String, dynamic> data) async {
    await _api.post('teacher/homework/submissions/$submissionId/review', data);
  }

  // Teaching Plans
  Future<List<dynamic>> getTeachingPlans() async {
    final response = await _api.get('teacher/teaching-plans');
    return response as List<dynamic>;
  }

  Future<void> createTeachingPlan(Map<String, dynamic> data) async {
    await _api.post('teacher/teaching-plans', data);
  }

  Future<void> updateTeachingPlan(int planId, Map<String, dynamic> data) async {
    await _api.put('teacher/teaching-plans/$planId', data);
  }

  // Weekly Tests
  Future<List<dynamic>> getWeeklyTests() async {
    final response = await _api.get('teacher/weekly-tests');
    return response as List<dynamic>;
  }

  Future<void> scheduleWeeklyTest(Map<String, dynamic> data) async {
    await _api.post('teacher/weekly-tests', data);
  }

  // Leads with Limited Details (Contact Request Flow)
  Future<List<dynamic>> getLeadsWithLimitedDetails() async {
    final response = await _api.get('teacher/leads/limited');
    return response as List<dynamic>;
  }

  Future<void> requestStudentContact(int leadId) async {
    await _api.post('teacher/leads/$leadId/request-contact', {});
  }

  // Wallet with Rewards
  Future<Map<String, dynamic>> getWalletWithRewards() async {
    final response = await _api.get('teacher/wallet/rewards');
    return response as Map<String, dynamic>;
  }
}

