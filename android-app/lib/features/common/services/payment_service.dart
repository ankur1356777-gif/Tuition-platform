import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api_service.dart';

final paymentServiceProvider = Provider((ref) => PaymentService());

class PaymentService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> initiatePayment({
    required double amount,
    required String purpose,
    Map<String, dynamic>? metadata,
  }) async {
    final response = await _api.post('payments/initiate', {
      'amount': amount,
      'purpose': purpose,
      'metadata': metadata,
    });
    return response as Map<String, dynamic>;
  }

  Future<void> verifyPayment({
    required String paymentId,
    required String orderId,
    required String signature,
  }) async {
    await _api.post('payments/verify', {
      'payment_id': paymentId,
      'order_id': orderId,
      'signature': signature,
    });
  }
}
