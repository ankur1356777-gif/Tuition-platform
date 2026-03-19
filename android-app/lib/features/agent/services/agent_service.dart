import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api_service.dart';

final agentServiceProvider = Provider((ref) => AgentService());

class AgentService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> getDashboardStats() async {
    final response = await _api.get('agent/dashboard');
    return response as Map<String, dynamic>;
  }

  // Fetch referrals (Teacher/Student)
  Future<List<dynamic>> getReferrals() async {
    final response = await _api.get('agent/referrals');
    return response as List<dynamic>;
  }

  Future<List<dynamic>> getWalletHistory() async {
    final response = await _api.get('agent/wallet');
    return response as List<dynamic>;
  }

  // Request payout
  Future<void> requestPayout(double amount) async {
    await _api.post('agent/payouts/request', {'amount': amount});
  }
}
