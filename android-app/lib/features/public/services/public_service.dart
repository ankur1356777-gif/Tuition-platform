import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api_service.dart';

final publicServiceProvider = Provider((ref) => PublicService());

final landingDataProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(publicServiceProvider).getLandingData();
});

class PublicService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> getLandingData() async {
    await _api.init(); // Initialize API service
    final response = await _api.get('public/landing');
    return response as Map<String, dynamic>;
  }

  Future<void> submitPublicRequest(Map<String, dynamic> data) async {
    await _api.post('public/request-tuition', data);
  }
}
