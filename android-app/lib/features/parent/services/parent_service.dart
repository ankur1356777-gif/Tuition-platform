import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api_service.dart';

final parentServiceProvider = Provider((ref) => ParentService());

class ParentService {
  final ApiService _api = ApiService();

  /// Get parent dashboard summary
  Future<Map<String, dynamic>> getDashboard() async {
    final response = await _api.get('parent/dashboard');
    return response as Map<String, dynamic>;
  }

  /// Get list of linked children
  Future<List<dynamic>> getChildren() async {
    final response = await _api.get('parent/children');
    return response as List<dynamic>;
  }

  /// Get detailed progress for a specific child
  Future<Map<String, dynamic>> getChildProgress(int studentId) async {
    final response = await _api.get('parent/children/$studentId/progress');
    return response as Map<String, dynamic>;
  }

  /// Get child's attendance records
  Future<Map<String, dynamic>> getChildAttendance(int studentId) async {
    final response = await _api.get('parent/children/$studentId/attendance');
    return response as Map<String, dynamic>;
  }

  /// Get child's test results
  Future<Map<String, dynamic>> getChildTestResults(int studentId) async {
    final response = await _api.get('parent/children/$studentId/tests');
    return response as Map<String, dynamic>;
  }

  /// Get child's homework status
  Future<Map<String, dynamic>> getChildHomework(int studentId) async {
    final response = await _api.get('parent/children/$studentId/homework');
    return response as Map<String, dynamic>;
  }

  /// Link a child to parent using child's phone number
  Future<Map<String, dynamic>> linkChild(String childPhone) async {
    final response = await _api.post('parent/children/link', {
      'child_phone': childPhone,
    });
    return response as Map<String, dynamic>;
  }

  /// Unlink a child from parent
  Future<Map<String, dynamic>> unlinkChild(int studentId) async {
    final response = await _api.delete('parent/children/$studentId/unlink');
    return response as Map<String, dynamic>;
  }
}

