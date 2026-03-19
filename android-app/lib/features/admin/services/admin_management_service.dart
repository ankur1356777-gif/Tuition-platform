import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api_service.dart';

final adminPayoutsProvider = FutureProvider.autoDispose((ref) async {
  final response = await ApiService().get('admin/payouts');
  return response as List<dynamic>;
});

final adminDocumentsProvider = FutureProvider.autoDispose((ref) async {
  final response = await ApiService().get('admin/documents/pending');
  return response as List<dynamic>;
});

class AdminManagementService {
  final ApiService _api = ApiService();

  Future<void> approvePayout(int id) async {
    await _api.post('admin/payouts/$id/approve', {});
  }

  Future<void> verifyDocument(int id, String status, {String? reason}) async {
    await _api.post('admin/documents/$id/verify', {
      'status': status,
      'reason': reason,
    });
  }
}

final adminManagementProvider = Provider((ref) => AdminManagementService());
