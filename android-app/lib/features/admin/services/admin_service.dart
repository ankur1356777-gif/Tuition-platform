import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api_service.dart';

final adminServiceProvider = Provider((ref) => AdminService());

class AdminService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> getDashboardStats() async {
    final response = await _api.get('admin/dashboard');
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getTeachers({int page = 1}) async {
    final response = await _api.get('admin/teachers?page=$page');
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getStudents({int page = 1}) async {
    final response = await _api.get('admin/students?page=$page');
    return response as Map<String, dynamic>;
  }

  Future<List<dynamic>> getCommissionSettings() async {
    final response = await _api.get('admin/commission-settings');
    return response as List<dynamic>;
  }

  Future<void> updateCommissionSettings(List<Map<String, dynamic>> settings) async {
    await _api.post('admin/commission-settings', {'settings': settings});
  }

  Future<void> updateUserStatus(String userId, String status) async {
    await _api.post('admin/users/$userId/status', {'status': status});
  }
}
