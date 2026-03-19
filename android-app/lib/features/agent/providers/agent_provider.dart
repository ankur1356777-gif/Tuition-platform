import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api_service.dart';

final agentDashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final apiService = ApiService();
  final response = await apiService.get('agent/dashboard');
  return response;
});

final agentReferralsProvider = FutureProvider<List<dynamic>>((ref) async {
  final apiService = ApiService();
  final response = await apiService.get('agent/referrals');
  return response['data'] ?? [];
});
