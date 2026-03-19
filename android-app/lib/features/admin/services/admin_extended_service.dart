import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api_service.dart';

final adminLeadsProvider = FutureProvider.autoDispose((ref) async {
  final response = await ApiService().get('admin/leads');
  return response['data'] as List<dynamic>;
});

final adminPendingLeadsProvider = FutureProvider.autoDispose((ref) async {
  final response = await ApiService().get('admin/leads/pending');
  return response as List<dynamic>;
});

final adminServiceExtendedProvider = Provider((ref) => AdminExtendedService());

class AdminExtendedService {
  final ApiService _api = ApiService();

  Future<void> approveLead(int leadId) async {
    await _api.post('admin/leads/$leadId/approve-contact', {});
  }

  Future<void> rejectLead(int leadId) async {
    await _api.post('admin/leads/$leadId/reject-contact', {});
  }
}

final adminAgentsProvider = FutureProvider.autoDispose((ref) async {
  final response = await ApiService().get('admin/agents');
  return response['data'] as List<dynamic>; // Paginated response
});
